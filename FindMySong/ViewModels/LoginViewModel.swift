//
//  LoginViewModel.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 05/08/25.
//
import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var loginError: String?
    @Published var biometricError: String?
    @Published var shouldNavigateToSearch: Bool = false
    @Published var showBiometricPrompt: Bool = false

    func loginWithSpotify(code: String) {
        guard !code.isEmpty else {
            loginError = "Tente novamente mais tarde"
            return
        }
        isLoading = true
        Task {
            do {
                let (accessToken, refreshToken) = try await SpotifyService.shared.requestAccessToken(withCode: code)
                await MainActor.run {
                    let accessSaved = KeyChainService.create(value: accessToken, forKey: "accessToken")
                    let refreshSaved = KeyChainService.create(value: refreshToken, forKey: "refreshToken")
                    if accessSaved && refreshSaved {
                        self.shouldNavigateToSearch = true
                    } else {
                        self.loginError = "Tente novamente mais tarde"
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.loginError = "Tente novamente mais tarde"
                    self.isLoading = false
                }
            }
        }
    }

    func loginWithBiometry() {
        guard let savedToken = KeyChainService.read(forKey: "refreshToken") else {
            biometricError = "Houve uma falha na comunicação com o Spotify"
            return
        }
        isLoading = true
        Task {
            do {
                let (accessToken, maybeNewRefreshToken) = try await SpotifyService.shared.refreshToken(with: savedToken)
                let refreshToken = maybeNewRefreshToken ?? savedToken
                await MainActor.run {
                    let accessSaved = KeyChainService.create(value: accessToken, forKey: "accessToken")
                    let refreshSaved = KeyChainService.create(value: refreshToken, forKey: "refreshToken")
                    if accessSaved && refreshSaved {
                        self.shouldNavigateToSearch = true
                    } else {
                        self.biometricError = "Houve uma falha na comunicação com o Spotify"
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.biometricError = "Houve uma falha na comunicação com o Spotify"
                    self.isLoading = false
                }
            }
        }
    }

    func checkBiometryPreference() {
        let hasBiometryPreference = UserDefaults.standard.bool(forKey: "prefersBiometricAuthentication")
        if hasBiometryPreference {
            BiometryService.shared.authenticateUser { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    Task { self.loginWithBiometry() } // Remove 'await'
                default:
                    Task { await MainActor.run { self.biometricError = "Houve uma falha na comunicação com o Spotify" } }
                }
            }
        }
    }

    func handleBiometricPrompt(_ useBiometry: Bool) {
        UserDefaults.standard.set(useBiometry, forKey: "prefersBiometricAuthentication")
    }
}
