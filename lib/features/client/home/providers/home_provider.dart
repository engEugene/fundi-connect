import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/worker.dart';
import '../data/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

final nearbyWorkersProvider = StreamProvider.autoDispose<List<Worker>>((ref) {
  return ref.watch(homeRepositoryProvider).watchNearbyWorkers();
});
