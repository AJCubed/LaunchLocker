# LaunchLocker
Add a passcode to your Mac apps.

## What is LaunchLocker?
LaunchLocker allows you to arbitrarily add password/Face ID requirements to any app. This is not a perfect defense (it can be turned off by someone who knows how the app works), but it allows you to have a greater sense of security whenever you hand my laptop to someone on a casual basis.

Add a list of app names to your protected list. It will check any launched app against that list, and kill the process as it waits for authentication. Afterwards, it will either resume the process or terminate it fully depending on the authentication result.

## Set up
Run the installation script as follows:
```bash
chmod +x install.sh && ./install.sh
```
This will copy LaunchLocker to a permanent location and create a com.launchlocker.applock.plist file in ~/Library/LaunchAgents. This will tell launchd we want this process to run perpetually in the background.

To give LaunchLocker the right to shut down other apps, go to Settings > Privacy & Security > App Management and add LaunchLocker.

## Usage
After the app is running, you may want to restart the app to refresh your blocklist, or to check if it's still running. 
1.) To stop running LaunchLocker
```
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.launchlocker.applock.plist
```
2.) To check if LaunchLocker is running
```
launchctl print gui/$(id -u)/com.launchlocker.applock
```
3.) To restart LaunchLocker
```
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.launchlocker.applock.plist
```

You may wonder, is it really password protection if you can turn it off? I have very specific pseudo-security needs, so it's sufficient for my personal use.
