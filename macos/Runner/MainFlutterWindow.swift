import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private static let minimumWindowSize = NSSize(width: 860, height: 560)

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let launchBackgroundColor = NSColor(
      calibratedRed: 245.0 / 255.0,
      green: 245.0 / 255.0,
      blue: 247.0 / 255.0,
      alpha: 1
    )
    let windowFrame = self.frame
    let windowSize = NSSize(
      width: max(windowFrame.width, MainFlutterWindow.minimumWindowSize.width),
      height: max(windowFrame.height, MainFlutterWindow.minimumWindowSize.height)
    )
    let adjustedWindowFrame = NSRect(
      x: windowFrame.midX - windowSize.width / 2,
      y: windowFrame.midY - windowSize.height / 2,
      width: windowSize.width,
      height: windowSize.height
    )
    self.backgroundColor = launchBackgroundColor
    flutterViewController.backgroundColor = launchBackgroundColor
    self.contentViewController = flutterViewController
    self.setFrame(adjustedWindowFrame, display: true)
    self.minSize = MainFlutterWindow.minimumWindowSize
    self.isReleasedWhenClosed = false

    RegisterGeneratedPlugins(registry: flutterViewController)
    ShuttleMacOSBridge.register(with: flutterViewController)

    super.awakeFromNib()
  }
}

final class ShuttleMacOSBridge {
  private static let channelName = "flutter_shuttle/macos"
  private static let launchAgentLabel = "com.fluttershuttle.loginitem"
  private static let loginLaunchFlag = "--launched-at-login"
  private static var channel: FlutterMethodChannel?
  private static var runningProcesses: [String: Process] = [:]

  static func register(with flutterViewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    self.channel = channel
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getLoginItemEnabled":
        result(FileManager.default.fileExists(atPath: launchAgentURL.path))
      case "setLoginItemEnabled":
        guard
          let arguments = call.arguments as? [String: Any],
          let enabled = arguments["enabled"] as? Bool
        else {
          result(FlutterError(code: "bad_arguments", message: "Missing enabled flag.", details: nil))
          return
        }
        do {
          if enabled {
            try enableLoginItem()
          } else {
            try disableLoginItem()
          }
          result(nil)
        } catch {
          result(FlutterError(code: "login_item_error", message: error.localizedDescription, details: nil))
        }
      case "runCommand":
        guard
          let arguments = call.arguments as? [String: Any],
          let command = arguments["command"] as? String,
          let taskId = arguments["taskId"] as? String
        else {
          result(FlutterError(code: "bad_arguments", message: "Missing command or task id.", details: nil))
          return
        }
        let runInTerminal = arguments["runInTerminal"] as? Bool ?? false
        if runInTerminal {
          runCommandInTerminal(command, result: result)
        } else {
          runCommand(command, taskId: taskId, result: result)
        }
      case "cancelCommand":
        guard
          let arguments = call.arguments as? [String: Any],
          let taskId = arguments["taskId"] as? String
        else {
          result(FlutterError(code: "bad_arguments", message: "Missing task id.", details: nil))
          return
        }
        cancelCommand(taskId)
        result(nil)
      case "updateRunningConfigs":
        guard
          let arguments = call.arguments as? [String: Any],
          let names = arguments["names"] as? [String]
        else {
          result(FlutterError(code: "bad_arguments", message: "Missing running config names.", details: nil))
          return
        }
        StatusBarController.shared.updateRunningConfigs(names)
        result(nil)
      case "openExternalUrl":
        guard
          let arguments = call.arguments as? [String: Any],
          let rawUrl = arguments["url"] as? String,
          let url = URL(string: rawUrl)
        else {
          result(FlutterError(code: "bad_arguments", message: "Missing or invalid URL.", details: nil))
          return
        }
        result(NSWorkspace.shared.open(url))
      case "chooseImportFile":
        result(chooseImportFile())
      case "chooseExportFile":
        result(chooseExportFile())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static var launchAgentURL: URL {
    let home = FileManager.default.homeDirectoryForCurrentUser
    return home
      .appendingPathComponent("Library")
      .appendingPathComponent("LaunchAgents")
      .appendingPathComponent("\(launchAgentLabel).plist")
  }

  private static func enableLoginItem() throws {
    guard let executablePath = Bundle.main.executablePath else {
      throw NSError(
        domain: "FlutterShuttle",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unable to find app executable path."]
      )
    }

    let launchAgentsDirectory = launchAgentURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(
      at: launchAgentsDirectory,
      withIntermediateDirectories: true
    )

    let plist: [String: Any] = [
      "Label": launchAgentLabel,
      "ProgramArguments": [executablePath, loginLaunchFlag],
      "RunAtLoad": true
    ]
    let data = try PropertyListSerialization.data(
      fromPropertyList: plist,
      format: .xml,
      options: 0
    )
    try data.write(to: launchAgentURL, options: .atomic)
  }

  private static func disableLoginItem() throws {
    if FileManager.default.fileExists(atPath: launchAgentURL.path) {
      try FileManager.default.removeItem(at: launchAgentURL)
    }
  }

  private static func chooseImportFile() -> String? {
    let panel = NSOpenPanel()
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.allowsMultipleSelection = false
    panel.allowedFileTypes = ["json"]
    panel.title = "Import Shuttle Configurations"
    return panel.runModal() == .OK ? panel.url?.path : nil
  }

  private static func chooseExportFile() -> String? {
    let panel = NSSavePanel()
    panel.allowedFileTypes = ["json"]
    panel.nameFieldStringValue = "shuttle-configs.json"
    panel.title = "Export Shuttle Configurations"
    return panel.runModal() == .OK ? panel.url?.path : nil
  }

  private static func runCommand(_ command: String, taskId: String, result: @escaping FlutterResult) {
    let process = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    var output = ""
    var errorOutput = ""

    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    process.arguments = ["-lc", command]
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    outputPipe.fileHandleForReading.readabilityHandler = { handle in
      let data = handle.availableData
      guard !data.isEmpty else {
        return
      }
      let chunk = String(data: data, encoding: .utf8) ?? ""
      output += chunk
      emitCommandLog(taskId: taskId, stream: "stdout", message: chunk)
    }

    errorPipe.fileHandleForReading.readabilityHandler = { handle in
      let data = handle.availableData
      guard !data.isEmpty else {
        return
      }
      let chunk = String(data: data, encoding: .utf8) ?? ""
      errorOutput += chunk
      emitCommandLog(taskId: taskId, stream: "stderr", message: chunk)
    }

    process.terminationHandler = { process in
      outputPipe.fileHandleForReading.readabilityHandler = nil
      errorPipe.fileHandleForReading.readabilityHandler = nil

      DispatchQueue.main.async {
        runningProcesses.removeValue(forKey: taskId)
        result([
          "exitCode": Int(process.terminationStatus),
          "output": output,
          "error": errorOutput
        ])
      }
    }

    runningProcesses[taskId] = process
    do {
      try process.run()
    } catch {
      runningProcesses.removeValue(forKey: taskId)
      result(FlutterError(code: "run_command_error", message: error.localizedDescription, details: nil))
    }
  }

  private static func runCommandInTerminal(_ command: String, result: @escaping FlutterResult) {
    let process = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()

    process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    process.arguments = [
      "-e", "on run argv",
      "-e", "tell application \"Terminal\"",
      "-e", "activate",
      "-e", "do script item 1 of argv",
      "-e", "end tell",
      "-e", "end run",
      command
    ]
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    process.terminationHandler = { process in
      let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
      let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(data: outputData, encoding: .utf8) ?? ""
      let error = String(data: errorData, encoding: .utf8) ?? ""

      DispatchQueue.main.async {
        result([
          "exitCode": Int(process.terminationStatus),
          "output": output,
          "error": error
        ])
      }
    }

    do {
      try process.run()
    } catch {
      result(FlutterError(code: "run_terminal_error", message: error.localizedDescription, details: nil))
    }
  }

  private static func cancelCommand(_ taskId: String) {
    guard let process = runningProcesses[taskId] else {
      return
    }
    if process.isRunning {
      process.terminate()
    }
  }

  private static func emitCommandLog(taskId: String, stream: String, message: String) {
    DispatchQueue.main.async {
      channel?.invokeMethod("commandLog", arguments: [
        "taskId": taskId,
        "stream": stream,
        "message": message,
        "timestamp": ISO8601DateFormatter().string(from: Date())
      ])
    }
  }
}
