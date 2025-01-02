import 'dart:io';

/// Runs a system process and returns its output.
///
/// This function executes the specified [command] with the provided [arguments].
/// If the process exits successfully (exit code 0), it returns the trimmed stdout output.
/// If the process fails (non-zero exit code), it throws an exception with detailed
/// error information.
///
/// Parameters:
/// - [command]: The command to execute (e.g., `git`).
/// - [arguments]: A list of arguments for the command (default: empty).
///
/// Returns:
/// - The trimmed stdout output of the executed process.
///
/// Throws:
/// - [Exception] if the process exits with a non-zero exit code.
///
/// Example Usage:
/// ```dart
/// final output = await runProcess(
///   command: 'git',
///   arguments: ['status'],
/// );
/// print(output);
/// ```
Future<String> runProcess({
  required String command,
  List<String> arguments = const [],
}) async {
  final result = await Process.run(
    command,
    arguments,
  );

  if (result.exitCode == 0) {
    return result.stdout.toString().trim();
  }

  // Construct a detailed error message for failures.
  final buffer = StringBuffer('❌ Error during command execution:')
    ..writeln()
    ..writeln('Command: $command')
    ..writeln('Arguments: $arguments')
    ..writeln('Exit Code: ${result.exitCode}')
    ..writeln('Standard Output:\n${result.stdout}')
    ..writeln('Standard Error:\n${result.stderr}');

  throw Exception(buffer.toString());
}
