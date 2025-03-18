//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Yun Dongbeom on 2023/08/08.
//

import ManagedSettings

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
// MARK: - ShieldAction
/// You can write actions for button clicks in the Block View that restricts usage
/// when accessing apps/web domains set with FamilyActivitySelection during scheduled times.
class ShieldActionExtension: ShieldActionDelegate {
    
    // MARK: ApplicationToken으로 설정 된 앱에서 버튼 클릭 시 동작을 설정합니다.
    /// The ShieldAction parameter of the handle method is divided into two cases:
    ///  - .primaryButtonPressed: Corresponds to the primaryButtonLabel of ShieldConfiguration.
    ///  - .secondaryButtonPressed: Corresponds to the secondaryButtonLabel of ShieldConfiguration.
    /// * If you don't distinguish between cases or don't use them, it can be set to work on all button clicks.
    /// * If there is no secondaryButtonLabel set in ShieldConfiguration, that case cannot be used.
    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void) {
            // Handle the action as needed.
            switch action {
            case .primaryButtonPressed:
                /// Makes the system close the current application or web browser.
                completionHandler(.close)
            case .secondaryButtonPressed:
                /// Delays the response to the action and refreshes the view.
                completionHandler(.defer)
            @unknown default:
                fatalError()
            }
        }
    
    // MARK: Set actions for button clicks in apps set with ApplicationToken
    /// The ShieldAction parameter of the handle method is divided into two cases:
    // MARK: WebDomainToken으로 설정 된 웹에서 버튼 클릭 시 동작을 설정합니다.
    // MARK: Set actions for button clicks on web pages set with WebDomainToken
    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void) {
            // Handle the action as needed.
            completionHandler(.close)
        }
    
    // MARK: ActivityCategoryToken으로 설정 된 웹에서 버튼 클릭 시 동작을 설정합니다.
    // MARK: Set actions for button clicks on content set with ActivityCategoryToken
    /// ActivityCategory is a higher-level category group that classifies each Application based on App Category.
    /// The system recognizes it as set with ActivityCategory when all Applications within the ActivityCategory are set.
    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void) {
            switch action {
            case .primaryButtonPressed:
                /// Makes the system close the current application or web browser.
                completionHandler(.close)
            case .secondaryButtonPressed:
                /// No additional action and does not refresh the view.
                completionHandler(.none)
            @unknown default:
                fatalError()
            }
        }
}
