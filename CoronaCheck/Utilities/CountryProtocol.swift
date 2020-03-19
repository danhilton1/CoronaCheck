//
//  CountryProtocol.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 19/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation

protocol CountryDelegate {
    func loadDataFromCountry(country: String, countryCode: String)
}
