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
                settingsStore.windowWidth = newValue ? 320 : 380
                settingsStore.windowHeight = newValue ? 280 : 380
            }
    }
    
    @ViewBuilder
    var menuBarLabel: some View {
        HStack {
            if !permissionStore.isTrusted {
                Text("􀎡􀝰")
            } else {
                Image(.handTimerSymbol)
                    .resizable()
                    .scaledToFit()
            }
            
            if clickTimerStore.isRunning && settingsStore.showTimeInMenuBar {
                Text("\(clickTimerStore.formattedTimeRemaining)")
            }
        }
    }
}
