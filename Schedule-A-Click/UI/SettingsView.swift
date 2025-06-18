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
        VStack(spacing: 24) {
            Text("Settings")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading) {
                startOnLoginToggle
                Toggle(isOn: store.$showTimeInMenuBar) {
                    Text("Show Time in Menu Bar")
                }
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
