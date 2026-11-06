# Keyflip

Keyflip is a macOS menu bar app that switches your keyboard input source automatically whenever you move to another app.

Type English in Xcode and Terminal, Japanese in Messages, and Pinyin in WeChat, without ever pressing the input source shortcut.

## Features

- **Per-app rules.** Choose the input source each app should always use.
- **A default for everything else.** Pick an input source for apps without a rule, or leave their input source unchanged.
- **Input source indicator.** When you switch to an app Keyflip manages, a small HUD briefly shows the input source now in use. It appears inside the app's window, never takes focus, and lets clicks pass through.
- **Menu bar menu.** Shows the current input source, sets one for the app you were just using, and turns automatic switching on or off.
- **Launch at login.** Keyflip then starts quietly in the menu bar; click its Dock icon to open the window.
- **Localized** in English, Japanese, Simplified Chinese, and Korean.

## Privacy

Keyflip runs in the App Sandbox and only uses public APIs. It does not need:

- Accessibility
- Input Monitoring
- Screen Recording
- Network access

It never reads what you type. To place the HUD it reads only the size and position of the active app's window, never its title or contents. Settings are stored locally in UserDefaults.

## Requirements

- macOS 26 or later
- Xcode 26 or later to build

## Building

Open `Keyflip.xcodeproj` in Xcode and run the **Keyflip** scheme.

To build and run the tests from the command line:

```sh
xcodebuild test -project Keyflip.xcodeproj -scheme Keyflip -destination 'platform=macOS'
```

## How it works

1. `SystemWorkspace` observes `NSWorkspace.didActivateApplicationNotification`.
2. `AutoSwitcher` looks up the app's rule in `RuleStore`, falling back to the default input source.
3. `SystemInputSourceProvider` selects the input source through the Text Input Sources (TIS) API.
4. `InputSourceHUD` shows the input source now in use.

## Project structure

```
Keyflip/
├── App/            App entry point and dependency setup (AppContainer)
├── Models/         AppIdentity, AppRule, InputSource
├── Services/       Switching, persistence, launch at login
│   ├── InputSources/   TIS access behind InputSourceProviding
│   ├── Workspace/      NSWorkspace access behind WorkspaceProviding
│   └── Indicator/      The input source HUD and its placement
├── ViewModels/     @Observable view models for the window and menu bar
├── Views/          SwiftUI views
└── Localizable.xcstrings
KeyflipTests/       Swift Testing unit tests, using fakes for system services
Design/             App icon source (SwiftUI) and 1024 px render
```

The app uses MVVM with Swift 6 strict concurrency. System services sit behind protocols, so the switching logic and view models are tested without touching the real input sources or other apps.

## Localization

User-facing strings live in `Keyflip/Localizable.xcstrings`. To add a language:

1. Add it under **Project → Info → Localizations**.
2. Translate the strings in the String Catalog.

Input source and app names come from macOS, so they are already localized.
