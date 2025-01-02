import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:dart_flutter_version/src/flutter_version_resolver.dart';

void main() {
  group('$FlutterVersionResolver', () {
    late FlutterVersionResolver resolver;

    setUp(() {
      resolver = FlutterVersionResolver();
    });

    test(
      '''
      given a direct mapping
      when resolve is called
      then it returns the mapped Flutter version
      ''',
      () {
        // Given
        final dartVersion = Version(2, 17, 0);
        final flutterVersion = Version(3, 0, 0);
        final map = {
          dartVersion: flutterVersion,
        };

        // When
        final result = resolver.resolve(
          currentDartVersion: dartVersion,
          dartToFlutterVersionMap: map,
        );

        // Then
        expect(result, equals(flutterVersion));
      },
    );

    test(
      '''
      given no direct mapping but a lower Flutter version exists
      when resolve is called
      then it returns the closest lower Flutter version
      ''',
      () {
        // Given
        final dartVersion_2_16 = Version(2, 16, 0);
        final dartVersion_2_17 = Version(2, 17, 0);

        final flutterVersion_3_0 = Version(3, 0, 0);
        final flutterVersion_3_1 = Version(3, 1, 0);

        final map = {
          dartVersion_2_16: flutterVersion_3_0,
          dartVersion_2_17: flutterVersion_3_1,
        };

        // The user’s current Dart version
        final dartVersionToCheck = Version(2, 17, 5);

        // When
        final result = resolver.resolve(
          currentDartVersion: dartVersionToCheck,
          dartToFlutterVersionMap: map,
        );

        // Then
        // The largest version below 2.17.5 is 2.17.0
        expect(result, equals(flutterVersion_3_1));
      },
    );

    test(
      '''
      given no direct mapping and no lower version
      when resolve is called
      then it returns null
      ''',
      () {
        // Given
        final dartVersion_2_18 = Version(2, 18, 0);
        final flutterVersion_3_3 = Version(3, 3, 0);

        final map = {
          dartVersion_2_18: flutterVersion_3_3,
        };

        // Current Dart version is even lower than the first known key.
        final dartVersionToCheck = Version(2, 17, 0);

        // When
        final result = resolver.resolve(
          currentDartVersion: dartVersionToCheck,
          dartToFlutterVersionMap: map,
        );

        // Then
        // There is no key less than 2.17.0 in the map
        expect(result, isNull);
      },
    );

    test(
      '''
      given no direct mapping but multiple lower versions
      when resolve is called
      then it returns the closest lower mapped version
      ''',
      () {
        // Given
        final dartVersion_2_10 = Version(2, 10, 0);
        final dartVersion_2_12 = Version(2, 12, 0);
        final dartVersion_2_14 = Version(2, 14, 0);

        final flutterVersion_2_10 = Version(3, 0, 0);
        final flutterVersion_2_12 = Version(3, 1, 0);
        final flutterVersion_2_14 = Version(3, 2, 0);

        final map = {
          dartVersion_2_10: flutterVersion_2_10,
          dartVersion_2_12: flutterVersion_2_12,
          dartVersion_2_14: flutterVersion_2_14,
        };

        // The user’s current Dart version is 2.13, so the closest
        // lower version is 2.12.0.
        final dartVersionToCheck = Version(2, 13, 0);

        // When
        final result = resolver.resolve(
          currentDartVersion: dartVersionToCheck,
          dartToFlutterVersionMap: map,
        );

        // Then
        expect(result, equals(flutterVersion_2_12));
      },
    );
  });
}
