# LaunchLocker
Add a passcode to your Mac apps.

## What is LaunchLocker?
LaunchLocker is a simple script that allows you to add password/Face ID requirements to any app on your Macbook. 

It checks every app on-launch against a blocklist, and kills protected processes until the user authenticates. Afterwards, it reactivates the application.

Note that this is not a perfect defense, and can be turned off by someone who knows how the app works.

## Install
Run the installation script as follows:
```bash
chmod +x install.sh && ./install.sh
```
This script checks if LaunchLocker is present in the repository root and if not, downloads the latest GitHub release. It then copies LaunchLocker to a permanent location, creates com.launchlocker.applock.plist in ~/Library/LaunchAgents, and activates LaunchLocker. Unless interrupted using the below commands, LaunchLocker will remain active perpetually from then on.

To give LaunchLocker the right to shut down other apps, go to Settings > Privacy & Security > App Management and add LaunchLocker.

## Usage
You must use the bundle ID of your app, not just the app name. To find the bundle ID of an app (eg. Notion), you can run this command:
```
osascript -e 'id of app "Notion"'
```
Use this format to find the bundle ID of any app on your Mac.

To add to your blocklist, you can open the file with this:
```
nano ~/Library/Application\ Support/LaunchLocker/protectedList.txt
```

## Troubleshooting
After the app is running, you may want to stop the app for some reason, or to check if it's still running. 

1.) To stop running LaunchLocker
```
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.launchlocker.applock.plist
```
2.) To check if LaunchLocker is running
```
launchctl print gui/$(id -u)/com.launchlocker.applock
```
3.) To restart LaunchLocker
```
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.launchlocker.applock.plist
``` 

You may wonder, is it really password protection if you can turn it off? I have very specific pseudo-security needs, so it's sufficient for my personal use.
