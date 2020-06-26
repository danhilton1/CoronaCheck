//
//  NetworkingServices.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 16/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation
import UIKit

class NetworkingServices {
    
    static let shared = NetworkingServices()
    
    private init() {}
    
    func downloadData(forCountryCode code: String?, completion: @escaping (Result<CoronaStatistic, ErrorMessage>) -> ()) {

        var url: URL
        if let countryCode = code {
            url = URL(string: "https://disease.sh/v2/countries/\(countryCode)")!
        }
        else {
            url = URL(string: "https://disease.sh/v2/all")!
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
                    
                    let lastUpdatedDate = Date(timeIntervalSince1970: TimeInterval(covidData.updated / 1000))
                    
                    statistic = CoronaStatistic(province: nil, country: covidData.country, lastUpdated: lastUpdatedDate, confirmed: covidData.cases, deaths: covidData.deaths, latitude: nil, longitude: nil)
                    
                }
                else {
                    let covidData = try JSONDecoder().decode(CoronaAllData.self, from: data)
                    let lastUpdatedDate = Date(timeIntervalSince1970: TimeInterval(covidData.updated / 1000))
                    statistic = CoronaStatistic(province: nil, country: nil, lastUpdated: lastUpdatedDate, confirmed: covidData.cases, deaths: covidData.deaths)
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
    
    
    
    func downloadAllLocationData(completion: @escaping (Result<[CoronaStatistic],ErrorMessage>) -> ()) {
        
        guard let url = URL(string: "https://disease.sh/v2/countries") else { return }
        
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
                let covidData = try JSONDecoder().decode([CoronaCountryData].self, from: data)
                var allStatistics = [CoronaStatistic]()
//                let dispatchGroup = DispatchGroup()
//                let dispatchQueue = DispatchQueue(label: "custom")
//                let dispatchSephamore = DispatchSemaphore(value: 0)
                
                var statistic = CoronaStatistic(province: nil, country: nil, lastUpdated: Date(), confirmed: 0, deaths: 0, yesterdayConfirmed: nil, yesterdayDeaths: nil, latitude: nil, longitude: nil)
                
                for entry in covidData {
                
                    statistic.country = entry.country
                    if entry.country == "Czechia" { statistic.country = "Czech Republic" }
                    
                    statistic.latitude = Double(entry.countryInfo.lat)
                    statistic.longitude = Double(entry.countryInfo.long)
                    
                    // Move annotation point to a more central location of UK on map
                    if entry.country == "United Kingdom" {
                        statistic.latitude = 52.9548
                        statistic.longitude = -1.581
                    }
                    
                    statistic.confirmed = entry.cases
                    statistic.deaths = entry.deaths
                    
                    allStatistics.append(statistic)
                }
                completion(.success(allStatistics))
//                self.blahblah(data: covidData) { (statistics) in
//                    print(statistics.count)
//                    completion(.success(statistics))
//                }
//                dispatchQueue.async {
//                    for entry in covidData {
//                        dispatchGroup.enter()
//                        self.appendTimelineDataTo(entry: entry) { statistic in
//                            allStatistics.append(statistic)
//                            dispatchSephamore.signal()
//
//                        }
//                        dispatchSephamore.wait()
//                        dispatchGroup.leave()
//                    }
//                }
//
//                dispatchGroup.notify(queue: dispatchQueue) {
//                    print("notified")
//                    completion(.success(allStatistics))
//                }
                
            }
            catch {
                print(error)
                completion(.failure(.invalidData))
            }
        }.resume()
    }
    
    
    func blahblah(data: [CoronaCountryData], completed: @escaping ([CoronaStatistic]) ->()) {
        let dispatchGroup = DispatchGroup()
        var allStatistics = [CoronaStatistic]()
        
        for entry in data {
            dispatchGroup.enter()
            self.appendTimelineDataTo(entry: entry) { statistic in
                allStatistics.append(statistic)
                dispatchGroup.leave()
            }
//            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            print(allStatistics.count)
            completed(allStatistics)
        }
        
        
    }
    
    
    func appendTimelineDataTo(entry: CoronaCountryData, completion: @escaping (CoronaStatistic) -> ()) {
        var statistic = CoronaStatistic(province: nil, country: nil, lastUpdated: Date(), confirmed: 0, deaths: 0, yesterdayConfirmed: nil, yesterdayDeaths: nil, latitude: nil, longitude: nil)
        
        downloadTimelineData(for: entry.country) { result in
            switch result {
            case .success(let timelineData):
                statistic.casesTimeline = timelineData.casesTimeline
                statistic.deathsTimeline = timelineData.deathsTimeline
                
                statistic.country = entry.country
                if entry.country == "Czechia" { statistic.country = "Czech Republic" }
                
                statistic.latitude = Double(entry.countryInfo.lat)
                statistic.longitude = Double(entry.countryInfo.long)
                
                // Move annotation point to a more central location of UK on map
                if entry.country == "United Kingdom" {
                    statistic.latitude = 52.9548
                    statistic.longitude = -1.581
                }
                
                statistic.confirmed = entry.cases
                statistic.deaths = entry.deaths
                statistic.yesterdayConfirmed = timelineData.casesTimeline.last?.value
                statistic.yesterdayDeaths = timelineData.deathsTimeline.last?.value

                completion(statistic)
                
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
    
    
    func downloadTimelineData(for country: String, completion: @escaping (Result<TimelineData,ErrorMessage>) -> ()) {
        let country = country.replacingOccurrences(of: " ", with: "-")
        guard let url = URL(string: "https://disease.sh/v2/historical/\(country)") else { return }
        
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
                let covidData = try JSONDecoder().decode(CoronaCoutryDataTimeline.self, from: data)

                let casesDict = self.convertTimelineData(timeline: covidData.timeline.cases)
                let deathsDict = self.convertTimelineData(timeline: covidData.timeline.deaths)
                let timelineData = TimelineData(casesTimeline: casesDict, deathsTimeline: deathsDict)
                
                completion(.success(timelineData))
            } catch {
                completion(.failure(.unableToComplete))
            }
        }.resume()
    }
    
    
    func convertTimelineData(timeline: [String: Int]) -> Array<(key: Date, value: Int)> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        var dateDictionary = [Date: Int]()
        
        for (key, value) in timeline {
            let date = dateFormatter.date(from: key)
            dateDictionary[date!] = value
        }
        let sortedList = dateDictionary.sorted { $0.0 < $1.0 }
        
        return sortedList
    }
    
    
}
