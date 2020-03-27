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
            url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations?country_code=\(country)&timelines=1")!
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
        
        guard let url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations?country_code=GB&timelines=1") else { return }
        
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
        
        guard let url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations?timelines=1") else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                var statistic = CoronaStatistic(province: nil, country: nil, confirmed: 0, deaths: 0, yesterdayConfirmed: nil, yesterdayDeaths: nil, latitude: nil, longitude: nil)
                var allStatistics = [CoronaStatistic]()
                
                let covidData = try JSONDecoder().decode(CoronaCountryData.self, from: data)
                
                let locations = covidData.locations
                
                for location in locations {
                    
                    let currentCases = location.latest.confirmed
                    let currentDeaths = location.latest.deaths
                    
                    statistic.country = location.country
                    statistic.confirmed = currentCases
                    statistic.deaths = currentDeaths
                    
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
                    let yesterdayCases = NetworkingServices.retrievePreviousDayData(timeline: location.timelines.confirmed.timeline, currentValue: currentCases)
                    let yesterdayDeaths = NetworkingServices.retrievePreviousDayData(timeline: location.timelines.deaths.timeline, currentValue: currentDeaths)
                    statistic.yesterdayConfirmed = yesterdayCases
                    statistic.yesterdayDeaths = yesterdayDeaths

                    allStatistics.append(statistic)
                    
                }
                
                
                completion(allStatistics)
            }
            catch {
                print(error)
            }   
        }.resume()
    }
    
    
    
    static func retrievePreviousDayData(timeline: [String: Int], currentValue: Int) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        var dateDictionary = [Date: Int]()
        
        for (key, value) in timeline {
            let date = dateFormatter.date(from: key)
            dateDictionary[date!] = value
        }
        var sortedDictionary = dateDictionary.sorted { $0.0 < $1.0 }
        var yesterdayValue = sortedDictionary.last?.value ?? 0
        if yesterdayValue == currentValue {
            sortedDictionary = sortedDictionary.dropLast()
            yesterdayValue = sortedDictionary.last?.value ?? 0
        }
        return yesterdayValue
    }
    
    
}
