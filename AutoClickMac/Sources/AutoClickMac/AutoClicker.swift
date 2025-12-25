import AppKit
import Carbon
import Foundation

class AutoClicker: ObservableObject {
    @Published var clicksPerSecond: Double = 10
    @Published var isClicking: Bool = false
    @Published var isTrusted: Bool = AXIsProcessTrusted()

    private var timer: Timer?
    private var globalMonitor: Any?
    private var localMonitor: Any?

    init() {
        print("AutoClicker initialized")
        checkPermissions()

        // Monitor global key events (Space bar)
        // Note: This requires Accessibility permissions in System Settings
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
            self?.handleKeyEvent(event)
        }

        // Also monitor local events in case the app is focused
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
    }

    func checkPermissions() {
        isTrusted = AXIsProcessTrusted()
        print("Accessibility Trusted: \(isTrusted)")
    }

    private func handleKeyEvent(_ event: NSEvent) {
        // 49 is the key code for Space
        guard event.keyCode == 49 else { return }

        if event.type == .keyDown {
            if !isClicking && !event.isARepeat {
                print("Space pressed, starting clicking")
                startClicking()
            }
        } else if event.type == .keyUp {
            if isClicking {
                print("Space released, stopping clicking")
                stopClicking()
            }
        }
    }

    private func startClicking() {
        DispatchQueue.main.async {
            self.isClicking = true
        }

        // Calculate interval. Ensure it's not zero.
        let cps = max(clicksPerSecond, 1.0)
        let interval = 1.0 / cps

        print("Starting timer with interval: \(interval)")
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.performClick()
        }
    }

    private func stopClicking() {
        DispatchQueue.main.async {
            self.isClicking = false
        }
        timer?.invalidate()
        timer = nil
        print("Stopped clicking")
    }

    private func performClick() {
        // Get current mouse location using CGEvent which is already in the correct coordinate system
        guard let currentPos = CGEvent(source: nil)?.location else {
            print("Failed to get mouse location")
            return
        }

        // Create mouse down event
        guard
            let eventDown = CGEvent(
                mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: currentPos,
                mouseButton: .left)
        else { return }
        eventDown.post(tap: .cghidEventTap)

        // Create mouse up event
        guard
            let eventUp = CGEvent(
                mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: currentPos,
                mouseButton: .left)
        else { return }
        eventUp.post(tap: .cghidEventTap)
    }

    deinit {
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
    }
}
