import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var autoClicker: AutoClicker!
    var mainViewController: MainViewController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the auto clicker
        autoClicker = AutoClicker()

        // Create main view controller
        mainViewController = MainViewController(autoClicker: autoClicker)

        // Create the window
        let windowRect = NSRect(x: 0, y: 0, width: 400, height: 500)
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "AutoClick"
        window.center()
        window.contentViewController = mainViewController
        window.minSize = NSSize(width: 350, height: 450)
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)

        // Activate the app
        NSApp.activate(ignoringOtherApps: true)

        // Request accessibility permissions
        requestAccessibilityPermissions()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        autoClicker.stop()
    }

    private func requestAccessibilityPermissions() {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ]
        let trusted = AXIsProcessTrustedWithOptions(options)

        if !trusted {
            print("⚠️ Accessibility permissions not granted. Please enable in System Preferences.")
        } else {
            print("✅ Accessibility permissions granted")
        }
    }
}
