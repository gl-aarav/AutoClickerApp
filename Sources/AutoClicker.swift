import Cocoa
import Foundation

class AutoClicker: ObservableObject {
    @Published var isClicking = false
    @Published var clickCount: Int = 0
    @Published var clicksPerSecond: Double = 10.0
    @Published var isEnabled = true

    private var clickTimer: DispatchSourceTimer?
    private var flagsMonitor: Any?
    private var lastClickTime: Date?

    init() {
        setupKeyMonitor()
    }

    deinit {
        stop()
        if let monitor = flagsMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func setupKeyMonitor() {
        // Monitor for modifier key changes (Option key)
        flagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) {
            [weak self] event in
            self?.handleFlagsChanged(event)
        }

        // Also monitor local events (when app is focused)
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
            return event
        }

        print("✅ Key monitor setup complete")
    }

    private func handleFlagsChanged(_ event: NSEvent) {
        guard isEnabled else { return }

        let optionPressed = event.modifierFlags.contains(.option)

        DispatchQueue.main.async { [weak self] in
            if optionPressed && !(self?.isClicking ?? false) {
                self?.start()
            } else if !optionPressed && (self?.isClicking ?? false) {
                self?.stop()
            }
        }
    }

    func start() {
        guard !isClicking else { return }

        isClicking = true
        clickCount = 0
        lastClickTime = Date()

        print("🖱️ Auto-clicking started at \(clicksPerSecond) CPS")

        // Calculate interval in nanoseconds
        let intervalNanos = UInt64(1_000_000_000.0 / clicksPerSecond)

        // Create a high-precision timer
        let timer = DispatchSource.makeTimerSource(
            flags: .strict, queue: DispatchQueue.global(qos: .userInteractive))
        timer.schedule(
            deadline: .now(), repeating: .nanoseconds(Int(intervalNanos)), leeway: .nanoseconds(0))

        timer.setEventHandler { [weak self] in
            self?.performClick()
        }

        clickTimer = timer
        timer.resume()
    }

    func stop() {
        guard isClicking else { return }

        clickTimer?.cancel()
        clickTimer = nil
        isClicking = false

        print("🛑 Auto-clicking stopped. Total clicks: \(clickCount)")
    }

    private func performClick() {
        // Get current mouse location from CGEvent (more reliable)
        guard let eventSource = CGEventSource(stateID: .hidSystemState) else { return }
        let mouseLocation = CGEvent(source: nil)?.location ?? .zero

        // Create mouse down event for LEFT click
        guard
            let mouseDown = CGEvent(
                mouseEventSource: eventSource,
                mouseType: .leftMouseDown,
                mouseCursorPosition: mouseLocation,
                mouseButton: .left
            )
        else { return }

        // Create mouse up event for LEFT click
        guard
            let mouseUp = CGEvent(
                mouseEventSource: eventSource,
                mouseType: .leftMouseUp,
                mouseCursorPosition: mouseLocation,
                mouseButton: .left
            )
        else { return }

        // Explicitly set the button number to 0 (left button)
        mouseDown.setIntegerValueField(.mouseEventButtonNumber, value: 0)
        mouseUp.setIntegerValueField(.mouseEventButtonNumber, value: 0)

        // Post the events
        mouseDown.post(tap: .cghidEventTap)
        mouseUp.post(tap: .cghidEventTap)

        // Update click count on main thread
        DispatchQueue.main.async { [weak self] in
            self?.clickCount += 1
        }
    }

    func setClickSpeed(_ cps: Double) {
        clicksPerSecond = max(1.0, min(100.0, cps))

        // If currently clicking, restart with new speed
        if isClicking {
            stop()
            start()
        }
    }

    func toggle() {
        isEnabled.toggle()
        if !isEnabled && isClicking {
            stop()
        }
    }
}
