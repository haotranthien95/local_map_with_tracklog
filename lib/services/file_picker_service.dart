import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// Service interface for file picking operations
abstract class FilePickerService {
  /// Pick a track file with specified allowed extensions
  /// Returns the selected file or null if cancelled
  Future<File?> pickTrackFile(List<String> allowedExtensions);
}

/// Implementation of FilePickerService using file_picker package
class FilePickerServiceImpl implements FilePickerService {
  @override
  Future<File?> pickTrackFile(List<String> allowedExtensions) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return null; // No path available
      }

      return File(filePath);
    } catch (e) {
      // Error during file picking
      rethrow;
    }
  }
}
