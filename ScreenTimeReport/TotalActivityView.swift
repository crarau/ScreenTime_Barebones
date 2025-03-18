//
//  TotalActivityView.swift
//  ScreenTimeReport
//
//  Created by 김영빈 on 2023/08/09.
//

import SwiftUI
import FamilyControls

// MARK: - SwiftUI view to display in MonitoringView
struct TotalActivityView: View {
    var activityReport: ActivityReport
    
    var body: some View {
        VStack(spacing: 4) {
            Spacer(minLength: 24)
            Text("Total Screen Time Usage")
                .font(.callout)
                .foregroundColor(.secondary)
            Text(activityReport.totalDuration.toString())
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 8)
            List {
                Section {
                    ForEach(activityReport.apps) { eachApp in
                        ListRow(eachApp: eachApp)
                    }
                } footer: {
                    /**
                     Reference article about Pickup
                     - Research shows that Pickup is not simply counted by the number of times the screen is turned on, but is counted when specific interaction criteria set by Apple are met.
                     - Therefore, even when app monitoring time is calculated, you may often notice that the screen wake count is not counted.
                     https://www.imobie.com/support/what-are-pickups-in-screen-time.htm#q1
                     https://www.theverge.com/2018/9/17/17870126/ios-12-screen-time-app-limits-downtime-features-how-to-use
                     */
                    Text(
                    """
                    [Screen Wake-ups] refers to the number of times you turned on a dark screen to use the app.
                    👉You can also check the number of screen wake-ups in [Settings] app → [Screen Time] → [View All Activity].
                    """
                    )
                }
            }
        }
    }
}

struct ListRow: View {
    var eachApp: AppDeviceActivity
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                if let token = eachApp.token {
                    Label(token)
                        .labelStyle(.iconOnly)
                        .offset(x: -4)
                }
                Text(eachApp.displayName)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Screen Wake-ups")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(width: 72, alignment: .leading)
                        Text("\(eachApp.numberOfPickups) times")
                            .font(.headline)
                            .bold()
                            .frame(minWidth: 52, alignment: .trailing)
                    }
                    HStack(spacing: 4) {
                        Text("Monitoring Time")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(width: 72, alignment: .leading)
                        Text(String(eachApp.duration.toString()))
                            .font(.headline)
                            .bold()
                            .frame(minWidth: 52, alignment: .trailing)
                    }
                }
            }
            HStack {
                Text("App ID")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text(eachApp.id)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .bold()
                Spacer()
            }
        }
        .background(.clear)
    }
}

// MARK: - SwiftUI view to display in MonitoringView
