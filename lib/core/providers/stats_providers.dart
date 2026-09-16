import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../clients/admin_user_client.dart';
import '../models/clients/dashboard/admin_guarantor_stats.dart';
import '../models/clients/dashboard/admin_interview_stats.dart';
import '../models/clients/dashboard/admin_kyc_stats.dart';
import '../models/clients/dashboard/admin_user_stats.dart';

final adminUserStatsProvider = FutureProvider<AdminUserStats?>((ref) async {
  final client = ref.watch(adminUserClientProvider);
  final response = await client.getUserStats();
  return response.data;
});

final adminKycStatsProvider = FutureProvider<AdminKycStats?>((ref) async {
  final client = ref.watch(adminUserClientProvider);
  final response = await client.getKycStats();
  return response.data;
});

final adminGuarantorStatsProvider = FutureProvider<AdminGuarantorStats?>((ref) async {
  final client = ref.watch(adminUserClientProvider);
  final response = await client.getGuarantorStats();
  return response.data;
});

final adminInterviewStatsProvider = FutureProvider<AdminInterviewStats?>((ref) async {
  final client = ref.watch(adminUserClientProvider);
  final response = await client.getInterviewStats();
  return response.data;
});
