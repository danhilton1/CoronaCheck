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
    
    func downloadData(forCountryCode code: String?, completion: @escaping (Result<CoronaCountryData, ErrorMessage>) -> ()) {

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
                let covidData = try JSONDecoder().decode(CoronaCountryData.self, from: data)
                completion(.success(covidData))
            }
            catch {
                print(error)
                completion(.failure(.invalidData))
            }
        }
        dataTask.resume()
    }
    
    
    
    func downloadAllLocationData(completion: @escaping (Result<[CoronaCountryData],ErrorMessage>) -> ()) {
        
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
                completion(.success(covidData))
            }
            catch {
                print(error)
                completion(.failure(.invalidData))
            }
        }.resume()
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
                let covidData = try JSONDecoder().decode(CoronaCountryDataTimeline.self, from: data)

                let casesDict = self.convertTimelineData(timeline: covidData.timeline.cases)
                let deathsDict = self.convertTimelineData(timeline: covidData.timeline.deaths)
                let timelineData = TimelineData(country: covidData.country, casesTimeline: casesDict, deathsTimeline: deathsDict)
                
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
