//
//  SearchViewModel.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 02/08/25.
//
import Foundation
import Combine

enum SearchType: Int {
    case band = 0
    case song = 1
    case album = 2

    var spotifyType: String {
        switch self {
        case .band: return "artist"
        case .song: return "track"
        case .album: return "album"
        }
    }
}

enum SearchResultType {
    case track(Track)
    case album(Album)
    case artist(Artist)
}

class SearchViewModel: ObservableObject {
    private let token: String
    @Published var searchType: SearchType = .song
    @Published var results: [SearchResultType] = []
    @Published var errorMessage: String?

    init(token: String) {
        self.token = token
    }

    func updateSearchType(_ type: SearchType, query: String) {
        searchType = type
        search(query: query)
    }

    func search(query: String) {
        guard query.count >= 3 else {
            results = []
            return
        }
        let typeString = searchType.spotifyType
        let baseURL = "https://api.spotify.com/v1/search"
        let urlString = "\(baseURL)?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=track%2C\(typeString)"
        guard let url = URL(string: urlString) else {
            results = []
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.results = []
                    self?.errorMessage = "Network error."
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    self?.results = []
                    self?.errorMessage = "Token is invalid or expired."
                    return
                }

                guard let data = data else {
                    self?.results = []
                    self?.errorMessage = "No data received."
                    return
                }

                do {
                    let result = try JSONDecoder().decode(SpotifyTrackSearchResult.self, from: data)
                    self?.results = result.tracks.items.map { .track($0) }
                } catch {
                    self?.results = []
                    self?.errorMessage = "Decoding error."
                }
            }
        }.resume()
    }
}
