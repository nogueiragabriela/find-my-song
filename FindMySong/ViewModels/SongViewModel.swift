//
//  SongViewModel.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 05/08/25.
//
import Foundation
import UIKit

class SongViewModel {
    let track: Track

    var artworkURL: URL? {
        URL(string: track.album.images?.first?.url ?? "")
    }
    var trackName: NSAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SFProText-Regular", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .regular),
            .kern: -0.43
        ]
        return NSAttributedString(string: track.name, attributes: attrs)
    }
    var albumName: NSAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SFProText-Light", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .light),
            .kern: 2.0
        ]
        return NSAttributedString(string: track.album.name.uppercased(), attributes: attrs)
    }
    var artistName: NSAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SFProText-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .bold),
            .kern: 2.0
        ]
        let name = (track.artists.first?.name ?? "").uppercased()
        return NSAttributedString(string: name, attributes: attrs)
    }
    var spotifyURL: URL? {
        guard let urlString = track.external_urls["spotify"] else { return nil }
        return URL(string: urlString)
    }

    init(track: Track) {
        self.track = track
    }
}
