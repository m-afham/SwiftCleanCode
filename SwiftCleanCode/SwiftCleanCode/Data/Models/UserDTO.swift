//
//  UserDTO.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import Foundation

// MARK: - Data Transfer Objects (DTOs)
struct UserDTO: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let company: CompanyDTO
    let address: AddressDTO
}

struct CompanyDTO: Codable {
    let name: String
    let catchPhrase: String
    let bs: String
}

struct AddressDTO: Codable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: GeoDTO
}

struct GeoDTO: Codable {
    let lat: String
    let lng: String
}

// MARK: - DTO to Domain Model Mapping
extension UserDTO {
    func toDomain() -> User {
        return User(
            id: id,
            name: name,
            username: username,
            email: email,
            phone: phone,
            website: website,
            company: company.toDomain(),
            address: address.toDomain()
        )
    }
}

extension CompanyDTO {
    func toDomain() -> Company {
        return Company(
            name: name,
            catchPhrase: catchPhrase,
            bs: bs
        )
    }
}

extension AddressDTO {
    func toDomain() -> Address {
        return Address(
            street: street,
            suite: suite,
            city: city,
            zipcode: zipcode,
            geo: geo.toDomain()
        )
    }
}

extension GeoDTO {
    func toDomain() -> Geo {
        return Geo(
            lat: lat,
            lng: lng
        )
    }
}
