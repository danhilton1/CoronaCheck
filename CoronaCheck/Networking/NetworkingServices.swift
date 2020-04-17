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
    
    
    static func downloadData(forCountryCode code: String?, completion: @escaping (Result<CoronaStatistic, ErrorMessage>) -> ()) {

        var url: URL
        if let countryCode = code {
            url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations?country_code=\(countryCode)&timelines=1")!
        }
        else {
            url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/latest")!
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error)
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
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
                completion(.success(statistic))
            }
            catch {
                print(error)
                completion(.failure(.invalidData))
            }
            
        }
        dataTask.resume()
    }
    
    
    static func retrieveDateOfLastUpdate(completion: @escaping (Result<String,ErrorMessage>) -> ()) {
        
        guard let url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations?country_code=GB&timelines=1") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error)
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let covidData = try JSONDecoder().decode(CoronaCountryData.self, from: data)
                
                if let dateLastUpdated = covidData.locations.first?.last_updated {
                    completion(.success(dateLastUpdated))
                }
                else {
                    completion(.failure(.unableToGetDate))
                }
            }
            catch {
                print(error)
                completion(.failure(.unableToGetDate))
            }
        }.resume()
    }
    
    
    static func downloadAllLocationData(completion: @escaping (Result<[CoronaStatistic],ErrorMessage>) -> ()) {
        
        guard let url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations?timelines=1") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error)
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                var statistic = CoronaStatistic(province: nil, country: nil, confirmed: 0, deaths: 0, yesterdayConfirmed: nil, yesterdayDeaths: nil, latitude: nil, longitude: nil)
                var allStatistics = [CoronaStatistic]()
                
                let covidData = try JSONDecoder().decode(CoronaCountryData.self, from: data)
                
                let locations = covidData.locations
                
                for location in locations {
                    
                    let currentCases = location.latest.confirmed
                    let currentDeaths = location.latest.deaths
                    
                    statistic.country = location.country
                    if location.country == "Czechia" { statistic.country = "Czech Republic" }
                    statistic.confirmed = currentCases
                    statistic.deaths = currentDeaths
                    
                    statistic.latitude = Double(location.coordinates.latitude)
                    statistic.longitude = Double(location.coordinates.longitude)
                    
                    // Move annotation point to a more central location of UK on map
                    if location.country == "United Kingdom" && location.province == "" {
                        statistic.latitude = 52.9548
                        statistic.longitude = -1.581
                    }
                    
                    statistic.province = location.province == "" ? location.country : location.province
                    
                    var casesDict = NetworkingServices.retrieveTimelineData(timeline: location.timelines.confirmed.timeline)
                    statistic.casesTimeline = casesDict
                    
                    var yesterdayCases = casesDict.last?.value ?? 0
                    if yesterdayCases == currentCases {
                        casesDict = casesDict.dropLast()
                        yesterdayCases = casesDict.last?.value ?? 0
                    }
                    statistic.yesterdayConfirmed = yesterdayCases
                    
                    var deathsDict = NetworkingServices.retrieveTimelineData(timeline: location.timelines.deaths.timeline)
                    statistic.deathsTimeline = deathsDict
                    
                    var yesterdayDeaths = deathsDict.last?.value ?? 0
                    if yesterdayDeaths == currentDeaths {
                        deathsDict = deathsDict.dropLast()
                        yesterdayDeaths = deathsDict.last?.value ?? 0
                    }
                    statistic.yesterdayDeaths = yesterdayDeaths
                    
                    

                    allStatistics.append(statistic)
                    
                }
                completion(.success(allStatistics))
            }
                
            catch {
                print(error)
                completion(.failure(.invalidData))
            }   
        }.resume()
    }
    
    
    
    static func retrieveTimelineData(timeline: [String: Int]) -> Array<(key: Date, value: Int)> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        var dateDictionary = [Date: Int]()
        
        for (key, value) in timeline {
            let date = dateFormatter.date(from: key)
            dateDictionary[date!] = value
        }
        let sortedList = dateDictionary.sorted { $0.0 < $1.0 }
        
        return sortedList
    }
    
    
}
