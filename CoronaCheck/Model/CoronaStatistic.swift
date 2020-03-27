//
//  CoronaStatistic.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 16/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation

struct CoronaStatistic {
    
    var province: String?
    var country: String?
//    var lastUpdate: String
    var confirmed: Int
    var deaths: Int
    var activeOrRecovered: Int {
        return confirmed - deaths
    }
    var yesterdayConfirmed: Int?
    var yesterdayDeaths: Int?
    var changeInConfirmed: Int? {
        return confirmed - (yesterdayConfirmed ?? 0)
    }
    var changeInDeaths: Int? {
        return deaths - (yesterdayDeaths ?? 0)
    }
    var latitude: Double?
    var longitude: Double?
    
}
