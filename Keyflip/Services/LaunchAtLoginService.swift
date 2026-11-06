//
//  LaunchAtLoginService.swift
//  Keyflip
//

import Observation
import ServiceManagement

/// Registers Keyflip as a login item through `SMAppService`, which works inside the sandbox.
@Observable
final class LaunchAtLoginService {
    private(set) var isEnabled = SMAppService.mainApp.status == .enabled
    private(set) var errorMessage: String?

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isEnabled = SMAppService.mainApp.status == .enabled
    }
}
