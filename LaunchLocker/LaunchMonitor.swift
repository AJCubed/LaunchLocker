//
//  LaunchMonitor.swift
//  LaunchLocker
//
//  Created by AJ on 6/18/26.
//

import AppKit
import LocalAuthentication

final class LaunchMonitor {
    private let protectedApps: Set<String>
    
    init() {
        protectedApps = LaunchMonitor.loadProtectedApps()
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(handleLaunch), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        
        print("Launch monitoring started!")
    }
    
    class func loadProtectedApps() -> Set<String> {
        guard let configFile = Bundle.main.url(forResource: "protectedList", withExtension: "txt") else {
                print("Config not found.")
                return Set()
            }
        
        do {
            let fileContents = try String(contentsOf: configFile, encoding: .utf8)
            print(fileContents)
            return Set(fileContents.components(separatedBy: .newlines))
        } catch {
            print("Unable to load file")
            return Set()
        }
    }
    
    @objc private func handleLaunch(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            else {
                return
            }
        
        printDetails(app)
        guard let appName = app.localizedName else {return}
        guard protectedApps.contains(appName) else {return}
        
        authenticate(app)
    }
    
    private func authenticate(_ app: NSRunningApplication) {
        let context = LAContext()
        let pid = app.processIdentifier

        kill(pid,SIGSTOP)
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "unlock \(app.localizedName ?? "Application")") { success, error in
            
            if success {
                print("Authenticated")
                kill(pid,SIGCONT)
            } else {
                print("Not authenticated, terminating...")
                kill(pid,SIGCONT)
                usleep(1000)
                kill(pid,SIGTERM)
                 
                if(!app.isTerminated) {
                    print("Fallback forceTerminate...")
                    app.forceTerminate()
                }
            }
        }
                               
    }
    private func printDetails(_ app: NSRunningApplication) {
        print("Launched: \(app.localizedName ?? "Unknown")")
        print("Bundle ID: \(app.bundleIdentifier ?? "Unknown")")
        print("Path: \(app.bundleURL?.path(percentEncoded:false) ?? "Unknown")")
        print("PID: \(app.processIdentifier)")

    }
}
