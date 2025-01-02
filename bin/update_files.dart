import 'dart:io';

import 'local/update_patch_versionIn_pubspec.dart';
import 'local/append_version_changes_to_changelog.dart';
import 'local/update_readme_badge_with_latest_flutter_version.dart';
import 'util/git.dart';
import 'util/log_info.dart';
import 'local/parse_dart_to_flutter_version_mappings.dart';
import 'util/run_process.dart';

/// Main function to synchronize Dart-to-Flutter versions, update the package version,
/// and prepare a new release.
///
/// This function performs the following steps:
/// 1. Retrieves the root directory of the repository.
/// 2. Verifies the existence of the Dart-to-Flutter mapping file.
/// 3. Synchronizes remote and local Dart-to-Flutter versions.
/// 4. If new versions are detected:
///   - Updates the mapping file.
///   - Increments the package version.
///   - Updates the changelog.
///   - Updates the README badge with the latest supported Flutter version.
///   - Commits the changes.
///   - Pushes the changes and creates a new Git tag.
///
/// Throws:
/// - [Exception] if the root directory or mapping file does not exist.
/// - [FileSystemException] for file-related issues.
Future<void> main() async {
  logInfo('🔄 Start updating versions [if needed]...');

  // Retrieve the root directory path.
  final rootDirPath = await runProcess(
      command: 'git', arguments: ['rev-parse', '--show-toplevel']);
  logInfo('Root directory path: $rootDirPath');

  // Verify the existence of the root directory.
  if (!Directory(rootDirPath).existsSync()) {
    throw Exception('Root directory does not exist: $rootDirPath');
  }

  // Define the path to the Dart-to-Flutter mapping file.
  const mapFileName = 'dart_to_flutter_map.dart';
  final mapFile = File('$rootDirPath/lib/src/$mapFileName');

  // Verify the existence of the mapping file.
  if (!mapFile.existsSync()) {
    throw FileSystemException(
      'The Dart-to-Flutter mapping file does not exist.',
      mapFile.path,
    );
  }

  // Synchronize versions and get the differences.
  final diffVersions = await syncDartToFlutterVersions(mapFile: mapFile);

  if (diffVersions.isEmpty) {
    // If there are no new versions, stop the process.
    logInfo('🏁 Process completed.');
    return;
  }

  await commitMapFileChanges(
    diffVersions: diffVersions,
    mapFileName: mapFileName,
  );

  final newPackageVersion = await updatePatchVersionInPubspec(
    rootDirPath: rootDirPath,
  );

  await appendVersionChangesToChangelog(
    rootDirPath: rootDirPath,
    newVersion: newPackageVersion,
    diffVersions: diffVersions,
  );

  await updateReadMeWithLatestSupportedVersionBadge(
    rootDirPath: rootDirPath,
    dartToFlutterMapFile: mapFile,
  );

  await commitRelease(newVersion: newPackageVersion);

  await createTag(newVersion: newPackageVersion);

  logInfo('✅ Finished updating versions.');
  logInfo('🏁 Process completed.');
}
