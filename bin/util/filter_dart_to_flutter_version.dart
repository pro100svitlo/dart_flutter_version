import 'package:pub_semver/pub_semver.dart';

import 'log_info.dart';

/// Filters a Dart-to-Flutter version map by a minimum Flutter version.
///
/// This function returns a new map containing only the entries where the Flutter
/// version is greater than or equal to the specified [minFlutterVersion].
///
/// Keys in the map are Dart versions, and values are Flutter versions.
///
/// Example:
/// ```dart
/// final original = {
///   Version.parse('3.0.0'): Version.parse('3.10.0'),
///   Version.parse('2.19.0'): Version.parse('3.7.0'),
///   Version.parse('2.18.0'): Version.parse('3.3.0'),
/// };
///
/// final filtered = filterByMinFlutterVersion(
///   original,
///   Version.parse('3.7.0'),
/// );
///
/// // Result:
/// // {
/// //   Version.parse('3.0.0'): Version.parse('3.10.0'),
/// //   Version.parse('2.19.0'): Version.parse('3.7.0'),
/// // }
/// ```
///
/// Parameters:
/// - [dartToFlutterMap]: A map of Dart [Version] to Flutter [Version].
/// - [minFlutterVersion]: The minimum Flutter [Version] to include in the result.
///
/// Returns:
/// A filtered [Map] containing only entries where the Flutter version
/// meets or exceeds [minFlutterVersion].
///
/// Example Edge Case:
/// If all versions are below [minFlutterVersion], the returned map will be empty.
Map<Version, Version> filterDartToFlutterVersion(
  Map<Version, Version> dartToFlutterMap,
  Version minFlutterVersion,
) {
  logInfo(
    'Filtering Dart-to-Flutter versions with minimum Flutter version ($minFlutterVersion)...',
  );

  // Initialize an empty map to store the filtered results.
  final filteredMap = <Version, Version>{};

  // Iterate over the original map entries.
  for (final entry in dartToFlutterMap.entries) {
    final flutterVersion = entry.value;
    if (flutterVersion >= minFlutterVersion) {
      filteredMap[entry.key] = flutterVersion;
    }
  }

  logInfo(
    'Filtered ${dartToFlutterMap.length} entries to ${filteredMap.length} entries matching the criteria.',
  );

  return filteredMap;
}
