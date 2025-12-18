// lib/features/cv/presentation/provider/cv_provider.dart
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cvProvider = StateNotifierProvider<CvNotifier, CvState>(
  (ref) => CvNotifier(),
);

class CvState {
  final bool isUploading;
  final double progress; // 0.0 → 1.0
  final Map<String, dynamic>? data;
  final String? error;

  const CvState({
    this.isUploading = false,
    this.progress = 0.0,
    this.data,
    this.error,
  });

  CvState copyWith({
    bool? isUploading,
    double? progress,
    Map<String, dynamic>? data,
    String? error,
  }) {
    return CvState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

class CvNotifier extends StateNotifier<CvState> {
  CvNotifier() : super(const CvState());

  Future<void> pickAndUpload({required String token}) async {
    state = state.copyWith(isUploading: true, progress: 0.0, error: null);

    FilePicker.platform
        .pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'docx', 'doc'],
        )
        .then((result) async {
          if (result == null ||
              result.files.isEmpty ||
              result.files.first.path == null) {
            state = state.copyWith(
              isUploading: false,
              error: "No file selected",
            );
            return;
          }

          final file = result.files.first;

          final formData = FormData.fromMap({
            "file": await MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            ),
          });

          try {
            final response = await Dio().post(
              "https://your-backend.com/cv/upload", // ← CHANGE THIS
              data: formData,
              options: Options(headers: {"Authorization": "Bearer $token"}),
              onSendProgress: (sent, total) {
                if (total > 0) {
                  state = state.copyWith(progress: sent / total);
                }
              },
            );

            state = state.copyWith(
              isUploading: false,
              progress: 1.0,
              data: response.data is Map
                  ? response.data
                  : Map<String, dynamic>.from(response.data),
            );
          } on DioException catch (e) {
            state = state.copyWith(
              isUploading: false,
              error:
                  e.response?.data?.toString() ?? e.message ?? "Upload failed",
            );
          } catch (e) {
            state = state.copyWith(isUploading: false, error: e.toString());
          }
        });
  }

  void reset() => state = const CvState();
}
