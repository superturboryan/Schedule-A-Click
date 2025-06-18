//
//  PermissionView.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-19.
//

import SwiftUI

struct PermissionView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            Text("👋 Welcome to Schedule-A-Click")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(spacing: 10) {
                Text("To schedule clicks, Schedule-A-Click needs permission to control your Mac.")
                Text.md("[**See FAQ**](https://github.com/superturboryan/Schedule-A-Click/discussions/1)")
                Text.md("Click **Open Settings** below, then in \n**Privacy & Security → Accessibility** \nadd Schedule-A-Click to the list of allowed apps.")
            }
            .lineSpacing(2)
            
            Button {
                openAccessibilitySettings()
            } label: {
                Label("Open Settings", systemImage: "gear")
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .tracking(1)
                    .textCase(.uppercase)
                    .padding(.vertical, 4)
                    .frame(width: 200)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.blue.gradient)
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Color.secondarySystemBackground.ignoresSafeArea() }
    }
    
    func openAccessibilitySettings() {
        guard let url = URL(string:"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return }
        NSWorkspace.shared.open(url)
    }
}
