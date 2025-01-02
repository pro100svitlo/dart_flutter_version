import 'package:html/parser.dart' as html_parser;

import 'package:pub_semver/pub_semver.dart';

import '../util/log_info.dart';

/// Parses the given [htmlContent] and returns a Map of:
///   Flutter Version -> Dart Version
///
/// If the same Flutter version is encountered multiple times,
/// the first Dart version for that Flutter version remains in the map,
/// and subsequent entries are ignored.
Map<Version, Version> parseFlutterToDartVersions({
  required String htmlContent,
  required String selectorID,
}) {
  logInfo('Start parsing remote Flutter->Dart versions...');

  // Parse the HTML string into a Document object
  final document = html_parser.parse(htmlContent);

  // This will store the mapping of Dart version to Flutter version
  final versionMap = <Version, Version>{};

  // Find the table with id="downloads-macos-stable"
  final table = document.querySelector(selectorID);
  if (table == null) {
    throw ('Table with id "$selectorID" not found.');
  }

  // Get all the rows <tr> within that table
  final rows = table.querySelectorAll('tr');

  // Loop through each row
  for (final row in rows) {
    // Each row should have <td> cells
    final cells = row.querySelectorAll('td');

    // We expect at least 5 cells:
    //    [0] Flutter version
    //    [4] Dart version
    if (cells.length < 5) {
      continue;
    }

    // Extract the text for Flutter version and Dart version
    final flutterVersionText = cells[0].text.trim();
    final dartVersionText = cells[4].text.trim();

    try {
      final flutterVersion = Version.parse(flutterVersionText);
      final dartVersion = Version.parse(dartVersionText);

      // Only add to the map if the Dart version hasn't been encountered yet.
      if (!versionMap.containsKey(flutterVersion)) {
        versionMap[flutterVersion] = dartVersion;
      }
    } catch (_) {
      // If Version.parse fails, just ignore this row.
    }
  }

  logInfo('Finished parsing remote Flutter->Dart versions.');

  return versionMap;
}
