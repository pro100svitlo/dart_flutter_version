import 'package:pub_semver/pub_semver.dart';

import 'log_info.dart';

/// Separator used when converting map entries to string.
const _entrySeparator = ' -> ';

/// Computes the differences between two Dart-to-Flutter version maps.
///
/// This function identifies all Dart-to-Flutter version mappings that exist in
/// [remoteMap] but do not exist in [localMap]. It returns these differences as a new map.
///
/// Steps:
/// 1. Converts [localMap] and [remoteMap] entries to sets of strings (e.g., `"3.0.0 -> 3.10.2"`).
/// 2. Computes the set difference: `(remoteSet - localSet)`.
/// 3. Parses the resulting strings back into `Version` objects and returns a new map.
///
/// Example:
/// ```dart
/// final localMap = {
///   Version.parse('3.0.0'): Version.parse('3.10.0'),
///   Version.parse('2.19.0'): Version.parse('3.7.0'),
/// };
/// final remoteMap = {
///   Version.parse('3.0.0'): Version.parse('3.10.0'),
///   Version.parse('2.19.0'): Version.parse('3.7.0'),
///   Version.parse('2.18.0'): Version.parse('3.3.0'),
/// };
///
/// final differences = computeDartToFlutterVersionDifferences(
///   localMap: localMap,
///   remoteMap: remoteMap,
/// );
///
/// // Result:
/// // {
/// //   Version.parse('2.18.0'): Version.parse('3.3.0'),
/// // }
/// ```
///
/// Parameters:
/// - [localMap]: A map of Dart [Version] to Flutter [Version] representing local data.
/// - [remoteMap]: A map of Dart [Version] to Flutter [Version] representing remote data.
///
/// Returns:
/// A [Map] of Dart [Version] to Flutter [Version] containing the differences.
///
/// Throws:
/// - [FormatException] if an invalid entry format is detected.
Map<Version, Version> computeDartToFlutterVersionDiffs({
  required Map<Version, Version> localMap,
  required Map<Version, Version> remoteMap,
}) {
  logInfo('Starting comparison of Dart-to-Flutter version maps...');

  // Convert map entries to strings for set operations.
  final localSet =
      localMap.entries.map((e) => '${e.key}$_entrySeparator${e.value}').toSet();
  final remoteSet = remoteMap.entries
      .map((e) => '${e.key}$_entrySeparator${e.value}')
      .toSet();

  logInfo(
    'Converted local map (${localSet.length} entries) and remote map (${remoteSet.length} entries) to sets.',
  );

  // Compute the set difference: remoteSet - localSet.
  final differenceLines = remoteSet.difference(localSet);

  logInfo('Identified ${differenceLines.length} differences between the maps.');

  // Parse the differences back into a map of Dart->Flutter versions.
  final differenceMap = <Version, Version>{};
  for (final line in differenceLines) {
    final parts = line.split(_entrySeparator);
    if (parts.length == 2) {
      final dartVersion = Version.parse(parts[0]);
      final flutterVersion = Version.parse(parts[1]);
      differenceMap[dartVersion] = flutterVersion;
    } else {
      throw FormatException('Invalid entry format detected.', line);
    }
  }

  logInfo(
    'Successfully found ${differenceMap.length} new Dart-to-Flutter versions.',
  );

  return differenceMap;
}
