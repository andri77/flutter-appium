#!/bin/bash

# Exit on error
set -e

# Install prerequisites
if ! command -v brew &> /dev/null
then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install node
brew install --cask flutter
brew install --cask android-studio
brew install openjdk

# Set up environment variables
export ANDROID_HOME=$HOME/Library/Android/sdk
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Build the Flutter app
flutter build apk --release

# Install Appium and its driver
npm install -g appium
appium driver install uiautomator2

# Install npm dependencies
cd test/appium
npm install

# Run the tests
npm test
