import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/home_service.dart';
import '../../../../core/services/api_service.dart';
import 'dashboard_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddPostState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  AddPostState({this.isLoading = false, this.error, this.isSuccess = false});

  AddPostState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return AddPostState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AddPostNotifier extends StateNotifier<AddPostState> {
  final HomeService _homeService;
  final ApiService _apiService;

  AddPostNotifier(this._homeService, this._apiService) : super(AddPostState());

  Future<void> createPost({
    required String title,
    required String description,
    required List<String> tags,
    File? image,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      final Map<String, dynamic> postData = {
        'title': title,
        'tags': tags,
        'description': description,
      };

      if (image != null) {
        postData['image'] = await _apiService.createMultipartFile(image.path);
      }

      await _homeService.createPost(postData);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = AddPostState();
  }
}

final addPostProvider =
    StateNotifierProvider.autoDispose<AddPostNotifier, AddPostState>((ref) {
      return AddPostNotifier(
        ref.watch(homeServiceProvider),
        ref.watch(apiServiceProvider),
      );
    });
