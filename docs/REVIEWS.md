# Reviews & Ratings — Implementation Notes

Track 5 of the build plan. Covers the `reviews` collection, the rating
aggregation on `workers`, and the security rules that protect both.

---

## 1. Data model

### `reviews/{reviewId}`

| Field            | Type      | Notes |
|------------------|-----------|-------|
| `bookingId`      | string    | The completed booking being rated. One review per booking. |
| `clientId`       | string    | Author. Must equal `request.auth.uid` on create. |
| `workerId`       | string    | Subject. Copied from the booking, never sent by the client UI. |
| `rating`         | number    | 1–5 whole stars. |
| `comment`        | string    | Optional, max 500 characters. |
| `clientName`     | string    | Denormalised from `users/{clientId}.displayName`. |
| `clientPhotoUrl` | string    | Denormalised from `users/{clientId}.photoUrl`. |
| `createdAt`      | timestamp | Server timestamp. Enforced in rules. |

`clientName` and `clientPhotoUrl` are duplicated onto the review on purpose. A
worker profile shows every review it has received; without the copy, rendering
20 reviews would mean 20 extra reads of `users/{clientId}`. This is the standard
NoSQL trade-off — storage is cheap, reads are not.

### Relationships

```
users (client) ──1:N──► reviews ──N:1──► workers
                  │
                  └──1:1──► bookings   (bookings.reviewId ⇄ reviews.bookingId)
```

`bookings.isRated` and `bookings.reviewId` are the back-pointer, so the Bookings
list can decide whether to show the **Rate** button without querying `reviews`
once per row.

---

## 2. Write path

Writing a review touches three documents that must agree with each other:

1. `reviews/{reviewId}` — created
2. `workers/{workerId}` — `ratingAvg` and `reviewCount` recomputed
3. `bookings/{bookingId}` — `isRated: true`, `reviewId` set

All three go through a single **Firestore transaction** in
`ReviewRepository.submitReview()`. If the network drops halfway, none of them
land. Without the transaction a worker could end up with a `reviewCount` that
counts a review document that was never written, and the average would be wrong
forever.

The team ruled out Cloud Functions for the MVP (ARCHITECTURE.md §12), so the
aggregation is client-side — which is exactly why the security rules below have
to constrain what the client is allowed to write.

### Aggregation

`RatingMath.applyNewRating()` folds the new score into the running average:

```
newCount = oldCount + 1
newAvg   = round2(((oldAvg × oldCount) + rating) / newCount)
```

This is O(1) — it never reads the existing review documents, so a worker with
500 reviews costs the same as a worker with 2. The result is rounded to two
decimals so repeated transactions cannot accumulate floating-point drift.

The function lives in `features/reviews/domain/` with no Firebase, Flutter or
Riverpod imports, which is what makes it unit-testable without an emulator.

### Validation happens three times

| Where | Catches |
|-------|---------|
| `ReviewFormState.canSubmit` | Empty rating, over-long comment — before any network call. |
| Inside the transaction | Booking not yours, job not completed, already rated — checked against the *server's* copy, so a replayed call fails. |
| `firestore.rules` | Everything above again, for a caller that skips the app entirely. |

---

## 3. Security rules

### `reviews`

- **read** — any signed-in user. Ratings are public by design; a client needs to
  read them before booking a stranger.
- **create** — only when *all* of:
  - the author is the signed-in user (`clientId == request.auth.uid`)
  - the payload has exactly the expected keys, no extras
  - `rating` is a number between 1 and 5
  - `comment` is a string of at most 500 characters
  - `createdAt == request.time`, which forces `FieldValue.serverTimestamp()`
    — a device with an altered clock cannot backdate a review to change where
    it sorts
  - a `get()` on the referenced booking confirms it belongs to the author, its
    status is `completed`, and it has not been rated yet
- **update / delete** — never. A tradesman cannot erase a bad rating and a
  client cannot revise one after the fact.

### `workers`

The reviewer, not the worker, has to write `ratingAvg` and `reviewCount`, so
these two fields cannot be owner-only. The rule allows any signed-in user to
update a worker document **only** when the change is a valid rating aggregate:

```javascript
incoming.diff(current).affectedKeys()
        .hasOnly(['ratingAvg', 'reviewCount', 'updatedAt'])
&& incoming.reviewCount == current.get('reviewCount', 0) + 1
&& incoming.ratingAvg >= 0 && incoming.ratingAvg <= 5
```

`affectedKeys().hasOnly(...)` is what stops a reviewer from editing someone
else's hourly rate, bio or verified badge in the same write. Requiring the count
to increase by exactly one stops a competitor from inflating or resetting a
rival's review count. Everything else on the worker profile stays owner-only.

### `bookings`

Tightened so neither party can reassign a job to a different account:

```javascript
request.resource.data.clientId == resource.data.clientId &&
request.resource.data.workerId == resource.data.workerId
```

---

## 4. Indexes

| Collection | Fields | Used by |
|------------|--------|---------|
| `reviews`  | `workerId` ASC, `createdAt` DESC | Worker detail + tradesman profile |
| `reviews`  | `clientId` ASC, `createdAt` DESC | "Reviews you have written" on client profile |

Both are in `firestore.indexes.json`. Deploy with:

```bash
firebase deploy --only firestore:indexes,firestore:rules
```

---

## 5. State management

No `setState` anywhere in this feature.

| Provider | Type | Purpose |
|----------|------|---------|
| `reviewRepositoryProvider` | `Provider` | Dependency injection; overridden in tests. |
| `workerReviewsProvider(workerId)` | `StreamProvider.family` | Reviews a tradesman received. |
| `myWrittenReviewsProvider` | `StreamProvider` | Reviews the signed-in client wrote. |
| `bookingReviewProvider(bookingId)` | `StreamProvider.family` | Switches the booking detail between "Rate Worker" and the submitted review. |
| `reviewFormProvider` | `NotifierProvider.autoDispose` | Stars, comment, submitting flag, error message. |

Because the reads are **streams**, the UI updates the instant the transaction
commits — the new review appears on the worker's profile and the "Rate" button
disappears from the bookings list with no manual refresh. This is worth showing
on camera for the demo video next to the Firebase console.

---

## 6. Tests

| File | Type | Covers |
|------|------|--------|
| `test/features/reviews/rating_math_test.dart` | Unit ×13 | Averaging, rounding, drift over 50 reviews, corrupt input, star/comment validation. |
| `test/features/reviews/review_model_test.dart` | Unit ×12 | `fromJson`/`toJson`, missing fields, pending server timestamp, round-trip, relative dates. |
| `test/features/reviews/leave_review_screen_test.dart` | Widget ×5 + unit ×5 | Star picker, disabled submit, refusing an incomplete or already-rated booking. |

```bash
flutter test
flutter test --coverage
```

---

## 7. Demo script (for the video)

1. Client opens **Bookings → Completed**, taps **Rate**.
2. Picks 5 stars, types a comment, submits.
3. Firebase console: the new `reviews` document appears, and the worker's
   `ratingAvg` / `reviewCount` update in the same instant.
4. Open the tradesman's public profile — the review is already there.
5. Go back to Bookings: the **Rate** button is gone, replaced by the review.
6. Try to submit twice (two devices, or replay) — the transaction rejects it.

---

## 8. Known limitations

- **No edit or delete.** Deliberate, but it means a typo is permanent. A future
  version could allow an edit within 24 hours, which would need the aggregate to
  be recomputed by subtracting the old rating.
- **Client-side aggregation.** A Cloud Function trigger on `reviews/{id}` would
  be more robust than trusting the client with `ratingAvg`, even with the rules
  above. Out of scope for the MVP.
- **`bookings.reviewId` is written but never read** by the app — `isRated` is
  what the UI checks. The field is kept because the ERD specifies it.
- **The worker document must already exist.** The transaction uses
  `set(..., merge: true)`, which would be a *create* if the worker document were
  missing, and the rules only allow the owner to create it. In practice the
  document is created at sign-up, so this only affects manually seeded data.
