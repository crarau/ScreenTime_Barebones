//
//  ScreenTimeActivityReport.swift
//  ScreenTimeReport
//
//  Created by 김영빈 on 2023/08/11.
//

// MARK: - This file defines data models related to Device Activity Reports
import Foundation
import ManagedSettings

struct ActivityReport {
    let totalDuration: TimeInterval
    let apps: [AppDeviceActivity]
}

struct AppDeviceActivity: Identifiable {
    var id: String
    var displayName: String
    var duration: TimeInterval
    var numberOfPickups: Int
    var token: ApplicationToken?
}

extension TimeInterval {
    /// Method to convert TimeInterval type value to String in 00:00 format
    func toString() -> String {
        let time = NSInteger(self)
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return String(format: "%0.2d:%0.2d", hours,minutes)
    }
}
