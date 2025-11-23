//
//  TimerView.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-18.
//

import SwiftUI

struct TimerView: View {

    @EnvironmentObject var timerStore: ClickTimerStore
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var permissionStore: PermissionStore

    @State var showSettings = false

    @AppStorage("Hours") var hours: String = "0"
    @AppStorage("Minutes") var minutes: String = "0"
    @AppStorage("Seconds") var seconds: String = "15"

    @AppStorage("ScheduleHour") var scheduleHour: String = "12"
    @AppStorage("ScheduleMinute") var scheduleMinute: String = "0"
    @AppStorage("ScheduleSecond") var scheduleSecond: String = "0"
    @AppStorage("IsAM") var isAM: Bool = true

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                header
                modePicker
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
        .animation(.default, value: settingsStore.timerMode)
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
    var modePicker: some View {
        Picker("Mode", selection: settingsStore.$timerMode) {
            ForEach(TimerMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .disabled(timerStore.isRunning)
    }

    @ViewBuilder
    var timerSettings: some View {
        if !timerStore.isRunning {
            switch settingsStore.timerMode {
            case .countdown:
                countdownFields
            case .schedule:
                datePicker
            }
        }
    }

    @ViewBuilder
    var countdownFields: some View {
        HStack {
            ForEach([
                ("0", $hours, "h", 99),
                ("0", $minutes, "m", 59),
                ("0", $seconds, "s", 59)
            ], id: \.2) { (placeholder, binding, suffix, maxValue) in
                VStack {
                    TextField(placeholder, text: binding)
                        .frame(width: 50)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: binding.wrappedValue) { _, newValue in
                            validateAndClamp(binding, newValue: newValue, max: maxValue)
                        }
                    Text(suffix)
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
        }
    }

    private func validateAndClamp(_ binding: Binding<String>, newValue: String, max: Int) {
        // Remove non-numeric characters
        let filtered = newValue.filter { $0.isNumber }

        // Clamp to max value
        if let intValue = Int(filtered), intValue > max {
            binding.wrappedValue = String(max)
        } else if filtered != newValue {
            binding.wrappedValue = filtered
        } else if let intValue = Int(filtered), intValue < 0 {
            binding.wrappedValue = "0"
        }
    }

    @ViewBuilder
    var datePicker: some View {
        VStack(spacing: 12) {
            Text("Time of Day")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 4) {
                TextField("12", text: $scheduleHour)
                    .frame(width: 45)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: scheduleHour) { _, newValue in
                        validateTimeField($scheduleHour, newValue: newValue, max: settingsStore.use12HourFormat ? 12 : 23, min: settingsStore.use12HourFormat ? 1 : 0)
                    }

                Text(":")
                    .font(.title2)
                    .fontWeight(.semibold)

                TextField("00", text: $scheduleMinute)
                    .frame(width: 45)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: scheduleMinute) { _, newValue in
                        validateTimeField($scheduleMinute, newValue: newValue, max: 59, min: 0)
                    }

                Text(":")
                    .font(.title2)
                    .fontWeight(.semibold)

                TextField("00", text: $scheduleSecond)
                    .frame(width: 45)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: scheduleSecond) { _, newValue in
                        validateTimeField($scheduleSecond, newValue: newValue, max: 59, min: 0)
                    }

                if settingsStore.use12HourFormat {
                    Picker("", selection: $isAM) {
                        Text("AM").tag(true)
                        Text("PM").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 70)
                }
            }

            Text("Click will occur at the next \(formattedScheduledTime)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var formattedScheduledTime: String {
        let hour = scheduleHour.intValue
        let minute = String(format: "%02d", scheduleMinute.intValue)
        let second = String(format: "%02d", scheduleSecond.intValue)

        if settingsStore.use12HourFormat {
            let period = isAM ? "AM" : "PM"
            return "\(hour):\(minute):\(second) \(period)"
        } else {
            return "\(String(format: "%02d", hour)):\(minute):\(second)"
        }
    }

    private func validateTimeField(_ binding: Binding<String>, newValue: String, max: Int, min: Int) {
        // Remove non-numeric characters
        let filtered = newValue.filter { $0.isNumber }

        // Clamp to max/min value
        if let intValue = Int(filtered) {
            if intValue > max {
                binding.wrappedValue = String(max)
            } else if intValue < min {
                binding.wrappedValue = String(min)
            } else if filtered != newValue {
                binding.wrappedValue = filtered
            }
        } else if filtered != newValue {
            binding.wrappedValue = filtered
        }
    }

    private func convertTo24Hour(hour: Int, isAM: Bool, useAMPM: Bool) -> Int {
        guard useAMPM else { return hour }

        if isAM {
            // 12 AM is 0 in 24-hour format, 1-11 AM stay the same
            return hour == 12 ? 0 : hour
        } else {
            // 12 PM stays 12, 1-11 PM add 12
            return hour == 12 ? 12 : hour + 12
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
                switch settingsStore.timerMode {
                case .countdown:
                    timerStore.start(
                        hours.intValue,
                        minutes.intValue,
                        seconds.intValue,
                        clickType: settingsStore.clickType,
                        playSound: settingsStore.playSound
                    )
                case .schedule:
                    let hour24 = convertTo24Hour(hour: scheduleHour.intValue, isAM: isAM, useAMPM: settingsStore.use12HourFormat)
                    timerStore.startAtNextOccurrence(
                        hour: hour24,
                        minute: scheduleMinute.intValue,
                        second: scheduleSecond.intValue,
                        clickType: settingsStore.clickType,
                        playSound: settingsStore.playSound
                    )
                }
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
