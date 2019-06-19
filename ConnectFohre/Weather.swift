//
//  Weather.swift
//  ConnectFohre
//
//  Created by joconnor on 6/19/19.
//  Copyright © 2019 joconnor. All rights reserved.
//

import Foundation

struct Weather {
    
    let city: String
    let temp: Double
    let description: String
    
    //append city name ot the end of requestPath
    static let requestPath = "https://api.apixu.com/v1/current.json?key=f1dda4ab723144e6b3e172647191906&q="
    
    enum WeatherError: Error {
        case invalid(String)
    }
    
    
    
    init(dictFromJSON: [String : Any], cityOfInterest: String) throws {
        guard let temp = dictFromJSON["temp_f"] as? Double else {
            throw WeatherError.invalid("Something went wrong with temp")
        }
        guard let descriptionDict = dictFromJSON["condition"] as? [String : Any] else {
            throw WeatherError.invalid("Something went wrong with description")
        }
        guard let description = descriptionDict["text"] as? String else {
            throw WeatherError.invalid("Something went wrong with description text")
        }
        
        self.temp = temp
        self.description = description
        self.city = cityOfInterest
    }
    
    //will this work with the parameter "city: String")
    static func getWeatherFromWeb(forCity city: String, completion: @escaping (Weather) -> Void) {
        let link = requestPath + city
        let request = URLRequest(url: URL(string: link)!)
        
        var result: Weather? = nil
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, _, _) in
            if let data = data {
                do {
                    if let allData = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                        if let todaysData = allData["current"] as? [String : Any] {
                            if let new = try? Weather(dictFromJSON: todaysData, cityOfInterest: city) {
                                result = new
                            } else {
                                throw WeatherError.invalid("Reading the JSON did not go well")
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                completion(result!)
            }
        }
        task.resume()

    }
}
