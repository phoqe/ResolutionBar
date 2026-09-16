import Carbon.HIToolbox
import OSLog
import ServiceManagement
import SwiftUI

@main
struct ResolutionBarApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        MenuBarExtra("ResolutionBar", systemImage: "display") {
            ResolutionMenu(store: appDelegate.store)
        }
    }
}

struct ResolutionMenu: View {
    let store: ResolutionStore

    var body: some View {
        ForEach(Resolution.all) { resolution in
            Toggle(resolution.title, isOn: Binding(
                get: { store.current == resolution },
                set: { if $0 { store.select(resolution) } }
            ))
        }

        Divider()

        Button("Switch Resolution") { store.toggle() }
            .keyboardShortcut("r", modifiers: [.control, .option, .command])

        Divider()

        Button("Quit ResolutionBar") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = ResolutionStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep in sync with the keyboardShortcut shown in ResolutionMenu.
        HotKey.register(keyCode: kVK_ANSI_R, modifiers: controlKey | optionKey | cmdKey) { [store] in
            store.toggle()
        }

        #if !DEBUG
        // Register only on first launch, so removing it in System Settings › Login Items sticks.
        // Checking SMAppService.mainApp.status doesn't work here: it reads .notFound, not
        // .notRegistered, before the first registration.
        // Debug builds are skipped so a DerivedData copy never becomes the login item.
        let key = "didRegisterLoginItem"
        if !UserDefaults.standard.bool(forKey: key) {
            do {
                try SMAppService.mainApp.register()
                UserDefaults.standard.set(true, forKey: key)
            } catch {
                Logger().error("Failed to register login item: \(error, privacy: .public)")
            }
        }
        #endif
    }
}
