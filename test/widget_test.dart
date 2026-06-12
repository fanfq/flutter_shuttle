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
