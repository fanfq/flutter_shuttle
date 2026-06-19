import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

const _loginLaunchFlag = '--launched-at-login';
const _productName = 'Shuttle';
const _fallbackAppVersion = '1.0.0';
const _aboutUrl = 'https://github.com/fanfq/flutter_shuttle';
const _defaultCategory = 'General';

typedef AppVersionLoader = Future<String> Function();

Future<String> _loadAppVersionFromPackage() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return _formatAppVersion(packageInfo.version, packageInfo.buildNumber);
}

String _formatAppVersion(String version, String buildNumber) {
  final trimmedVersion = version.trim();
  final trimmedBuildNumber = buildNumber.trim();
  if (trimmedBuildNumber.isEmpty) {
    return trimmedVersion.isEmpty ? _fallbackAppVersion : trimmedVersion;
  }
  final displayVersion = trimmedVersion.isEmpty
      ? _fallbackAppVersion
      : trimmedVersion;
  return '$displayVersion ($trimmedBuildNumber)';
}

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('zh')];
  static const delegate = _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        const AppStrings(Locale('en'));
  }

  bool get _zh => locale.languageCode == 'zh';

  String get appName => _productName;
  String get version => _zh ? '版本' : 'Version';
  String get about => 'About';
  String get importConfigs => _zh ? '导入' : 'Import';
  String get exportConfigs => _zh ? '导出' : 'Export';
  String get allCategories => _zh ? '全部' : 'All';
  String get categories => _zh ? '分类' : 'Categories';
  String get uncategorized => _zh ? '未分类' : 'Uncategorized';
  String get launchAtLogin => _zh ? '开机自启动' : 'Launch at Login';
  String get running => _zh ? '正在执行' : 'Running';
  String get shortcuts => _zh ? '快捷配置' : 'Shortcuts';
  String get addConfig => _zh ? '新增配置' : 'Add Configuration';
  String get run => _zh ? '运行' : 'Run';
  String get stop => _zh ? '停止' : 'Stop';
  String get stopped => _zh ? '已停止' : 'Stopped';
  String get logs => _zh ? '日志' : 'Logs';
  String get clearLogs => _zh ? '清空日志' : 'Clear Logs';
  String get noLogsYet => _zh ? '暂无日志' : 'No logs yet';
  String get stdout => 'stdout';
  String get stderr => 'stderr';
  String get runInTerminal => _zh ? '在系统命令行中执行' : 'Run in Terminal';
  String get edit => _zh ? '编辑' : 'Edit';
  String get delete => _zh ? '删除' : 'Delete';
  String get deleteConfig => _zh ? '删除配置' : 'Delete Configuration';
  String deleteConfigMessage(String name) {
    return _zh
        ? '确定要删除“$name”吗？此操作无法撤销。'
        : 'Delete "$name"? This action cannot be undone.';
  }

  String get runAfterLogin => _zh ? '登录后运行' : 'Run after login';
  String get emptyTitle => _zh ? '还没有配置' : 'No configurations yet';
  String get emptySubtitle =>
      _zh ? '点击右上角的加号新增一个命令。' : 'Click the plus button to add a command.';
  String get newConfig => _zh ? '新增配置' : 'New Configuration';
  String get editConfig => _zh ? '编辑配置' : 'Edit Configuration';
  String get name => _zh ? '名称' : 'Name';
  String get category => _zh ? '分类' : 'Category';
  String get command => _zh ? '命令' : 'Command';
  String get runThisAfterLogin =>
      _zh ? '登录后自动运行此配置' : 'Run this configuration after login';
  String get cancel => _zh ? '取消' : 'Cancel';
  String get save => _zh ? '保存' : 'Save';
  String get loginEnabled => _zh ? '已开启开机自启动' : 'Launch at login enabled';
  String get loginDisabled => _zh ? '已关闭开机自启动' : 'Launch at login disabled';
  String get importSucceeded => _zh ? '配置已导入' : 'Configurations imported';
  String get exportSucceeded => _zh ? '配置已导出' : 'Configurations exported';

  String importFailed(Object error) {
    return _zh ? '导入失败：$error' : 'Import failed: $error';
  }

  String exportFailed(Object error) {
    return _zh ? '导出失败：$error' : 'Export failed: $error';
  }

  String loginConfigsRan(int count) {
    return _zh
        ? '已运行 $count 个开机自动启动配置'
        : 'Ran $count launch-at-login configuration${count == 1 ? '' : 's'}';
  }

  String loginUpdateFailed(Object error) {
    return _zh
        ? '更新开机自启动失败：$error'
        : 'Failed to update launch at login: $error';
  }

  String runningConfig(String name) {
    return _zh ? '正在运行：$name' : 'Running: $name';
  }

  String runCompleted(String name) {
    return _zh ? '运行完成：$name' : 'Completed: $name';
  }

  String runFailed(String name) {
    return _zh ? '运行失败：$name' : 'Failed: $name';
  }

  String logTitle(String name) {
    return _zh ? '$name 日志' : '$name Logs';
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'en' || locale.languageCode == 'zh';
  }

  @override
  Future<AppStrings> load(Locale locale) async {
    final languageCode = locale.languageCode == 'zh' ? 'zh' : 'en';
    return AppStrings(Locale(languageCode));
  }

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp(launchedAtLogin: args.contains(_loginLaunchFlag)));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.launchedAtLogin = false,
    ShuttleStore? store,
    ShuttlePlatform? platform,
    AppVersionLoader? appVersionLoader,
  }) : _store = store,
       _platform = platform,
       _appVersionLoader = appVersionLoader;

  final bool launchedAtLogin;
  final ShuttleStore? _store;
  final ShuttlePlatform? _platform;
  final AppVersionLoader? _appVersionLoader;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _productName,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale?.languageCode == 'zh') {
          return const Locale('zh');
        }
        return const Locale('en');
      },
      theme: ThemeData(
        fontFamily: Platform.isMacOS ? '.AppleSystemUIFont' : null,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: ShuttleHomePage(
        launchedAtLogin: launchedAtLogin,
        store: _store ?? FileShuttleStore(),
        platform: _platform ?? MethodChannelShuttlePlatform(),
        appVersionLoader: _appVersionLoader ?? _loadAppVersionFromPackage,
      ),
    );
  }
}

class ShuttleConfig {
  const ShuttleConfig({
    required this.id,
    required this.name,
    this.category = _defaultCategory,
    required this.command,
    this.runAtLogin = false,
    this.runInTerminal = false,
  });

  final String id;
  final String name;
  final String category;
  final String command;
  final bool runAtLogin;
  final bool runInTerminal;

  ShuttleConfig copyWith({
    String? id,
    String? name,
    String? category,
    String? command,
    bool? runAtLogin,
    bool? runInTerminal,
  }) {
    return ShuttleConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      command: command ?? this.command,
      runAtLogin: runAtLogin ?? this.runAtLogin,
      runInTerminal: runInTerminal ?? this.runInTerminal,
    );
  }

  factory ShuttleConfig.fromJson(Map<String, dynamic> json) {
    return ShuttleConfig(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Untitled',
      category: json['category'] as String? ?? _defaultCategory,
      command: json['command'] as String? ?? '',
      runAtLogin: json['runAtLogin'] as bool? ?? false,
      runInTerminal: json['runInTerminal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'command': command,
      'runAtLogin': runAtLogin,
      'runInTerminal': runInTerminal,
    };
  }
}

abstract class ShuttleStore {
  Future<List<ShuttleConfig>> loadConfigs();

  Future<void> saveConfigs(List<ShuttleConfig> configs);
}

class FileShuttleStore implements ShuttleStore {
  FileShuttleStore({File? file}) : _file = file;

  final File? _file;

  Future<File> get _configFile async {
    if (_file != null) {
      return _file;
    }
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw StateError('HOME is not available.');
    }
    final directory = Directory(
      '$home/Library/Application Support/FlutterShuttle',
    );
    await directory.create(recursive: true);
    return File('${directory.path}/config.json');
  }

  @override
  Future<List<ShuttleConfig>> loadConfigs() async {
    final file = await _configFile;
    if (!await file.exists()) {
      return const [];
    }
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ShuttleConfig.fromJson)
        .toList();
  }

  @override
  Future<void> saveConfigs(List<ShuttleConfig> configs) async {
    final file = await _configFile;
    await file.writeAsString(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(configs.map((config) => config.toJson()).toList()),
    );
  }
}

abstract class ShuttlePlatform {
  Future<bool> getLoginItemEnabled();

  Future<void> setLoginItemEnabled(bool enabled);

  Future<void> updateRunningConfigs(List<String> configNames);

  Future<void> openExternalUrl(String url);

  Future<String?> chooseImportFile();

  Future<String?> chooseExportFile();

  Future<void> cancelCommand(String taskId);

  void setCommandLogListener(CommandLogListener? listener);

  Future<CommandResult> runCommand(
    String command, {
    required String taskId,
    required bool runInTerminal,
  });
}

typedef CommandLogListener = void Function(CommandLogEntry entry);

enum CommandOutputStream { stdout, stderr, system }

class CommandLogEntry {
  const CommandLogEntry({
    required this.taskId,
    required this.stream,
    required this.message,
    this.timestamp,
  });

  final String taskId;
  final CommandOutputStream stream;
  final String message;
  final DateTime? timestamp;

  factory CommandLogEntry.fromJson(Map<Object?, Object?> json) {
    final streamName = json['stream'] as String? ?? 'system';
    return CommandLogEntry(
      taskId: json['taskId'] as String? ?? '',
      stream: switch (streamName) {
        'stdout' => CommandOutputStream.stdout,
        'stderr' => CommandOutputStream.stderr,
        _ => CommandOutputStream.system,
      },
      message: json['message'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
    );
  }
}

class CommandResult {
  const CommandResult({
    required this.exitCode,
    required this.output,
    required this.error,
  });

  final int exitCode;
  final String output;
  final String error;

  bool get succeeded => exitCode == 0;

  factory CommandResult.fromJson(Map<Object?, Object?> json) {
    return CommandResult(
      exitCode: json['exitCode'] as int? ?? -1,
      output: json['output'] as String? ?? '',
      error: json['error'] as String? ?? '',
    );
  }
}

class MethodChannelShuttlePlatform implements ShuttlePlatform {
  static const _channel = MethodChannel('flutter_shuttle/macos');
  CommandLogListener? _logListener;

  MethodChannelShuttlePlatform() {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'commandLog') {
        throw MissingPluginException();
      }
      final arguments = call.arguments;
      if (arguments is Map<Object?, Object?>) {
        _logListener?.call(CommandLogEntry.fromJson(arguments));
      }
    });
  }

  @override
  Future<bool> getLoginItemEnabled() async {
    if (!Platform.isMacOS) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('getLoginItemEnabled') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> setLoginItemEnabled(bool enabled) async {
    if (!Platform.isMacOS) {
      throw UnsupportedError(
        'Login item management is only available on macOS.',
      );
    }
    await _channel.invokeMethod<void>('setLoginItemEnabled', {
      'enabled': enabled,
    });
  }

  @override
  Future<void> updateRunningConfigs(List<String> configNames) async {
    if (!Platform.isMacOS) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('updateRunningConfigs', {
        'names': configNames,
      });
    } on MissingPluginException {
      return;
    }
  }

  @override
  Future<void> openExternalUrl(String url) async {
    if (!Platform.isMacOS) {
      return;
    }
    await _channel.invokeMethod<void>('openExternalUrl', {'url': url});
  }

  @override
  Future<String?> chooseImportFile() async {
    if (!Platform.isMacOS) {
      return null;
    }
    return _channel.invokeMethod<String>('chooseImportFile');
  }

  @override
  Future<String?> chooseExportFile() async {
    if (!Platform.isMacOS) {
      return null;
    }
    return _channel.invokeMethod<String>('chooseExportFile');
  }

  @override
  Future<void> cancelCommand(String taskId) async {
    if (!Platform.isMacOS) {
      return;
    }
    await _channel.invokeMethod<void>('cancelCommand', {'taskId': taskId});
  }

  @override
  void setCommandLogListener(CommandLogListener? listener) {
    _logListener = listener;
  }

  @override
  Future<CommandResult> runCommand(
    String command, {
    required String taskId,
    required bool runInTerminal,
  }) async {
    if (!Platform.isMacOS) {
      throw UnsupportedError(
        'Command execution is only implemented for macOS.',
      );
    }
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'runCommand',
      {'command': command, 'taskId': taskId, 'runInTerminal': runInTerminal},
    );
    return CommandResult.fromJson(result ?? const {});
  }
}

class ShuttleHomePage extends StatefulWidget {
  const ShuttleHomePage({
    super.key,
    required this.launchedAtLogin,
    required this.store,
    required this.platform,
    required this.appVersionLoader,
  });

  final bool launchedAtLogin;
  final ShuttleStore store;
  final ShuttlePlatform platform;
  final AppVersionLoader appVersionLoader;

  @override
  State<ShuttleHomePage> createState() => _ShuttleHomePageState();
}

class _ShuttleHomePageState extends State<ShuttleHomePage> {
  static const _maxLogEntriesPerConfig = 1000;

  var _configs = <ShuttleConfig>[];
  var _loading = true;
  var _loginItemEnabled = false;
  var _appVersion = _fallbackAppVersion;
  String? _selectedCategory;
  var _showRunningOnly = false;
  final _runningConfigs = <String, String>{};
  final _stoppingConfigIds = <String>{};
  final _logNotifiers = <String, ValueNotifier<List<CommandLogEntry>>>{};

  @override
  void initState() {
    super.initState();
    widget.platform.setCommandLogListener(_appendCommandLog);
    _loadAppVersion();
    _load();
  }

  @override
  void dispose() {
    widget.platform.setCommandLogListener(null);
    for (final notifier in _logNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final configs = await widget.store.loadConfigs();
    final loginItemEnabled = await widget.platform.getLoginItemEnabled();
    if (!mounted) {
      return;
    }
    setState(() {
      _configs = configs;
      _loginItemEnabled = loginItemEnabled;
      _loading = false;
    });

    if (widget.launchedAtLogin) {
      await _runLoginConfigs(configs);
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final appVersion = await widget.appVersionLoader();
      if (!mounted) {
        return;
      }
      setState(() => _appVersion = appVersion);
    } catch (_) {
      // Keep the fallback version visible if package metadata is unavailable.
    }
  }

  Future<void> _runLoginConfigs(List<ShuttleConfig> configs) async {
    final startupConfigs = configs
        .where((config) => config.runAtLogin)
        .toList();
    for (final config in startupConfigs) {
      await _runConfig(config, showSnackBar: false);
    }
    if (startupConfigs.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.of(context).loginConfigsRan(startupConfigs.length),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveConfigs(List<ShuttleConfig> configs) async {
    final categories = _categoriesFor(configs);
    setState(() {
      _configs = configs;
      if (_selectedCategory != null &&
          !categories.contains(_selectedCategory)) {
        _selectedCategory = null;
      }
    });
    await widget.store.saveConfigs(configs);
  }

  List<String> _categoriesFor(List<ShuttleConfig> configs) {
    final categories =
        configs
            .map((config) => _normalizedCategory(config.category))
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }

  String _normalizedCategory(String category) {
    final trimmed = category.trim();
    return trimmed.isEmpty ? _defaultCategory : trimmed;
  }

  Future<void> _setLoginItemEnabled(bool enabled) async {
    final previous = _loginItemEnabled;
    setState(() => _loginItemEnabled = enabled);
    try {
      await widget.platform.setLoginItemEnabled(enabled);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loginItemEnabled = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).loginUpdateFailed(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _runConfig(
    ShuttleConfig config, {
    bool showSnackBar = true,
  }) async {
    if (config.runInTerminal) {
      final result = await widget.platform.runCommand(
        config.command,
        taskId: config.id,
        runInTerminal: true,
      );
      if (!mounted || !showSnackBar) {
        return;
      }
      if (!result.succeeded) {
        final details = result.error.trim().isNotEmpty
            ? result.error.trim()
            : result.output.trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              details.isEmpty
                  ? AppStrings.of(context).runFailed(config.name)
                  : details,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    if (_runningConfigs.containsKey(config.id)) {
      await _stopConfig(config);
      return;
    }
    _appendCommandLog(
      CommandLogEntry(
        taskId: config.id,
        stream: CommandOutputStream.system,
        message: 'Started: ${config.command}',
        timestamp: DateTime.now(),
      ),
    );
    _runningConfigs[config.id] = config.name;
    setState(() {});
    await _syncRunningConfigs();
    try {
      final result = await widget.platform.runCommand(
        config.command,
        taskId: config.id,
        runInTerminal: config.runInTerminal,
      );
      if (!mounted) {
        return;
      }
      final strings = AppStrings.of(context);
      final wasStopped = _stoppingConfigIds.remove(config.id);
      final message = wasStopped
          ? '${strings.stopped}: ${config.name}'
          : result.succeeded
          ? strings.runCompleted(config.name)
          : strings.runFailed(config.name);
      _appendCommandLog(
        CommandLogEntry(
          taskId: config.id,
          stream: CommandOutputStream.system,
          message: message,
          timestamp: DateTime.now(),
        ),
      );
      if (showSnackBar) {
        final details = result.succeeded
            ? result.output.trim()
            : result.error.trim().isNotEmpty
            ? result.error.trim()
            : result.output.trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(details.isEmpty ? message : '$message\n$details'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _runningConfigs.remove(config.id);
      if (mounted) {
        setState(() {});
      }
      await _syncRunningConfigs();
    }
  }

  Future<void> _stopConfig(ShuttleConfig config) async {
    _stoppingConfigIds.add(config.id);
    _appendCommandLog(
      CommandLogEntry(
        taskId: config.id,
        stream: CommandOutputStream.system,
        message: 'Stopping...',
        timestamp: DateTime.now(),
      ),
    );
    await widget.platform.cancelCommand(config.id);
    if (!mounted) {
      return;
    }
  }

  ValueNotifier<List<CommandLogEntry>> _logsFor(String configId) {
    return _logNotifiers.putIfAbsent(
      configId,
      () => ValueNotifier<List<CommandLogEntry>>(const []),
    );
  }

  void _appendCommandLog(CommandLogEntry entry) {
    if (entry.taskId.isEmpty || entry.message.isEmpty) {
      return;
    }
    final notifier = _logsFor(entry.taskId);
    final next = [...notifier.value, entry];
    notifier.value = next.length > _maxLogEntriesPerConfig
        ? next.sublist(next.length - _maxLogEntriesPerConfig)
        : next;
  }

  void _clearLogs(String configId) {
    _logsFor(configId).value = const [];
  }

  Future<void> _openLogs(ShuttleConfig config) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _CommandLogPage(
          config: config,
          logs: _logsFor(config.id),
          isRunning: _runningConfigs.containsKey(config.id),
          onRun: () => _runConfig(config),
          onClear: () => _clearLogs(config.id),
        ),
      ),
    );
  }

  Future<void> _syncRunningConfigs() {
    return widget.platform.updateRunningConfigs(
      _runningConfigs.values.toList(),
    );
  }

  Future<void> _editConfig([ShuttleConfig? config]) async {
    final edited = await showDialog<ShuttleConfig>(
      context: context,
      builder: (context) => _ConfigDialog(
        config: config,
        defaultCategory: config == null ? _selectedCategory : null,
      ),
    );
    if (edited == null) {
      return;
    }
    if (config == null) {
      await _saveConfigs([..._configs, edited]);
    } else {
      await _saveConfigs(
        _configs.map((item) => item.id == edited.id ? edited : item).toList(),
      );
    }
  }

  Future<void> _deleteConfig(ShuttleConfig config) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDeleteDialog(
        title: strings.deleteConfig,
        message: strings.deleteConfigMessage(config.name),
        cancelLabel: strings.cancel,
        deleteLabel: strings.delete,
      ),
    );
    if (confirmed != true) {
      return;
    }
    await _saveConfigs(_configs.where((item) => item.id != config.id).toList());
  }

  Future<void> _toggleConfigLogin(ShuttleConfig config, bool value) async {
    final updated = config.copyWith(runAtLogin: value);
    await _saveConfigs(
      _configs.map((item) => item.id == config.id ? updated : item).toList(),
    );
  }

  Future<void> _openAbout() {
    return widget.platform.openExternalUrl(_aboutUrl);
  }

  Future<void> _exportConfigs() async {
    final strings = AppStrings.of(context);
    try {
      final path = await widget.platform.chooseExportFile();
      if (path == null) {
        return;
      }
      final file = File(path);
      await file.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(_configs.map((config) => config.toJson()).toList()),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.exportSucceeded),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.exportFailed(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _importConfigs() async {
    final strings = AppStrings.of(context);
    try {
      final path = await widget.platform.chooseImportFile();
      if (path == null) {
        return;
      }
      final raw = await File(path).readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('Expected a JSON array.');
      }
      final configs = decoded
          .whereType<Map<String, dynamic>>()
          .map(ShuttleConfig.fromJson)
          .toList();
      setState(() {
        _selectedCategory = null;
        _showRunningOnly = false;
      });
      await _saveConfigs(configs);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.importSucceeded),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.importFailed(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoriesFor(_configs);
    final visibleConfigs = _showRunningOnly
        ? _configs
              .where((config) => _runningConfigs.containsKey(config.id))
              .toList()
        : _selectedCategory == null
        ? _configs
        : _configs
              .where(
                (config) =>
                    _normalizedCategory(config.category) == _selectedCategory,
              )
              .toList();
    return Scaffold(
      backgroundColor: _MacColors.windowBackground,
      body: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth < 860
                    ? 860.0
                    : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: contentWidth,
                    child: Row(
                      children: [
                        _Sidebar(
                          loginItemEnabled: _loginItemEnabled,
                          appVersion: _appVersion,
                          runningCount: _runningConfigs.length,
                          categories: categories,
                          selectedCategory: _selectedCategory,
                          selectedRunning: _showRunningOnly,
                          onLoginItemChanged: _setLoginItemEnabled,
                          onRunningSelected: () => setState(() {
                            _showRunningOnly = true;
                            _selectedCategory = null;
                          }),
                          onCategorySelected: (category) => setState(() {
                            _showRunningOnly = false;
                            _selectedCategory = category;
                          }),
                          onImport: _importConfigs,
                          onExport: _exportConfigs,
                          onAbout: () {
                            _openAbout();
                          },
                        ),
                        const VerticalDivider(
                          width: 1,
                          color: _MacColors.separator,
                        ),
                        Expanded(
                          child: _ContentPane(
                            configs: visibleConfigs,
                            runningConfigIds: _runningConfigs.keys.toSet(),
                            selectedCategory: _selectedCategory,
                            showingRunningOnly: _showRunningOnly,
                            onAdd: () => _editConfig(),
                            onRun: _runConfig,
                            onOpenLogs: _openLogs,
                            onEdit: _editConfig,
                            onDelete: _deleteConfig,
                            onRunAtLoginChanged: _toggleConfigLogin,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _MacColors {
  static const windowBackground = Color(0xFFF5F5F7);
  static const sidebarBackground = Color(0xFFEDEEF2);
  static const panelBackground = Color(0xFFFFFFFF);
  static const separator = Color(0xFFD7D7DB);
  static const primaryText = Color(0xFF1D1D1F);
  static const secondaryText = Color(0xFF6E6E73);
  static const blue = Color(0xFF007AFF);
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.loginItemEnabled,
    required this.appVersion,
    required this.runningCount,
    required this.categories,
    required this.selectedCategory,
    required this.selectedRunning,
    required this.onLoginItemChanged,
    required this.onRunningSelected,
    required this.onCategorySelected,
    required this.onImport,
    required this.onExport,
    required this.onAbout,
  });

  final bool loginItemEnabled;
  final String appVersion;
  final int runningCount;
  final List<String> categories;
  final String? selectedCategory;
  final bool selectedRunning;
  final ValueChanged<bool> onLoginItemChanged;
  final VoidCallback onRunningSelected;
  final ValueChanged<String?> onCategorySelected;
  final VoidCallback onImport;
  final VoidCallback onExport;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Container(
      width: 260,
      color: _MacColors.sidebarBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.appName,
                style: TextStyle(
                  color: _MacColors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              _SidebarRow(
                icon: Icons.power_settings_new,
                title: strings.launchAtLogin,
                trailing: CupertinoSwitch(
                  value: loginItemEnabled,
                  activeTrackColor: _MacColors.blue,
                  onChanged: onLoginItemChanged,
                ),
              ),
              const SizedBox(height: 10),
              _SidebarRow(
                icon: Icons.bolt,
                title: strings.running,
                trailing: _CountBadge(value: runningCount),
                selected: selectedRunning,
                onTap: onRunningSelected,
              ),
              const SizedBox(height: 22),
              Text(
                strings.categories,
                style: const TextStyle(
                  color: _MacColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _CategoryRow(
                      title: strings.allCategories,
                      count: null,
                      selected: selectedCategory == null && !selectedRunning,
                      onTap: () => onCategorySelected(null),
                    ),
                    for (final category in categories)
                      _CategoryRow(
                        title: category,
                        count: null,
                        selected: selectedCategory == category,
                        onTap: () => onCategorySelected(category),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SidebarUtilityButton(
                      icon: Icons.file_open_outlined,
                      label: strings.importConfigs,
                      onTap: onImport,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SidebarUtilityButton(
                      icon: Icons.ios_share_outlined,
                      label: strings.exportConfigs,
                      onTap: onExport,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SidebarFooter(
                versionLabel: '${strings.version} $appVersion',
                aboutLabel: strings.about,
                onAbout: onAbout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.icon,
    required this.title,
    required this.trailing,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 42,
      padding: const EdgeInsets.only(left: 10, right: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.white : const Color(0x94FFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? _MacColors.blue : _MacColors.secondaryText,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _MacColors.primaryText,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
    if (onTap == null) {
      return content;
    }
    return CupertinoButton(
      minimumSize: const Size(0, 42),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(8),
      onPressed: onTap,
      child: content,
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.title,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: CupertinoButton(
        minimumSize: const Size(0, 34),
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(8),
        onPressed: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.folder : Icons.folder_outlined,
                size: 17,
                color: selected ? _MacColors.blue : _MacColors.secondaryText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? _MacColors.primaryText
                        : _MacColors.secondaryText,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (count != null)
                Text(
                  '$count',
                  style: const TextStyle(
                    color: _MacColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({
    required this.versionLabel,
    required this.aboutLabel,
    required this.onAbout,
  });

  final String versionLabel;
  final String aboutLabel;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0x94FFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x66FFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              versionLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _MacColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: aboutLabel,
            child: CupertinoButton(
              minimumSize: const Size.square(28),
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(7),
              color: const Color(0xFFE4E5EA),
              onPressed: onAbout,
              child: const Icon(
                Icons.info_outline,
                size: 16,
                color: _MacColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarUtilityButton extends StatelessWidget {
  const _SidebarUtilityButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: CupertinoButton(
        minimumSize: const Size(0, 32),
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(8),
        onPressed: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: const Color(0x94FFFFFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: _MacColors.secondaryText),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _MacColors.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      height: 22,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: value == 0 ? const Color(0xFFDADBE0) : _MacColors.blue,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        '$value',
        style: TextStyle(
          color: value == 0 ? _MacColors.secondaryText : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ContentPane extends StatelessWidget {
  const _ContentPane({
    required this.configs,
    required this.runningConfigIds,
    required this.selectedCategory,
    required this.showingRunningOnly,
    required this.onAdd,
    required this.onRun,
    required this.onOpenLogs,
    required this.onEdit,
    required this.onDelete,
    required this.onRunAtLoginChanged,
  });

  final List<ShuttleConfig> configs;
  final Set<String> runningConfigIds;
  final String? selectedCategory;
  final bool showingRunningOnly;
  final VoidCallback onAdd;
  final ValueChanged<ShuttleConfig> onRun;
  final ValueChanged<ShuttleConfig> onOpenLogs;
  final ValueChanged<ShuttleConfig> onEdit;
  final ValueChanged<ShuttleConfig> onDelete;
  final void Function(ShuttleConfig config, bool value) onRunAtLoginChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Toolbar(
              selectedCategory: selectedCategory,
              showingRunningOnly: showingRunningOnly,
              onAdd: onAdd,
            ),
            const SizedBox(height: 18),
            if (configs.isEmpty)
              const Expanded(child: _EmptyState())
            else
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _MacColors.panelBackground,
                      border: Border.all(color: _MacColors.separator),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.separated(
                      itemCount: configs.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 72,
                        color: _MacColors.separator,
                      ),
                      itemBuilder: (context, index) {
                        final config = configs[index];
                        return _ConfigRow(
                          config: config,
                          isRunning: runningConfigIds.contains(config.id),
                          onRun: () => onRun(config),
                          onOpenLogs: () => onOpenLogs(config),
                          onEdit: () => onEdit(config),
                          onDelete: () => onDelete(config),
                          onRunAtLoginChanged: (value) =>
                              onRunAtLoginChanged(config, value),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.selectedCategory,
    required this.showingRunningOnly,
    required this.onAdd,
  });

  final String? selectedCategory;
  final bool showingRunningOnly;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(
              showingRunningOnly
                  ? strings.running
                  : selectedCategory ?? strings.shortcuts,
              style: const TextStyle(
                color: _MacColors.primaryText,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _MacToolbarButton(
            tooltip: strings.addConfig,
            icon: Icons.add,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({
    required this.config,
    required this.isRunning,
    required this.onRun,
    required this.onOpenLogs,
    required this.onEdit,
    required this.onDelete,
    required this.onRunAtLoginChanged,
  });

  final ShuttleConfig config;
  final bool isRunning;
  final VoidCallback onRun;
  final VoidCallback onOpenLogs;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onRunAtLoginChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return ColoredBox(
      color: _MacColors.panelBackground,
      child: SizedBox(
        height: 82,
        child: Row(
          children: [
            const SizedBox(width: 14),
            _RoundIconButton(
              tooltip: isRunning ? strings.stop : strings.run,
              icon: isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: isRunning ? const Color(0xFFFF3B30) : _MacColors.blue,
              onPressed: onRun,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          config.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _MacColors.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CategoryBadge(label: config.category),
                      if (config.runInTerminal) ...[
                        const SizedBox(width: 6),
                        _TerminalBadge(label: strings.runInTerminal),
                      ],
                      if (config.runAtLogin) ...[
                        const SizedBox(width: 6),
                        _LaunchAtLoginBadge(label: strings.runAfterLogin),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    config.command,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _MacColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(width: 18),
            // CupertinoSwitch(
            //   value: config.runAtLogin,
            //   activeTrackColor: _MacColors.blue,
            //   onChanged: onRunAtLoginChanged,
            // ),
            const SizedBox(width: 12),
            _RoundIconButton(
              tooltip: strings.logs,
              icon: Icons.article_outlined,
              color: _MacColors.secondaryText,
              onPressed: onOpenLogs,
            ),
            const SizedBox(width: 6),
            _RoundIconButton(
              tooltip: strings.edit,
              icon: Icons.edit_outlined,
              color: _MacColors.secondaryText,
              onPressed: onEdit,
            ),
            const SizedBox(width: 6),
            _RoundIconButton(
              tooltip: strings.delete,
              icon: Icons.delete_outline,
              color: const Color(0xFFFF3B30),
              onPressed: onDelete,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _MacToolbarButton extends StatelessWidget {
  const _MacToolbarButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: CupertinoButton(
        minimumSize: const Size.square(32),
        padding: EdgeInsets.zero,
        color: const Color(0xFFE4E5EA),
        borderRadius: BorderRadius.circular(7),
        onPressed: onPressed,
        child: Icon(icon, size: 19, color: _MacColors.primaryText),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label.trim().isEmpty ? _defaultCategory : label.trim(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _MacColors.blue,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TerminalBadge extends StatelessWidget {
  const _TerminalBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F4),
          borderRadius: BorderRadius.circular(7),
        ),
        child: const Icon(
          Icons.terminal_rounded,
          size: 12,
          color: _MacColors.secondaryText,
        ),
      ),
    );
  }
}

class _LaunchAtLoginBadge extends StatelessWidget {
  const _LaunchAtLoginBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F4),
          borderRadius: BorderRadius.circular(7),
        ),
        child: const Icon(
          Icons.login_rounded,
          size: 12,
          color: _MacColors.secondaryText,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: CupertinoButton(
        minimumSize: const Size.square(32),
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        onPressed: onPressed,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF0F1F4),
          ),
          child: SizedBox.square(
            dimension: 32,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

class _CommandLogPage extends StatefulWidget {
  const _CommandLogPage({
    required this.config,
    required this.logs,
    required this.isRunning,
    required this.onRun,
    required this.onClear,
  });

  final ShuttleConfig config;
  final ValueListenable<List<CommandLogEntry>> logs;
  final bool isRunning;
  final VoidCallback onRun;
  final VoidCallback onClear;

  @override
  State<_CommandLogPage> createState() => _CommandLogPageState();
}

class _CommandLogPageState extends State<_CommandLogPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      backgroundColor: _MacColors.windowBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    _MacToolbarButton(
                      tooltip: strings.cancel,
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        strings.logTitle(widget.config.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _MacColors.primaryText,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _MacToolbarButton(
                      tooltip: widget.isRunning ? strings.stop : strings.run,
                      icon: widget.isRunning
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      onPressed: widget.onRun,
                    ),
                    const SizedBox(width: 8),
                    _MacToolbarButton(
                      tooltip: strings.clearLogs,
                      icon: Icons.delete_sweep_outlined,
                      onPressed: widget.onClear,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.config.command,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _MacColors.secondaryText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111315),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF25292D)),
                  ),
                  child: ValueListenableBuilder<List<CommandLogEntry>>(
                    valueListenable: widget.logs,
                    builder: (context, entries, child) {
                      _scrollToBottom();
                      if (entries.isEmpty) {
                        return Center(
                          child: Text(
                            strings.noLogsYet,
                            style: const TextStyle(
                              color: Color(0xFF9BA3AC),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(14),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          return _CommandLogLine(entry: entries[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandLogLine extends StatelessWidget {
  const _CommandLogLine({required this.entry});

  final CommandLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final timestamp = entry.timestamp ?? DateTime.now();
    final streamLabel = switch (entry.stream) {
      CommandOutputStream.stdout => AppStrings.of(context).stdout,
      CommandOutputStream.stderr => AppStrings.of(context).stderr,
      CommandOutputStream.system => 'system',
    };
    final streamColor = switch (entry.stream) {
      CommandOutputStream.stdout => const Color(0xFFB7F7C5),
      CommandOutputStream.stderr => const Color(0xFFFFC1BA),
      CommandOutputStream.system => const Color(0xFFAAD8FF),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SelectableText.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${_formatLogTime(timestamp)} ',
              style: const TextStyle(color: Color(0xFF7E8790)),
            ),
            TextSpan(
              text: '[$streamLabel] ',
              style: TextStyle(color: streamColor, fontWeight: FontWeight.w700),
            ),
            TextSpan(text: entry.message),
          ],
        ),
        style: const TextStyle(
          color: Color(0xFFE5E7EB),
          fontSize: 12,
          height: 1.35,
          fontFamily: 'Menlo',
        ),
      ),
    );
  }

  String _formatLogTime(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return [
      twoDigits(value.hour),
      twoDigits(value.minute),
      twoDigits(value.second),
    ].join(':');
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _MacColors.panelBackground,
          border: Border.all(color: _MacColors.separator),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.terminal_rounded,
                size: 36,
                color: _MacColors.secondaryText,
              ),
              const SizedBox(height: 12),
              Text(
                strings.emptyTitle,
                style: const TextStyle(
                  color: _MacColors.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                strings.emptySubtitle,
                style: const TextStyle(
                  color: _MacColors.secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigDialog extends StatefulWidget {
  const _ConfigDialog({this.config, this.defaultCategory});

  final ShuttleConfig? config;
  final String? defaultCategory;

  @override
  State<_ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<_ConfigDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _commandController;
  late bool _runAtLogin;
  late bool _runInTerminal;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.config?.name ?? '');
    _categoryController = TextEditingController(
      text:
          widget.config?.category ?? widget.defaultCategory ?? _defaultCategory,
    );
    _commandController = TextEditingController(
      text: widget.config?.command ?? '',
    );
    _runAtLogin = widget.config?.runAtLogin ?? false;
    _runInTerminal = widget.config?.runInTerminal ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final command = _commandController.text.trim();
    if (name.isEmpty || command.isEmpty) {
      return;
    }
    Navigator.of(context).pop(
      ShuttleConfig(
        id:
            widget.config?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        category: category.isEmpty ? _defaultCategory : category,
        command: command,
        runAtLogin: _runAtLogin,
        runInTerminal: _runInTerminal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _MacColors.panelBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _MacColors.separator),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.config == null ? strings.newConfig : strings.editConfig,
              style: const TextStyle(
                color: _MacColors.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            _MacTextField(
              controller: _nameController,
              autofocus: true,
              label: strings.name,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            _MacTextField(
              controller: _categoryController,
              label: strings.category,
              hintText: _defaultCategory,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            _MacTextField(
              controller: _commandController,
              label: strings.command,
              hintText: 'ssh user@example.com',
              minLines: 6,
              maxLines: 10,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.runThisAfterLogin,
                    style: const TextStyle(
                      color: _MacColors.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: _runAtLogin,
                  activeTrackColor: _MacColors.blue,
                  onChanged: (value) => setState(() => _runAtLogin = value),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.runInTerminal,
                    style: const TextStyle(
                      color: _MacColors.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: _runInTerminal,
                  activeTrackColor: _MacColors.blue,
                  onChanged: (value) => setState(() => _runInTerminal = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogButton(
                  label: strings.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                _DialogButton(
                  label: strings.save,
                  emphasized: true,
                  onPressed: _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.deleteLabel,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _MacColors.panelBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _MacColors.separator),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _MacColors.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                color: _MacColors.secondaryText,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogButton(
                  label: cancelLabel,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: 8),
                _DialogButton(
                  label: deleteLabel,
                  destructive: true,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacTextField extends StatelessWidget {
  const _MacTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.autofocus = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool autofocus;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: _MacColors.primaryText, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        labelStyle: const TextStyle(color: _MacColors.secondaryText),
        hintStyle: const TextStyle(color: Color(0xFF9A9AA0)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: _MacColors.separator),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: _MacColors.blue, width: 1.4),
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onPressed,
    this.emphasized = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool emphasized;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minimumSize: const Size(0, 30),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      color: destructive
          ? const Color(0xFFFF3B30)
          : emphasized
          ? _MacColors.blue
          : const Color(0xFFE6E6EA),
      borderRadius: BorderRadius.circular(7),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: emphasized || destructive
              ? Colors.white
              : _MacColors.primaryText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
