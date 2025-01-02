import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import '../util/log_info.dart';

/// Appends version updates and differences to the `CHANGELOG.md` file.
///
/// This method updates the `CHANGELOG.md` file with the provided new version,
/// the current date, and a list of differences between Dart and Flutter versions.
///
/// The new content is prepended to the existing changelog, ensuring that the most
/// recent updates appear at the top.
///
/// Throws:
/// - [FileSystemException] if the `CHANGELOG.md` file does not exist.
///
/// Parameters:
/// - [rootDirPath]: The root directory containing the `CHANGELOG.md` file.
/// - [newVersion]: The new package [Version] to record in the changelog.
/// - [diffVersions]: A map of Dart [Version] to Flutter [Version] representing the changes.
///
/// Example Changelog Update:
/// ```
/// ## 1.2.4
///
/// * Updated map file with new versions:
///   - Dart 2.14.0 -> Flutter 2.5.0
///   - Dart 2.15.0 -> Flutter 2.8.0
/// ```
Future<void> appendVersionChangesToChangelog({
  required String rootDirPath,
  required Version newVersion,
  required Map<Version, Version> diffVersions,
}) async {
  logInfo('Updating the changelog with the new version and changes...');

  final changelogFile = File('$rootDirPath/CHANGELOG.md');

  if (!changelogFile.existsSync()) {
    throw FileSystemException(
      'The changelog file does not exist.',
      changelogFile.path,
    );
  }

  logInfo('Found changelog file at ${changelogFile.path}.');

  final content = await changelogFile.readAsString();
  logInfo('Read existing content from changelog file.');

  // Build the new changelog entry.
  final builder = StringBuffer('## $newVersion')
    ..writeln()
    ..writeln()
    ..writeln('* Updated map file with new versions:');

  for (final entry in diffVersions.entries) {
    builder.writeln('  - Dart ${entry.key} -> Flutter ${entry.value}');
  }

  // Append old content after the new entry.
  builder
    ..writeln()
    ..write(content);

  await changelogFile.writeAsString(builder.toString());

  logInfo('Successfully updated the changelog with version $newVersion.');
}
