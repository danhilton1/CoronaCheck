//
//  CodableStructs.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 16/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation


struct CoronaCountryData: Codable {
    let country: String?
    let updated: Int
    let cases: Int
    let deaths: Int
    let recovered: Int
    let countryInfo: CountryInfo?
}


struct CoronaCountryDataTimeline: Codable {
    let country: String
    let timeline: Timeline
}


struct CountryInfo: Codable {
    let lat: Double
    let long: Double
}


struct Timeline: Codable {
    let cases: [String: Int]
    let deaths: [String: Int]
}


struct TimelineData {
    var country: String
    var casesTimeline: Array<(key: Date, value: Int)>
    var deathsTimeline: Array<(key: Date, value: Int)>
}

