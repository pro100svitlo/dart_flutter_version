import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:dart_flutter_version/src/dart_to_flutter_map.dart';
import 'package:dart_flutter_version/src/dart_version_parser.dart';
import 'package:dart_flutter_version/src/flutter_version_resolver.dart';

/// An abstract class providing access to Dart and Flutter SDK version information.
///
/// Use the factory constructor to obtain the singleton instance.
abstract class DartFlutterVersion {
  /// Factory constructor that returns the singleton instance of
  /// [DartFlutterVersionImpl].
  factory DartFlutterVersion() => DartFlutterVersionImpl._instance;

  /// Current Dart SDK [Version], or `null` if it cannot be determined.
  ///
  /// The version is derived by parsing the [Platform.version] string,
  /// simplified to the `MAJOR.MINOR.PATCH` format.
  Version? get dartVersion;

  /// The Flutter SDK [Version] that corresponds to the current [dartVersion],
  /// or `null` if it cannot be determined.
  ///
  /// This version is resolved using a Dart-to-Flutter SDK mapping based on stable channel releases
  /// from [docs.flutter.dev](https://docs.flutter.dev/release/archive#stable-channel-macos).
  ///
  /// **Important Notes:**
  /// - The mapping starts from Flutter version `3.0.0`, which aligns with Dart version `2.17.0`.
  /// - The resolved version may not be 100% accurate, as it is based solely on stable channel releases.
  ///   Other release channels (beta, dev, master) or different platforms might have varying version alignments.
  Version? get flutterVersion;
}

/// Implementation of the [DartFlutterVersion] interface.
///
/// This class provides the concrete implementation for the methods and
/// properties defined in the [DartFlutterVersion] interface.
class DartFlutterVersionImpl implements DartFlutterVersion {
  /// Creates [DartFlutterVersionImpl].
  ///
  /// Allows for dependency injection of [DartVersionParser] and [FlutterVersionResolver]
  /// for testing purposes. Defaults are provided if none are supplied.
  @visibleForTesting
  DartFlutterVersionImpl({
    DartVersionParser? dartVersionParser,
    FlutterVersionResolver? flutterVersionResolver,
  })  : _dartVersionParser = dartVersionParser ?? const DartVersionParser(),
        _flutterVersionResolver =
            flutterVersionResolver ?? const FlutterVersionResolver();

  /// The single, private static instance.
  static final _instance = DartFlutterVersionImpl();

  final DartVersionParser _dartVersionParser;
  final FlutterVersionResolver _flutterVersionResolver;

  late final Version? _dartVersion = _parseDartVersion();
  late final Version? _flutterVersion = _resolveFlutterVersion(_dartVersion);

  @override
  Version? get dartVersion => _dartVersion;

  @override
  Version? get flutterVersion => _flutterVersion;

  Version? _parseDartVersion() {
    return _dartVersionParser.parseDartVersion(Platform.version);
  }

  Version? _resolveFlutterVersion(Version? dartVersion) {
    if (dartVersion == null) return null;
    return _flutterVersionResolver.resolve(
      currentDartVersion: dartVersion,
      dartToFlutterVersionMap: dartToFlutterMap,
    );
  }
}
