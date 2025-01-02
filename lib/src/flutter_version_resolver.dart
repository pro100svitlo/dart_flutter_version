import 'package:collection/collection.dart';
import 'package:dart_flutter_version/src/logger.dart';
import 'package:pub_semver/pub_semver.dart';

/// A class that resolves the best matching Flutter version
/// for a given Dart version based on a known mapping.
class FlutterVersionResolver {
  /// Creates a const [FlutterVersionResolver].
  const FlutterVersionResolver();

  /// Returns the Flutter [Version] that best matches [currentDartVersion].
  ///
  /// - If there's a direct mapping for [currentDartVersion] in [dartToFlutterVersionMap],
  ///   that version is returned immediately.
  ///
  /// - Otherwise, this method finds the **largest** Dart version that is still
  ///   **less than** [currentDartVersion] and returns the corresponding Flutter
  ///   version. If no such version exists, it returns `null`.
  Version? resolve({
    required Version currentDartVersion,
    required Map<Version, Version> dartToFlutterVersionMap,
  }) {
    // 1. Check for a direct mapping first
    final directFlutterVersion = dartToFlutterVersionMap[currentDartVersion];
    if (directFlutterVersion != null) {
      logger.info(
        'Direct mapping found for Dart $currentDartVersion to Flutter $directFlutterVersion',
      );
      return directFlutterVersion;
    }

    // 2. Sort the known Dart versions in ascending order
    final sortedDartVersions = dartToFlutterVersionMap.keys.toList()..sort();

    // 3. Find the largest Dart version that is less than the currentDartVersion
    final fallbackDartVersion = sortedDartVersions.lastWhereOrNull(
      (version) => version < currentDartVersion,
    );

    // 4. If a lower version exists, return the corresponding Flutter version
    if (fallbackDartVersion != null) {
      logger.info(
        'No direct mapping found for Dart $currentDartVersion. '
        'Falling back to Dart $fallbackDartVersion',
      );
      return dartToFlutterVersionMap[fallbackDartVersion];
    }

    // 5. If no lower version exists, return null
    logger.error(
      'No direct or fallback mapping found for Dart $currentDartVersion',
    );
    return null;
  }
}
