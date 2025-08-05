//
//  TabBarViewController.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 04/08/25.
//
import UIKit
import Combine

class TabBarViewController: UIViewController, UITabBarDelegate {
    // MARK: - Properties
    let tabBar = UITabBar()
    let viewModel: TabBarViewModel
    var cancellables = Set<AnyCancellable>()
    var currentVC: UIViewController?
    
    // MARK: - Initializer
    init(token: String) {
        self.viewModel = TabBarViewModel(token: token)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        
        setupTabBar()
        bindViewModel()
        switchToVC(viewModel.viewController(for: viewModel.selectedTab))
    }
    
    // MARK: - TabBar Setup
    private func setupTabBar() {
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        let search = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: TabType.search.rawValue)
        let profile = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: TabType.profile.rawValue)
        let settings = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: TabType.settings.rawValue)
        tabBar.items = [search, profile, settings]
        tabBar.selectedItem = search
        tabBar.delegate = self
        tabBar.backgroundColor = .systemBackground
        tabBar.isTranslucent = false
        
        view.addSubview(tabBar)
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.$selectedTab
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tab in
                guard let self = self else { return }
                let vc = self.viewModel.viewController(for: tab)
                self.switchToVC(vc)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - VC Switching & Layout
    func updateCurrentVCConstraints() {
        guard let vc = currentVC else { return }
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.removeConstraints(vc.view.constraints)
        vc.view.removeFromSuperview()
        view.insertSubview(vc.view, belowSubview: tabBar)
        let bottomAnchor: NSLayoutYAxisAnchor = tabBar.isHidden ? view.safeAreaLayoutGuide.bottomAnchor : tabBar.topAnchor
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func switchToVC(_ vc: UIViewController) {
        // Remove current
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()
        
        // Add new
        addChild(vc)
        view.insertSubview(vc.view, belowSubview: tabBar)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        let bottomAnchor: NSLayoutYAxisAnchor = tabBar.isHidden ? view.safeAreaLayoutGuide.bottomAnchor : tabBar.topAnchor
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        vc.didMove(toParent: self)
        currentVC = vc
    }
    
    // MARK: - UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let tab = TabType(rawValue: item.tag) {
            viewModel.selectedTab = tab
        }
    }
}
