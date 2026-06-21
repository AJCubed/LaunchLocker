//
//  LaunchLockerApp.swift
//  LaunchLocker
//
//  Created by AJ on 6/18/26.
//

import SwiftUI

@main
struct LaunchLockerApp: App {
    let monitor = LaunchMonitor()

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
