//
//  ErrorMessage.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 14/04/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation

enum ErrorMessage: String, Error {

    case unableToComplete = "Unable able to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
    case unableToGetDate = "The date could not be retrieved."

}
