//
//  TabBarViewModel.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 05/08/25.
//
import UIKit

enum TabType: Int {
    case search = 0
    case profile = 1
    case settings = 2
}

class TabBarViewModel: ObservableObject {
    @Published var selectedTab: TabType = .search
    let searchNav: UINavigationController
    let profileNav = UINavigationController(rootViewController: ProfileViewController())
    let settingsNav = UINavigationController(rootViewController: SettingsViewController())

    init(token: String) {
        self.searchNav = UINavigationController(rootViewController: SearchViewController(token: token))
    }

    func viewController(for tab: TabType) -> UIViewController {
        switch tab {
        case .search: return searchNav
        case .profile: return profileNav
        case .settings: return settingsNav
        }
    }
}
