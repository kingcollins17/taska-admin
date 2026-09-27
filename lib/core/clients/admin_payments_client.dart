import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:taska_admin/core/providers/network_providers.dart';

import '../models/clients/base_response.dart';
import '../models/clients/payments/admin_payout_item.dart';
import '../models/clients/payments/admin_transaction_item.dart';

part 'admin_payments_client.g.dart';

final adminPaymentsClientProvider = Provider<AdminPaymentsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminPaymentsClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class AdminPaymentsClient {
  factory AdminPaymentsClient(Dio dio, {String baseUrl}) = _AdminPaymentsClient;

  /// List transactions for admin inspection with inlined retrieval queries and pagination.
  @GET('/admin/payments/transactions')
  Future<BaseApiResponse<PaginatedData<AdminTransactionItem>>> listTransactions({
    @Query('id') String? id,
    @Query('user_id') String? userId,
    @Query('task_id') String? taskId,
    @Query('transaction_type') String? transactionType,
    @Query('status') String? status,
    @Query('reference') String? reference,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  /// List payouts for admin inspection with inlined retrieval queries and pagination.
  @GET('/admin/payments/payouts')
  Future<BaseApiResponse<PaginatedData<AdminPayoutItem>>> listPayouts({
    @Query('id') String? id,
    @Query('provider_id') String? providerId,
    @Query('customer_id') String? customerId,
    @Query('task_id') String? taskId,
    @Query('status') String? status,
    @Query('reference') String? reference,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  /// Trigger provider payout transfer for a payout in CUSTOMER_PAID status.
  @POST('/admin/payments/payouts/{payout_id}/transfer')
  Future<BaseApiResponse<dynamic>> transferPayout(
    @Path('payout_id') String payoutId,
  );
}
