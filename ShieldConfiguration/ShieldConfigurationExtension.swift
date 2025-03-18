//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Yun Dongbeom on 2023/08/08.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
// MARK: - ShieldView Customization
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    // MARK: - Method to customize ShieldView with restricted app/web domain information
    /// The ShieldView that overlays when app/web domain usage is restricted can be customized using ShieldConfiguration.
    /// Try customizing using the app information received from each configuration method.
    ///  * Customization of ShieldView is limited outside ShieldConfiguration init.
    ///  * For more information, check the link below.
    ///  https://developer.apple.com/documentation/managedsettingsui/shieldconfiguration
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
            text: "No effect",
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
    
    // MARK: - App with only application restricted
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        guard let displayName = application.localizedDisplayName else {
            return setShieldConfig("Unrecognized App")
        }
        return setShieldConfig(displayName)
    }
    
    // MARK: - App with application restricted through category
    override func configuration(
        shielding application: Application,
        in category: ActivityCategory) -> ShieldConfiguration {
            // Customize the shield as needed for applications shielded because of their category.
        guard let displayName = application.localizedDisplayName,
              let categoryName = category.localizedDisplayName else {
            return setShieldConfig("Unrecognized App")
        }
        return setShieldConfig(categoryName + " " + displayName, hasSecondaryButton: true)
    }
    
    // MARK: - App with only web domain restricted
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        guard let displayName = webDomain.domain else {
            return setShieldConfig("Unrecognized Web Domain")
        }
        return setShieldConfig(displayName)
    }
    
    // MARK: - App with web domain restricted through category
    override func configuration(
        shielding webDomain: WebDomain,
        in category: ActivityCategory) -> ShieldConfiguration {
            // Customize the shield as needed for web domains shielded because of their category.
        guard let displayName = webDomain.domain,
              let categoryName = category.localizedDisplayName else {
            return setShieldConfig("Unrecognized Web Domain")
        }
        return setShieldConfig(categoryName + " " + displayName)
    }
}
