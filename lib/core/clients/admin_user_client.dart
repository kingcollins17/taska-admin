import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:taska_admin/core/providers/network_providers.dart';

import '../models/clients/base_response.dart';
import '../models/clients/dashboard/admin_dashboard_overview.dart';

part 'admin_user_client.g.dart';

final adminUserClientProvider = Provider<AdminUserClient>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminUserClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class AdminUserClient {
  factory AdminUserClient(Dio dio, {String baseUrl}) = _AdminUserClient;

  @GET('/admin/dashboard/overview')
  Future<BaseApiResponse<AdminDashboardOverview>> getDashboardOverview();
}