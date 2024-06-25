#!/bin/bash

echo "Installing Flutter..."

# Download Flutter SDK
wget -qO- https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_$(date +%Y-%m-%d)-stable.tar.xz | tar -xJf - -C /home/gitpod/
# Add to PATH (ensure it's at the beginning)
export PATH="/home/gitpod/flutter/bin:$PATH"

# Run Flutter Doctor (accept licenses)
flutter doctor --android-licenses

# Install Android tools (if not present)
if ! flutter doctor | grep -q "Android toolchain - develop for Android devices"; then
  echo "Installing Android tools..."
  sudo apt-get update && sudo apt-get install -y android-sdk
  export ANDROID_HOME="/usr/lib/android-sdk"
  export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"
fi

echo "Flutter installation complete!"
