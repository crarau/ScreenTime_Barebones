// MARK: - Schedule settings member variables
@AppStorage("scheduleStartTime", store: UserDefaults(suiteName: Bundle.main.appGroupName))
var scheduleStartTime = Date() // Current time
@AppStorage("scheduleEndTime", store: UserDefaults(suiteName: Bundle.main.appGroupName))
var scheduleEndTime = Date() + 900 // Current time + 15 minutes
// MARK: - Member variables containing user-selected apps/domains

// MARK: - Open FamilyActivity Sheet
/// When called, opens FamilyActivitySelection where the user can select
/// apps or web domains installed on the device they want to restrict.

// MARK: - Open ScreenTime API permission removal alert
/// When called, opens an alert to remove ScreenTime API permission
/// that was granted for app usage.

// MARK: - Save schedule
/// You can monitor the set time by passing it through DeviceActivityManager.
/// When monitoring is registered, you can detect events at specific times using DeviceActivityMonitorExtension.

// MARK: - Stop schedule monitoring
/// Stops monitoring the currently monitored schedule.

// MARK: - Open stop schedule monitoring alert
/// When called, opens an alert to stop monitoring
/// the currently monitored schedule. 