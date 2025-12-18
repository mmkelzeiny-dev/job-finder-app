// lib/features/cv/presentation/widgets/cv_upload_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cv_provider.dart';

class CvUploadButton extends ConsumerWidget {
  // ← THIS IS CORRECT
  final String token;

  const CvUploadButton({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cvState = ref.watch(cvProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cvState.isUploading)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LinearProgressIndicator(value: cvState.progress),
          ),

        ElevatedButton.icon(
          onPressed: cvState.isUploading
              ? null
              : () => ref.read(cvProvider.notifier).pickAndUpload(token: token),
          icon: const Icon(Icons.cloud_upload),
          label: Text(cvState.isUploading ? "Uploading..." : "Upload Your CV"),
        ),

        if (cvState.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              cvState.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),

        if (cvState.data != null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "CV parsed successfully!",
              style: TextStyle(color: Colors.green),
            ),
          ),
      ],
    );
  }
}
