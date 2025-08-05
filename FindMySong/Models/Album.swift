//
//  Album.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 05/08/25.
//

import Foundation

struct Album: Codable {
    let album_type: String
    let total_tracks: Int
    let available_markets: [String]
    let external_urls: [String: String]
    let href: String
    let id: String
    let images: [Image]?
    let name: String
    let release_date: String
    let release_date_precision: String
    let type: String
    let uri: String
    let artists: [Artist]
}

