import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:dart_flutter_version/src/dart_version_parser.dart';

void main() {
  group('$DartVersionParser', () {
    late DartVersionParser parser;

    setUp(() {
      parser = const DartVersionParser();
    });

    test(
      '''
      given a valid semver string (MAJOR.MINOR.PATCH)
      when parseDartVersion is called
      then it returns an expected $Version with the correct values
      ''',
      () {
        // Given
        const dataSource = '2.10.5';
        final expectedVersion = Version(2, 10, 5);

        // When
        final version = parser.parseDartVersion(dataSource);

        // Then
        expect(version, equals(expectedVersion));
      },
    );

    test(
      '''
      given an invalid version string
      when parseDartVersion is called
      then it returns null
      ''',
      () {
        // Given
        const dataSource = 'invalid-version';

        // When
        final version = parser.parseDartVersion(dataSource);

        // Then
        expect(version, isNull);
      },
    );

    test(
      '''
      given a string with only MAJOR.MINOR (missing PATCH)
      when parseDartVersion is called
      then it returns null because it doesn't match the regex
      ''',
      () {
        // Given
        const dataSource = '2.10';

        // When
        final version = parser.parseDartVersion(dataSource);

        // Then
        expect(version, isNull);
      },
    );

    test(
      '''
      given a version string with extra text following patch (e.g., build info)
      when parseDartVersion is called
      then it returns a Version that only reflects the MAJOR.MINOR.PATCH portion
      ''',
      () {
        // Given
        const dataSource = '2.10.5-0.dev (build abc123)';

        // When
        final version = parser.parseDartVersion(dataSource);

        // Then
        expect(version, isNotNull);
        // Our regex captures only '2.10.5'
        expect(version, equals(Version(2, 10, 5)));
      },
    );

    test(
      '''
      given a valid semver string (MAJOR.MINOR.PATCH)
      when parseDartVersion is called on multiple data sources
      then it consistently returns correct version objects or null
      ''',
      () {
        // Given
        // Multiple examples, including valid, partial, or invalid.
        final dataSources = [
          '3.0.0',
          '3.1.4',
          '10.20.30',
          'invalid-version',
          '2.10',
        ];

        final expectedResults = [
          Version(3, 0, 0),
          Version(3, 1, 4),
          Version(10, 20, 30),
          null,
          null,
        ];

        // When
        final results = dataSources.map(parser.parseDartVersion).toList();

        // Then
        expect(results, equals(expectedResults));
      },
    );
  });
}
