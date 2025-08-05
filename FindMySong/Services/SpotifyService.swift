//
//  SpotifyService.swift
//  FindMySong
//
//  Created by henrique.cisi on 05/06/25.
//

import Foundation

final class SpotifyService {
    static let shared = SpotifyService()
    
    // MARK: - Private Properties
    private let clientId: String
    private let clientSecret: String
    private let redirectURI = "fms://login/callback"
    private let scopes = "user-read-private user-top-read user-read-email"
    private let authorizeBaseURL = "https://accounts.spotify.com/authorize"
    private let responseType = "code"
    private let showDialog = "true"
    private let tokenBaseURL = "https://accounts.spotify.com/api/token"
    
    //MARK: - Init()
    private init() {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let clientId = dict["SPOTIFY_CLIENT_ID"] as? String,
              let clientSecret = dict["SPOTIFY_CLIENT_SECRET"] as? String else {
            fatalError("Secrets.plist missing or keys not found")
        }
        
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    
    // MARK: - Public Methods
    func getSpotifyAuthURL() -> URL? {
        var components = URLComponents(string: authorizeBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: responseType),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "show_dialog", value: showDialog)
        ]
        return components?.url
    }
    
    func requestAccessToken(withCode code: String) async throws -> (accessToken: String, refreshToken: String) {
        guard let request = createRequest(with: code) else {
            throw NSError(domain: "Invalid Request", code: -1)
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let tokens = self.parseResponse(with: data) else {
            throw NSError(domain: "Invalid Response", code: -1)
        }
        
        return tokens
    }
    
    func refreshToken(with refreshToken: String) async throws -> (accessToken: String, refreshToken: String?) {
        guard let request = createRefreshTokenRequest(with: refreshToken) else {
            throw NSError(domain: "Invalid Request", code: -1)
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        print(data)
              
        guard let tokens = self.parseRefreshResponse(with: data) else {
            throw NSError(domain: "Invalid Response", code: -1)
        }
        
        return tokens
    }
    
    func isSpotifyCallbackUrlValid(_ url: URL) -> Bool {
        return url.scheme == "fms" && url.host == "login" && url.path == "/callback"
    }
    
    func getSpotifyAccessCode(from url: URL) -> String? {
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "code" })?.value
    }
    
    // MARK: - Private Helpers
    private func createRequest(with code: String) -> URLRequest? {
        guard let url = URL(string: tokenBaseURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(formatAuthorizationHeader(), forHTTPHeaderField: "Authorization")
        
        let queryParams = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI
        ]
        
        let queryString = self.formatQueryString(with: queryParams)
        
        request.httpBody = queryString.data(using: .utf8)
        
        return request
    }
    
    private func createRefreshTokenRequest(with savedRefreshToken: String) -> URLRequest? {
        guard let url = URL(string: tokenBaseURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(formatAuthorizationHeader(), forHTTPHeaderField: "Authorization")
        
        let queryParams = [
            "grant_type": "refresh_token",
            "refresh_token": savedRefreshToken,
        ]
        
        let queryString = self.formatQueryString(with: queryParams)
        
        request.httpBody = queryString.data(using: .utf8)
        return request
    }
    
    private func formatAuthorizationHeader() -> String {
        let credentials = "\(clientId):\(clientSecret)"
        let base64 = Data(credentials.utf8).base64EncodedString()
        return "Basic \(base64)"
    }
    
    private func formatQueryString(with params: [String : String] ) -> String {
        return params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    }
    
    //MARK: Parsers
    private func parseResponse(with data: Data) -> (accessToken: String, refreshToken: String)? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accessToken = json["access_token"] as? String,
              let refreshToken = json["refresh_token"] as? String else {
            return nil
        }
        return (accessToken, refreshToken)
    }
    
    private func parseRefreshResponse(with data: Data) -> (accessToken: String, refreshToken: String?)? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accessToken = json["access_token"] as? String else {
            return nil
        }
        let refreshToken = json["refresh_token"] as? String
        return (accessToken, refreshToken)
    }
}

