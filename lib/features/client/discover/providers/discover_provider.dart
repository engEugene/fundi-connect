import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/review.dart';
import '../../../../core/models/worker.dart';
import '../../../../core/services/firestore_service.dart';
import '../data/discover_repository.dart';



final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  return const DiscoverRepository(FirestoreService());
});

class DiscoverFilters {
  const DiscoverFilters({
    this.searchQuery = '',
    this.category = 'All',
    this.filter = 'All',
    this.district = 'Kigali',
  });

  final String searchQuery;
  final String category;
  final String filter;
  final String? district;

  DiscoverFilters copyWith({
    String? searchQuery,
    String? category,
    String? filter,
  }) {
    return DiscoverFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      filter: filter ?? this.filter,
      district: district,
    );
  }
}

class DiscoverFilterNotifier extends StateNotifier<DiscoverFilters> {
  DiscoverFilterNotifier() : super(const DiscoverFilters());

  void setSearchQuery(String value) =>
      state = state.copyWith(searchQuery: value);

  void setCategory(String value) => state = state.copyWith(category: value);

  void setFilter(String value) => state = state.copyWith(filter: value);


  void setDistrict(String? value) {
    state = DiscoverFilters(
      searchQuery: state.searchQuery,
      category: state.category,
      filter: state.filter,
      district: value,
    );
  }
}

final discoverFilterProvider =
    StateNotifierProvider<DiscoverFilterNotifier, DiscoverFilters>(
  (ref) => DiscoverFilterNotifier(),
);



final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(discoverRepositoryProvider);
  return repo.watchCategories();
});


final _rawWorkersProvider = StreamProvider<List<Worker>>((ref) {
  final filters = ref.watch(discoverFilterProvider);
  final repo = ref.watch(discoverRepositoryProvider);
  return repo.watchWorkers(
    category: filters.category,
    district: filters.district,
  );
});


final discoverWorkersProvider = Provider<AsyncValue<List<Worker>>>((ref) {
  final filters = ref.watch(discoverFilterProvider);
  final rawAsync = ref.watch(_rawWorkersProvider);

  return rawAsync.whenData((workers) {
    var result = workers;

    final query = filters.searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where(
            (w) =>
                w.name.toLowerCase().contains(query) ||
                w.role.toLowerCase().contains(query),
          )
          .toList();
    }

    switch (filters.filter) {
      case 'Top Rated':
        result = [...result]..sort((a, b) => b.rating.compareTo(a.rating));
      case 'Price ↑':
        result = [...result]
          ..sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
      case 'Available':
        result = result.where((w) => w.isOpen).toList();
      default:
        break;
    }

    return result;
  });
});


class WorkerDetail {
  const WorkerDetail({this.worker, this.reviews = const []});

  final Worker? worker;
  final List<Review> reviews;
}


Stream<WorkerDetail> _combineWorkerDetail(
  Stream<Worker?> workerStream,
  Stream<List<Review>> reviewsStream,
) {
  late final StreamController<WorkerDetail> controller;

  Worker? latestWorker;
  List<Review> latestReviews = const [];
  var workerReady = false;
  var reviewsReady = false;

  StreamSubscription<Worker?>? workerSub;
  StreamSubscription<List<Review>>? reviewsSub;

  void emit() {
    if (workerReady && reviewsReady) {
      controller.add(WorkerDetail(worker: latestWorker, reviews: latestReviews));
    }
  }

  controller = StreamController<WorkerDetail>(
    onListen: () {
      workerSub = workerStream.listen(
        (worker) {
          latestWorker = worker;
          workerReady = true;
          emit();
        },
        onError: controller.addError,
      );
      reviewsSub = reviewsStream.listen(
        (reviews) {
          latestReviews = reviews;
          reviewsReady = true;
          emit();
        },
        onError: controller.addError,
      );
    },
    onCancel: () async {
      await workerSub?.cancel();
      await reviewsSub?.cancel();
    },
  );

  return controller.stream;
}

final workerDetailProvider =
    StreamProvider.family<WorkerDetail, String>((ref, workerId) {
  final repo = ref.watch(discoverRepositoryProvider);
  return _combineWorkerDetail(
    repo.watchWorker(workerId),
    repo.watchReviews(workerId),
  );
});