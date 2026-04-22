# walleto
A money manager app

## Setup on macOS

### Prerequisites
- Install Flutter SDK and make sure `flutter doctor` passes.
- Install Xcode from the Mac App Store.
- Install CocoaPods: `sudo gem install cocoapods`
- Install Android Studio if you also want to run Android builds.

### Run the project
1. Clone the repository and open it in your IDE.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate environment/config files if your team uses them.
4. Run the app:
   ```bash
   flutter run
   ```

### Run on iOS
1. Open the iOS Simulator from Xcode, or connect an iPhone.
2. Install iOS pods:
   ```bash
   cd ios && pod install && cd ..
   ```
3. Start the app:
   ```bash
   flutter run
   ```

### Common macOS notes
- If Xcode command line tools are missing, run `xcode-select --install`.
- If iOS signing fails, open `ios/Runner.xcworkspace` in Xcode and verify your signing team.

## Setup on Windows

### Prerequisites
- Install Flutter SDK and verify with `flutter doctor`.
- Install Git for Windows.
- Install Android Studio with Android SDK and at least one emulator.
- Install Visual Studio if you need Windows desktop support.

### Run the project
1. Clone the repository and open it in VS Code or Android Studio.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Accept Android SDK licenses:
   ```bash
   flutter doctor --android-licenses
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Common Windows notes
- Add Flutter to your system `PATH`.
- If Gradle or Android build issues appear, run:
   ```bash
   flutter clean
   flutter pub get
   ```
- iOS builds are not supported on Windows, so use macOS for iPhone/iPad development.
