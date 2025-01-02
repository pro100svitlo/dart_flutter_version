import 'dart:io';
import 'package:pub_semver/pub_semver.dart';
import '../util/log_info.dart';

/// Parses a mapping of Dart versions to Flutter versions from a given file.
///
/// This method reads a file containing mappings in the format:
/// `Version.parse('x.y.z') : Version.parse('a.b.c')`
///
/// The method returns a `Map` where the keys are Dart [Version] objects
/// and the values are the corresponding Flutter [Version] objects.
///
/// Example File Content:
/// ```
/// Version.parse('2.13.0') : Version.parse('2.2.0'),
/// Version.parse('2.14.0') : Version.parse('2.5.0'),
/// ```
///
/// Example Return Value:
/// ```
/// {
///   Version(2.13.0): Version(2.2.0),
///   Version(2.14.0): Version(2.5.0),
/// }
/// ```
///
/// Throws:
/// - [FileSystemException] if the file does not exist.
/// - [FormatException] if the file contains invalid mappings.
///
/// Parameters:
/// - [file]: A [File] object pointing to the file containing the mappings.
///
/// Returns:
/// A [Map] of Dart [Version] objects to Flutter [Version] objects.
Future<Map<Version, Version>> parseDartToFlutterVersionMappings({
  required File file,
}) async {
  if (!file.existsSync()) {
    throw FileSystemException('Dart to Flutter map file not found.', file.path);
  }

  logInfo(
    'Start reading Dart->Flutter version mappings from file: ${file.path}',
  );

  final contents = await file.readAsString();

  final regex = RegExp(
    r"Version\.parse\('(.*?)'\)\s*:\s*Version\.parse\('(.*?)'\)",
  );

  final matches = regex.allMatches(contents);

  if (matches.isEmpty) {
    throw FormatException(
      'No valid Dart->Flutter version mappings found in the file.',
      contents,
    );
  }

  final versionMap = <Version, Version>{};
  for (final match in matches) {
    _parseAndAddVersionMapping(match, versionMap);
  }

  logInfo(
    'Successfully parsed ${versionMap.length} Dart->Flutter version mappings.',
  );

  return versionMap;
}

/// Parses and adds a version mapping to the provided map.
///
/// This helper method extracts Dart and Flutter versions from a regex match
/// and adds them to the provided [versionMap]. It also validates the match
/// format and logs any issues.
///
/// Parameters:
/// - [match]: A [RegExpMatch] containing Dart and Flutter version strings.
/// - [versionMap]: A [Map] to which the parsed versions are added.
///
/// Throws:
/// - [FormatException] if the match does not contain valid groups.
/// - [FormatException] if the Dart or Flutter version strings are invalid.
void _parseAndAddVersionMapping(
  RegExpMatch match,
  Map<Version, Version> versionMap,
) {
  if (match.groupCount < 2) {
    throw FormatException(
      'Invalid version mapping format detected.',
      match.input,
    );
  }

  final dartVersionStr = match.group(1);
  final flutterVersionStr = match.group(2);

  if (dartVersionStr == null || flutterVersionStr == null) {
    throw FormatException(
      'Invalid version mapping format detected.',
      match.input,
    );
  }

  final dartVersion = Version.parse(dartVersionStr);
  final flutterVersion = Version.parse(flutterVersionStr);
  versionMap[dartVersion] = flutterVersion;
}
