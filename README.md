## Pre-requisite
- You'll need Flutter SDK installed on your respective Operating System (Window / Mac OS / *nix). 
    - See [How to get Flutter SDK](#how-to-get-flutter-sdk)

- If you aim to build and test app on Android then you will need to have:
    - **Physical Android Device** with a USB cable. See [How to debug with Physical Android Device](#debugging-with-physical-android-device)


    - or an **Android Virtual Device (AVD)** which can be obtain from **Android Studio**. [How to debug with Android Studio and AVD](#debugging-with-android-studio-and-avd)



## Getting Started
1. Clone the Repository.

~~~shell
git clone https://github.com/JD-01-DEV/Roka-AI.git
~~~

2. Create Flutter Project.

~~~shell
flutter create roka_ai && cd roka_ai
~~~

3. Delete `test`, replace `lib` & `pubspec.yaml` with the `lib` & `pubspec.yaml` of cloned repository.

4. Install all the dependencies.

~~~shell
flutter pub get --no-example
~~~

5. At last run the app in `main.dart` either using IDE like VS CODE or using flutter in terminal.

~~~shell
flutter run
~~~

6. Choose device on which you want run 


## How to get Flutter SDK

> All The instructions are from official documention: https://docs.flutter.dev/get-started/quick

### Linux 
#### Terminal

**Download** the Flutter SDK bundle from https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.38.5-stable.tar.xz

1. Create a folder to store the SDK

~~~shell
mkdir ~/develop/
~~~

2. Extract file (Replace <sdk_zip_path> with the path to the bundle you downloaded.)

~~~shell
tar -xf <sdk_zip_path> -C ~/develop/
~~~

3. For example:

~~~shell
tar -xf ~/Downloads/flutter_linux_3.29.3-stable.tar.xz -C ~/develop/
~~~

4. Determine your default shell

~~~shell
echo $SHELL
~~~

**Add Flutter to your `PATH`**

***Bash***

~~~shell 
echo 'export PATH="~/develop/flutter/bin:$PATH"' >> ~/.bash_profile 

OR

echo 'export PATH="~/develop/flutter/bin:$PATH"' >> ~/.bashrc
~~~


***Zsh***

~~~shell 
echo 'export PATH="~/develop/flutter/bin:$PATH"' >> ~/.zshenv
~~~


***Fish***

~~~shell 
fish_add_path -g -p ~/develop/flutter/bin
~~~

***Csh***

~~~shell 
echo 'setenv PATH "~/develop/flutter/bin:$PATH"' >> ~/.cshrc
~~~


***Tcsh***

~~~shell 
echo 'setenv PATH "~/develop/flutter/bin:$PATH"' >> ~/.tcshrc
~~~


***Ksh***

~~~shell 
echo 'export PATH="~/develop/flutter/bin:$PATH"' >> ~/.profile
~~~

***sh***

~~~shell 
echo 'export PATH="~/develop/flutter/bin:$PATH"' >> ~/.profile
~~~


**Apply your changes**

To apply this change and get access to the flutter tool, close and reopen all open shell sessions in your terminal apps and IDEs.


5. Validate your setup

~~~shell
flutter --version
dart --version
~~~


#### VS CODE
A. Download and install prerequisite packages

~~~shell
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
~~~

B. Install and set up Flutter
1. Launch VS Code
2. Add the Flutter extension to VS Code
3. Install Flutter with VS Code
    1. Press `Control + Shift + P` and type flutter
    3. Select `Flutter: New Project`.
    4. VS Code prompts you to locate the Flutter SDK on your computer. `Select Download SDK`.
    5. Select Folder for ***Flutter SDK*** and click `Clone Flutter`.
    6. VS Code starts downloading Flutter, wait for it to complete.
    7. After download completes, Click `Add SDK to PATH` and choose path i.e. `~/develop`.
    8. Restart IDE / Terminal to see Flutter into action


### Windows

#### Prerequisite software

1. Download and install the latest version of Git for Windows from https://git-scm.com/downloads/win
2. Download and install Visual Studio Code

3. Follow [Installation through VS CODE](#vs-code), Don't forget to **replace** path to respective **SDK path**

### Mac OS

#### Prerequisite software

1. Install `git`

~~~shell
xcode-select --install
~~~

2. Download and install Visual Studio Code
2. Follow [Installation through VS CODE](#vs-code), Don't forget to **replace** path to respective **SDK path**


## Debugging with Physical Android Device
1. You'll need a **USB cable** compatible with your Android and PC / Laptop.

2. **Connect** device using USB cable and allow **file transfer**.

3. Enable **Devloper Mode** by tapping 9 times on Build version in About Device or similar, if not already then allow **USB debugging** and **Installtion through  USB** if available.

4. **Run / Build** the app and allow the **installation** on Android if asked.

5. The will be built in seconds or minuts depending on your device.


## Debugging with Android Studio and AVD

### Android Studio

1. Get Android Studio and setup. See [How to Get and Setup Android Studio](#how-to-setup-android-studio)

2. Create Virtual Device according to your preferences of minimum API 16.

3. Choose the Device in your respective IDE.

4. Run / Build App and see it in qction.


### AVD (Android Vertual Device)

#### Linux and Mac OS
1. Install Android Studio. See [How to Get and Setup Android Studio]()

2. Add Android SDK path to repective shell config file
~~~shell
# SDK path
export ANDROID_HOME=~/Android/Sdk

# Complementry paths
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# NDK path
export ANDROID_NDK_HOME=/home/jd01/Android/Sdk/ndk/<ndk-version> # replace <ndk-version> with the version you have.
export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
~~~

3. Create Android Device using Android Studio, See [Creating Virtual Device ](#creating-virtual-device)

4. Now you can check installed Android device  

~~~shell
emulator -list-avds
~~~

5. Run the device
~~~shell
emulator <Device Name>
~~~

6. At last the device will appear in respected IDE for debugging


#### Windows
Debugging through Android Studio is recommanded for Windows


## How to setup Android Studio

### Installaion

#### Linux
you can get **Android Studio** either from Flatpak / Snap / Homebrew / Official website in `deb` format. but my recommandation is to have it through `deb` package so that Android Studio can interact with Linux for debugging purpose.

***Deb:***

Download `tar.gz` file from https://developer.android.com/studio and Extract the file:

~~~shell
tar -xf ~/Downloads/android-studio-*-linux.tar.gz
~~~

And install
~~~shell
sudo dpkg -i android-studio-*-linux.deb
~~~


#### Windows
Download `exe` file from https://developer.android.com/studio and Extract the file:

Follow installtion steps


#### Mac OS

Download `dmg` file from https://developer.android.com/studio and Install it.


### Creating Virtual Device
1. Click on Device Manager at right sidebar or Click on Search Icon at top right and search Device Manger then select that.

2. Device Manager will open at right sidebar. Click on `+` button and select `Create Virtual Device`

3. A window will pop up where you can select any device you want to debug for.

4. Just go with default config for selected Device and you will be able to see the newly created Virtual Device in Device Manager.

5. Now you can run and debug the Virtual Device.
