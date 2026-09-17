import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:taska_admin/core/providers/network_providers.dart';

import '../clients/admin_auth_client.dart';
import '../clients/admin_user_client.dart';
import '../models/clients/auth/accept_invitation_request.dart';
import '../models/clients/auth/admin_user.dart';
import '../models/clients/auth/login_request.dart';
import '../models/clients/auth/login_response_data.dart';
import '../models/clients/dashboard/admin_dashboard_overview.dart';
import '../services/local_storage.dart';
import '../utils/error_handler.dart';

final adminAuthProvider = AsyncNotifierProvider<AdminAuthNotifier, AdminUser?>(AdminAuthNotifier.new);

final adminDashboardOverviewProvider = FutureProvider<AdminDashboardOverview?>((ref) async {
  ref.watch(isAuthenticatedProvider);
  final client = ref.watch(adminUserClientProvider);
  final response = await client.getDashboardOverview();
  return response.data;
});

final adminUserProvider = FutureProvider<AdminUser>((ref) async {
  try {
    ref.watch(isAuthenticatedProvider);
    final client = ref.read(adminAuthClientProvider);
    final response = await client.getMe();
    if (response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.detail ?? 'Something went wrong');
    }
  } on Exception catch (e) {
    ErrorHandler.handle(e);
    rethrow;
  }
}, retry: retryFunc(3));

class AdminAuthNotifier extends AsyncNotifier<AdminUser?> {
  @override
  Future<AdminUser?> build() async {
    ref.watch(isAuthenticatedProvider);
    return _fetchUser();
  }

  Future<AdminUser?> _fetchUser() async {
    try {
      final token = localStorage.getItem('accessToken');
      if (token == null || token.isEmpty) return null;
      final client = ref.read(adminAuthClientProvider);
      final response = await client.getMe();
      return response.data;
    } catch (e) {
      return null;
    }
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
        state = AsyncData(loginData.admin);
        onSuccess?.call(loginData);
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Login failed';
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
        state = AsyncData(adminUser);
        onSuccess?.call(adminUser);
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Accept invitation failed';
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
        return data['message'] as String? ?? data['detail'] as String? ?? e.message ?? 'An unexpected error occurred';
      }
    }
    return e.toString();
  }
}
