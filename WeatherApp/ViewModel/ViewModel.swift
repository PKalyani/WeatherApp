//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Kalyani Puvvada on 5/21/23.
//

import Foundation

class ViewModel {
    // Closure to update data after fetching from API
    var reloadClosure: (() -> ())?
    // Model object
    var weatherDetails: WeatherModel?
    
    // Make an API call to fetch wether update
    func fetchWeatherDetails(city: String) {
        var url = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=e9a2b98b449845121ed6b07d9551813e&units=metric"
        url = url.replacingOccurrences(of: " ", with: "%20")
        print(url)
        APIService.shared.getJSON(urlString: url) { (result: Result<WeatherModel, APIService.APIError>) in
            switch result {
            case .success(let model):
                print(model)
                self.weatherDetails = model
                self.reloadClosure?()
            case .failure(let apiError):
                print(apiError)
            }
        }
    }
    
    // Get city name
    func getLocation() -> String {
        return weatherDetails?.name ?? ""
    }
    
    // Get current temperature
    func getTemperature() -> String {
        guard let temp = weatherDetails?.main?.temp else { return "" }
        return "\(temp)"
    }
    
    // Get weather info
    func getTitle() -> String {
        return weatherDetails?.weather?.first?.main ?? ""
    }
    
    // Get description for weather
    func getDescription() -> String {
        return weatherDetails?.weather?.first?.description ?? ""
    }
    
    // Get message as response if any error from api
    func getMessage() -> String {
        return weatherDetails?.message ?? ""
    }
    
    // Get image icon
    func getImageURLString() -> String {
        return "https://openweathermap.org/img/wn/\(weatherDetails?.weather?.first?.icon ?? "")@2x.png" 
    }
}
