import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private let statusBarController = StatusBarController.shared

  override func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.regular)
    statusBarController.show()
    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      for window in sender.windows where window is MainFlutterWindow {
        window.makeKeyAndOrderFront(nil)
        break
      }
    }
    return true
  }
}

final class StatusBarController: NSObject {
  static let shared = StatusBarController()

  private var statusItem: NSStatusItem?
  private var runningConfigNames: [String] = []

  func show() {
    guard statusItem == nil else {
      return
    }

    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    item.isVisible = true
    if let button = item.button {
      let image = StatusBarController.statusBarIcon()
      button.image = image
      button.imagePosition = .imageOnly
      button.toolTip = "Shuttle"
    }
    statusItem = item
    rebuildMenu()
  }

  func updateRunningConfigs(_ names: [String]) {
    runningConfigNames = names
    rebuildMenu()
  }

  private func rebuildMenu() {
    let strings = StatusBarStrings.current
    let menu = NSMenu()

    let runningHeader = NSMenuItem(title: strings.running, action: nil, keyEquivalent: "")
    runningHeader.isEnabled = false
    menu.addItem(runningHeader)

    if runningConfigNames.isEmpty {
      let emptyItem = NSMenuItem(title: strings.none, action: nil, keyEquivalent: "")
      emptyItem.isEnabled = false
      menu.addItem(emptyItem)
    } else {
      for name in runningConfigNames {
        let item = NSMenuItem(title: name, action: nil, keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
      }
    }

    menu.addItem(NSMenuItem.separator())
    let openItem = NSMenuItem(
      title: strings.openManagement,
      action: #selector(openMainWindow),
      keyEquivalent: ""
    )
    openItem.target = self
    menu.addItem(openItem)

    let quitItem = NSMenuItem(
      title: strings.quit,
      action: #selector(quit),
      keyEquivalent: "q"
    )
    quitItem.target = self
    menu.addItem(quitItem)

    statusItem?.menu = menu
  }

  @objc private func openMainWindow() {
    NSApp.activate(ignoringOtherApps: true)
    for window in NSApp.windows where window is MainFlutterWindow {
      window.makeKeyAndOrderFront(nil)
      return
    }
  }

  @objc private func quit() {
    NSApp.terminate(nil)
  }

  private static func statusBarIcon() -> NSImage {
    if let statusBarIcon = NSImage(named: "StatusIcon") {
      let statusIcon = NSImage(size: NSSize(width: 18, height: 18))
      statusIcon.lockFocus()
      statusBarIcon.draw(
        in: NSRect(x: 0, y: 0, width: 18, height: 18),
        from: .zero,
        operation: .sourceOver,
        fraction: 1
      )
      statusIcon.unlockFocus()
      statusIcon.isTemplate = false
      return statusIcon
    }
    return fallbackStatusImage()
  }

  private static func fallbackStatusImage() -> NSImage {
    let image = NSImage(size: NSSize(width: 18, height: 18))
    image.lockFocus()
    NSColor.black.setFill()
    let path = NSBezierPath()
    path.move(to: NSPoint(x: 2, y: 9))
    path.line(to: NSPoint(x: 16, y: 15))
    path.line(to: NSPoint(x: 11, y: 3))
    path.line(to: NSPoint(x: 8, y: 8))
    path.close()
    path.fill()
    image.unlockFocus()
    image.isTemplate = true
    return image
  }
}

private struct StatusBarStrings {
  let running: String
  let none: String
  let openManagement: String
  let quit: String

  static var current: StatusBarStrings {
    let languageCode = Locale.preferredLanguages.first?.split(separator: "-").first
    if languageCode == "zh" {
      return StatusBarStrings(
        running: "正在执行",
        none: "无",
        openManagement: "打开管理页面",
        quit: "退出 Shuttle"
      )
    }
    return StatusBarStrings(
      running: "Running",
      none: "None",
      openManagement: "Open Management Window",
      quit: "Quit Shuttle"
    )
  }
}
