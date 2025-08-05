//
//  Artist.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 02/08/25.
//

import Foundation

struct SpotifyArtistSearchResult: Codable {
    let artists: SpotifyArtistItems
}

struct SpotifyArtistItems: Codable {
    let items: [Artist]
}

struct Artist: Codable {
    let id: String
    let name: String
    let popularity: Int?
    let external_urls: [String: String]
    let href: String
    let type: String
    let uri: String
    let images: [Image]?
    let genres: [String]?
}
