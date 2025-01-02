import 'package:pub_semver/pub_semver.dart';

import 'log_info.dart';
import 'run_process.dart';

/// Creates a new Git tag for the specified [newVersion] in the format `dart_flutter_version-v<newVersion>`.
///
/// Parameters:
/// - [newVersion]: The [Version] to tag.
Future<void> createTag({
  required Version newVersion,
}) async {
  logInfo(
    'Creating and pushing a new Git tag for version $newVersion...',
  );

  final tag = 'dart_flutter_version-v$newVersion';

  await runProcess(
    command: 'git',
    arguments: ['tag', tag],
  );
  logInfo('Tag created: $tag');
}

/// Commits a new release with the specified [newVersion].
///
/// This function stages all changes and commits them with a message indicating
/// the new package version, changelog update, and README badge update.
///
/// Parameters:
/// - [newVersion]: The new package [Version] being committed.
Future<void> commitRelease({
  required Version newVersion,
}) async {
  logInfo('Committing the version increment and changelog update...');
  final commitMessage = StringBuffer(
    'chore: Release version $newVersion\n\n',
  )
    ..writeln()
    ..writeln()
    ..writeln(' - Increment version in pubspec.yaml file')
    ..writeln(' - Update CHANGELOG.md file')
    ..writeln(' - Update README.md badge with latest Flutter version');

  await _addAllFilesAndCommit(message: commitMessage.toString());
  logInfo('Committed version increment and CHANGELOG.md update.');
}

/// Commits changes to a version map file with the specified [mapFileName]
/// and new [diffVersions].
///
/// The commit message includes details of the Dart-to-Flutter version mappings
/// added to the map file.
///
/// Parameters:
/// - [mapFileName]: The name of the version map file being updated.
/// - [diffVersions]: A map of Dart [Version] to Flutter [Version] representing the changes.
Future<void> commitMapFileChanges({
  required String mapFileName,
  required Map<Version, Version> diffVersions,
}) async {
  logInfo('Committing changes in the mapping file...');
  final commitMessage = StringBuffer(
    'feat: Update $mapFileName file with new versions\n\n',
  );

  for (final entry in diffVersions.entries) {
    commitMessage.writeln('Dart ${entry.key} -> Flutter ${entry.value}');
  }

  await _addAllFilesAndCommit(message: commitMessage.toString());
  logInfo('Committed changes in $mapFileName.');
}

/// Stages all changes and commits them to the Git repository with the specified [message].
///
/// Parameters:
/// - [message]: The commit message to use.
Future<void> _addAllFilesAndCommit({
  required String message,
}) async {
  await runProcess(
    command: 'git',
    arguments: const ['add', '-A'],
  );
  await runProcess(
    command: 'git',
    arguments: ['commit', '-m', message],
  );
}
