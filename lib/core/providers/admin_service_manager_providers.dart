import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../clients/admin_service_manager_client.dart';
import '../models/clients/base_response.dart';
import '../models/clients/services/admin_category_item.dart';
import '../models/clients/services/admin_service_item.dart';

class ListCategoriesParams {
  final int? page;
  final int? perPage;
  final String? search;
  final bool? isActive;
  final String? sortBy;
  final bool? sortDesc;

  const ListCategoriesParams({
    this.page,
    this.perPage,
    this.search,
    this.isActive,
    this.sortBy,
    this.sortDesc,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListCategoriesParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          perPage == other.perPage &&
          search == other.search &&
          isActive == other.isActive &&
          sortBy == other.sortBy &&
          sortDesc == other.sortDesc;

  @override
  int get hashCode => Object.hash(
        page,
        perPage,
        search,
        isActive,
        sortBy,
        sortDesc,
      );
}

final adminCategoriesProvider =
    FutureProvider.family<PaginatedData<AdminCategoryItem>?, ListCategoriesParams>(
  (ref, params) async {
    final client = ref.watch(adminServiceManagerClientProvider);
    final response = await client.getCategories(
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
      search: params.search,
      isActive: params.isActive,
      sortBy: params.sortBy,
      sortDesc: params.sortDesc,
    );
    return response.data;
  },
);

final adminCategoryDetailProvider =
    FutureProvider.family<AdminCategoryItem?, String>(
  (ref, categoryId) async {
    final client = ref.watch(adminServiceManagerClientProvider);
    final response = await client.getCategory(categoryId);
    return response.data;
  },
);

class ListServicesParams {
  final int? page;
  final int? perPage;
  final String? search;
  final String? categoryId;
  final bool? isActive;
  final String? sortBy;
  final bool? sortDesc;

  const ListServicesParams({
    this.page,
    this.perPage,
    this.search,
    this.categoryId,
    this.isActive,
    this.sortBy,
    this.sortDesc,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListServicesParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          perPage == other.perPage &&
          search == other.search &&
          categoryId == other.categoryId &&
          isActive == other.isActive &&
          sortBy == other.sortBy &&
          sortDesc == other.sortDesc;

  @override
  int get hashCode => Object.hash(
        page,
        perPage,
        search,
        categoryId,
        isActive,
        sortBy,
        sortDesc,
      );
}

final adminServicesProvider =
    FutureProvider.family<PaginatedData<AdminServiceItem>?, ListServicesParams>(
  (ref, params) async {
    final client = ref.watch(adminServiceManagerClientProvider);
    final response = await client.getServices(
      page: params.page ?? 1,
      perPage: params.perPage ?? 20,
      search: params.search,
      categoryId: params.categoryId,
      isActive: params.isActive,
      sortBy: params.sortBy,
      sortDesc: params.sortDesc,
    );
    return response.data;
  },
);

final adminServiceDetailProvider =
    FutureProvider.family<AdminServiceItem?, String>(
  (ref, serviceId) async {
    final client = ref.watch(adminServiceManagerClientProvider);
    final response = await client.getService(serviceId);
    return response.data;
  },
);

final adminServiceManagerNotifierProvider =
    AsyncNotifierProvider<AdminServiceManagerNotifier, void>(
        AdminServiceManagerNotifier.new);

class AdminServiceManagerNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createCategory(
    Map<String, dynamic> body, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(adminServiceManagerClientProvider);
      final response = await client.createCategory(body);
      final successMsg = response.message ?? response.detail ?? 'Category created successfully';
      state = const AsyncValue.data(null);
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> body, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(adminServiceManagerClientProvider);
      final response = await client.updateCategory(categoryId, body);
      final successMsg = response.message ?? response.detail ?? 'Category updated successfully';
      state = const AsyncValue.data(null);
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  Future<void> createService(
    Map<String, dynamic> body, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(adminServiceManagerClientProvider);
      final response = await client.createService(body);
      final successMsg = response.message ?? response.detail ?? 'Service created successfully';
      state = const AsyncValue.data(null);
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      final errorMsg = _extractErrorMessage(e);
      onError?.call(errorMsg);
    }
  }

  Future<void> updateService(
    String serviceId,
    Map<String, dynamic> body, {
    void Function(String message)? onSuccess,
    void Function(String message)? onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(adminServiceManagerClientProvider);
      final response = await client.updateService(serviceId, body);
      final successMsg = response.message ?? response.detail ?? 'Service updated successfully';
      state = const AsyncValue.data(null);
      onSuccess?.call(successMsg);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
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
            'An error occurred';
      }
    }
    return e.toString();
  }
}

