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

    @Published var isRunning: Bool = false
    @Published var timeRemaining: Int = 0

    private var timer: Timer?
    private var targetDate: Date?

    var formattedTimeRemaining: String {
        let hours = timeRemaining / 3600
        let minutes = (timeRemaining % 3600) / 60
        let seconds = timeRemaining % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    func start(_ hours: Int, _ minutes: Int, _ seconds: Int, clickType: ClickType, playSound: Bool) {
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        guard totalSeconds > 0 else { return }

        timeRemaining = totalSeconds
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self else { return }
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                t.invalidate()
                self.timer = nil
                Mouse.click(type: clickType, playSound: playSound)
                self.isRunning = false
            }
        }
    }

    func startAt(_ date: Date, clickType: ClickType, playSound: Bool) {
        let now = Date()
        guard date > now else { return }

        targetDate = date
        timeRemaining = Int(date.timeIntervalSince(now))
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self, let targetDate = self.targetDate else { return }
            let now = Date()
            self.timeRemaining = max(0, Int(targetDate.timeIntervalSince(now)))

            if self.timeRemaining <= 0 {
                t.invalidate()
                self.timer = nil
                self.targetDate = nil
                Mouse.click(type: clickType, playSound: playSound)
                self.isRunning = false
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
        targetDate = nil
        isRunning = false
        timeRemaining = 0
    }
}
