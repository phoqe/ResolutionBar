import AppKit
import CoreGraphics

/// A scaled (HiDPI) resolution of the built-in display, in points.
struct Resolution: Identifiable, Equatable {
    let name: String
    let width: Int
    let height: Int

    var id: String { name }
    var title: String { "\(name) (\(width) × \(height))" }

    static let `default` = Resolution(name: "Default", width: 1728, height: 1117)
    static let moreSpace = Resolution(name: "More Space", width: 2056, height: 1329)
    static let all = [`default`, moreSpace]
}

@Observable
final class ResolutionStore {
    private(set) var current: Resolution?

    init() {
        refresh()
        // Also picks up changes made in System Settings.
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
    }

    func toggle() {
        select(current == .default ? .moreSpace : .default)
    }

    func select(_ resolution: Resolution) {
        let display = Self.targetDisplay
        let currentMode = CGDisplayCopyDisplayMode(display)
        let options = [kCGDisplayShowDuplicateLowResolutionModes: true] as CFDictionary
        let modes = CGDisplayCopyAllDisplayModes(display, options) as? [CGDisplayMode] ?? []
        let candidates = modes.filter {
            $0.width == resolution.width && $0.height == resolution.height
                && $0.pixelWidth == $0.width * 2 && $0.isUsableForDesktopGUI()
        }
        // Keep the current refresh rate so the ProMotion panel stays at 120 Hz.
        guard let mode = candidates.first(where: { $0.refreshRate == currentMode?.refreshRate })
            ?? candidates.max(by: { $0.refreshRate < $1.refreshRate })
        else { return }

        var config: CGDisplayConfigRef?
        guard CGBeginDisplayConfiguration(&config) == .success else { return }
        guard CGConfigureDisplayWithDisplayMode(config, display, mode, nil) == .success else {
            CGCancelDisplayConfiguration(config)
            return
        }
        // .permanently saves the choice like System Settings does, so it survives logout and restarts.
        CGCompleteDisplayConfiguration(config, .permanently)
        refresh()
    }

    private func refresh() {
        let mode = CGDisplayCopyDisplayMode(Self.targetDisplay)
        current = Resolution.all.first { $0.width == mode?.width && $0.height == mode?.height }
    }

    /// The built-in display, or the main display when the lid is closed.
    private static var targetDisplay: CGDirectDisplayID {
        var displays = [CGDirectDisplayID](repeating: 0, count: 16)
        var count: UInt32 = 0
        CGGetActiveDisplayList(UInt32(displays.count), &displays, &count)
        return displays.prefix(Int(count)).first { CGDisplayIsBuiltin($0) != 0 } ?? CGMainDisplayID()
    }
}
