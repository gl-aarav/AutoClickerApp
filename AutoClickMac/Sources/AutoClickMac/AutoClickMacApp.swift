import SwiftUI

@main
struct AutoClickMacApp: App {
    @StateObject var autoClicker = AutoClicker()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(autoClicker)
                .fixedSize()
                .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
