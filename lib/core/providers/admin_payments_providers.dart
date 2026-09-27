import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../clients/admin_payments_client.dart';
import '../models/clients/base_response.dart';
import '../models/clients/payments/admin_payout_item.dart';
import '../models/clients/payments/admin_transaction_item.dart';
import '../utils/error_handler.dart';

class ListTransactionsParams {
  final String? id;
  final String? userId;
  final String? taskId;
  final String? transactionType;
  final String? status;
  final String? reference;
  final String? search;
  final int? page;
  final int? perPage;

  const ListTransactionsParams({
    this.id,
    this.userId,
    this.taskId,
    this.transactionType,
    this.status,
    this.reference,
    this.search,
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListTransactionsParams &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          taskId == other.taskId &&
          transactionType == other.transactionType &&
          status == other.status &&
          reference == other.reference &&
          search == other.search &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        taskId,
        transactionType,
        status,
        reference,
        search,
        page,
        perPage,
      );
}

class ListPayoutsParams {
  final String? id;
  final String? providerId;
  final String? customerId;
  final String? taskId;
  final String? status;
  final String? reference;
  final String? search;
  final int? page;
  final int? perPage;

  const ListPayoutsParams({
    this.id,
    this.providerId,
    this.customerId,
    this.taskId,
    this.status,
    this.reference,
    this.search,
    this.page,
    this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListPayoutsParams &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          providerId == other.providerId &&
          customerId == other.customerId &&
          taskId == other.taskId &&
          status == other.status &&
          reference == other.reference &&
          search == other.search &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(
        id,
        providerId,
        customerId,
        taskId,
        status,
        reference,
        search,
        page,
        perPage,
      );
}

final listTransactionsProvider = FutureProvider.family<
    PaginatedData<AdminTransactionItem>?, ListTransactionsParams>(
  (ref, params) async {
    final client = ref.watch(adminPaymentsClientProvider);

    String? id = params.id;
    String? userId = params.userId;
    String? taskId = params.taskId;
    String? reference = params.reference;

    if (params.search != null && params.search!.trim().isNotEmpty) {
      final rawQuery = params.search!.trim();
      final lower = rawQuery.toLowerCase();
      if (lower.startsWith('id:')) {
        id = rawQuery.substring(3).trim();
      } else if (lower.startsWith('task:') || lower.startsWith('task_id:')) {
        final colonIdx = rawQuery.indexOf(':');
        taskId = rawQuery.substring(colonIdx + 1).trim();
      } else if (lower.startsWith('ref:') || lower.startsWith('reference:')) {
        final colonIdx = rawQuery.indexOf(':');
        reference = rawQuery.substring(colonIdx + 1).trim();
      } else if (lower.startsWith('user:') || lower.startsWith('user_id:')) {
        final colonIdx = rawQuery.indexOf(':');
        userId = rawQuery.substring(colonIdx + 1).trim();
      } else {
        if (rawQuery.startsWith('trx_')) {
          id = rawQuery;
        } else if (rawQuery.startsWith('usr_')) {
          userId = rawQuery;
        } else if (rawQuery.startsWith('tsk_')) {
          taskId = rawQuery;
        } else {
          reference = rawQuery;
        }
      }
    }

    final response = await client.listTransactions(
      id: (id != null && id.isNotEmpty) ? id : null,
      userId: (userId != null && userId.isNotEmpty) ? userId : null,
      taskId: (taskId != null && taskId.isNotEmpty) ? taskId : null,
      transactionType: params.transactionType,
      status: params.status,
      reference: (reference != null && reference.isNotEmpty) ? reference : null,
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
    );
    return response.data;
  },
);

final listPayoutsProvider = FutureProvider.family<
    PaginatedData<AdminPayoutItem>?, ListPayoutsParams>(
  (ref, params) async {
    final client = ref.watch(adminPaymentsClientProvider);

    String? id = params.id;
    String? providerId = params.providerId;
    String? customerId = params.customerId;
    String? taskId = params.taskId;
    String? reference = params.reference;

    if (params.search != null && params.search!.trim().isNotEmpty) {
      final rawQuery = params.search!.trim();
      final lower = rawQuery.toLowerCase();
      if (lower.startsWith('id:')) {
        id = rawQuery.substring(3).trim();
      } else if (lower.startsWith('task:') || lower.startsWith('task_id:')) {
        final colonIdx = rawQuery.indexOf(':');
        taskId = rawQuery.substring(colonIdx + 1).trim();
      } else if (lower.startsWith('ref:') || lower.startsWith('reference:')) {
        final colonIdx = rawQuery.indexOf(':');
        reference = rawQuery.substring(colonIdx + 1).trim();
      } else if (lower.startsWith('provider:') || lower.startsWith('provider_id:')) {
        final colonIdx = rawQuery.indexOf(':');
        providerId = rawQuery.substring(colonIdx + 1).trim();
      } else if (lower.startsWith('customer:') || lower.startsWith('customer_id:')) {
        final colonIdx = rawQuery.indexOf(':');
        customerId = rawQuery.substring(colonIdx + 1).trim();
      } else {
        if (rawQuery.startsWith('po_') || rawQuery.startsWith('payout_')) {
          id = rawQuery;
        } else if (rawQuery.startsWith('tsk_')) {
          taskId = rawQuery;
        } else {
          reference = rawQuery;
        }
      }
    }

    final response = await client.listPayouts(
      id: (id != null && id.isNotEmpty) ? id : null,
      providerId: (providerId != null && providerId.isNotEmpty) ? providerId : null,
      customerId: (customerId != null && customerId.isNotEmpty) ? customerId : null,
      taskId: (taskId != null && taskId.isNotEmpty) ? taskId : null,
      status: params.status,
      reference: (reference != null && reference.isNotEmpty) ? reference : null,
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
    );
    return response.data;
  },
);

final adminPaymentsNotifierProvider =
    AsyncNotifierProvider<AdminPaymentsNotifier, void>(
        AdminPaymentsNotifier.new);

class AdminPaymentsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Trigger provider payout transfer for a payout in CUSTOMER_PAID status.
  Future<void> transferPayout(
    String payoutId, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(adminPaymentsClientProvider);
      final response = await client.transferPayout(payoutId);

      final successMsg = response.message ??
          response.detail ??
          'Payout transfer triggered successfully';
      state = const AsyncValue.data(null);
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
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
