//
//  SettingsView.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-18.
//

import ServiceManagement
import StoreKit
import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var store: SettingsStore
    
    @State var closeButtonHover = false
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.title3)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 10) {
                startOnLoginToggle
                Toggle(isOn: store.$showTimeInMenuBar) {
                    Text("Show Time in Menu Bar")
                }
                Toggle(isOn: store.$playSound) {
                    Text("Play Sound on Click")
                }
                Toggle(isOn: store.$use12HourFormat) {
                    Text("Use 12-Hour Format")
                }
            }

            Divider()

            VStack(spacing: 8) {
                Text("Click Type")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Picker("Click Type", selection: store.$clickType) {
                    ForEach(ClickType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            Divider()

            Button("Rate App") {
                AppStore.requestReview(in: NSViewController())
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    store.hasRatedApp = true
                }
            }
            .disabled(store.hasRatedApp)
        }
        .padding()
        .overlay(alignment: .topLeading) {
            closeButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Color.secondarySystemBackground.ignoresSafeArea() }
    }
    
    var startOnLoginToggle: some View {
        Toggle(isOn: store.$startOnLogin) {
            Text("Start App On Login")
        }
        .onChange(of: store.startOnLogin) { _, newValue in
            Task {
                do {
                    if newValue {
                        try SMAppService.mainApp.register()
                    } else {
                        try await SMAppService.mainApp.unregister()
                    }
                } catch {
                    print("Error setting login item: \(error)")
                }
            }
        }
    }
    
    var closeButton: some View {
        HStack {
            Button {
                isPresented.toggle()
            } label: {
                Image(systemName: closeButtonHover ? "x.circle.fill" : "circle.fill")
            }
            Spacer()
        }
        .buttonStyle(.plain)
        .foregroundStyle(closeButtonHover ? .red : .secondary)
        .onHover { closeButtonHover = $0 }
        .animation(.default, value: closeButtonHover)
        .padding()
    }
}
