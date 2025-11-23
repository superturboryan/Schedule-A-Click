//
//  Mouse.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-18.
//

import AppKit
import ApplicationServices
import AVFoundation

enum ClickType: String, CaseIterable {
    case left = "Left Click"
    case right = "Right Click"
    case double = "Double Click"
}

enum Mouse {

    static func click(type: ClickType = .left, playSound: Bool = false) {
        guard AXIsProcessTrusted() else { return }

        let location = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let flippedY = screenHeight - location.y
        let point = CGPoint(x: location.x, y: flippedY)

        switch type {
        case .left:
            performClick(
                at: point,
                mouseType: .leftMouseDown,
                upType: .leftMouseUp,
                button: .left,
                clickCount: 1
            )
        case .right:
            performClick(
                at: point,
                mouseType: .rightMouseDown,
                upType: .rightMouseUp,
                button: .right,
                clickCount: 1
            )
        case .double:
            performClick(
                at: point,
                mouseType: .leftMouseDown,
                upType: .leftMouseUp,
                button: .left,
                clickCount: 2
            )
        }

        if playSound {
            NSSound.beep()
        }
    }

    private static func performClick(at point: CGPoint, mouseType: CGEventType, upType: CGEventType, button: CGMouseButton, clickCount: Int) {
        let mouseDown = CGEvent(
            mouseEventSource: nil,
            mouseType: mouseType,
            mouseCursorPosition: point,
            mouseButton: button
        )
        let mouseUp = CGEvent(
            mouseEventSource: nil,
            mouseType: upType,
            mouseCursorPosition: point,
            mouseButton: button
        )

        mouseDown?.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))
        mouseUp?.setIntegerValueField(.mouseEventClickState, value: Int64(clickCount))

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }
}
