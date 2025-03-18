//
//  PermissionVM.swift
//  ScreenTime_Barebones
//
//  Created by Yun Dongbeom on 2023/08/13.
//

import Foundation
import SwiftUI

class PermissionVM: ObservableObject {
    @Published var isViewLoaded = false
    @Published var isSheetActive = false
    
    let HEADER_ICON_LABEL = "info.circle.fill"
    
    let DECORATION_TEXT_INFO = (
        imgSrc: "AppSymbol",
        title: "Screen Time 101",
        subTitle: "Let's explore the basic\nfunctions of Screen Time API."
    )
    
    let PERMISSION_BUTTON_LABEL = "Get Started"
    
    let SHEET_INFO_LIST = [
        "You can restrict and monitor app/web usage at specific times using the ScreenTime API.",
        "For more detailed information, please refer to the GitHub repo through the button below.\nImprovements and inquiries are always welcome."
    ]
    
    let GIT_LINK_LABEL = "[Check GitHub](https://github.com/CoffeeNaeriRei/ScreenTime_Barebones)"
}

extension PermissionVM {
    func handleTranslationView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                self.isViewLoaded = true
            }
        }
    }
    
    func showIsSheetActive() {
        isSheetActive = true
    }
    
    @MainActor
    func handleRequestAuthorization() {
        FamilyControlsManager.shared.requestAuthorization()
    }
}
