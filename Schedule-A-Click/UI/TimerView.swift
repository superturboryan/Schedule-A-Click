//
//  TimerView.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-18.
//

import SwiftUI

struct TimerView: View {
    
    @EnvironmentObject var timerStore: ClickTimerStore
    @EnvironmentObject var permissionStore: PermissionStore
    
    @State var showSettings = false
    
    @AppStorage("Hours") var hours: String = "0"
    @AppStorage("Minutes") var minutes: String = "0"
    @AppStorage("Seconds") var seconds: String = "15"
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                header
                timerSettings
                countdown
                startButton
            }
            .padding()
            
            settingsOverlay
            permissionOverlay
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: timerStore.isRunning)
    }
    
    @ViewBuilder
    var header: some View {
        HStack {
            if !timerStore.isRunning{
                Button("Settings") {
                    withAnimation { showSettings.toggle() }
                }
            }
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        .buttonStyle(.bordered)
    }
    
    @ViewBuilder
    var timerSettings: some View {
        if !timerStore.isRunning {
            HStack {
                ForEach([
                    ("Hour", $hours, "h"),
                    ("Min", $minutes, "m"),
                    ("Sec", $seconds, "s")
                ], id: \.0) { (label, binding, suffix) in
                    VStack {
                        TextField(label, text: binding)
                            .frame(width: 50)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                        Text(suffix)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var countdown: some View {
        if timerStore.isRunning {
            Text("Clicking in \(timerStore.timeRemaining)...")
                .monospacedDigit()
                .font(.title3)
                .fontWeight(.medium)
                .contentTransition(.numericText())
                .animation(.default, value: timerStore.timeRemaining)
        }
    }
    
    var startButton: some View {
        Button {
            if timerStore.isRunning {
                timerStore.cancel()
            } else {
                timerStore.start(hours.intValue, minutes.intValue, seconds.intValue)
            }
        } label: {
            Text(timerStore.isRunning ? "Cancel" : "Schedule Click")
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .tracking(1)
                .textCase(.uppercase)
                .padding(.horizontal)
                .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .tint(timerStore.isRunning ? Color.pink.gradient : Color.green.gradient)
        .transition(.opacity)
        .disabled(!permissionStore.isTrusted)
    }
    
    @ViewBuilder
    var settingsOverlay: some View {
        let transition = PushTransition.push(from: .bottom).combined(with: MoveTransition.move(edge: .bottom))
        if showSettings {
            SettingsView(isPresented: $showSettings)
                .transition(transition)
        }
    }
    
    @ViewBuilder
    var permissionOverlay: some View {
        if !permissionStore.isTrusted {
            PermissionView()
                .transition(
                    PushTransition.push(from: .bottom)
                        .combined(with: MoveTransition.move(edge: .bottom))
                )
        }
    }
}

#Preview {
    TimerView()
        .environmentObject(ClickTimerStore())
}

extension String {
    var intValue: Int { Int(self) ?? 0 }
}
