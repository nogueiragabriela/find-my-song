//
//  SettingsViewModel.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 05/08/25.
//
import Foundation
import UIKit

class SettingsViewModel {
    struct SettingItem {
        let title: String
        let detail: String?
        let action: (() -> Void)?
    }
    
    let settings: [SettingItem]
    let privacyPolicyURL = URL(string: "https://www.accenture.com/us-en/support/privacy-policy")!
    
    init() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        settings = [
            SettingItem(title: "Version", detail: version, action: nil),
            SettingItem(title: "Privacy Policy", detail: nil, action: nil)
        ]
    }
    
    func performAction(for index: Int, on viewController: UIViewController) {
        let item = settings[index]
        if item.title == "Privacy Policy" {
            UIApplication.shared.open(privacyPolicyURL)
        }
    }
    
    func logout() {
        _ = KeyChainService.delete(forKey: "accessToken")
        _ = KeyChainService.delete(forKey: "refreshToken")
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObject(forKey: key)
        }
    }
}
