import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_shuttle/main.dart';

void main() {
  testWidgets('shows shuttle settings and saved configs', (tester) async {
    await tester.pumpWidget(
      MyApp(
        store: _MemoryStore(const [
          ShuttleConfig(
            id: '1',
            name: 'Production SSH',
            command: 'ssh user@example.com',
          ),
        ]),
        platform: _FakePlatform(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shuttle'), findsOneWidget);
    expect(find.text('Launch at Login'), findsOneWidget);
    expect(find.text('Production SSH'), findsOneWidget);
    expect(find.text('General'), findsWidgets);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('shows app version from package metadata', (tester) async {
    await tester.pumpWidget(
      MyApp(
        store: _MemoryStore(const []),
        platform: _FakePlatform(),
        appVersionLoader: () async => '2.3.4 (57)',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Version 2.3.4 (57)'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsNothing);
  });

  testWidgets('shows live command output in the config log view', (
    tester,
  ) async {
    final platform = _FakePlatform();
    await tester.pumpWidget(
      MyApp(
        store: _MemoryStore(const [
          ShuttleConfig(
            id: 'redis',
            name: 'Redis',
            command: '/Users/fred/apps/redis-4.0.1/src/redis-server',
          ),
        ]),
        platform: platform,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Logs'));
    await tester.pumpAndSettle();
    expect(find.text('Redis Logs'), findsOneWidget);

    await tester.tap(find.byTooltip('Run'));
    await tester.pump();
    platform.emitLog(
      const CommandLogEntry(
        taskId: 'redis',
        stream: CommandOutputStream.stdout,
        message: 'Ready to accept connections',
      ),
    );
    await tester.pump();

    expect(find.textContaining('Ready to accept connections'), findsOneWidget);
  });

  testWidgets('shows a badge for configs that run after login', (tester) async {
    await tester.pumpWidget(
      MyApp(
        store: _MemoryStore(const [
          ShuttleConfig(
            id: 'startup',
            name: 'Startup Redis',
            command: 'redis-server',
            runAtLogin: true,
          ),
        ]),
        platform: _FakePlatform(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Startup Redis'), findsOneWidget);
    expect(find.byTooltip('Run after login'), findsOneWidget);
  });
}

class _MemoryStore implements ShuttleStore {
  _MemoryStore(this.configs);

  List<ShuttleConfig> configs;

  @override
  Future<List<ShuttleConfig>> loadConfigs() async => configs;

  @override
  Future<void> saveConfigs(List<ShuttleConfig> configs) async {
    this.configs = configs;
  }
}

class _FakePlatform implements ShuttlePlatform {
  var loginItemEnabled = false;
  CommandLogListener? logListener;

  @override
  Future<bool> getLoginItemEnabled() async => loginItemEnabled;

  @override
  Future<CommandResult> runCommand(
    String command, {
    required String taskId,
    required bool runInTerminal,
  }) async {
    return const CommandResult(exitCode: 0, output: 'ok', error: '');
  }

  @override
  Future<void> cancelCommand(String taskId) async {}

  @override
  void setCommandLogListener(CommandLogListener? listener) {
    logListener = listener;
  }

  void emitLog(CommandLogEntry entry) {
    logListener?.call(entry);
  }

  @override
  Future<void> setLoginItemEnabled(bool enabled) async {
    loginItemEnabled = enabled;
  }

  @override
  Future<void> updateRunningConfigs(List<String> configNames) async {}

  @override
  Future<void> openExternalUrl(String url) async {}

  @override
  Future<String?> chooseImportFile() async => null;

  @override
  Future<String?> chooseExportFile() async => null;
}
