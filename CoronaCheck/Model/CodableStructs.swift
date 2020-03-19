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

struct Latest: Codable {
    let confirmed: Int
    let deaths: Int
    let recovered: Int
}

struct Location: Codable {
    let latest: Latest
    let country: String
    
}

//struct Confirmed: Codable {
//    let last_updated: String
//    let latest: Int
//    let locations: [Location]
//}
//
//struct Deaths: Codable {
//    let last_updated: String
//    let latest: Int
//    let locations: [Location]
//}
//
//struct Recovered: Codable {
//    let last_updated: String
//    let latest: Int
//    let locations: [Location]
//}


