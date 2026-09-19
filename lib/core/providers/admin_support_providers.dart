import 'dart:async';

import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../clients/admin_support_client.dart';
import '../models/clients/base_response.dart';
import '../models/clients/support/admin_add_support_internal_note_body.dart';
import '../models/clients/support/admin_assign_support_case_body.dart';
import '../models/clients/support/admin_resolve_support_case_body.dart';
import '../models/clients/support/admin_send_support_message_body.dart';
import '../models/clients/support/admin_support_case_detail.dart';
import '../models/clients/support/admin_support_case_item.dart';
import '../models/clients/support/admin_support_message_item.dart';
import '../models/clients/support/admin_support_timeline_item.dart';
import '../models/clients/support/admin_update_support_case_body.dart';
import '../utils/error_handler.dart';

class GetAdminSupportCasesParams {
  final int? page;
  final int? perPage;
  final List<String>? status;
  final String? priority;
  final String? type;
  final String? assignedAgentId;
  final String? customerId;
  final String? providerId;
  final String? taskId;
  final String? search;

  const GetAdminSupportCasesParams({
    this.page,
    this.perPage,
    this.status,
    this.priority,
    this.type,
    this.assignedAgentId,
    this.customerId,
    this.providerId,
    this.taskId,
    this.search,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetAdminSupportCasesParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          perPage == other.perPage &&
          priority == other.priority &&
          type == other.type &&
          assignedAgentId == other.assignedAgentId &&
          customerId == other.customerId &&
          providerId == other.providerId &&
          taskId == other.taskId &&
          search == other.search;

  @override
  int get hashCode => Object.hashAll([
        page,
        perPage,
        priority,
        type,
        assignedAgentId,
        customerId,
        providerId,
        taskId,
        search,
      ]);
}

final adminSupportCasesProvider =
    FutureProvider.family<PaginatedData<AdminSupportCaseItem>?, GetAdminSupportCasesParams>(
  (ref, params) async {
    final client = ref.watch(adminSupportClientProvider);
    final response = await client.listCases(
      page: params.page,
      perPage: params.perPage,
      status: params.status,
      priority: params.priority,
      type: params.type,
      assignedAgentId: params.assignedAgentId,
      customerId: params.customerId,
      providerId: params.providerId,
      taskId: params.taskId,
      search: params.search,
    );
    return response.data;
  },
);

final adminMyAssignedSupportCasesProvider =
    FutureProvider.family<PaginatedData<AdminSupportCaseItem>?, GetAdminSupportCasesParams>(
  (ref, params) async {
    final client = ref.watch(adminSupportClientProvider);
    final response = await client.listAssignedCases(
      page: params.page,
      perPage: params.perPage,
      status: params.status,
      priority: params.priority,
      type: params.type,
      search: params.search,
    );
    return response.data;
  },
);

final adminSupportCaseDetailProvider =
    FutureProvider.family<AdminSupportCaseDetail?, String>(
  (ref, caseId) async {
    final client = ref.watch(adminSupportClientProvider);
    final response = await client.getCase(caseId);
    return response.data;
  },
);

class GetAdminSupportMessagesParams {
  final String caseId;
  final int? page;
  final int? perPage;

  const GetAdminSupportMessagesParams({
    required this.caseId,
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetAdminSupportMessagesParams &&
          runtimeType == other.runtimeType &&
          caseId == other.caseId &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(caseId, page, perPage);
}

final adminSupportMessagesProvider =
    FutureProvider.family<PaginatedData<AdminSupportMessageItem>?, GetAdminSupportMessagesParams>(
  (ref, params) async {
    final client = ref.watch(adminSupportClientProvider);
    final response = await client.getMessages(
      params.caseId,
      page: params.page,
      perPage: params.perPage,
    );
    return response.data;
  },
);

class GetAdminSupportTimelineParams {
  final String caseId;
  final int? page;
  final int? perPage;

  const GetAdminSupportTimelineParams({
    required this.caseId,
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetAdminSupportTimelineParams &&
          runtimeType == other.runtimeType &&
          caseId == other.caseId &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(caseId, page, perPage);
}

final adminSupportTimelineProvider =
    FutureProvider.family<PaginatedData<AdminSupportTimelineItem>?, GetAdminSupportTimelineParams>(
  (ref, params) async {
    final client = ref.watch(adminSupportClientProvider);
    final response = await client.getTimeline(
      params.caseId,
      page: params.page,
      perPage: params.perPage,
    );
    return response.data;
  },
);

final adminSupportManagementProvider =
    AsyncNotifierProvider<AdminSupportManagement, void>(AdminSupportManagement.new);

class AdminSupportManagement extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateCase(
    String caseId,
    AdminUpdateSupportCaseBody body, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminSupportClientProvider);
      final response = await client.updateCase(caseId, body);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        ref.invalidate(adminSupportCaseDetailProvider(caseId));
        ref.invalidate(adminSupportTimelineProvider(GetAdminSupportTimelineParams(caseId: caseId)));
        ref.invalidate(adminMyAssignedSupportCasesProvider);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to update support case';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      state = AsyncError(errorMsg, stackTrace);
      onError?.call(errorMsg);
    }
  }

  Future<void> sendMessage(
    String caseId,
    AdminSendSupportMessageBody body, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminSupportClientProvider);
      final response = await client.sendMessage(caseId, body);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        ref.invalidate(adminSupportCaseDetailProvider(caseId));
        ref.invalidate(adminSupportMessagesProvider(GetAdminSupportMessagesParams(caseId: caseId, perPage: 100)));
        ref.invalidate(adminSupportTimelineProvider(GetAdminSupportTimelineParams(caseId: caseId, perPage: 50)));
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to send message';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      state = AsyncError(errorMsg, stackTrace);
      onError?.call(errorMsg);
    }
  }

  Future<void> claimCase(
    String caseId, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminSupportClientProvider);
      final response = await client.claimCase(caseId);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        ref.invalidate(adminSupportCaseDetailProvider(caseId));
        ref.invalidate(adminSupportTimelineProvider(GetAdminSupportTimelineParams(caseId: caseId)));
        ref.invalidate(adminMyAssignedSupportCasesProvider);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to claim support case';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      state = AsyncError(errorMsg, stackTrace);
      onError?.call(errorMsg);
    }
  }

  Future<void> assignCase(
    String caseId,
    AdminAssignSupportCaseBody body, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminSupportClientProvider);
      final response = await client.assignCase(caseId, body);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        ref.invalidate(adminSupportCaseDetailProvider(caseId));
        ref.invalidate(adminSupportTimelineProvider(GetAdminSupportTimelineParams(caseId: caseId)));
        ref.invalidate(adminMyAssignedSupportCasesProvider);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to assign support case';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      state = AsyncError(errorMsg, stackTrace);
      onError?.call(errorMsg);
    }
  }

  Future<void> uploadAttachment(
    String caseId,
    MultipartFile file, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminSupportClientProvider);
      final response = await client.uploadAttachment(caseId, file);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        ref.invalidate(adminSupportMessagesProvider(GetAdminSupportMessagesParams(caseId: caseId)));
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to upload attachment';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      state = AsyncError(errorMsg, stackTrace);
      onError?.call(errorMsg);
    }
  }

  Future<void> addInternalNote(
    String caseId,
    AdminAddSupportInternalNoteBody body, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminSupportClientProvider);
      final response = await client.addInternalNote(caseId, body);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        ref.invalidate(adminSupportCaseDetailProvider(caseId));
        ref.invalidate(adminSupportMessagesProvider(GetAdminSupportMessagesParams(caseId: caseId, perPage: 100)));
        ref.invalidate(adminSupportTimelineProvider(GetAdminSupportTimelineParams(caseId: caseId, perPage: 50)));
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to add internal note';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      state = AsyncError(errorMsg, stackTrace);
      onError?.call(errorMsg);
    }
  }

  Future<void> resolveCase(
    String caseId,
    AdminResolveSupportCaseBody body, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminSupportClientProvider);
      final response = await client.resolveCase(caseId, body);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        ref.invalidate(adminSupportCaseDetailProvider(caseId));
        ref.invalidate(adminSupportTimelineProvider(GetAdminSupportTimelineParams(caseId: caseId)));
        ref.invalidate(adminMyAssignedSupportCasesProvider);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to resolve support case';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      state = AsyncError(errorMsg, stackTrace);
      onError?.call(errorMsg);
    }
  }

  Future<void> escalateCase(
    String caseId, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminSupportClientProvider);
      final response = await client.escalateCase(caseId);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        ref.invalidate(adminSupportCaseDetailProvider(caseId));
        ref.invalidate(adminSupportTimelineProvider(GetAdminSupportTimelineParams(caseId: caseId)));
        ref.invalidate(adminMyAssignedSupportCasesProvider);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to escalate support case';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
      }
    } catch (e, stackTrace) {
      ErrorHandler.handle(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      state = AsyncError(errorMsg, stackTrace);
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

class CurrentSupportTicketNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setTicketId(String? id) {
    state = id;
  }
}

final currentSupportTicketProvider =
    NotifierProvider<CurrentSupportTicketNotifier, String?>(CurrentSupportTicketNotifier.new);


