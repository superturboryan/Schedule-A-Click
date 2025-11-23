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
        // On first launch, set time format to match system preference
        if appLaunchCount == 0 {
            use12HourFormat = systemUses12HourFormat()
        }
        appLaunchCount += 1
    }

    /// Detects whether the system is using 12-hour or 24-hour time format
    private func systemUses12HourFormat() -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        let dateString = formatter.string(from: Date())
        // If the time string contains AM/PM, it's 12-hour format
        return dateString.contains(formatter.amSymbol) || dateString.contains(formatter.pmSymbol)
    }
}
