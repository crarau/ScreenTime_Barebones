# ScreenTime_Barebones

### Project Introduction

- This is a bare-bones project to help you utilize Apple's Screen Time functionality.
- **Implements basic Screen Time features using three frameworks: FamilyControls, DeviceActivity, and ManagedSettings**.
- Implements an app that applies restrictions when you select apps to restrict and your desired time periods.

### What is Screen Time?

Screen Time is an Apple service that helps manage phone usage by tracking how often apps and websites are used and allowing usage restrictions.

Usage tracking and restrictions can apply to individual users or to children connected through iCloud.

Screen Time-related features can be developed using three frameworks together: FamilyControls, DeviceActivity, and ManagedSettings.

- **[FamilyControls](https://developer.apple.com/documentation/familycontrols)** : Framework that allows access to ManagedSettings and DeviceActivity, enabling the use of Screen Time features
- **[DeviceActivity](https://developer.apple.com/documentation/deviceactivity)** : Framework that monitors usage and performs restriction-related actions at desired times without needing to be explicitly run from the app
- **[ManagedSettings](https://developer.apple.com/documentation/managedsettings)** : Framework that actually performs app usage restrictions

### Project Structure

```swift
.
├── ScreenTime_Barebones // Main target of the project
│   ├── App
│   │   ├── ContentView.swift
│   │   ├── ScreenTime_BarebonesApp.swift
│   │   └── XCConfig
│   │       └── shared.xcconfig
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset
│   │   │   ├── AppIcon_box.png
│   │   │   └── Contents.json
│   │   ├── AppSymbol.imageset
│   │   │   ├── AppIcon.png
│   │   │   └── Contents.json
│   │   └── Contents.json
│   ├── Extension
│   │   ├── Bundle+Extension.swift
│   │   └── Color+Extension.swift
│   ├── Presentation 
│   │   ├── ViewModels
│   │   │   ├── Components
│   │   │   │   └── MainTabVM.swift
│   │   │   ├── PermissionVM.swift
│   │   │   └── ScheduleVM.swift // ViewModel for managing schedules that track usage time through Screen Time
│   │   └── Views
│   │       ├── Components
│   │       │   └── MainTabView.swift
│   │       ├── MonitoringView
│   │       │   └── MonitoringView.swift
│   │       ├── PermissionView
│   │       │   └── PermissionView.swift
│   │       └── ScheduleView
│   │           └── ScheduleView.swift
│   ├── Preview Content
│   │   └── Preview Assets.xcassets
│   │       └── Contents.json
│   ├── ScreenTime_Barebones.entitlements
│   └── Utils
│       ├── DeviceActivtyManager.swift
│       └── FamilyControlsManager.swift
├── DeviceActivityMonitor // Target for managing methods called when events occur based on created Screen Time schedules
│   ├── DeviceActivityMonitor.entitlements
│   ├── DeviceActivityMonitorExtension.swift
│   └── Info.plist
├── ScreenTimeReport // Target for viewing and managing usage history through Screen Time
│   ├── Info.plist
│   ├── ScreenTimeActivityReport.swift
│   ├── ScreenTimeReport.entitlements
│   ├── ScreenTimeReport.swift
│   ├── TotalActivityReport.swift
│   └── TotalActivityView.swift
├── ShieldAction // Target for managing methods called when events occur on screens where app usage is restricted through Screen Time
│   ├── Info.plist
│   ├── ShieldAction.entitlements
│   └── ShieldActionExtension.swift
└── ShieldConfiguration // Target that helps customize screens where app usage is restricted through Screen Time
    ├── AppSymbol.png
    ├── Info.plist
    ├── ShieldConfiguration.entitlements
    └── ShieldConfigurationExtension.swift
```

### Core Code

**✅ Requesting Screen Time Permissions**

- The Screen Time API can only be used after the user has completed the permission settings themselves.

```swift
// ./ScreenTime_Barebones/Utils/FamilyControlsManager.swift

import FamilyControls

class FamilyControlsManager: ObservableObject {
	// MARK: - Object managing FamilyControls permission status
    let authorizationCenter = AuthorizationCenter.shared
    
    // MARK: - Member variable to track Screen Time permission status
    @Published var hasScreenTimePermission: Bool = false

	@MainActor
    func requestAuthorization() {
        if authorizationCenter.authorizationStatus == .approved {
            print("ScreenTime Permission approved")
        } else {
            Task {
                do {
                    try await authorizationCenter.requestAuthorization(for: .individual)
                    hasScreenTimePermission = true
                    // Agreed
                } catch {
                    // Disagreed
                    print("Failed to enroll with error: \(error)")
                    hasScreenTimePermission = false
                    // User did not allow permission
                    // Error Domain=FamilyControls.FamilyControlsError Code=5 "(null)
                }
            }
        }
    }
}
```

**✅ Creating a Screen Time Schedule**

- You can create a schedule to monitor app usage during specific time periods.

```swift
// ./ScreenTime_Barebones/Utils/DeviceActivityManager.swift

class DeviceActivityManager: ObservableObject {

	/// DeviceActivityCenter is a class that controls monitoring for schedules you've set.
    /// We create an instance to handle actions like starting and stopping monitoring.
    let deviceActivityCenter = DeviceActivityCenter()

	func handleStartDeviceActivityMonitoring(
        startTime: DateComponents,
        endTime: DateComponents,
        deviceActivityName: DeviceActivityName = .daily,
        warningTime: DateComponents = DateComponents(minute: 5)
    ) {
        let schedule: DeviceActivitySchedule
        
        if deviceActivityName == .daily {
            schedule = DeviceActivitySchedule(
                intervalStart: startTime,
                intervalEnd: endTime,
                repeats: true,
                warningTime: warningTime
            )
            
            do {
                /// Starts monitoring for the Device Activity with the name passed in deviceActivityName during the period passed in schedule.
                try deviceActivityCenter.startMonitoring(deviceActivityName, during: schedule)
                /// Comment for debugging.
                /// You can check the currently monitored DeviceActivityName and schedule.
//                print("Monitoring started --> \(deviceActivityCenter.activities.description)")
//                print("Schedule --> \(schedule)")
            } catch {
                print("Unexpected error: \(error).")
            }
        }
    }
}

// MARK: - Schedule Name List
extension DeviceActivityName {
    static let daily = Self("daily")
}

// MARK: - MAnagedSettingsStore List
extension ManagedSettingsStore.Name {
    static let daily = Self("daily")
}
```

**✅ Restricting App Usage When Screen Time Schedule Events Occur**

- You can restrict app usage by utilizing events that occur during schedule execution.

```swift
// ./DeviceActivityMonitor/DeviceActivityMonitorExtension.swift

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
	let store = ManagedSettingsStore(named: .daily)
    let vm = ScheduleVM()

	// MARK: - Method called when the device is first used after the start time of the schedule
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Handle the start of the interval.
        // FamilyActivityPicker로 선택한 앱들에 실드(제한) 적용
        let appTokens = vm.selection.applicationTokens
        let categoryTokens = vm.selection.categoryTokens
        
        if appTokens.isEmpty {
            store.shield.applications = nil
        } else {
            store.shield.applications = appTokens
        }
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categoryTokens)
    }
    
    // MARK: - Method called when the device is first used after the end time of the schedule or when monitoring is stopped
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Handle the end of the interval.
        // Remove all shields that were applied to the store
        store.clearAllSettings()
    }
}
```

**✅ Customizing the Screen Shown in Apps Restricted During Schedule**

- When a restricted app is launched, Screen Time overlays a Shield View on the app to restrict its usage.

- The Shield View can be customized for a limited number of elements.

```swift
// ./ShieldConfiguration/ShieldConfigurationExtension.swift

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
		private func setShieldConfig(
        _ tokenName: String,
        hasSecondaryButton: Bool = false) -> ShieldConfiguration {
            let CUSTOM_ICON = UIImage(named: "AppSymbol.png")
        let CUSTOM_TITLE = ShieldConfiguration.Label(
            text: "Screen Time 101",
            color: ColorManager.accentColor
        )
        let CUSTOM_SUBTITLE = ShieldConfiguration.Label(
            text: "\(tokenName) is restricted.",
            color: .black
        )
        let CUSTOM_PRIMARY_BUTTON_LABEL = ShieldConfiguration.Label(
            text: "Close",
            color: .white
        )
        let CUSTOM_PRIAMRY_BUTTON_BACKGROUND: UIColor = ColorManager.accentColor
        let CUSTOM_SECONDARY_BUTTON_LABEL = ShieldConfiguration.Label(
            text: "눌러도 효과없음",
            color: ColorManager.accentColor
        )
        
        let ONE_BUTTON_SHIELD_CONFIG = ShieldConfiguration(
            backgroundBlurStyle: .systemChromeMaterialLight,
            backgroundColor: .white,
            icon: CUSTOM_ICON,
            title: CUSTOM_TITLE,
            subtitle: CUSTOM_SUBTITLE,
            primaryButtonLabel: CUSTOM_PRIMARY_BUTTON_LABEL,
            primaryButtonBackgroundColor: CUSTOM_PRIAMRY_BUTTON_BACKGROUND
        )
        
        let TWO_BUTTON_SHIELD_CONFIG = ShieldConfiguration(
            backgroundBlurStyle: .systemChromeMaterialLight,
            backgroundColor: .white,
            icon: CUSTOM_ICON,
            title: CUSTOM_TITLE,
            subtitle: CUSTOM_SUBTITLE,
            primaryButtonLabel: CUSTOM_PRIMARY_BUTTON_LABEL,
            primaryButtonBackgroundColor: CUSTOM_PRIAMRY_BUTTON_BACKGROUND,
            secondaryButtonLabel: CUSTOM_SECONDARY_BUTTON_LABEL
        )
        
        return hasSecondaryButton ? TWO_BUTTON_SHIELD_CONFIG : ONE_BUTTON_SHIELD_CONFIG
    }

	// MARK: - 어플리케이션만 제한된 앱
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        guard let displayName = application.localizedDisplayName else {
            return setShieldConfig("확인불가 앱")
        }
        return setShieldConfig(displayName)
    }
}
```

**✅ 스크린 타임 활동 조회하기**

- Device Activity Report Extension을 추가하여 스크린 타임 활동 내용을 모니터링 할 수 있습니다.

```swift
// ./ScreenTimeReport/ScreenTimeReport.swift

import DeviceActivity
import SwiftUI

@main
struct ScreenTimeReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(activityReport: totalActivity)
        }
        // Add more reports here...
    }
}
```

```swift
// ./ScreenTimeReport/TotalActivityReport.swift

import DeviceActivity
import SwiftUI

// MARK: - 각각의 Device Activity Report들에 대응하는 컨텍스트 정의
extension DeviceActivityReport.Context {
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    /// 해당 리포트의 내용 렌더링에 사용할 DeviceActivityReportScene에 대응하는 익스텐션이 필요합니다.  ex) TotalActivityReport
    static let totalActivity = Self("Total Activity")
}

// MARK: - Device Activity Report의 내용을 어떻게 구성할 지 설정
struct TotalActivityReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    /// 보여줄 리포트에 대한 컨텍스트를 정의해줍니다.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // Define the custom configuration and the resulting view for this report.
    /// 어떤 데이터를 사용해서 어떤 뷰를 보여줄 지 정의해줍니다. (SwiftUI View)
    let content: (ActivityReport) -> TotalActivityView
    
    /// DeviceActivityResults 데이터를 받아서 필터링
    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>) async -> ActivityReport {
        // Reformat the data into a configuration that can be used to create
        // the report's view.
        var totalActivityDuration: Double = 0 /// 총 스크린 타임 시간
        var list: [AppDeviceActivity] = [] /// 사용 앱 리스트
        
        /// DeviceActivityResults 데이터에서 화면에 보여주기 위해 필요한 내용을 추출해줍니다.
        for await eachData in data {
            /// 특정 시간 간격 동안 사용자의 활동
            for await activitySegment in eachData.activitySegments {
                /// 활동 세그먼트 동안 사용자의 카테고리 별 Device Activity
                for await categoryActivity in activitySegment.categories {
                    /// 이 카테고리의 totalActivityDuration에 기여한 사용자의 application Activity
                    for await applicationActivity in categoryActivity.applications {
                        let appName = (applicationActivity.application.localizedDisplayName ?? "nil") /// 앱 이름
                        let bundle = (applicationActivity.application.bundleIdentifier ?? "nil") /// 앱 번들id
                        let duration = applicationActivity.totalActivityDuration /// 앱의 total activity 기간
                        totalActivityDuration += duration
                        let numberOfPickups = applicationActivity.numberOfPickups /// 앱에 대해 직접적인 pickup 횟수
                        let token = applicationActivity.application.token /// 앱의 토큰
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
        
        /// 필터링된 ActivityReport 데이터들을 반환
        return ActivityReport(totalDuration: totalActivityDuration, apps: list)
    }
}
```

```swift
// ./ScreenTimeReport/TotalActivityView.swift

import SwiftUI
import FamilyControls

// MARK: - SwiftUI view to display in MonitoringView
struct TotalActivityView: View {
    var activityReport: ActivityReport
    
    var body: some View {

        ...

        /// Configure the Report View as desired.

        ...

    }
}
```

## **☕️ CoffeeNaeriRei**  

|Coffee|Rei|
|:---:|:---:|
|<img alt="" src="https://avatars.githubusercontent.com/u/88574289?v=4" width="150">|<img alt="" src="https://github.com/kybeen/kybeen/assets/89764127/54276ea1-b548-4f95-ab48-5887f0bf6137" width="150">|
|[<img src="https://img.shields.io/badge/Github-black?style=for-the-badge&logo=github&logoColor=white" alt="Github Blog Badge"/>](https://github.com/yuncoffee)|[<img src="https://img.shields.io/badge/Github-black?style=for-the-badge&logo=github&logoColor=white" alt="Github Blog Badge"/>](https://github.com/kybeen)|
| **💻 Developer** | **💻 Developer** |
| **🎨 Designer**
<br>

### References

**📼 Apple Developer Videos**

[Meet the Screen Time API - WWDC21 - Videos - Apple Developer](https://developer.apple.com/videos/play/wwdc2021/10123/)

[What's new in Screen Time API - WWDC22 - Videos - Apple Developer](https://developer.apple.com/videos/play/wwdc2022/110336/)

**🛠️ Troubleshooting Records**

[Screen Time API](https://www.notion.so/Screen-Time-API-c76cf8289958418a90d14e6ffd298e14?pvs=21)

**📚 WWDC Video Summaries**

[Summary of Screen Time related WWDC videos](https://healthy-degree-cc2.notion.site/Screen-Time-6fda458dbf0e43f5893afc9f1641844c?pvs=4)
