//
//  CodableStructs.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 16/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation


struct CoronaAllData: Codable {
    let latest: Latest
}

struct CoronaCountryData: Codable {
    let locations: [Location]
}

struct CoronaCountryIDData: Codable {
    let location: LocationWithID
}

struct Latest: Codable {
    let confirmed: Int
    let deaths: Int
    let recovered: Int
}

struct Location: Codable {
    let id: Int
    let latest: Latest
    let country: String
    let province: String
    let last_updated: String
    let coordinates: Coordinate
    let timelines: Timelines
}

struct Coordinate: Codable {
    let latitude: String
    let longitude: String
}

struct LocationWithID: Codable {
    let timelines: Timelines
}

struct Timelines: Codable {
    let confirmed: Confirmed
    let deaths: Deaths
}

struct Confirmed: Codable {
    let latest: Int
    let timeline: [String: Int]
}

struct Deaths: Codable {
    let latest: Int
    let timeline: [String: Int]
}
//
//struct Recovered: Codable {
//    let last_updated: String
//    let latest: Int
//    let locations: [Location]
//}


