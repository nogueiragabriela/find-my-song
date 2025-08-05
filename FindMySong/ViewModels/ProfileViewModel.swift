//
//  ProfileViewModel.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 03/08/25.
//
import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var favoriteTracks: [Track] = []
    @Published var favoriteArtists: [Artist] = []
    @Published var user: User?
    @Published var errorMessage: String?
    
    private var token: String? {
        KeyChainService.read(forKey: "accessToken")
    }
    
    func fetchUserFavoriteItems(endpoint: String) {
        let urlString = "https://api.spotify.com/v1/me/top/\(endpoint)"
        guard let url = URL(string: urlString), let token = token else {
            if endpoint == "tracks" { self.favoriteTracks = [] }
            else if endpoint == "artists" { self.favoriteArtists = [] }
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    if endpoint == "tracks" { self?.favoriteTracks = [] }
                    else if endpoint == "artists" { self?.favoriteArtists = [] }
                    self?.errorMessage = "Network error."
                    return
                }
                guard let data = data else {
                    if endpoint == "tracks" { self?.favoriteTracks = [] }
                    else if endpoint == "artists" { self?.favoriteArtists = [] }
                    self?.errorMessage = "No data received."
                    return
                }
                do {
                    if endpoint == "tracks" {
                        let result = try JSONDecoder().decode(UserTopTracks.self, from: data)
                        self?.favoriteTracks = result.items
                    } else if endpoint == "artists" {
                        let result = try JSONDecoder().decode(UserTopArtists.self, from: data)
                        self?.favoriteArtists = result.items
                    }
                } catch {
                    if endpoint == "tracks" { self?.favoriteTracks = [] }
                    else if endpoint == "artists" { self?.favoriteArtists = [] }
                    self?.errorMessage = "Decoding error."
                }
            }
        }.resume()
    }
    
    func fetchUserProfile() {
        let urlString = "https://api.spotify.com/v1/me"
        guard let url = URL(string: urlString), let token = token else {
            self.errorMessage = "Invalid URL or missing token"
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.errorMessage = "Network error."
                    return
                }
                guard let data = data else {
                    self?.errorMessage = "No data received."
                    return
                }
                do {
                    let result = try JSONDecoder().decode(User.self, from: data)
                    self?.user = result
                } catch {
                    self?.errorMessage = "Decoding error."
                }
            }
        }.resume()
    }
}
