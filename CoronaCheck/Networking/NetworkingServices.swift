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
                        
                        let locations = covidData.locations
                        for location in locations {
                            totalConfirmed += location.latest.confirmed
                            totalDeaths += location.latest.deaths
                        }
                        
                        statistic = CoronaStatistic(province: nil, country: locations.first?.country, confirmed: totalConfirmed, deaths: totalDeaths, latitude: nil, longitude: nil)
                        
                    }
                    else {
                        let covidData = try JSONDecoder().decode(CoronaAllData.self, from: data)
                        
                        statistic = CoronaStatistic(province: nil, country: nil, confirmed: covidData.latest.confirmed, deaths: covidData.latest.deaths)
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
    
    static func downloadAllLocationData(completion: @escaping ([CoronaStatistic]) -> ()) {
        
        guard let url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations") else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                var statistic = CoronaStatistic(province: nil, country: nil, confirmed: 0, deaths: 0, latitude: nil, longitude: nil)
                var allStatistics = [CoronaStatistic]()
                
                let covidData = try JSONDecoder().decode(CoronaCountryData.self, from: data)
                
                let locations = covidData.locations
                for location in locations {
                    
                    statistic.country = location.country
                    statistic.confirmed = location.latest.confirmed
                    statistic.deaths = location.latest.deaths
                    statistic.latitude = Double(location.coordinates.latitude)
                    statistic.longitude = Double(location.coordinates.longitude)
                    if location.province == "" {
                        statistic.province = location.country
                    }
                    else {
                        statistic.province = location.province
                    }
                    if location.country == "United Kingdom" && location.province == "" {
                        statistic.latitude = 52.9548
                        statistic.longitude = -1.581
                    }

                    allStatistics.append(statistic)
                    
                    
                }
                completion(allStatistics)
            }
            catch {
                print(error)
            }   
        }.resume()
    }
    
    
}
