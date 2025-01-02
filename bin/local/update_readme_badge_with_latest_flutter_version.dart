import 'dart:io';
import 'package:pub_semver/pub_semver.dart';
import '../util/log_info.dart';
import 'get_local_dart_to_flutter_versions.dart';

/// Key for identifying the badge in the README file.
const _badgeStartKey = '![Bintray]';

/// Updates the `README.md` badge with the latest supported Flutter version.
///
/// This function reads the Dart-to-Flutter version mappings from the provided file,
/// determines the latest supported Flutter version, and updates the badge in the
/// `README.md` file located at the provided root directory path.
///
/// Parameters:
/// - [rootDirPath]: The path to the root directory containing the `README.md` file.
/// - [dartToFlutterMapFile]: A file containing Dart-to-Flutter version mappings.
///
/// Throws:
/// - [FileSystemException] if the `README.md` file is not found or cannot be updated.
/// - [FormatException] if the badge line is not found in the `README.md` file.
Future<void> updateReadMeWithLatestSupportedVersionBadge({
  required String rootDirPath,
  required File dartToFlutterMapFile,
}) async {
  logInfo(
    'Updating README.md badge with the latest supported Flutter version...',
  );

  final latestVersion = await _getLatestSupportedVersion(
    file: dartToFlutterMapFile,
  );

  logInfo('Latest supported Flutter version: $latestVersion');

  final badge = _getNewBadge(version: latestVersion);

  await _replaceBadge(
    rootDirPath: rootDirPath,
    newBadge: badge,
  );

  logInfo(
    'README.md badge updated successfully with the latest supported Flutter version.',
  );
}

/// Retrieves the latest supported Flutter version from the Dart-to-Flutter version mappings.
///
/// Parameters:
/// - [file]: A file containing Dart-to-Flutter version mappings in a map structure.
///
/// Returns:
/// - The latest supported Flutter version.
///
/// Throws:
/// - [FormatException] if the file contents are invalid or cannot be parsed.
Future<Version> _getLatestSupportedVersion({required File file}) async {
  final versions = await parseDartToFlutterVersionMappings(file: file);

  // Find the latest version among all mapped Flutter versions.
  final latestFlutterVersion = versions.values.reduce((a, b) {
    return a.compareTo(b) > 0 ? a : b;
  });

  return latestFlutterVersion;
}

/// Generates a new badge string for the latest supported Flutter version.
///
/// Parameters:
/// - [version]: The latest supported Flutter version.
///
/// Returns:
/// - A string representing the badge for the README file.
String _getNewBadge({
  required Version version,
}) {
  final buffer = StringBuffer()
    ..write('[')
    ..write(_badgeStartKey)
    ..write('(')
    ..write('https://img.shields.io/static/v1?')
    ..write('label=Latest%20Supported%20Flutter%20Version')
    ..write('&message=$version')
    ..write('&color=green')
    ..write(')')
    ..write(']')
    ..write('(https://docs.flutter.dev/release/archive#stable-channel-macos)');

  return buffer.toString();
}

/// Replaces the badge in the `README.md` file with a new one.
///
/// Parameters:
/// - [rootDirPath]: The path to the root directory containing the `README.md` file.
/// - [newBadge]: The new badge string to replace the existing one.
///
/// Throws:
/// - [FileSystemException] if the `README.md` file is not found or cannot be updated.
/// - [FormatException] if the badge line is not found in the `README.md` file.
Future<void> _replaceBadge({
  required String rootDirPath,
  required String newBadge,
}) async {
  final file = File('$rootDirPath/README.md');

  // Ensure the file exists before proceeding.
  if (!await file.exists()) {
    throw FileSystemException('The file was not found: ${file.path}');
  }

  try {
    // Read all lines from the file.
    List<String> lines = await file.readAsLines();

    // Flag to indicate whether the badge was replaced.
    bool replaced = false;

    // Replace the line containing the badge.
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains(_badgeStartKey)) {
        lines[i] = newBadge;
        replaced = true;
        break; // Replace the first occurrence only.
      }
    }

    // Update the file if a replacement was made.
    if (replaced) {
      await file.writeAsString(lines.join('\n'));
    } else {
      throw FormatException('Badge line not found in README.md file.');
    }
  } catch (e) {
    throw FileSystemException('Error during README.md file update: $e');
  }
}
