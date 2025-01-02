import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import '../util/log_info.dart';
import 'get_local_dart_to_flutter_versions.dart';
import 'save_dart_to_flutter_versions_map.dart';
import '../util/filter_dart_to_flutter_version.dart';
import '../util/compute_dart_to_flutter_version_diffs.dart';
import '../remote/fetch_flutter_to_dart_versions_from_remote.dart';

/// The minimum Flutter version to be included in the mapping.
final _minFlutterVersion = Version(3, 0, 0);

/// Synchronizes Dart-to-Flutter version mappings by updating the local map file.
///
/// This method fetches Dart-to-Flutter version mappings from a remote source,
/// filters them based on the minimum Flutter version, calculates the difference
/// between local and remote mappings, and updates the local file if new versions
/// are found.
///
/// Throws:
/// - [Exception] if remote or filtered versions are empty.
/// - [FileSystemException] if the local mapping file does not exist.
///
/// Parameters:
/// - [mapFile]: The file containing the Dart-to-Flutter version mappings.
///
/// Returns:
/// A [Map] of Dart [Version] to Flutter [Version] representing the differences
/// between the local and remote mappings. If no updates are required, an empty map is returned.
Future<Map<Version, Version>> syncDartToFlutterVersions({
  required File mapFile,
}) async {
  logInfo('Starting synchronization of Dart-to-Flutter version mappings...');

  // Fetch remote Flutter-to-Dart versions.
  final remoteFlutterToDartVersions =
      await fetchFlutterToDartVersionsFromRemote();
  if (remoteFlutterToDartVersions.isEmpty) {
    throw Exception('Remote versions should not be empty.');
  }

  // Invert the map to get Dart->Flutter
  final remoteDartToFlutterVersions = _invertFlutterDartMap(
    remoteFlutterToDartVersions,
  );

  // Filter remote versions based on the minimum Flutter version.
  final filteredRemoteVersions = filterDartToFlutterVersion(
    remoteDartToFlutterVersions,
    _minFlutterVersion,
  );

  if (filteredRemoteVersions.isEmpty) {
    throw Exception(
      'No remote versions meet the minimum Flutter version ($_minFlutterVersion).',
    );
  }

  // Verify the existence of the local version mapping file.
  if (!mapFile.existsSync()) {
    throw FileSystemException(
      'The Dart-to-Flutter mapping file does not exist.',
      mapFile.path,
    );
  }

  // Load local Dart-to-Flutter versions.
  final localVersions = await parseDartToFlutterVersionMappings(
    file: mapFile,
  );

  // Calculate the difference between remote and local versions.
  final diffVersions = computeDartToFlutterVersionDiffs(
    remoteMap: filteredRemoteVersions,
    localMap: localVersions,
  );

  if (diffVersions.isEmpty) {
    logInfo('No new Dart-to-Flutter versions found. Synchronization complete.');
    return const {};
  }

  // Update the local file with the filtered remote versions.
  await saveDartToFlutterVersionsMap(
    outputFile: mapFile,
    dartToFlutterMap: filteredRemoteVersions,
  );

  logInfo(
    diffVersions.isEmpty
        ? 'No new Dart-to-Flutter versions found.'
        : 'Successfully synchronized ${diffVersions.length} Dart-to-Flutter version mappings.',
  );

  return diffVersions;
}

/// Inverts a [flutterToDartVersions] map  from Flutter->Dart
/// into a Dart->Flutter map.
///
/// If the same Dart version appears more than once, the first encountered
/// Flutter version is retained (i.e., duplicates are ignored).
Map<Version, Version> _invertFlutterDartMap(
  Map<Version, Version> flutterToDartVersions,
) {
  logInfo('Inverting Flutter->Dart map to Dart->Flutter...');
  final dartToFlutterVersions = <Version, Version>{};

  for (final entry in flutterToDartVersions.entries) {
    final flutterVer = entry.key;
    final dartVer = entry.value;

    // If we already have a Flutter version for this Dart version, skip
    // (the first Flutter version we find is considered the "preferred" mapping).
    if (!dartToFlutterVersions.containsKey(dartVer)) {
      dartToFlutterVersions[dartVer] = flutterVer;
    }
  }

  logInfo('Inverted Flutter->Dart map to Dart->Flutter successfully.');

  return dartToFlutterVersions;
}
