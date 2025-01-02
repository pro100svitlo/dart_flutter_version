import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../util/log_info.dart';

/// Updates the patch version in the `pubspec.yaml` file and returns the new version.
///
/// This method increments the patch version of the `version` field in the `pubspec.yaml`
/// file located in the given directory. The updated file will reflect the new version.
///
/// Example:
/// - Current version: `1.2.3`
/// - Updated version: `1.2.4`
///
/// Throws:
/// - [FileSystemException] if the `pubspec.yaml` file does not exist.
/// - [FormatException] if the `version` field is missing or invalid.
///
/// Parameters:
/// - [rootDirPath]: The path to the directory containing the `pubspec.yaml` file.
///
/// Returns:
/// The updated [Version] object after the patch increment.
Future<Version> updatePatchVersionInPubspec({
  required String rootDirPath,
}) async {
  const fileName = 'pubspec.yaml';
  const keyVersion = 'version';

  logInfo('Starting to increment the patch version in $fileName...');

  final yamlFile = File('$rootDirPath/$fileName');

  if (!yamlFile.existsSync()) {
    throw FileSystemException('$fileName does not exist', yamlFile.path);
  }

  final content = await yamlFile.readAsString();

  logInfo('Loaded content of $fileName.');

  final yaml = loadYaml(content) as YamlMap;

  if (!yaml.containsKey(keyVersion)) {
    throw FormatException('The "$keyVersion" field is missing in $fileName.');
  }

  final currentVersionStr = yaml[keyVersion] as String;

  final Version currentVersion;
  try {
    currentVersion = Version.parse(currentVersionStr);
  } catch (e) {
    throw FormatException(
      'Invalid version format in "$keyVersion": $currentVersionStr',
      currentVersionStr,
    );
  }

  logInfo('Current version: $currentVersion');

  final incrementedVersion = currentVersion.nextPatch;

  logInfo('New version after patch increment: $incrementedVersion');

  final yamlEditor = YamlEditor(content)
    ..update(
      [keyVersion],
      incrementedVersion.toString(),
    );

  await yamlFile.writeAsString(yamlEditor.toString());

  logInfo('Successfully updated $fileName to version $incrementedVersion.');

  return incrementedVersion;
}
