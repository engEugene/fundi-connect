import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/review.dart';
import '../../../../core/models/worker.dart';
import '../data/discover_repository.dart';

final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  return DiscoverRepository();
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(discoverRepositoryProvider).watchCategories();
});

class DiscoverFilterState {
  const DiscoverFilterState({
    this.searchQuery = '',
    this.category = 'All',
    this.filter = 'All',
  });

  final String searchQuery;
  final String category;
  final String filter;

  DiscoverFilterState copyWith({
    String? searchQuery,
    String? category,
    String? filter,
  }) {
    return DiscoverFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      filter: filter ?? this.filter,
    );
  }
}

/// Deliberately not autoDispose: Home sets the category before navigating to
/// Discover, so the state has to outlive the moment neither screen listens.
final discoverFilterProvider =
    NotifierProvider<DiscoverFilterNotifier, DiscoverFilterState>(
  DiscoverFilterNotifier.new,
);

class DiscoverFilterNotifier extends Notifier<DiscoverFilterState> {
  @override
  DiscoverFilterState build() => const DiscoverFilterState();

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);

  void setCategory(String category) => state = state.copyWith(category: category);

  void setFilter(String filter) => state = state.copyWith(filter: filter);
}

final discoverWorkersProvider = FutureProvider.autoDispose<List<Worker>>((ref) {
  final filters = ref.watch(discoverFilterProvider);

  return ref.watch(discoverRepositoryProvider).getWorkers(
        category: filters.category,
        searchQuery: filters.searchQuery,
        filter: filters.filter,
      );
});

class WorkerDetailData {
  const WorkerDetailData({required this.worker, required this.reviews});

  final Worker? worker;
  final List<Review> reviews;
}

final workerDetailProvider =
    FutureProvider.autoDispose.family<WorkerDetailData, String>((ref, id) async {
  final repository = ref.watch(discoverRepositoryProvider);
  final worker = await repository.getWorkerById(id);
  if (worker == null) {
    return const WorkerDetailData(worker: null, reviews: []);
  }

  return WorkerDetailData(
    worker: worker,
    reviews: await repository.getWorkerReviews(id),
  );
});
