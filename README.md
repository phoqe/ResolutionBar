# ResolutionBar

A menu bar app that switches the built-in display between two scaled resolutions:

- **Default**: 1728 × 1117
- **More Space**: 2056 × 1329

It has no Dock icon and no windows. It starts at login and stays in the menu bar.

## Usage

- Click the display icon in the menu bar and pick a resolution. The current one is checked.
- Press **⌃⌥⌘R** anywhere to switch between the two resolutions.

Changes persist across logouts and restarts, the same as changing them in System Settings.

## Install

```sh
make install
```

This builds a Release copy, installs it to `/Applications/ResolutionBar.app` and starts it. On first launch, the Release build registers itself as a login item. macOS shows a "Background Items Added" notification when that happens. To stop it from starting at login, turn it off in System Settings › General › Login Items & Extensions. Run `make uninstall` to remove the app.

To work on the app, open `ResolutionBar.xcodeproj` and run it. Debug builds skip the login-item registration, so a DerivedData copy never ends up as the login item.

## Customizing

- **Resolutions**: `Resolution.default` and `Resolution.moreSpace` in `ResolutionBar/ResolutionStore.swift`. List the available scaled modes with `displayplacer list`, or in System Settings › Displays › Advanced › Show resolutions as list.
- **Shortcut**: `HotKey.register` in `ResolutionBar/ResolutionBarApp.swift`. Also update the matching `.keyboardShortcut`, which only sets the hint shown in the menu.

## Notes

- The app targets the built-in display. When the lid is closed, it falls back to the main display, and nothing happens if that display lacks these modes.
- Switching keeps the current refresh rate, so the ProMotion panel stays at 120 Hz.
- App Sandbox is off and the app is ad-hoc signed ("Sign to Run Locally"). To sign with your certificate instead, set your team under Signing & Capabilities.
