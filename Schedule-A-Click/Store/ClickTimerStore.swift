//
//  ClickTimerStore.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-18.
//

import SwiftUI

final class ClickTimerStore: ObservableObject {
    
    @Published var isRunning: Bool = false
    @Published var timeRemaining: Int = 0
    
    private var timer: Timer?
    
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
    
    func start(_ hours: Int, _ minutes: Int, _ seconds: Int) {
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
                Mouse.click()
                self.isRunning = false
            }
        }
    }
    
    func cancel() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        timeRemaining = 0
    }
}
