import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:taska_admin/core/providers/network_providers.dart';

import '../models/clients/auth/accept_invitation_request.dart';
import '../models/clients/auth/admin_user.dart';
import '../models/clients/auth/login_request.dart';
import '../models/clients/auth/login_response_data.dart';
import '../models/clients/auth/refresh_token_request.dart';
import '../models/clients/base_response.dart';

part 'admin_auth_client.g.dart';

final adminAuthClientProvider = Provider<AdminAuthClient>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminAuthClient(dio);
});


@RestApi(baseUrl: '/api/v1')
abstract class AdminAuthClient {
  factory AdminAuthClient(Dio dio, {String baseUrl}) = _AdminAuthClient;

  @POST('/admin/auth/login')
  Future<BaseApiResponse<LoginResponseData>> login(
    @Body() LoginRequest request,
  );

  @POST('/admin/auth/accept-invitation')
  Future<BaseApiResponse<AdminUser>> acceptInvitation(
    @Body() AcceptInvitationRequest request,
  );

  @POST('/admin/auth/refresh')
  Future<BaseApiResponse<LoginResponseData>> refreshToken(
    @Body() RefreshTokenRequest request,
  );

  @GET('/admin/auth/me')
  Future<BaseApiResponse<AdminUser>> getMe();
}