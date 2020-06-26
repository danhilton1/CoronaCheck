//
//  CodableStructs.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 16/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation


struct CoronaAllData: Codable {
    let cases: Int
    let deaths: Int
    let recovered: Int
    let updated: Int
}

struct CoronaCountryData: Codable {
//    let locations: [Location]
    let country: String
    let updated: Int
    let cases: Int
    let deaths: Int
    let recovered: Int
    let countryInfo: CountryInfo
}


struct CoronaCoutryDataTimeline: Codable {
    let country: String
//    let province: String
    let timeline: Timeline
}

struct CoronaCountryIDData: Codable {
    let location: LocationWithID
}

struct CountryInfo: Codable {
    let lat: Double
    let long: Double
}


struct Coordinate: Codable {
    let latitude: String
    let longitude: String
}

struct LocationWithID: Codable {
    let timelines: Timeline
}

struct Timeline: Codable {
    let cases: [String: Int]
    let deaths: [String: Int]
}


//
//struct Recovered: Codable {
//    let last_updated: String
//    let latest: Int
//    let locations: [Location]
//}


