//
//  Mouse.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-18.
//

import AppKit
import ApplicationServices

enum Mouse {
    
    static func click() {
        guard AXIsProcessTrusted() else { return }
        
        let location = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let flippedY = screenHeight - location.y
        let point = CGPoint(x: location.x, y: flippedY)

        let mouseDown = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: point,
            mouseButton: .left
        )
        let mouseUp = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseUp,
            mouseCursorPosition: point,
            mouseButton: .left
        )

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }
}
