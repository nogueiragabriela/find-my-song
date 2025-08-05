//
//  Track.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 02/08/25.
//
import Foundation

struct SpotifyTrackSearchResult: Codable {
    let tracks: SpotifyTrackItems
}

struct SpotifyTrackItems: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [Track]
}

struct Track: Codable {
    let album: Album
    let artists: [Artist]
    let available_markets: [String]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_ids: [String: String]?
    let external_urls: [String: String]
    let href: String
    let id: String
    let is_local: Bool
    let is_playable: Bool?
    let name: String
    let popularity: Int?
    let preview_url: String?
    let track_number: Int
    let type: String
    let uri: String
    let images: [Image]?
}

