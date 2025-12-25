# AutoClickMac

A simple Auto Clicker for macOS written in Swift.

## Features
- **Hold 'Fn' to Click**: Automatically clicks when you hold down the Function (Fn) key.
- **Adjustable Speed**: Change the Clicks Per Second (CPS) using the slider.
- **Modern UI**: Clean and simple interface.

## Requirements
- macOS 13.0 or later.

## How to Run

1. Open a terminal in this directory.
2. Run the app using:
   ```bash
   swift run
   ```

## Permissions
**Important**: For the app to detect the 'Fn' key globally (when the app is in the background) and to perform clicks, you must grant **Accessibility** permissions.

1. When you first run the app and try to use it, macOS might prompt you to grant permissions.
2. If not, go to **System Settings** > **Privacy & Security** > **Accessibility**.
3. Add the application (or your Terminal if running from there) to the list and enable it.
   - If running via `swift run`, you might need to add the compiled binary or the Terminal app itself.
   - To find the binary, look in `.build/debug/AutoClickMac`.

## Troubleshooting
- If clicking doesn't work, ensure the app has Accessibility permissions.
- If the 'Fn' key isn't detected, try focusing the app window first, then try globally.
