//
//  LaunchMonitor.swift
//  LaunchLocker
//
//  Created by AJ on 6/18/26.
//

import AppKit
import LocalAuthentication

final class LaunchMonitor {
    private var protectedAppIds: Set<String> {
        LaunchMonitor.loadProtectedAppIds()
    }
    
    init() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(handleLaunch), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        
        print("Launch monitoring started!")
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    class func loadProtectedAppIds() -> Set<String> {
        let configFile =
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("LaunchLocker/protectedList.txt")
        
        do {
            let fileContents = try String(contentsOf: configFile, encoding: .utf8)
            
            return Set(fileContents.components(separatedBy: .newlines)
                .map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
                .filter{!$0.isEmpty})
        } catch {
            return Set()
        }
    }
    
    @objc private func handleLaunch(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            else {
                return
            }
        
        guard let bundleId = app.bundleIdentifier else {return}
        guard protectedAppIds.contains(bundleId) else {return}
        
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
                 
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !app.isTerminated {
                        print("Fallback forceTerminate...")
                        app.forceTerminate()
                    }
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
