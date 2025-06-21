# macOS Settings Automation

## Automated macOS System Configuration Scripts

### Description

This repository contains two powerful scripts designed to automate and verify macOS system settings configuration. These scripts help you quickly set up a new Mac or standardize settings across multiple machines with consistent, reproducible results.

### Scripts Overview

#### 🔧 `modify-settings.sh`
Programmatically configures macOS system settings using command-line tools and defaults commands. This script eliminates the need to manually click through System Settings by automating the configuration process.

#### ✅ `ensure-setings.sh`
Provides an interactive way to verify that critical settings are properly configured by opening specific System Settings panels with user-friendly dialogs to guide you through manual verification.

### Features

#### System Configuration (`modify-settings.sh`)
- **Power Management**: Optimized sleep and power settings for different machine types
- **Sharing Services**: Configurable screen sharing, SSH, and file sharing
- **Regional Settings**: Language, measurement units, date/time formats
- **Appearance**: Dark mode, accent colors, sidebar sizes, scroll bar behavior
- **Control Center**: Menu bar item configuration and preferences
- **Desktop & Dock**: Size, magnification, auto-hide, hot corners
- **Finder**: View options, sidebar settings, default behaviors
- **Security**: Password requirements, screen saver settings
- **Trackpad**: Tap to click, gestures, corner clicking
- **Screenshots**: Location, format, and thumbnail settings
- **App Store**: Auto-update configuration

#### Settings Verification (`ensure-setings.sh`)
- **Interactive Dialogs**: User-friendly prompts for each settings category
- **Automated Opening**: Directly opens relevant System Settings panels
- **Comprehensive Coverage**: Covers accessibility, privacy, display, and account settings
- **Progress Tracking**: Waits for user completion before moving to next section

### Usage

#### Quick Setup
```bash
# Clone the repository
git clone <your-repository-url>
cd macos-setup

# Make scripts executable
chmod +x modify-settings.sh ensure-setings.sh

# Run settings modification (for regular machine)
./modify-settings.sh N

# Run settings modification (for server machine)
./modify-settings.sh Y

# Verify settings interactively
./ensure-setings.sh
```

#### Machine Types

**Regular Machine** (`./modify-settings.sh N`):
- Standard power management settings
- Disabled sharing services for security
- Optimized for personal/work use
- Normal sleep and display settings

**Server Machine** (`./modify-settings.sh Y`):
- Always-on power configuration
- Enabled screen sharing, SSH, and file sharing
- Wake-on-LAN and network optimizations
- Minimal sleep settings for continuous operation

### Requirements

- macOS (tested on recent versions)
- Administrator privileges
- Terminal access

### Settings Categories

#### Power Management
- Sleep configuration for battery, power adapter, and UPS
- Display sleep timing
- Power Nap and lid wake settings
- Auto-restart and TCP keep-alive (server mode)

#### System Appearance
- Dark mode interface
- Scroll bar behavior
- Sidebar sizing
- Menu bar customization

#### Dock Configuration
- Size and magnification settings
- Auto-hide behavior with custom timing
- Recent applications display
- Process indicators

#### Finder Optimization
- Default view settings (list view)
- Path bar and status bar visibility
- Desktop icon preferences
- Search scope configuration
- Sidebar organization

#### Security Settings
- Immediate password requirement after screen saver
- Secure keyboard entry in Terminal
- Screen capture settings and location

### Customization

#### Modifying Settings
Edit `modify-settings.sh` to customize:
- Power management timings
- Appearance preferences
- Dock sizing and behavior
- Finder default settings
- Security requirements

#### Adding New Verifications
Edit `ensure-setings.sh` to add new settings verification:
```bash
settings_tabs+=(
    "New Setting ## x-apple.systempreferences:com.apple.YourPreferencePane"
)
```

### File Structure

```
macos-setup/
├── modify-settings.sh      # Main settings configuration script
├── ensure-setings.sh       # Interactive settings verification
└── dialog/                 # Dialog utilities and icons
    ├── settings.icns       # Icon for dialog windows
    └── user-dialog.sh      # Dialog helper functions
```

### Troubleshooting

#### Common Issues
1. **Permission Denied**: Ensure you have administrator privileges
2. **Settings Not Applied**: Some settings require logout/restart to take effect
3. **System Settings Won't Open**: Try killing existing System Settings processes

#### Manual Verification
After running `modify-settings.sh`, use `ensure-setings.sh` to verify:
- All critical settings were applied correctly
- System-specific configurations are appropriate
- Manual adjustments needed for personal preferences

### Contributing

Feel free to submit issues and enhancement requests! To contribute:

1. Fork the repository
2. Create a feature branch
3. Test changes on a clean macOS installation
4. Submit a pull request with detailed description

### License

This project is open source. Feel free to use, modify, and distribute according to your needs.

---

*Automate your macOS setup and never manually configure system settings again!*
