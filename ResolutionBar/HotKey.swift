import Carbon.HIToolbox

/// A system-wide keyboard shortcut. Carbon hot keys, unlike an `NSEvent` global monitor,
/// don't need Accessibility permission.
enum HotKey {
    private static var action: (@MainActor () -> Void)?

    /// Registers the app's one global shortcut for the lifetime of the process. Call it once.
    static func register(keyCode: Int, modifiers: Int, action: @escaping @MainActor () -> Void) {
        self.action = action

        var pressed = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in
            MainActor.assumeIsolated { HotKey.action?() }
            return noErr
        }, 1, &pressed, nil, nil)

        var hotKey: EventHotKeyRef?
        let id = EventHotKeyID(signature: 0x5242_4152, id: 1) // "RBAR"
        RegisterEventHotKey(UInt32(keyCode), UInt32(modifiers), id, GetApplicationEventTarget(), 0, &hotKey)
    }
}
