//
//  NetworkingServices.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 16/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation
import UIKit

struct NetworkingServices {
    
    
    static func downloadData(forCountryCode code: String?, completion: @escaping (CoronaStatistic) -> ()) {

        var url: URL
        if let country = code {
            url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations?country_code=\(country)")!
        }
        else {
            url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/latest")!
        }
        
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print(error)
            } else {
                
                guard let data = data else { return }
                
                do {
                    
                    
                    var statistic: CoronaStatistic!
                    
                    if code != nil {
                        
                        let covidData = try JSONDecoder().decode(CoronaCountryData.self, from: data)
                        
                        var totalConfirmed = 0
                        var totalDeaths = 0
                        var totalRecovered = 0
                        
                        let locations = covidData.locations
                        for location in locations {
                            totalConfirmed += location.latest.confirmed
                            totalDeaths += location.latest.deaths
                            totalRecovered += location.latest.recovered
                        }
                        statistic = CoronaStatistic(province: nil, country: locations.first?.country, confirmed: totalConfirmed, deaths: totalDeaths, recovered: totalRecovered)
                        
                    }
                    else {
                        let covidData = try JSONDecoder().decode(CoronaAllData.self, from: data)
                        
                        statistic = CoronaStatistic(province: nil, country: nil, confirmed: covidData.latest.confirmed, deaths: covidData.latest.deaths, recovered: covidData.latest.recovered)
                        
                    }
                    completion(statistic)
                    
                }
                catch {
                    print(error)
                }
            }
        }

        dataTask.resume()
    }
    
    
    static func retrieveDateOfLastUpdate(completion: @escaping (String) -> ()) {
        
        guard let url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations?country_code=GB") else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let covidData = try JSONDecoder().decode(CoronaCountryData.self, from: data)
                
                if let dateLastUpdated = covidData.locations.first?.last_updated {
                    completion(dateLastUpdated)
                }
                else {
                    print("Date could not be retrieved")
                }
            }
            catch {
                print(error)
            }
        }.resume()
    }
    
    
}
