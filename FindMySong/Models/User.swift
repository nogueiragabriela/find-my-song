//
//  User.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 03/08/25.
//
import Foundation

struct User: Codable {
    let country: String
    let display_name: String
    let email: String
    let explicit_content: ExplicitContent
    let external_urls: ExternalUrls
    let followers: Followers
    let href: String
    let id: String
    let images: [Image]
    let product: String
    let type: String
    let uri: String
}

struct ExplicitContent: Codable {
    let filter_enabled: Bool
    let filter_locked: Bool
}

struct ExternalUrls: Codable {
    let spotify: String
}

struct Followers: Codable {
    let href: String?
    let total: Int
}

struct UserTopTracks: Codable {
    let items: [Track]
    let total: Int
    let limit: Int
    let offset: Int
    let href: String
    let next: String?
    let previous: String?
}

struct UserTopArtists: Codable {
    let items: [Artist]
    let total: Int
    let limit: Int
    let offset: Int
    let href: String
    let next: String?
    let previous: String?
}
