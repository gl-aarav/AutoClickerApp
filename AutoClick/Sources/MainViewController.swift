import Cocoa

class MainViewController: NSViewController {
    private var autoClicker: AutoClicker
    private var statusLabel: NSTextField!
    private var clickCountLabel: NSTextField!
    private var speedSlider: NSSlider!
    private var speedLabel: NSTextField!
    private var enableButton: NSButton!
    private var statusIndicator: NSView!
    private var updateTimer: Timer?

    init(autoClicker: AutoClicker) {
        self.autoClicker = autoClicker
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 500))
        view.wantsLayer = true
        view.layer?.backgroundColor =
            NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.14, alpha: 1.0).cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startUpdateTimer()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        updateTimer?.invalidate()
    }

    private func setupUI() {
        // Title
        let titleLabel = createLabel(text: "AutoClick", fontSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: 20, y: 430, width: 360, height: 40)
        view.addSubview(titleLabel)

        // Subtitle
        let subtitleLabel = createLabel(
            text: "Hold Option (⌥) to auto-click", fontSize: 14, weight: .regular)
        subtitleLabel.textColor = NSColor(calibratedWhite: 0.7, alpha: 1.0)
        subtitleLabel.alignment = .center
        subtitleLabel.frame = NSRect(x: 20, y: 400, width: 360, height: 25)
        view.addSubview(subtitleLabel)

        // Status Card
        let statusCard = createCard(frame: NSRect(x: 20, y: 280, width: 360, height: 110))
        view.addSubview(statusCard)

        // Status indicator (colored dot)
        statusIndicator = NSView(frame: NSRect(x: 30, y: 60, width: 16, height: 16))
        statusIndicator.wantsLayer = true
        statusIndicator.layer?.cornerRadius = 8
        statusIndicator.layer?.backgroundColor = NSColor.systemGray.cgColor
        statusCard.addSubview(statusIndicator)

        // Status label
        statusLabel = createLabel(text: "Ready", fontSize: 20, weight: .semibold)
        statusLabel.textColor = .white
        statusLabel.frame = NSRect(x: 55, y: 55, width: 200, height: 30)
        statusCard.addSubview(statusLabel)

        // Click count label
        clickCountLabel = createLabel(text: "Clicks: 0", fontSize: 16, weight: .medium)
        clickCountLabel.textColor = NSColor(calibratedWhite: 0.8, alpha: 1.0)
        clickCountLabel.frame = NSRect(x: 30, y: 20, width: 300, height: 25)
        statusCard.addSubview(clickCountLabel)

        // Speed Card
        let speedCard = createCard(frame: NSRect(x: 20, y: 150, width: 360, height: 120))
        view.addSubview(speedCard)

        // Speed title
        let speedTitle = createLabel(text: "Click Speed", fontSize: 16, weight: .semibold)
        speedTitle.textColor = .white
        speedTitle.frame = NSRect(x: 20, y: 80, width: 200, height: 25)
        speedCard.addSubview(speedTitle)

        // Speed value label
        speedLabel = createLabel(text: "10 clicks/sec", fontSize: 14, weight: .regular)
        speedLabel.textColor = NSColor.systemBlue
        speedLabel.alignment = .right
        speedLabel.frame = NSRect(x: 200, y: 80, width: 140, height: 25)
        speedCard.addSubview(speedLabel)

        // Speed slider
        speedSlider = NSSlider(frame: NSRect(x: 20, y: 40, width: 320, height: 25))
        speedSlider.minValue = 1
        speedSlider.maxValue = 50
        speedSlider.doubleValue = 10
        speedSlider.target = self
        speedSlider.action = #selector(speedChanged)
        speedSlider.isContinuous = true
        speedCard.addSubview(speedSlider)

        // Speed range labels
        let minLabel = createLabel(text: "1", fontSize: 11, weight: .regular)
        minLabel.textColor = NSColor(calibratedWhite: 0.5, alpha: 1.0)
        minLabel.frame = NSRect(x: 20, y: 15, width: 50, height: 20)
        speedCard.addSubview(minLabel)

        let maxLabel = createLabel(text: "50", fontSize: 11, weight: .regular)
        maxLabel.textColor = NSColor(calibratedWhite: 0.5, alpha: 1.0)
        maxLabel.alignment = .right
        maxLabel.frame = NSRect(x: 290, y: 15, width: 50, height: 20)
        speedCard.addSubview(maxLabel)

        // Enable/Disable Button
        enableButton = NSButton(frame: NSRect(x: 20, y: 80, width: 360, height: 50))
        enableButton.title = "Enabled"
        enableButton.bezelStyle = .rounded
        enableButton.target = self
        enableButton.action = #selector(toggleEnabled)
        enableButton.wantsLayer = true
        enableButton.layer?.cornerRadius = 10
        enableButton.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        styleButton(enableButton, enabled: true)
        view.addSubview(enableButton)

        // Instructions
        let instructionsLabel = createLabel(
            text: "⌨️ Hold Option (⌥) key anywhere to start clicking\n🖱️ Release Option to stop",
            fontSize: 12, weight: .regular)
        instructionsLabel.textColor = NSColor(calibratedWhite: 0.5, alpha: 1.0)
        instructionsLabel.alignment = .center
        instructionsLabel.maximumNumberOfLines = 2
        instructionsLabel.frame = NSRect(x: 20, y: 20, width: 360, height: 50)
        view.addSubview(instructionsLabel)
    }

    private func createLabel(text: String, fontSize: CGFloat, weight: NSFont.Weight) -> NSTextField
    {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: fontSize, weight: weight)
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.drawsBackground = false
        return label
    }

    private func createCard(frame: NSRect) -> NSView {
        let card = NSView(frame: frame)
        card.wantsLayer = true
        card.layer?.backgroundColor =
            NSColor(calibratedRed: 0.18, green: 0.18, blue: 0.20, alpha: 1.0).cgColor
        card.layer?.cornerRadius = 12
        card.layer?.borderWidth = 1
        card.layer?.borderColor = NSColor(calibratedWhite: 0.25, alpha: 1.0).cgColor
        return card
    }

    private func styleButton(_ button: NSButton, enabled: Bool) {
        if enabled {
            button.contentTintColor = .white
            button.layer?.backgroundColor = NSColor.systemGreen.cgColor
            button.title = "Enabled"
        } else {
            button.contentTintColor = .white
            button.layer?.backgroundColor = NSColor.systemRed.cgColor
            button.title = "Disabled"
        }
    }

    @objc private func speedChanged() {
        let speed = speedSlider.doubleValue
        autoClicker.setClickSpeed(speed)
        speedLabel.stringValue = String(format: "%.0f clicks/sec", speed)
    }

    @objc private func toggleEnabled() {
        autoClicker.toggle()
        styleButton(enableButton, enabled: autoClicker.isEnabled)
    }

    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateStatus()
        }
    }

    private func updateStatus() {
        if autoClicker.isClicking {
            statusLabel.stringValue = "Clicking..."
            statusIndicator.layer?.backgroundColor = NSColor.systemGreen.cgColor

            // Pulse animation
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.1
                statusIndicator.animator().alphaValue = 0.5
            }) {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.1
                    self.statusIndicator.animator().alphaValue = 1.0
                })
            }
        } else if autoClicker.isEnabled {
            statusLabel.stringValue = "Ready"
            statusIndicator.layer?.backgroundColor = NSColor.systemBlue.cgColor
            statusIndicator.alphaValue = 1.0
        } else {
            statusLabel.stringValue = "Disabled"
            statusIndicator.layer?.backgroundColor = NSColor.systemGray.cgColor
            statusIndicator.alphaValue = 1.0
        }

        clickCountLabel.stringValue = "Clicks: \(autoClicker.clickCount)"
    }
}
