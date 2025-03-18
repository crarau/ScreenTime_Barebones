//
//  TotalActivityReport.swift
//  ScreenTimeReport
//
//  Created by 김영빈 on 2023/08/09.
//

import DeviceActivity
import SwiftUI

// MARK: - Context definition for each Device Activity Report
extension DeviceActivityReport.Context {
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    /// You need an extension that corresponds to the DeviceActivityReportScene to be used for rendering the
 contents of this report. ex) TotalActivityReport
    static let totalActivity = Self("Total Activity")
}

// MARK: - Configuration for Device Activity Report content
struct TotalActivityReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    /// Define the context for the report to display.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // Define the custom configuration and the resulting view for this report.
    /// Define which data to use and which view to show. (SwiftUI View)
    let content: (ActivityReport) -> TotalActivityView
    
    /// Filter data received from DeviceActivityResults
    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>) async -> ActivityReport {
        // Reformat the data into a configuration that can be used to create
        // the report's view.
        var totalActivityDuration: Double = 0 /// Total screen time
        var list: [AppDeviceActivity] = [] /// List of used apps
        
        /// Extract information needed to display from DeviceActivityResults data.
        for await eachData in data {
            /// User activity during a specific time interval
            for await activitySegment in eachData.activitySegments {
                /// User's Device Activity by category during the activity segment
                for await categoryActivity in activitySegment.categories {
                    /// User's application Activity that contributed to this category's totalActivityDuration
                    for await applicationActivity in categoryActivity.applications {
                        let appName = (applicationActivity.application.localizedDisplayName ?? "nil") /// App name
                        let bundle = (applicationActivity.application.bundleIdentifier ?? "nil") /// App bundle ID
                        let duration = applicationActivity.totalActivityDuration /// App's total activity duration
                        totalActivityDuration += duration
                        let numberOfPickups = applicationActivity.numberOfPickups /// Number of direct pickups for the app
                        let token = applicationActivity.application.token /// App's token
                        let appActivity = AppDeviceActivity(
                            id: bundle,
                            displayName: appName,
                            duration: duration,
                            numberOfPickups: numberOfPickups,
                            token: token
                        )
                        list.append(appActivity)
                    }
                }

            }
        }
        
        /// Return filtered ActivityReport data
        return ActivityReport(totalDuration: totalActivityDuration, apps: list)
    }
}
