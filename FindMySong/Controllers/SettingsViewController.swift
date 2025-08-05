//
//  SettingsViewController.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 04/08/25.
//
import UIKit

class SettingsViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let viewModel = SettingsViewModel()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.backgroundColor = UIColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.12)
        button.layer.cornerRadius = 12
        button.setTitleColor(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        title = "Settings"

        if let navBar = navigationController?.navigationBar {
            let separator = UIView()
            separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
            separator.translatesAutoresizingMaskIntoConstraints = false
            navBar.addSubview(separator)
            NSLayoutConstraint.activate([
                separator.heightAnchor.constraint(equalToConstant: 1),
                separator.leadingAnchor.constraint(equalTo: navBar.leadingAnchor),
                separator.trailingAnchor.constraint(equalTo: navBar.trailingAnchor),
                separator.bottomAnchor.constraint(equalTo: navBar.bottomAnchor)
            ])
        }

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        view.addSubview(tableView)
        view.addSubview(logoutButton)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -16),

            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            logoutButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func logoutTapped() {
        viewModel.logout()
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = ViewController()
            window.makeKeyAndVisible()
        }
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.settings[indexPath.row]
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.detail
        cell.selectionStyle = item.action == nil ? .none : .default
        if item.title == "Privacy Policy" {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.performAction(for: indexPath.row, on: self)
    }
}
