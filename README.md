# 🦏 Rhino - Instagram Tweak for Sileo

The ultimate Instagram enhancement tweak for jailbroken iOS devices. Features story/reel downloading, anonymous viewing, HiFi audio, ad blocking, and much more.

## Features

| Feature | Description |
|---------|-------------|
| **📥 Story Downloader** | Download any story video or image with one tap |
| **📱 Reels Downloader** | Save any reel to your device for offline viewing |
| **👻 Anonymous Story View** | View stories without appearing in viewers list |
| **🎵 HiFi Audio** | Enhanced audio quality for Instagram audio tracks |
| **🚫 Ad Blocker** | Remove all sponsored posts and advertisements |
| **🔒 Privacy Tools** | Disable typing indicators, read receipts, analytics |
| **🎤 Voice Message Download** | Save voice messages from DMs |
| **👁 Hide Seen Stories** | Remove seen indicators from story tray |
| **📊 Analytics Blocker** | Block Instagram tracking completely |
| **❤️ Hide Like Counts** | Option to hide like counts on posts |

## Requirements

- Jailbroken iOS device (iOS 13.0+)
- Sileo, Zebra, or Cydia package manager
- MobileSubstrate / Substitute

## Installation

### Add Repository to Sileo

1. Open **Sileo**
2. Go to **Sources** tab
3. Tap **+** to add a new source
4. Enter the repository URL:
   ```
   https://your-repo-url.github.io/InstagramRepo/repo
   ```
5. Search for **Rhino**
6. Tap **Install** then **Confirm**
7. **Respring** your device

### Build from Source

```bash
# Install Theos (if not installed)
git clone --recursive https://github.com/theos/theos.git ~/theos
export THEOS=~/theos

# Clone this repository
git clone https://github.com/user/InstagramRepo.git
cd InstagramRepo

# Make setup script executable
chmod +x setup.sh

# Run build script
./setup.sh
```

## Configuration

After installation, go to **Settings > Rhino** to configure all options:

### General Settings
- Enable/Disable Rhino globally
- Disable Instagram analytics

### Download Settings
- Enable/disable story downloads
- Enable/disable reel downloads
- Enable/disable feed media downloads
- Enable/disable voice message downloads

### Privacy Settings
- Anonymous story viewing
- Hide story viewers
- Disable typing indicator
- Disable read receipts

### Audio Settings
- HiFi audio enhancement
- Ad blocking

### Appearance
- Hide like counts

## Project Structure

```
InstagramRepo/
├── repo/                          # Sileo repository files
│   ├── Release                    # Repository metadata
│   ├── Packages                   # Package listings
│   ├── Packages.bz2              # Compressed packages
│   ├── pool/                      # Built .deb packages
│   │   └── main/r/
│   └── descriptions/              # Sileo depiction files
│       ├── index.html             # Main description page
│       ├── com.rhino.sileo.json  # Sileo native depiction
│       ├── com.rhino.features.html
│       └── com.rhino.changelog.html
├── tweak/                         # Theos tweak source
│   ├── Makefile                   # Build configuration
│   ├── control                    # Debian control file
│   ├── Tweak.x                    # Main tweak code (Logos)
│   ├── Info.plist                  # Bundle info
│   └── Prefs/                     # Settings bundle
│       ├── Makefile
│       ├── control
│       └── RHSettingsController.m
├── setup.sh                       # Build script
└── README.md                      # This file
```

## Compatibility

| iOS Version | Status |
|-------------|--------|
| iOS 13.x | ✅ Supported |
| iOS 14.x | ✅ Supported |
| iOS 15.x | ✅ Supported |
| iOS 16.x | ✅ Supported |
| iOS 17.x | ✅ Supported |
| iOS 18.x | ⏳ Testing |

## Tech Stack

- **Language:** Objective-C
- **Build System:** Theos
- **Hooking:** Logos (preprocessor)
- **Frameworks:** UIKit, Foundation, Photos, AVFoundation
- **Package Format:** Debian (.deb)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Disclaimer

This tweak is for educational purposes only. Use at your own risk. The developers are not responsible for any account restrictions or legal issues that may arise from using this tweak.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

- **Theos** - Build system for iOS tweaks
- **Sileo** - Modern package manager for jailbroken iOS
- **Community** - For all the bug reports and feature requests
