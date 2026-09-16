import 'dart:async';

import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../clients/admin_user_client.dart';
import '../models/clients/base_response.dart';
import '../models/clients/users/admin_platform_user_item.dart';
import '../models/clients/users/admin_user_detail.dart';
import '../models/clients/users/admin_user_status_update_body.dart';
import '../models/clients/vetting/admin_approve_vetting_body.dart';
import '../models/clients/vetting/admin_guarantor_item.dart';
import '../models/clients/vetting/admin_interview_item.dart';
import '../models/clients/vetting/admin_kyc_document_item.dart';
import '../models/clients/vetting/admin_reject_vetting_body.dart';
import '../models/clients/vetting/admin_schedule_interview_body.dart';
import '../utils/error_handler.dart';

class GetUsersParams {
  final String? search;
  final int? page;

  const GetUsersParams({this.search, this.page});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetUsersParams &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          page == other.page;

  @override
  int get hashCode => Object.hash(search, page);
}

final adminUsersProvider =
    FutureProvider.family<PaginatedData<AdminPlatformUserItem>?, GetUsersParams>(
  (ref, params) async {
    final client = ref.watch(adminUserClientProvider);
    final response = await client.getUsers(
      email: (params.search != null && params.search!.isNotEmpty) ? params.search : null,
      page: params.page ?? 1,
    );
    return response.data;
  },
);

final adminUserDetailProvider =
    FutureProvider.family<AdminUserDetail?, String>(
  (ref, userId) async {
    final client = ref.watch(adminUserClientProvider);
    final response = await client.getUserDetail(userId);
    return response.data;
  },
);

class GetKycDocumentsParams {
  final String? userId;
  final String? documentId;
  final String? providerProfileId;
  final String? idType;
  final String? idNumber;
  final String? status;
  final int? attemptNumber;
  final String? search;
  final String? submittedFrom;
  final String? submittedTo;
  final String? reviewedFrom;
  final String? reviewedTo;
  final String? createdFrom;
  final String? createdTo;
  final int? page;
  final int? perPage;
  final String? sortBy;
  final String? order;

  const GetKycDocumentsParams({
    this.userId,
    this.documentId,
    this.providerProfileId,
    this.idType,
    this.idNumber,
    this.status,
    this.attemptNumber,
    this.search,
    this.submittedFrom,
    this.submittedTo,
    this.reviewedFrom,
    this.reviewedTo,
    this.createdFrom,
    this.createdTo,
    this.page,
    this.perPage,
    this.sortBy,
    this.order,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetKycDocumentsParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          documentId == other.documentId &&
          providerProfileId == other.providerProfileId &&
          idType == other.idType &&
          idNumber == other.idNumber &&
          status == other.status &&
          attemptNumber == other.attemptNumber &&
          search == other.search &&
          submittedFrom == other.submittedFrom &&
          submittedTo == other.submittedTo &&
          reviewedFrom == other.reviewedFrom &&
          reviewedTo == other.reviewedTo &&
          createdFrom == other.createdFrom &&
          createdTo == other.createdTo &&
          page == other.page &&
          perPage == other.perPage &&
          sortBy == other.sortBy &&
          order == other.order;

  @override
  int get hashCode => Object.hashAll([
        userId,
        documentId,
        providerProfileId,
        idType,
        idNumber,
        status,
        attemptNumber,
        search,
        submittedFrom,
        submittedTo,
        reviewedFrom,
        reviewedTo,
        createdFrom,
        createdTo,
        page,
        perPage,
        sortBy,
        order,
      ]);
}

final adminKycDocumentsProvider =
    FutureProvider.family<PaginatedData<AdminKycDocumentItem>?, GetKycDocumentsParams>(
  (ref, params) async {
    final client = ref.watch(adminUserClientProvider);
    final response = await client.getKycDocuments(
      userId: params.userId,
      documentId: params.documentId,
      providerProfileId: params.providerProfileId,
      idType: params.idType,
      idNumber: params.idNumber,
      status: params.status,
      attemptNumber: params.attemptNumber,
      search: params.search,
      submittedFrom: params.submittedFrom,
      submittedTo: params.submittedTo,
      reviewedFrom: params.reviewedFrom,
      reviewedTo: params.reviewedTo,
      createdFrom: params.createdFrom,
      createdTo: params.createdTo,
      page: params.page,
      perPage: params.perPage,
      sortBy: params.sortBy,
      order: params.order,
    );
    return response.data;
  },
);

class GetGuarantorsParams {
  final String? providerId;
  final String? guarantorId;
  final String? status;
  final String? guarantorName;
  final String? guarantorPhone;
  final String? relationship;
  final String? search;
  final String? createdFrom;
  final String? createdTo;
  final String? verifiedFrom;
  final String? verifiedTo;
  final int? page;
  final int? perPage;
  final String? sortBy;
  final String? order;

  const GetGuarantorsParams({
    this.providerId,
    this.guarantorId,
    this.status,
    this.guarantorName,
    this.guarantorPhone,
    this.relationship,
    this.search,
    this.createdFrom,
    this.createdTo,
    this.verifiedFrom,
    this.verifiedTo,
    this.page,
    this.perPage,
    this.sortBy,
    this.order,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetGuarantorsParams &&
          runtimeType == other.runtimeType &&
          providerId == other.providerId &&
          guarantorId == other.guarantorId &&
          status == other.status &&
          guarantorName == other.guarantorName &&
          guarantorPhone == other.guarantorPhone &&
          relationship == other.relationship &&
          search == other.search &&
          createdFrom == other.createdFrom &&
          createdTo == other.createdTo &&
          verifiedFrom == other.verifiedFrom &&
          verifiedTo == other.verifiedTo &&
          page == other.page &&
          perPage == other.perPage &&
          sortBy == other.sortBy &&
          order == other.order;

  @override
  int get hashCode => Object.hashAll([
        providerId,
        guarantorId,
        status,
        guarantorName,
        guarantorPhone,
        relationship,
        search,
        createdFrom,
        createdTo,
        verifiedFrom,
        verifiedTo,
        page,
        perPage,
        sortBy,
        order,
      ]);
}

final adminGuarantorsProvider =
    FutureProvider.family<PaginatedData<AdminGuarantorItem>?, GetGuarantorsParams>(
  (ref, params) async {
    final client = ref.watch(adminUserClientProvider);
    final response = await client.getGuarantors(
      providerId: params.providerId,
      guarantorId: params.guarantorId,
      status: params.status,
      guarantorName: params.guarantorName,
      guarantorPhone: params.guarantorPhone,
      relationship: params.relationship,
      search: params.search,
      createdFrom: params.createdFrom,
      createdTo: params.createdTo,
      verifiedFrom: params.verifiedFrom,
      verifiedTo: params.verifiedTo,
      page: params.page,
      perPage: params.perPage,
      sortBy: params.sortBy,
      order: params.order,
    );
    return response.data;
  },
);

class GetInterviewsParams {
  final String? userId;
  final String? adminId;
  final String? status;
  final String? meetingLink;
  final String? notes;
  final String? search;
  final String? scheduledFrom;
  final String? scheduledTo;
  final String? passedFrom;
  final String? passedTo;
  final String? createdFrom;
  final String? createdTo;
  final int? page;
  final int? perPage;
  final String? sortBy;
  final String? order;

  const GetInterviewsParams({
    this.userId,
    this.adminId,
    this.status,
    this.meetingLink,
    this.notes,
    this.search,
    this.scheduledFrom,
    this.scheduledTo,
    this.passedFrom,
    this.passedTo,
    this.createdFrom,
    this.createdTo,
    this.page,
    this.perPage,
    this.sortBy,
    this.order,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetInterviewsParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          adminId == other.adminId &&
          status == other.status &&
          meetingLink == other.meetingLink &&
          notes == other.notes &&
          search == other.search &&
          scheduledFrom == other.scheduledFrom &&
          scheduledTo == other.scheduledTo &&
          passedFrom == other.passedFrom &&
          passedTo == other.passedTo &&
          createdFrom == other.createdFrom &&
          createdTo == other.createdTo &&
          page == other.page &&
          perPage == other.perPage &&
          sortBy == other.sortBy &&
          order == other.order;

  @override
  int get hashCode => Object.hashAll([
        userId,
        adminId,
        status,
        meetingLink,
        notes,
        search,
        scheduledFrom,
        scheduledTo,
        passedFrom,
        passedTo,
        createdFrom,
        createdTo,
        page,
        perPage,
        sortBy,
        order,
      ]);
}

final adminInterviewsProvider =
    FutureProvider.family<PaginatedData<AdminInterviewItem>?, GetInterviewsParams>(
  (ref, params) async {
    final client = ref.watch(adminUserClientProvider);
    final response = await client.getInterviews(
      userId: params.userId,
      adminId: params.adminId,
      status: params.status,
      meetingLink: params.meetingLink,
      notes: params.notes,
      search: params.search,
      scheduledFrom: params.scheduledFrom,
      scheduledTo: params.scheduledTo,
      passedFrom: params.passedFrom,
      passedTo: params.passedTo,
      createdFrom: params.createdFrom,
      createdTo: params.createdTo,
      page: params.page,
      perPage: params.perPage,
      sortBy: params.sortBy,
      order: params.order,
    );
    return response.data;
  },
);

final adminUserManagementProvider =
    AsyncNotifierProvider<AdminUserManagement, void>(AdminUserManagement.new);

class AdminUserManagement extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<void> approveKyc(
    String userId, {
    String? notes,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminUserClientProvider);
      final response = await client.approveKyc(
        userId,
        AdminApproveVettingBody(notes: notes),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to approve KYC';
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

  Future<void> rejectKyc(
    String userId, {
    required String reason,
    String? notes,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminUserClientProvider);
      final response = await client.rejectKyc(
        userId,
        AdminRejectVettingBody(reason: reason, notes: notes),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to reject KYC';
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

  Future<void> approveGuarantor(
    String guarantorId, {
    String? notes,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminUserClientProvider);
      final response = await client.approveGuarantor(
        guarantorId,
        AdminApproveVettingBody(notes: notes),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to approve guarantor';
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

  Future<void> rejectGuarantor(
    String guarantorId, {
    required String reason,
    String? notes,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminUserClientProvider);
      final response = await client.rejectGuarantor(
        guarantorId,
        AdminRejectVettingBody(reason: reason, notes: notes),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to reject guarantor';
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

  Future<void> activateUser(
    String userId,
    AdminUserStatusUpdateBody body, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminUserClientProvider);
      final response = await client.activateUser(userId, body);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to activate user';
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

  Future<void> deactivateUser(
    String userId,
    AdminUserStatusUpdateBody body, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminUserClientProvider);
      final response = await client.deactivateUser(userId, body);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to deactivate user';
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

  Future<void> scheduleInterview(
    AdminScheduleInterviewBody body, {
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(adminUserClientProvider);
      final response = await client.scheduleInterview(body);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        state = const AsyncData(null);
        onSuccess?.call();
      } else {
        final errorMsg = response.message ?? response.detail ?? 'Failed to schedule interview';
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

