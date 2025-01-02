import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:dart_flutter_version/src/dart_to_flutter_map.dart';
import 'package:dart_flutter_version/src/dart_version_parser.dart';
import 'package:dart_flutter_version/src/flutter_version_resolver.dart';
import 'package:dart_flutter_version/src/dart_flutter_version.dart';

void main() {
  group('$DartFlutterVersion', () {
    late _MockDartVersionParser mockDartParser;
    late _MockFlutterVersionResolver mockFlutterResolver;

    late DartFlutterVersion provider;

    setUp(() {
      mockDartParser = _MockDartVersionParser();
      mockFlutterResolver = _MockFlutterVersionResolver();

      provider = DartFlutterVersionImpl(
        dartVersionParser: mockDartParser,
        flutterVersionResolver: mockFlutterResolver,
      );
      registerFallbackValue(Version(3, 14, 159));
    });

    test(
      '''
      given multiple calls to $DartFlutterVersion()
      when check if the instances are identical
      then should return true
      ''',
      () {
        // Given
        final instance1 = DartFlutterVersion();
        final instance2 = DartFlutterVersion();

        // When
        final isIdentical = identical(instance1, instance2);

        // Then
        expect(isIdentical, isTrue);
      },
    );

    test(
      '''
      given parseDartVersion returns null
      when accessing dartVersion
      then dartVersion and flutterVersion should be null
      ''',
      () {
        // Given
        when(() => mockDartParser.parseDartVersion(Platform.version))
            .thenReturn(null);

        // When
        final dartVer = provider.dartVersion;
        final flutterVer = provider.flutterVersion;

        // Then
        expect(dartVer, isNull);
        expect(flutterVer, isNull);

        // Ensure parseDartVersion was called exactly once
        verify(() => mockDartParser.parseDartVersion(Platform.version))
            .called(1);
        // Also verify that flutterVersionResolver.resolve wasn't called
        verifyNever(
          () => mockFlutterResolver.resolve(
            currentDartVersion: any(named: 'currentDartVersion'),
            dartToFlutterVersionMap: any(named: 'dartToFlutterVersionMap'),
          ),
        );
      },
    );

    test(
      '''
      given parseDartVersion returns a valid version
      when accessing dartVersion
      then dartVersion should match the parsed value
      ''',
      () {
        // Given
        final fakeDartVersion = Version(2, 17, 1);
        when(() => mockDartParser.parseDartVersion(Platform.version))
            .thenReturn(fakeDartVersion);

        // When
        final dartVer = provider.dartVersion;

        // Then
        expect(dartVer, equals(fakeDartVersion));
        // Ensure parseDartVersion was called exactly once
        verify(() => mockDartParser.parseDartVersion(Platform.version))
            .called(1);
      },
    );

    test(
      '''
      given parseDartVersion returns a valid version and flutterVersionResolver returns a matching Flutter version
      when accessing flutterVersion
      then flutterVersion should match the resolved value
      ''',
      () {
        // Given
        final fakeDartVersion = Version(2, 17, 1);
        final fakeFlutterVersion = Version(3, 0, 0);

        when(() => mockDartParser.parseDartVersion(Platform.version))
            .thenReturn(fakeDartVersion);

        when(
          () => mockFlutterResolver.resolve(
            currentDartVersion: fakeDartVersion,
            dartToFlutterVersionMap: dartToFlutterMap,
          ),
        ).thenReturn(fakeFlutterVersion);

        // When
        final dartVer = provider.dartVersion;
        final flutterVer = provider.flutterVersion;

        // Then
        expect(dartVer, equals(fakeDartVersion));
        expect(flutterVer, equals(fakeFlutterVersion));
      },
    );

    test(
      '''
      given parseDartVersion returns a valid version and flutterVersionResolver returns null
      when accessing flutterVersion
      then flutterVersion should be null
      ''',
      () {
        // Given
        final fakeDartVersion = Version(2, 17, 1);

        when(() => mockDartParser.parseDartVersion(Platform.version))
            .thenReturn(fakeDartVersion);

        // The resolver can't find a match in dartToFlutterMap
        when(
          () => mockFlutterResolver.resolve(
            currentDartVersion: fakeDartVersion,
            dartToFlutterVersionMap: dartToFlutterMap,
          ),
        ).thenReturn(null);

        // When
        final flutterVer = provider.flutterVersion;

        // Then
        expect(flutterVer, isNull);
      },
    );

    test(
      '''
      given dartVersion and flutterVersion are accessed multiple times
      when parseDartVersion and flutterVersionResolver returns a valid versions
      then parseDartVersion and flutterVersionResolver.resolve are each called only once (lazy initialization)
      ''',
      () {
        // Given
        final fakeDartVersion = Version(2, 17, 1);
        final fakeFlutterVersion = Version(3, 0, 0);

        when(() => mockDartParser.parseDartVersion(Platform.version))
            .thenReturn(fakeDartVersion);

        when(
          () => mockFlutterResolver.resolve(
            currentDartVersion: fakeDartVersion,
            dartToFlutterVersionMap: dartToFlutterMap,
          ),
        ).thenReturn(fakeFlutterVersion);

        // When
        for (var i = 0; i < 2; i++) {
          provider.dartVersion;
          // ignore: cascade_invocations
          provider.flutterVersion;
        }

        // Then
        // parseDartVersion should only be called once despite multiple accesses
        verify(() => mockDartParser.parseDartVersion(any())).called(1);

        // flutterVersionResolver.resolve should only be called once
        verify(
          () => mockFlutterResolver.resolve(
            currentDartVersion: any(named: 'currentDartVersion'),
            dartToFlutterVersionMap: any(named: 'dartToFlutterVersionMap'),
          ),
        ).called(1);
      },
    );
  });
}

class _MockDartVersionParser extends Mock implements DartVersionParser {}

class _MockFlutterVersionResolver extends Mock
    implements FlutterVersionResolver {}
