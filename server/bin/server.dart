import 'dart:async';
import 'dart:io';

import 'package:hobbyswap_server/hobbyswap_server.dart';

const _usage = '''
HobbySwap server

Usage: dart run bin/server.dart [--port 8080] [--data path/to/data.json]

Environment variables PORT and DATA_FILE work too. Flags win.
''';

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    stdout.write(_usage);
    return;
  }
  final port = int.parse(
    _flag(args, '--port') ?? Platform.environment['PORT'] ?? '8080',
  );
  final dataPath = _flag(args, '--data') ??
      Platform.environment['DATA_FILE'] ??
      _defaultDataPath();

  final store = await Store.open(dataPath);
  final handler = ApiHandler(store, log: (line) => stdout.writeln(line));
  final server = await handler.serve(port: port);

  stdout.writeln('HobbySwap server listening on port ${server.port}');
  stdout.writeln('Data file: ${store.file.absolute.path}');
  stdout.writeln('Try: http://localhost:${server.port}/health');
  for (final address in await _lanAddresses()) {
    stdout.writeln('Phones on the same Wi-Fi: http://$address:${server.port}');
  }

  // Save pending writes and stop cleanly on Ctrl-C (and SIGTERM off Windows).
  var stopping = false;
  Future<void> shutDown(ProcessSignal signal) async {
    if (stopping) return;
    stopping = true;
    stdout.writeln('\nShutting down...');
    await server.close();
    await store.flush();
    exit(0);
  }

  ProcessSignal.sigint.watch().listen(shutDown);
  if (!Platform.isWindows) ProcessSignal.sigterm.watch().listen(shutDown);
}

String? _flag(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1) return null;
  if (index + 1 >= args.length) {
    stderr.write('Missing value for $name\n\n$_usage');
    exit(64);
  }
  return args[index + 1];
}

/// server/data/hobbyswap.json, wherever the command is run from.
String _defaultDataPath() {
  final serverDir = File.fromUri(Platform.script).parent.parent;
  return '${serverDir.path}/data/hobbyswap.json';
}

Future<List<String>> _lanAddresses() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    return [
      for (final i in interfaces)
        for (final a in i.addresses)
          if (!a.isLoopback) a.address,
    ];
  } on SocketException {
    return const [];
  }
}
