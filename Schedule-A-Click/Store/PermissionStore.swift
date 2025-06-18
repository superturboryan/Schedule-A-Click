//
//  PermissionStore.swift
//  Schedule-A-Click
//
//  Created by Ryan on 2025-06-19.
//

import Cocoa

final class PermissionStore: ObservableObject {
    
    @Published var isTrusted: Bool = AXIsProcessTrusted()
    
    private var pollingTask: Task<Void, Never>?
    
    init() {
        pollingTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(0.5))
                self.isTrusted = AXIsProcessTrusted()
            }
        }
    }
}
