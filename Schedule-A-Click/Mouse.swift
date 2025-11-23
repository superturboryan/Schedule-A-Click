//
//  Mouse.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-18.
//

import AppKit
import ApplicationServices
import AVFoundation

// MARK: - Click Type

enum ClickType: String, CaseIterable {
    case left = "Left 1x"
    case right = "Right 1x"
    case doubleLeft = "Left 2x"
    case doubleRight = "Right 2x"

    var button: CGMouseButton {
        switch self {
        case .left, .doubleLeft: .left
        case .right, .doubleRight: .right
        }
    }

    var mouseDownType: CGEventType {
        switch self {
        case .left, .doubleLeft: .leftMouseDown
        case .right, .doubleRight: .rightMouseDown
        }
    }

    var mouseUpType: CGEventType {
        switch self {
        case .left, .doubleLeft: .leftMouseUp
        case .right, .doubleRight: .rightMouseUp
        }
    }

    var isDouble: Bool {
        switch self {
        case .left, .right: false
        case .doubleLeft, .doubleRight: true
        }
    }
}

// MARK: - Mouse Click Automation

enum Mouse {

    /// Performs a mouse click at the current cursor position
    /// - Parameters:
    ///   - type: The type of click to perform
    ///   - playSound: Whether to play a system beep after the click
    static func click(type: ClickType = .left, playSound: Bool = false) {
        guard AXIsProcessTrusted() else { return }

        let point = convertToQuartzCoordinates(NSEvent.mouseLocation)

        if type.isDouble {
            performDoubleClick(at: point, type: type)
        } else {
            performSingleClick(at: point, type: type)
        }

        if playSound {
            NSSound.beep()
        }
    }

    // MARK: - Private Helpers

    /// Converts AppKit coordinates to Quartz coordinates
    /// - AppKit: Origin at bottom-left, Y increases upward
    /// - Quartz: Origin at top-left, Y increases downward
    private static func convertToQuartzCoordinates(_ point: NSPoint) -> CGPoint {
        let maxY = NSScreen.screens.map { $0.frame.maxY }.max() ?? 0
        let flippedY = maxY - point.y
        return CGPoint(x: point.x, y: flippedY)
    }

    /// Performs a single click (left or right)
    private static func performSingleClick(at point: CGPoint, type: ClickType) {
        postClickEvents(at: point, type: type, clickCount: 1)
    }

    /// Performs a double click by sending two rapid click sequences
    private static func performDoubleClick(at point: CGPoint, type: ClickType) {
        // First click with clickCount=1
        postClickEvents(at: point, type: type, clickCount: 1)

        // Brief delay between clicks (10ms)
        usleep(10_000)

        // Second click with clickCount=2
        postClickEvents(at: point, type: type, clickCount: 2)
    }

    /// Posts mouse down and up events to the system
    private static func postClickEvents(at point: CGPoint, type: ClickType, clickCount: Int) {
        guard let mouseDown = CGEvent(
            mouseEventSource: nil,
            mouseType: type.mouseDownType,
            mouseCursorPosition: point,
            mouseButton: type.button
        ),
        let mouseUp = CGEvent(
            mouseEventSource: nil,
            mouseType: type.mouseUpType,
            mouseCursorPosition: point,
            mouseButton: type.button
        ) else {
            return
        }

        mouseDown.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))
        mouseUp.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))

        mouseDown.post(tap: .cghidEventTap)
        mouseUp.post(tap: .cghidEventTap)
    }
}
