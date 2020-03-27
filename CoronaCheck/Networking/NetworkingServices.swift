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
                var statistic = CoronaStatistic(province: nil, country: nil, confirmed: 0, deaths: 0, yesterdayConfirmed: nil, yesterdayDeaths: nil, latitude: nil, longitude: nil)
                var allStatistics = [CoronaStatistic]()
                
                let covidData = try JSONDecoder().decode(CoronaCountryData.self, from: data)
                
                let dispatchGroup = DispatchGroup()
                
                let locations = covidData.locations
                for location in locations {
                    dispatchGroup.enter()
                    
                    let currentCases = location.latest.confirmed
                    let currentDeaths = location.latest.deaths
                    
                    NetworkingServices.downloadTimelineData(countryID: location.id, currentCases: currentCases, currentDeaths: currentDeaths) { (cases, deaths) in
                        
                        statistic.yesterdayConfirmed = cases
                        statistic.yesterdayDeaths = deaths
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

                        allStatistics.append(statistic)
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(allStatistics)
                }
                
            }
            catch {
                print(error)
            }   
        }.resume()
    }
    
    static func downloadTimelineData(countryID: Int, currentCases: Int, currentDeaths: Int, completion: @escaping (Int, Int) -> ()) {
        
        guard let url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations/\(countryID)") else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let covidData = try JSONDecoder().decode(CoronaCountryIDData.self, from: data)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                
                var casesDictionary = [Date: Int]()
                
                for (key, value) in covidData.location.timelines.confirmed.timeline {
                    let date = dateFormatter.date(from: key)
                    casesDictionary[date!] = value
                }
                var sortedCases = casesDictionary.sorted { $0.0 < $1.0 }
                var yesterdayConfirmed = sortedCases.last?.value ?? 0
                if yesterdayConfirmed == currentCases {
                    sortedCases = sortedCases.dropLast()
                    yesterdayConfirmed = sortedCases.last?.value ?? 0
                }
                
                var deathsDictionary = [Date: Int]()
                
                for (key, value) in covidData.location.timelines.deaths.timeline {
                    let date = dateFormatter.date(from: key)
                    deathsDictionary[date!] = value
                }
                var sortedDeaths = deathsDictionary.sorted { $0.0 < $1.0 }
                var yesterdayDeaths = sortedDeaths.last?.value ?? 0
                if yesterdayDeaths == currentDeaths {
                    sortedDeaths = sortedDeaths.dropLast()
                    yesterdayDeaths = sortedDeaths.last?.value ?? 0
                }
                 
                completion(yesterdayConfirmed, yesterdayDeaths)
                
            }
            catch {
                
            }
        }.resume()
    }
    
    
}
