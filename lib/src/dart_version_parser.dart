import 'package:dart_flutter_version/src/logger.dart';
import 'package:pub_semver/pub_semver.dart';

/// A utility class for parsing a Dart SDK [Version] from a given string.
class DartVersionParser {
  /// Creates a const [DartVersionParser].
  const DartVersionParser();

  /// A regex capturing only `MAJOR.MINOR.PATCH`.
  ///
  /// Examples that match: `2.10.5`, `3.0.0`, `10.20.30`
  static final _versionRegExp = RegExp(r'^(\d+\.\d+\.\d+)');

  /// Parses a Dart SDK version string.
  ///
  /// - Returns a [Version] if the string **starts with** a valid
  ///   `MAJOR.MINOR.PATCH` pattern.
  /// - Returns `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final parser = DartVersionParser();
  /// final version = parser.parseDartVersion('2.10.5-0.dev (build abc123)');
  /// print(version); // 2.10.5
  /// ```
  Version? parseDartVersion(String versionString) {
    final match = _versionRegExp.firstMatch(versionString);
    if (match == null) {
      logger.error('Could not parse Dart version from: $versionString');
      return null;
    }

    return Version.parse(match.group(1)!);
  }
}
