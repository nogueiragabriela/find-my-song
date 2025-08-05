//
//  ArtistCellViewModel.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 05/08/25.
//
import Foundation
import UIKit

class ArtistCellViewModel: ObservableObject {
    let name: String
    @Published var image: UIImage?

    init(artist: Artist) {
        self.name = artist.name
        self.image = UIImage(systemName: "photo")
        if let urlString = artist.images?.first?.url, let url = URL(string: urlString) {
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
