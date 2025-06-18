//
//  SettingsStore.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-18.
//

import SwiftUI

@MainActor
final class SettingsStore: ObservableObject {
    
    @AppStorage("AppLaunchCount") var appLaunchCount = 0
    @AppStorage("HasRatedApp") var hasRatedApp = false
    @AppStorage("ShowTimeInMenuBar") var showTimeInMenuBar = true
    @AppStorage("StartOnLogin") var startOnLogin = false
    
    @AppStorage("WindowWidth") var windowWidth: Int = 260
    @AppStorage("WindowHeight") var windowHeight: Int = 300
    
    init() {
        appLaunchCount += 1
    }
}
