import 'package:pub_semver/pub_semver.dart';
import 'package:puppeteer/puppeteer.dart';
import '../util/log_info.dart';
import 'parse_html_flutter_to_dart_versions.dart';

/// URL to the Flutter stable channel (macOS) releases on Flutter Dev.
const _flutterDevArchiveUrl =
    'https://docs.flutter.dev/release/archive#stable-channel-macos';

/// The CSS selector for the macOS stable downloads table.
const _downloadsTableSelector = '#downloads-macos-stable';

/// Fetches a map of Flutter-to-Dart versions from the Flutter Dev archive.
///
/// This function:
/// 1. Launches a headless Chromium browser using Puppeteer.
/// 2. Navigates to the Flutter Dev archive's stable macOS section.
/// 3. Extracts the HTML content of the `#downloads-macos-stable` table.
/// 4. Parses and returns a Flutter-to-Dart version map using [parseFlutterToDartVersions].
///
/// Throws:
/// - [Exception] if the `#downloads-macos-stable` table is not found on the page.
///
/// Returns:
/// A [Map] of Flutter [Version] to Dart [Version].
///
/// Example Result:
/// ```dart
/// {
///   Version(3.0.0): Version(2.15.0),
///   Version(3.3.0): Version(2.17.0),
/// }
/// ```
Future<Map<Version, Version>> fetchFlutterToDartVersionsFromRemote() async {
  logInfo('Launching headless browser...');

  late Browser browser;

  var tryCount = 0;
  while (tryCount < 3) {
    try {
      browser = await puppeteer.launch(headless: true);
      logInfo('Browser launched successfully from the $tryCount try.');
      break;
    } catch (e) {
      logInfo('Failed to launch browser from the $tryCount try:\n$e');
      tryCount++;
    }
  }

  try {
    logInfo('Starting to fetch Flutter-to-Dart versions from remote source...');

    // Open a new page in the browser.
    final page = await browser.newPage();

    logInfo('Navigate in browser $_flutterDevArchiveUrl...');
    // Navigate to the Flutter Dev archive stable macOS section.
    await page.goto(_flutterDevArchiveUrl, wait: Until.networkIdle);

    logInfo('Page loaded. Extracting content from the downloads table...');

    // Retrieve the HTML of the `#downloads-macos-stable` table.
    final content = await page.$eval<String>(
      _downloadsTableSelector,
      'element => element.outerHTML',
    );

    if (content == null) {
      throw Exception(
        'Failed to locate the table with selector "$_downloadsTableSelector".',
      );
    }

    logInfo(
      'Content extracted successfully. Parsing Flutter-to-Dart versions...',
    );

    // Parse a map of Flutter->Dart versions from the extracted HTML content.
    final flutterToDartVersions = parseFlutterToDartVersions(
      htmlContent: content,
      selectorID: _downloadsTableSelector,
    );

    logInfo(
      'Successfully fetched and parsed ${flutterToDartVersions.length} Flutter-to-Dart versions.',
    );

    return flutterToDartVersions;
  } finally {
    // Ensure the browser is closed even if an error occurs.
    logInfo('Closing the browser...');
    await browser.close();
    logInfo('Browser closed.');
  }
}
