//
//  Teamperature.swift
//  Weather
//
//  Created by Ram Kumar on 20/04/19.
//  Copyright © 2019 Ram Kumar. All rights reserved.
//

import Foundation

class Temperatures: Codable {
    let latitude, longitude: Double
    let timezone: String
    let currently: Currently
    let hourly: Hourly
    let daily: Daily
    let flags: Flags
    let offset: Double
    
    init(latitude: Double, longitude: Double, timezone: String, currently: Currently, hourly: Hourly, daily: Daily, flags: Flags, offset: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.currently = currently
        self.hourly = hourly
        self.daily = daily
        self.flags = flags
        self.offset = offset
    }
}

class Currently: Codable {
    let time: Double
    let summary: String
    let icon: String
    let precipIntensity, precipProbability: Double
    let temperature, apparentTemperature, dewPoint, humidity: Double
    let pressure, windSpeed, windGust: Double
    let windBearing: Double
    let cloudCover: Double
    let uvIndex: Double
    let visibility, ozone: Double
    
    init(time: Double, summary: String, icon: String, precipIntensity: Double, precipProbability: Double, temperature: Double, apparentTemperature: Double, dewPoint: Double, humidity: Double, pressure: Double, windSpeed: Double, windGust: Double, windBearing: Double, cloudCover: Double, uvIndex: Double, visibility: Double, ozone: Double) {
        self.time = time
        self.summary = summary
        self.icon = icon
        self.precipIntensity = precipIntensity
        self.precipProbability = precipProbability
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.dewPoint = dewPoint
        self.humidity = humidity
        self.pressure = pressure
        self.windSpeed = windSpeed
        self.windGust = windGust
        self.windBearing = windBearing
        self.cloudCover = cloudCover
        self.uvIndex = uvIndex
        self.visibility = visibility
        self.ozone = ozone
    }
}

class Daily: Codable {
    let summary: String
    let icon: String
    let data: [Datum]
    
    init(summary: String, icon: String, data: [Datum]) {
        self.summary = summary
        self.icon = icon
        self.data = data
    }
}

class Datum: Codable {
    let time: Double
    let summary: String
    let icon: String
    let sunriseTime, sunsetTime: Double
    let moonPhase: Double
    let precipIntensity: Double
    let precipIntensityMax: Double
    let precipIntensityMaxTime: Double?
    let precipProbability: Double
    let temperatureHigh: Double
    let temperatureHighTime: Double
    let temperatureLow: Double
    let temperatureLowTime: Double
    let apparentTemperatureHigh: Double
    let apparentTemperatureHighTime: Double
    let apparentTemperatureLow: Double
    let apparentTemperatureLowTime: Double
    let dewPoint, humidity, pressure, windSpeed: Double
    let windGust: Double
    let windGustTime, windBearing: Double
    let cloudCover: Double
    let uvIndex, uvIndexTime: Double
    let visibility, ozone, temperatureMin: Double
    let temperatureMinTime: Double
    let temperatureMax: Double
    let temperatureMaxTime: Double
    let apparentTemperatureMin: Double
    let apparentTemperatureMinTime: Double
    let apparentTemperatureMax: Double
    let apparentTemperatureMaxTime: Double
    
    init(time: Double, summary: String, icon: String, sunriseTime: Double, sunsetTime: Double, moonPhase: Double, precipIntensity: Double, precipIntensityMax: Double, precipIntensityMaxTime: Double?, precipProbability: Double, temperatureHigh: Double, temperatureHighTime: Double, temperatureLow: Double, temperatureLowTime: Double, apparentTemperatureHigh: Double, apparentTemperatureHighTime: Double, apparentTemperatureLow: Double, apparentTemperatureLowTime: Double, dewPoint: Double, humidity: Double, pressure: Double, windSpeed: Double, windGust: Double, windGustTime: Double, windBearing: Double, cloudCover: Double, uvIndex: Double, uvIndexTime: Double, visibility: Double, ozone: Double, temperatureMin: Double, temperatureMinTime: Double, temperatureMax: Double, temperatureMaxTime: Double, apparentTemperatureMin: Double, apparentTemperatureMinTime: Double, apparentTemperatureMax: Double, apparentTemperatureMaxTime: Double) {
        self.time = time
        self.summary = summary
        self.icon = icon
        self.sunriseTime = sunriseTime
        self.sunsetTime = sunsetTime
        self.moonPhase = moonPhase
        self.precipIntensity = precipIntensity
        self.precipIntensityMax = precipIntensityMax
        self.precipIntensityMaxTime = precipIntensityMaxTime
        self.precipProbability = precipProbability
        self.temperatureHigh = temperatureHigh
        self.temperatureHighTime = temperatureHighTime
        self.temperatureLow = temperatureLow
        self.temperatureLowTime = temperatureLowTime
        self.apparentTemperatureHigh = apparentTemperatureHigh
        self.apparentTemperatureHighTime = apparentTemperatureHighTime
        self.apparentTemperatureLow = apparentTemperatureLow
        self.apparentTemperatureLowTime = apparentTemperatureLowTime
        self.dewPoint = dewPoint
        self.humidity = humidity
        self.pressure = pressure
        self.windSpeed = windSpeed
        self.windGust = windGust
        self.windGustTime = windGustTime
        self.windBearing = windBearing
        self.cloudCover = cloudCover
        self.uvIndex = uvIndex
        self.uvIndexTime = uvIndexTime
        self.visibility = visibility
        self.ozone = ozone
        self.temperatureMin = temperatureMin
        self.temperatureMinTime = temperatureMinTime
        self.temperatureMax = temperatureMax
        self.temperatureMaxTime = temperatureMaxTime
        self.apparentTemperatureMin = apparentTemperatureMin
        self.apparentTemperatureMinTime = apparentTemperatureMinTime
        self.apparentTemperatureMax = apparentTemperatureMax
        self.apparentTemperatureMaxTime = apparentTemperatureMaxTime
    }
}

class Flags: Codable {
    let sources: [String]
    let nearestStation: Double
    let units: String
    
    enum CodingKeys: String, CodingKey {
        case sources
        case nearestStation = "nearest-station"
        case units
    }
    
    init(sources: [String], nearestStation: Double, units: String) {
        self.sources = sources
        self.nearestStation = nearestStation
        self.units = units
    }
}

class Hourly: Codable {
    let summary: String
    let icon: String
    let data: [Currently]
    
    init(summary: String, icon: String, data: [Currently]) {
        self.summary = summary
        self.icon = icon
        self.data = data
    }
}

class Location: NSObject,NSCoding  {
    
    var lat, lon : Double
    var city : String
    
    init(lat: Double, lon: Double,city:String) {
        self.lon = lon
        self.lat = lat
        self.city = city
    }
    
    required init(coder aDecoder: NSCoder) {
        self.lat = aDecoder.decodeDouble(forKey: "lat")
        self.lon = aDecoder.decodeDouble(forKey: "lon")
        self.city = aDecoder.decodeObject(forKey: "city") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encode(lat, forKey: "lat")
        aCoder.encode(lon, forKey: "lon")
        aCoder.encode(city, forKey: "city")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lat, forKey: "lat")
        aCoder.encode(lon, forKey: "lon")
        aCoder.encode(city, forKey: "city")
    }
    
}
