import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/worker.dart';
import '../../../auth/providers/auth_provider.dart';
import '../data/worker_profile_repository.dart';

final workerProfileRepositoryProvider = Provider<WorkerProfileRepository>((ref) {
  return WorkerProfileRepository();
});

final workerProfileProvider = FutureProvider.autoDispose<Worker?>((ref) async {
  final uid = ref.watch(authProvider).authenticatedUser?.uid;
  if (uid == null) return null;

  return ref.watch(workerProfileRepositoryProvider).getWorkerProfile(uid);
});
