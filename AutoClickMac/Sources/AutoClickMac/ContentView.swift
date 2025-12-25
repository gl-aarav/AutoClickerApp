import SwiftUI

struct ContentView: View {
    @EnvironmentObject var autoClicker: AutoClicker

    var body: some View {
        VStack(spacing: 25) {
            Text("Auto Clicker")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .padding(.top)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Speed")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(autoClicker.clicksPerSecond)) CPS")
                        .font(.monospacedDigit(.body)())
                        .foregroundColor(.secondary)
                }

                Slider(value: $autoClicker.clicksPerSecond, in: 1...50, step: 1) {
                    Text("CPS")
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("50")
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            .shadow(radius: 1)

            HStack(spacing: 15) {
                Circle()
                    .fill(autoClicker.isClicking ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                    .shadow(color: autoClicker.isClicking ? .green.opacity(0.5) : .clear, radius: 4)

                Text(autoClicker.isClicking ? "Clicking Active" : "Hold 'Space' to Click")
                    .font(.headline)
                    .foregroundColor(autoClicker.isClicking ? .primary : .secondary)
            }
            .padding(.vertical, 5)

            Divider()

            VStack(spacing: 8) {
                HStack {
                    Circle()
                        .fill(autoClicker.isTrusted ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(autoClicker.isTrusted ? "Permissions Granted" : "Permissions Missing")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(autoClicker.isTrusted ? .green : .red)
                }

                if !autoClicker.isTrusted {
                    Button("Check Permissions") {
                        autoClicker.checkPermissions()
                        let options = [
                            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
                        ]
                        AXIsProcessTrustedWithOptions(options as CFDictionary)
                    }
                    .font(.caption)
                }

                Text("System Settings > Privacy & Security > Accessibility")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.bottom)
        }
        .padding()
        .frame(width: 320)
    }
}
