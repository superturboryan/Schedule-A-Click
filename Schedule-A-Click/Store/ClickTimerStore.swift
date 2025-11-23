//
//  ClickTimerStore.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-18.
//

import SwiftUI

enum TimerMode: String, CaseIterable {
    case countdown = "Countdown"
    case schedule = "Schedule"
}

final class ClickTimerStore: ObservableObject {

    @Published var isRunning = false
    @Published var scheduledTime: Date?

    private var timer: Timer?

    /// Calculated time remaining until the scheduled click
    var timeRemaining: Int {
        guard let scheduledTime else { return 0 }
        return max(0, Int(scheduledTime.timeIntervalSince(Date())))
    }

    var formattedTimeRemaining: String {
        let remaining = timeRemaining
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    /// Returns the formatted scheduled time
    /// - Parameter use12Hour: Whether to use 12-hour format
    /// - Returns: Formatted time string (e.g., "3:45 PM" or "15:45")
    func formattedScheduledTime(use12Hour: Bool) -> String {
        guard let scheduledTime else { return "" }

        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        if use12Hour {
            formatter.dateFormat = "h:mm:ss a"
        } else {
            formatter.dateFormat = "HH:mm:ss"
        }

        return formatter.string(from: scheduledTime)
    }

    func start(_ hours: Int, _ minutes: Int, _ seconds: Int, clickType: ClickType, playSound: Bool) {
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        guard totalSeconds > 0 else { return }

        // Calculate scheduled time from now + duration
        scheduledTime = Date().addingTimeInterval(TimeInterval(totalSeconds))
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self, let scheduledTime = self.scheduledTime else { return }

            if Date() >= scheduledTime {
                t.invalidate()
                self.timer = nil
                Mouse.click(type: clickType, playSound: playSound)
                self.isRunning = false
                self.scheduledTime = nil
            }
        }
    }

    func startAt(_ date: Date, clickType: ClickType, playSound: Bool) {
        let now = Date()
        guard date > now else { return }

        scheduledTime = date
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self, let scheduledTime = self.scheduledTime else { return }

            if Date() >= scheduledTime {
                t.invalidate()
                self.timer = nil
                Mouse.click(type: clickType, playSound: playSound)
                self.isRunning = false
                self.scheduledTime = nil
            }
        }
    }

    func startAtNextOccurrence(hour: Int, minute: Int, second: Int, clickType: ClickType, playSound: Bool) {
        let calendar = Calendar.current
        let now = Date()

        // Create a date with today's date but the specified time
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = second

        guard let todayAtTime = calendar.date(from: components) else { return }

        // If the time has already passed today, schedule for tomorrow
        let targetDate: Date
        if todayAtTime > now {
            targetDate = todayAtTime
        } else {
            // Add one day
            guard let tomorrowAtTime = calendar.date(byAdding: .day, value: 1, to: todayAtTime) else { return }
            targetDate = tomorrowAtTime
        }

        // Use the existing startAt method
        startAt(targetDate, clickType: clickType, playSound: playSound)
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        scheduledTime = nil
        isRunning = false
    }
}
