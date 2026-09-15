import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../clients/admin_auth_client.dart';
import '../models/clients/auth/accept_invitation_request.dart';
import '../models/clients/auth/admin_user.dart';
import '../models/clients/auth/login_request.dart';
import '../models/clients/auth/login_response_data.dart';
import '../services/local_storage.dart';
import '../utils/error_handler.dart';


final adminAuthProvider =
    NotifierProvider<AdminAuthNotifier, AdminUser?>(AdminAuthNotifier.new);

class AdminAuthNotifier extends Notifier<AdminUser?> {
  @override
  AdminUser? build() {
    return null;
  }

  Future<void> login(
    LoginRequest request, {
    void Function(LoginResponseData data)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(adminAuthClientProvider);
      final response = await client.login(request);

      if (response.data != null) {
        final loginData = response.data!;
        if (loginData.accessToken != null) {
          localStorage.setItem('accessToken', loginData.accessToken!);
        }
        if (loginData.refreshToken != null) {
          localStorage.setItem('refreshToken', loginData.refreshToken!);
        }
        state = loginData.admin;
        onSuccess?.call(loginData);
      } else {
        final errorMsg =
            response.message ?? response.detail ?? 'Login failed';
        onError?.call(errorMsg);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  Future<void> acceptInvite(
    AcceptInvitationRequest request, {
    void Function(AdminUser user)? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(adminAuthClientProvider);
      final response = await client.acceptInvitation(request);

      if (response.data != null) {
        final adminUser = response.data!;
        state = adminUser;
        onSuccess?.call(adminUser);
      } else {
        final errorMsg =
            response.message ?? response.detail ?? 'Accept invitation failed';
        onError?.call(errorMsg);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ??
            data['detail'] as String? ??
            e.message ??
            'An unexpected error occurred';
      }
    }
    return e.toString();
  }
}
