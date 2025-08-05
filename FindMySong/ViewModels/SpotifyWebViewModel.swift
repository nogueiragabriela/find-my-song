//
//  SpotifyWebViewModel.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 05/08/25.
//
import Foundation
import WebKit

class SpotifyWebViewModel: ObservableObject {
    @Published var authURL: URL?
    @Published var receivedCode: String?
    
    init() {
        authURL = SpotifyService.shared.getSpotifyAuthURL()
    }
    
    func handleNavigationAction(_ navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else { return nil }
        let service = SpotifyService.shared
        if service.isSpotifyCallbackUrlValid(url),
           let code = service.getSpotifyAccessCode(from: url) {
            receivedCode = code
            return code
        }
        return nil
    }
}
