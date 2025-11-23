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
    @AppStorage("ClickType") var clickType: ClickType = .left
    @AppStorage("PlaySound") var playSound = false
    @AppStorage("TimerMode") var timerMode: TimerMode = .countdown
    @AppStorage("Use12HourFormat") var use12HourFormat = false

    @AppStorage("WindowWidth") var windowWidth: Int = 320
    @AppStorage("WindowHeight") var windowHeight: Int = 380

    init() {
        appLaunchCount += 1
    }
}
