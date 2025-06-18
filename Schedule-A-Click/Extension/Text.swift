//
//  Text.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-19.
//

import SwiftUI

extension Text {
    
    static func md(_ markdownText: String) -> Text {
        guard var attr = try? AttributedString(
            markdown: markdownText,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        ) else {
            return Text("⚠️ Failed to parse markdown")
        }
        
        attr.foregroundColor = .primary
        
        for run in attr.runs where run.link != nil {
            attr[run.range].foregroundColor = .blue
            attr[run.range].underlineStyle = .single
        }
        
        return Text(attr)
    }
}
