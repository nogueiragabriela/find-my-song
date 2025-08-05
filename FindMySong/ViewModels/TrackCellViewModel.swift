//
//  TrackCellViewModel.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 05/08/25.
//
import Foundation
import UIKit
import Combine

class TrackCellViewModel: ObservableObject {
    let name: String
    let artist: String
    @Published var image: UIImage?
    var onArrowTapped: (() -> Void)?

    init(track: Track, onArrowTapped: (() -> Void)? = nil) {
        self.name = track.name
        self.artist = track.artists.first?.name ?? ""
        self.image = UIImage(systemName: "photo")
        self.onArrowTapped = onArrowTapped
        if let urlString = track.album.images?.first?.url, let url = URL(string: urlString) {
            fetchImage(from: url)
        }
    }

    private func fetchImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}
