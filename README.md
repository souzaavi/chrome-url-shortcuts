# URL Shortcuts Chrome Extension

A Flutter-based Chrome extension that allows you to create custom URL shortcuts for quick navigation. Use shortcuts like "g" for Google search or "yt" for YouTube search directly from Chrome's address bar.

## Features

- Create custom URL shortcuts with descriptions
- Use shortcuts directly from Chrome's address bar
- Search suggestions as you type
- Persistent storage of shortcuts
- Clean and intuitive UI

## Prerequisites

1. Install Flutter:
   ```bash
   # macOS (using Homebrew)
   brew install flutter

   # Or download from Flutter website
   # https://flutter.dev/docs/get-started/install
   ```

2. Configure Flutter:
   ```bash
   flutter doctor
   ```
   Fix any issues reported by `flutter doctor`

3. Install Chrome:
   - Download and install from [https://www.google.com/chrome/](https://www.google.com/chrome/)

## Building the Extension

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd chrome_search_shortcuts
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Build the extension:
   ```bash
   flutter build web --release --web-renderer html --csp --base-href /
   ```
   This will create the extension files in the `build/web` directory.

## Installing the Extension

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" in the top-right corner
3. Click "Load unpacked"
4. Select the `build/web` directory from your project
5. The extension should now appear in your Chrome toolbar

## Using the Extension

### Adding Shortcuts

1. Click the extension icon in Chrome toolbar
2. Click the "+" button
3. Fill in the shortcut details:
   - **Key**: The shortcut trigger (e.g., "g" for Google)
   - **URL**: The URL pattern with {query} placeholder (e.g., "https://www.google.com/search?q={query}")
   - **Description**: A helpful description of what the shortcut does

### Using Shortcuts

1. Click Chrome's address bar
2. Type "go" and press Tab
3. Type your shortcut key followed by your search query
   - Example: `g flutter docs` (searches Google for "flutter docs")
   - Example: `yt flutter tutorial` (searches YouTube for "flutter tutorial")

## Example Shortcuts

1. Google Search:
   - Key: g
   - URL: https://www.google.com/search?q={query}
   - Description: Search Google

2. YouTube Search:
   - Key: yt
   - URL: https://www.youtube.com/results?search_query={query}
   - Description: Search YouTube

## Development Notes

### Project Structure

```
chrome_search_shortcuts/
├── lib/
│   ├── main.dart           # Main Flutter app
│   ├── models/             # Data models
│   └── services/           # Business logic
├── web/
│   ├── manifest.json       # Extension manifest
│   ├── background.js       # Background script
│   ├── index.html         # Entry point
│   └── styles.css         # Custom styles
└── pubspec.yaml           # Flutter dependencies
```

### Key Files

- `manifest.json`: Chrome extension configuration
- `background.js`: Handles omnibox (address bar) integration
- `main.dart`: Flutter UI and state management
- `storage_service.dart`: Chrome storage integration

### Building for Development

For development, you can use:
```bash
flutter run -d chrome --web-renderer html
```

For production builds, always use:
```bash
flutter build web --release --web-renderer html --csp --base-href /
```

## Troubleshooting

1. **Extension not showing up?**
   - Make sure you've enabled Developer mode
   - Try removing and re-adding the extension
   - Check Chrome's console for errors

2. **Shortcuts not working?**
   - Ensure you type "go" and press Tab first
   - Check if the shortcut is listed in the extension popup
   - Try removing and re-adding the shortcut

3. **Build errors?**
   - Run `flutter clean`
   - Delete the `build` directory
   - Run `flutter pub get`
   - Try building again

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with Flutter
- Uses Chrome Extension APIs
- Inspired by browser search shortcuts
