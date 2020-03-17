//
//  NetworkingServices.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 16/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation

struct NetworkingServices {
    
    
    static func downloadData(for country: String?, completion: @escaping (CoronaStatistic) -> ()) {

        let url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/all")!
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print(error)
            } else {
                
                guard let data = data else { return }
                
                do {
                    let covidData = try JSONDecoder().decode(CoronaData.self, from: data)
                    
                    let stat = CoronaStatistic(province: nil, country: nil, lastUpdate: covidData.confirmed.last_updated, confirmed: covidData.latest.confirmed, deaths: covidData.latest.deaths, recovered: covidData.latest.recovered)
//                    var allStats = [CoronaStatistic]()
//                    var statistic: CoronaStatistic!
//                    var totalCases = 0
//                    var totalDeaths = 0
//                    var totalRecoveries = 0
                    
//                    for stat in statsArray {
//                       statistic = CoronaStatistic(
//                        province: stat.province,
//                        country: stat.country,
//                        lastUpdate: stat.lastUpdate,
//                        confirmed: stat.confirmed,
//                        deaths: stat.deaths,
//                        recovered: stat.recovered)
//                        allStats.append(statistic)
//                        totalCases += stat.confirmed
//                        totalDeaths += stat.deaths
//                        totalRecoveries += stat.recovered
//                    }
                    
                    
                    completion(stat)
                }
                catch {
                    print(error)
                }
            }
        }

        dataTask.resume()
    }
    
}
