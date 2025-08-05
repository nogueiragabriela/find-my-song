//
//  Created by saulo.santos.freire on 26/03/25.
//

import UIKit
import SafariServices
import Combine

class ViewController: UIViewController, SpotifyWebViewControllerDelegate {
    private let viewModel = LoginViewModel()
    private var cancellables = Set<AnyCancellable>()

    // UI Elements
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    // MARK: Alerts
    private func showBiometricPromptAlert() {
        let alert = UIAlertController(
            title: "Usar biometria?",
            message: "Você deseja usar biometria para logar da próxima vez?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Não", style: .default) { _ in
            self.viewModel.handleBiometricPrompt(false)
            self.navigateToSearch()
        })
        alert.addAction(UIAlertAction(title: "Sim", style: .default) { _ in
            self.viewModel.handleBiometricPrompt(true)
            self.navigateToSearch()
        })
        present(alert, animated: true)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Não foi possível logar",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkBiometryPreference()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layoutIfNeeded()
        setupTextWithGradient()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 1
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        view.addSubview(loadingView)
        loadingView.addSubview(spinner)
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        let titleView = UIView()
        titleView.backgroundColor = .systemBackground
        titleView.translatesAutoresizingMaskIntoConstraints = false

        let titleStackView = UIStackView()
        titleStackView.axis = .horizontal
        titleStackView.spacing = 0.43
        titleStackView.translatesAutoresizingMaskIntoConstraints = false

        titleView.addSubview(titleStackView)
        titleStackView.isLayoutMarginsRelativeArrangement = true
        titleStackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        titleStackView.addArrangedSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 50),
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
        ])
        NSLayoutConstraint.activate([
            titleStackView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleStackView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -150),
            titleStackView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 16),
            titleStackView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
        ])
        mainStackView.addArrangedSubview(titleView)

        let buttonsView = UIView()
        buttonsView.backgroundColor = .systemBackground
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(buttonsView)

        let loginWithSpotifyButton = UIButton(type: .system)
        loginWithSpotifyButton.setTitle("Login with Spotify", for: .normal)
        loginWithSpotifyButton.accessibilityLabel = "Login with Spotify"
        loginWithSpotifyButton.accessibilityHint = "Logs you into the app using your Spotify account"
        loginWithSpotifyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        loginWithSpotifyButton.backgroundColor = UIColor(red: 0.12, green: 0.84, blue: 0.38, alpha: 1.0)
        loginWithSpotifyButton.tintColor = .black
        loginWithSpotifyButton.layer.cornerRadius = 25
        loginWithSpotifyButton.translatesAutoresizingMaskIntoConstraints = false
        loginWithSpotifyButton.addTarget(self, action: #selector(onLoginWithSpotifyPressed), for: .touchUpInside)
        buttonsView.addSubview(loginWithSpotifyButton)

        let purpleColor = UIColor(red: 0.50, green: 0.11, blue: 0.84, alpha: 1.0)
        let loginLaterButton = UIButton(type: .system)
        loginLaterButton.setTitle("Login Later", for: .normal)
        loginLaterButton.accessibilityLabel = "Login Later"
        loginLaterButton.accessibilityHint = "Skips the login process for now"
        loginLaterButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        loginLaterButton.tintColor = purpleColor
        loginLaterButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.addSubview(loginLaterButton)

        NSLayoutConstraint.activate([
            loginWithSpotifyButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 50),
            loginWithSpotifyButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -50),
            loginWithSpotifyButton.heightAnchor.constraint(equalToConstant: 50),
            loginLaterButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 50),
            loginLaterButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -50),
            loginLaterButton.topAnchor.constraint(equalTo: loginWithSpotifyButton.bottomAnchor, constant: 14),
            loginLaterButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -65),
            loginLaterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
                isLoading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
            }
            .store(in: &cancellables)

        viewModel.$loginError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showErrorAlert(message: message)
            }
            .store(in: &cancellables)

        viewModel.$biometricError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showErrorAlert(message: message)
            }
            .store(in: &cancellables)

        viewModel.$shouldNavigateToSearch
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleNavigation()
            }
            .store(in: &cancellables)
    }

    // MARK: - SpotifyWebViewControllerDelegate
    func spotifyWebViewController(_ controller: SpotifyWebViewController, didReceiveCode code: String) {
        viewModel.loginWithSpotify(code: code)
    }

    // MARK: - Button Actions
    @objc private func onLoginWithSpotifyPressed() {
        let webVC = SpotifyWebViewController()
        webVC.delegate = self
        let nav = UINavigationController(rootViewController: webVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    // MARK: - Navigation
    private func handleNavigation() {
        guard let accessToken = KeyChainService.read(forKey: "accessToken") else { return }
        let tabBarVC = TabBarViewController(token: accessToken)
        let hasBiometryPreference = UserDefaults.standard.bool(forKey: "prefersBiometricAuthentication")
        if !hasBiometryPreference {
            showBiometricPromptAlert()
        } else {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = tabBarVC
                window.makeKeyAndVisible()
            }
        }
    }

    private func navigateToSearch() {
        guard let accessToken = KeyChainService.read(forKey: "accessToken") else { return }
        let tabBarVC = TabBarViewController(token: accessToken)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = tabBarVC
            window.makeKeyAndVisible()
        }
    }

    // MARK: - Gradient Text Setup
    private func setupTextWithGradient() {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        containerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let fullText = "find my Song"
        let prefix = "find my "
        let gradientText = "Song"
        let font = UIFont.systemFont(ofSize: 32, weight: .regular)

        let prefixSize = (prefix as NSString).size(withAttributes: [.font: font])
        let gradientSize = (gradientText as NSString).size(withAttributes: [.font: font])
        let totalSize = (fullText as NSString).size(withAttributes: [.font: font])

        // Calculate the starting x to center the whole title
        let startX = (containerView.bounds.width - totalSize.width) / 2

        // "find my" label
        let blackTextLabel = UILabel()
        blackTextLabel.text = prefix
        blackTextLabel.font = font
        blackTextLabel.textColor = .black
        blackTextLabel.frame = CGRect(
            x: startX,
            y: 0,
            width: prefixSize.width,
            height: containerView.bounds.height
        )
        containerView.addSubview(blackTextLabel)

        // Gradient "Song"
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(hex: "#801CD6").cgColor,
            UIColor(hex: "#D61C70").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = CGRect(
            x: startX + prefixSize.width,
            y: 0,
            width: gradientSize.width,
            height: containerView.bounds.height
        )

        let textMask = CATextLayer()
        textMask.string = gradientText
        textMask.font = font
        textMask.fontSize = font.pointSize
        textMask.frame = CGRect(
            x: 0,
            y: (containerView.bounds.height - gradientSize.height) / 2,
            width: gradientSize.width,
            height: gradientSize.height
        )
        textMask.foregroundColor = UIColor.black.cgColor
        textMask.contentsScale = UIScreen.main.scale

        gradientLayer.mask = textMask
        containerView.layer.addSublayer(gradientLayer)
    }
}
