import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import '../util/log_info.dart';

/// Saves the provided Dart-to-Flutter version mappings to a specified file.
///
/// This method generates Dart code representing the provided [dartToFlutterMap]
/// and writes it to the specified [outputFile]. The generated file is intended
/// to be machine-generated and should not be modified manually.
///
/// Throws:
/// - [FileSystemException] if the [outputFile] does not exist.
///
/// Parameters:
/// - [outputFile]: The file to which the Dart-to-Flutter map will be saved.
/// - [dartToFlutterMap]: A map of Dart [Version] to Flutter [Version] to save.
///
/// Example Generated Output:
/// ```dart
/// // GENERATED CODE - DO NOT MODIFY BY HAND
/// import 'package:pub_semver/pub_semver.dart';
///
/// /// This is a map of Dart SDK versions to Flutter SDK versions.
/// ///
/// /// Key: Dart SDK version
/// /// Value: Flutter SDK version
/// final dartToFlutterMap = {
///   Version.parse('2.19.1'): Version.parse('3.7.1'),
///   Version.parse('2.18.0'): Version.parse('3.6.0'),
/// };
/// ```
Future<void> saveDartToFlutterVersionsMap({
  required File outputFile,
  required Map<Version, Version> dartToFlutterMap,
}) async {
  if (!outputFile.existsSync()) {
    throw FileSystemException(
      'The output file does not exist.',
      outputFile.path,
    );
  }

  logInfo('Starting to save Dart-to-Flutter versions to file...');

  final newContent = _generateContentFromMap(
    dartToFlutterMap: dartToFlutterMap,
  );

  // Write the generated content to the specified file.
  await outputFile.writeAsString(newContent);

  logInfo(
    'Successfully saved ${dartToFlutterMap.length} Dart-to-Flutter version mappings to ${outputFile.path}.',
  );
}

/// Generates Dart code representing a map of Dart-to-Flutter version mappings.
///
/// The generated code includes metadata comments and defines a constant map
/// variable `dartToFlutterMap` where keys are Dart SDK versions and values
/// are Flutter SDK versions.
///
/// Parameters:
/// - [dartToFlutterMap]: A map of Dart [Version] to Flutter [Version] to generate.
///
/// Returns:
/// A [String] containing the Dart code representation of the map.
String _generateContentFromMap({
  required Map<Version, Version> dartToFlutterMap,
}) {
  // Header with metadata and import statement
  const initialPart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:pub_semver/pub_semver.dart';

/// A lookup table matching Dart SDK versions to their corresponding
/// Flutter SDK versions.
///
/// - **Key** (Dart SDK Version): Identifies a specific stable release of the
///   Dart SDK.
/// - **Value** (Flutter SDK Version): Identifies the corresponding stable
///   Flutter release that ships with (or supports) that Dart version.
///
/// To find ouf more about the generation process, check README.md 
/// file in the root directory.
final dartToFlutterMap = {
''';

  final buffer = StringBuffer(initialPart);

  // Generate each entry in the map.
  for (final entry in dartToFlutterMap.entries) {
    final dartVersionStr = entry.key.toString(); // e.g., "2.19.1"
    final flutterVersionStr = entry.value.toString(); // e.g., "3.7.1"

    buffer
      ..write('  ') // Indentation
      ..write("Version.parse('$dartVersionStr')") // Key
      ..write(': ') // Separator
      ..write("Version.parse('$flutterVersionStr'),") // Value
      ..writeln(); // Newline
  }

  // Close the map definition.
  buffer.writeln('};');

  return buffer.toString();
}
