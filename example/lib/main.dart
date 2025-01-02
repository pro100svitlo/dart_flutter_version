import 'package:flutter/material.dart';
import 'package:dart_flutter_version/dart_flutter_version.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  /// Create an instance of the [DartFlutterVersion] class
  late final versionInfo = DartFlutterVersion();

  @override
  Widget build(BuildContext context) {
    final dartVersion = versionInfo.dartVersion;
    final flutterVersion = versionInfo.flutterVersion;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Version Info')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the Dart version if known
              Text('Dart SDK Version: ${dartVersion ?? "Unknown"}'),

              // Display the Flutter version if known
              Text('Flutter SDK Version: ${flutterVersion ?? "Unknown"}'),

              ElevatedButton(
                onPressed: () {
                  // Your logic to track the Flutter SDK version
                  print('Flutter SDK Version: $flutterVersion');
                },
                child: const Text('Track Flutter SDK Version'),
              ),

              if (flutterVersion != null && flutterVersion >= Version(3, 21, 0))
                const Text(
                  'This widget will be shown only if you run on Flutter 3.21.0 or newer',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
