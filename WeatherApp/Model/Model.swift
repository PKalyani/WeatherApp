//
//  Model.swift
//  WeatherAPP
//
//  Created by Kalyani Puvvada on 5/20/23.
//

import Foundation

// Data model for weather api

struct WeatherModel: Codable {
    let weather: [Weather]?
    let main: Main?
    let clouds: Clouds?
    let dt: Date?
    let name: String?
    let message: String?
}

struct Weather: Codable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
}

struct Main: Codable {
    let temp_min: Float?
    let temp_max: Float?
    let temp: Float?
    let humidity: Int?
}

struct Clouds: Codable {
    let all: Int?
}
