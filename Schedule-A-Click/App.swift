//
//  App.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-18.
//

import SwiftUI

@main
struct Schedule_A_ClickApp: App {
    
    @StateObject var clickTimerStore = ClickTimerStore()
    @StateObject var settingsStore = SettingsStore()
    @StateObject var permissionStore = PermissionStore()
    
    var body: some Scene {
        MenuBarExtra {
            timerView
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)
    }
    
    var timerView: some View {
        TimerView()
            .frame(width: CGFloat(settingsStore.windowWidth), height: CGFloat(settingsStore.windowHeight))
            .environmentObject(clickTimerStore)
            .environmentObject(settingsStore)
            .environmentObject(permissionStore)
            .onChange(of: permissionStore.isTrusted, initial: true) { _, newValue in
                settingsStore.windowWidth = newValue ? 220 : 300
                settingsStore.windowHeight = newValue ? 180 : 280
            }
    }
    
    @ViewBuilder
    var menuBarLabel: some View {
        if !permissionStore.isTrusted {
            Text("􀎡􀝰")
        } else if clickTimerStore.isRunning && settingsStore.showTimeInMenuBar {
            Text("􀝱 \(clickTimerStore.formattedTimeRemaining)")
        } else if clickTimerStore.isRunning {
            Text("􀐱􀝱")
        } else {
            Text("􀐱􀝰")
        }
    }
}
