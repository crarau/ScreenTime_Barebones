//
//  ScheduleView.swift
//  ScreenTime_Barebones
//
//  Created by Yun Dongbeom on 2023/08/08.
//

import SwiftUI
import FamilyControls
/**
 
 1. Should be able to check permission settings
 2. Schedule settings (time settings)
 3. App settings
 4. Create monitoring schedule based on the set schedule and app settings
 
 */

struct ScheduleView: View {
//    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var scheduleVM: ScheduleVM

    /// Variable to store selected apps before pressing the Save Schedule button.
    @State var tempSelection = FamilyActivitySelection()
    
    var body: some View {
        NavigationView {
            VStack {
                setupListView()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar { savePlanButtonView() }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .familyActivityPicker(
                isPresented: $scheduleVM.isFamilyActivitySectionActive,
                selection: $tempSelection
            )
            .alert("Saved successfully.", isPresented: $scheduleVM.isSaveAlertActive) {
                Button("OK", role: .cancel) {}
            }
            .alert("When monitoring stops, the set time and apps will be reset.", isPresented: $scheduleVM.isStopMonitoringAlertActive) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm", role: .destructive) {
                    tempSelection = FamilyActivitySelection()
                    scheduleVM.stopScheduleMonitoring()
                }
            }
            .alert("When permission is removed, the schedule will also be removed.", isPresented: $scheduleVM.isRevokeAlertActive) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm", role: .destructive) {
                    FamilyControlsManager.shared.requestAuthorizationRevoke()
                }
            }
        }
        .onAppear {
            tempSelection = scheduleVM.selection
        }
//        .onChange(of: colorScheme) { _ in
//            tempSelection = scheduleVM.selection
//        }
    }
}

// MARK: - Views
extension ScheduleView {
    
    /// Schedule page right toolbar top button.
    private func savePlanButtonView() -> ToolbarItemGroup<Button<Text>> {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            let BUTTON_LABEL = "Save Schedule"
            
            Button {
                scheduleVM.saveSchedule(selectedApps: tempSelection)
            } label: {
                Text(BUTTON_LABEL)
            }
        }
    }
    
    /// Complete list view within the schedule page.
    private func setupListView() -> some View {
        List {
            setUpTimeSectionView()
            setUPAppSectionView()
            stopScheduleMonitoringSectionView()
            revokeAuthSectionView()
        }
        .listStyle(.insetGrouped)
    }
    
    /// View for the time setting section in the main list.
    private func setUpTimeSectionView() -> some View {
        let TIME_LABEL_LIST = ["Start Time", "End Time"]
        let times = [$scheduleVM.scheduleStartTime, $scheduleVM.scheduleEndTime]
        
        return Section(
            header: Text(ScheduleSectionInfo.time.header),
            footer: Text(ScheduleSectionInfo.time.footer)) {
                ForEach(0..<TIME_LABEL_LIST.count, id: \.self) { index in
                    DatePicker(selection: times[index], displayedComponents: .hourAndMinute) {
                        Text(TIME_LABEL_LIST[index])
                    }
                }
            }
    }
    
    /// View for the app setting section in the main list.
    private func setUPAppSectionView() -> some View {
        let BUTTON_LABEL = "Change"
        let EMPTY_TEXT = "Choose Your App"
        
        return Section(
            header: HStack {
                Text(ScheduleSectionInfo.apps.header)
                Spacer()
                Button {
                    scheduleVM.showFamilyActivitySelection()
                } label: {
                    Text(BUTTON_LABEL)
                }
            },
            footer: Text(ScheduleSectionInfo.apps.footer)
        ) {
            if isSelectionEmpty() {
                Text(EMPTY_TEXT)
                    .foregroundColor(Color.secondary)
            } else {
                ForEach(Array(tempSelection.applicationTokens), id: \.self) { token in
                    Label(token)
                }
                ForEach(Array(tempSelection.categoryTokens), id: \.self) { token in
                    Label(token)
                }
                ForEach(Array(tempSelection.webDomainTokens), id: \.self) { token in
                    Label(token)
                }
            }
        }
    }
    
    /// View for the stop schedule monitoring section in the main list.
    private func stopScheduleMonitoringSectionView() -> some View {
        Section(
            header: Text(ScheduleSectionInfo.monitoring.header)
        ) {
            stopScheduleMonitoringButtonView()
        }
    }
    
    /// Button for stopping schedule monitoring.
    private func stopScheduleMonitoringButtonView() -> some View {
        let BUTTON_LABEL = "Stop Schedule Monitoring"
        
        return Button {
            scheduleVM.showStopMonitoringAlert()
        } label: {
            Text(BUTTON_LABEL)
                .tint(Color.red)
        }
    }
    
    /// View for the permission removal section in the main list.
    private func revokeAuthSectionView() -> some View {
        Section(
            header: Text(ScheduleSectionInfo.revoke.header)
        ) {
            revokeAuthButtonView()
        }
    }
    
    /// Button for the permission removal section.
    /// When clicked, it removes Screen Time permission through an alert window.
    private func revokeAuthButtonView() -> some View {
        let BUTTON_LABEL = "Remove Screen Time Permission"
        
        return Button {
            scheduleVM.showRevokeAlert()
        } label: {
            Text(BUTTON_LABEL)
                .tint(Color.red)
        }
    }
    
}

// MARK: - Methods
extension ScheduleView {
    
    /// Method to check if the user-selected app & domain tokens are empty.
    private func isSelectionEmpty() -> Bool {
        tempSelection.applicationTokens.isEmpty &&
        tempSelection.categoryTokens.isEmpty &&
        tempSelection.webDomainTokens.isEmpty
    }
    
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}
