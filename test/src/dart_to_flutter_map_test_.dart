import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:dart_flutter_version/src/dart_to_flutter_map.dart';

void main() {
  test(
    '''
    given map of Dart versions to Flutter versions 
    when  check the smallest Flutter version 
    then should return Flutter 3.0.0
    ''',
    () {
      // Given
      final flutterValues = dartToFlutterMap.values.toList();

      // When
      final smallestFlutterVersion =
          flutterValues.reduce((a, b) => a.compareTo(b) < 0 ? a : b);

      // Then
      expect(smallestFlutterVersion, equals(Version(3, 0, 0)));
    },
  );

  test(
    '''
    given map of Dart versions to Flutter versions 
    when check unique Dart versions 
    then should return the same number of Dart versions as the map has
    ''',
    () {
      // Given
      final dartValues = dartToFlutterMap.keys.toList();

      // When
      final uniqueDartValues = dartValues.toSet();

      // Then
      expect(uniqueDartValues.length, equals(dartValues.length));
    },
  );

  test(
    '''
    given map of Dart versions to Flutter versions 
    when check unique Flutter versions 
    then should return the same number of Flutter versions as the map has
    ''',
    () {
      // Given
      final flutterValues = dartToFlutterMap.values.toList();

      // When
      final uniqueFlutterValues = flutterValues.toSet();

      // Then
      expect(uniqueFlutterValues.length, equals(flutterValues.length));
    },
  );
}
