//
//  User.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import Foundation

// MARK: - Domain Entity
struct User: Identifiable, Equatable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let company: Company
    let address: Address
}

struct Company: Equatable {
    let name: String
    let catchPhrase: String
    let bs: String
}

struct Address: Equatable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo
}

struct Geo: Equatable {
    let lat: String
    let lng: String
}
