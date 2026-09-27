import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:taska_admin/core/providers/network_providers.dart';

import '../models/clients/base_response.dart';
import '../models/clients/services/admin_category_item.dart';
import '../models/clients/services/admin_service_item.dart';
import '../models/clients/services/create_category_request.dart';
import '../models/clients/services/create_service_request.dart';
import '../models/clients/services/update_category_request.dart';
import '../models/clients/services/update_service_request.dart';

part 'admin_service_manager_client.g.dart';

final adminServiceManagerClientProvider = Provider<AdminServiceManagerClient>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminServiceManagerClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class AdminServiceManagerClient {
  factory AdminServiceManagerClient(Dio dio, {String baseUrl}) = _AdminServiceManagerClient;

  /// Retrieve a list of categories with pagination, filtering, searching and sorting.
  @GET('/categories')
  Future<BaseApiResponse<PaginatedData<AdminCategoryItem>>> getCategories({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('search') String? search,
    @Query('is_active') bool? isActive,
    @Query('sort_by') String? sortBy,
    @Query('sort_desc') bool? sortDesc,
  });

  /// Retrieve a single category by its ID.
  @GET('/categories/{category_id}')
  Future<BaseApiResponse<AdminCategoryItem>> getCategory(
    @Path('category_id') String categoryId,
  );

  /// Create a new category.
  @POST('/categories')
  Future<BaseApiResponse<AdminCategoryItem>> createCategory(
    @Body() CreateCategoryRequest body,
  );

  /// Update an existing category by its ID.
  @PUT('/categories/{category_id}')
  Future<BaseApiResponse<AdminCategoryItem>> updateCategory(
    @Path('category_id') String categoryId,
    @Body() UpdateCategoryRequest body,
  );

  /// Delete a service category by its ID.
  @DELETE('/categories/{category_id}')
  Future<BaseApiResponse<dynamic>> deleteCategory(
    @Path('category_id') String categoryId,
  );

  /// Retrieve a list of services with pagination, filtering, searching and sorting.
  @GET('/services')
  Future<BaseApiResponse<PaginatedData<AdminServiceItem>>> getServices({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('search') String? search,
    @Query('category_id') String? categoryId,
    @Query('is_active') bool? isActive,
    @Query('sort_by') String? sortBy,
    @Query('sort_desc') bool? sortDesc,
  });

  /// Retrieve a single service by its ID.
  @GET('/services/{service_id}')
  Future<BaseApiResponse<AdminServiceItem>> getService(
    @Path('service_id') String serviceId,
  );

  /// Create a new service.
  @POST('/services')
  Future<BaseApiResponse<AdminServiceItem>> createService(
    @Body() CreateServiceRequest body,
  );

  /// Update an existing service by its ID.
  @PUT('/services/{service_id}')
  Future<BaseApiResponse<AdminServiceItem>> updateService(
    @Path('service_id') String serviceId,
    @Body() UpdateServiceRequest body,
  );

  /// Delete a service by its ID.
  @DELETE('/services/{service_id}')
  Future<BaseApiResponse<dynamic>> deleteService(
    @Path('service_id') String serviceId,
  );
}
