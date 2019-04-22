//
//  ViewController.swift
//  Weather
//
//  Created by Ram Kumar on 15/04/19.
//  Copyright © 2019 Ram Kumar. All rights reserved.
//

import UIKit
import Reachability
import Charts
import CoreLocation

class ViewController: UIViewController,SearchViewControllerDelegate {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var updatedWhen: UILabel!
    @IBOutlet var cityName: UILabel!
    @IBOutlet weak var barChartView: LineChartView!
    var delegate : NewViewControllerAdded?
    var months: [String]!
    var location : Location?
    let reachability = Reachability()!
    var isConnection :Bool = false
    var temperature : Temperatures!
    public var locationIndex : Int!
    @IBOutlet weak var addCity: UIButton!
    
    var dataTask: URLSessionDataTask?
    override func viewDidLoad() {
        super.viewDidLoad()
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        setChart(dataPoints:months, values: unitsSold)
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            self.isConnection = true
            if Global.sharedInstance.locationList.count == 0 {
                self.activityIndicator.startAnimating()
                self.presentLocation()
            }else{
                self.location = Global.sharedInstance.locationList[self.locationIndex]
                self.cityName.text = self.location?.city == nil ? "" : self.location?.city
                self.temperatureCall()
            }
            
        }
        
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            self.isConnection = false
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        if Global.sharedInstance.locationList.count != 0 && Global.sharedInstance.locationList.count >= self.locationIndex{
            self.location = Global.sharedInstance.locationList[self.locationIndex]
        }
        cityName.text = self.location?.city == nil ? "" : self.location?.city
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        present(viewController, animated: true) {
            viewController.delegate = self
        }
    }
    
    func searchDismissed(location: CLPlacemark) {
        if Global.sharedInstance.locationList.count > 0 {
            for i in 0...Global.sharedInstance.locationList.count-1 {
                if Global.sharedInstance.locationList[i].city == location.name {
                    Global.sharedInstance.locationList.remove(at: i)
                    break
                }
            }
            Global.sharedInstance.locationList.insert(Location(lat:(location.location?.coordinate.latitude)!,lon:(location.location?.coordinate.longitude)!,city:location.name!), at: 0)
        }
        delegate?.onNewLocationAdded(locationIndex:0)
    }
    
    fileprivate func temperatureCall() {
        let url = URL(string: "https://api.darksky.net/forecast/53bb398c7d4971848bda0ac96a4b26bf/"+String(Double((self.location?.lat)!))+","+String(Double((self.location?.lon)!)))!
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            let currentlyObj : Currently
            let hourlyObj : Hourly
            let dailyObj : Daily
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    //self.temperature = jsonResult
                
                
                let jsonResultcurrently : NSDictionary =  jsonResult!.value(forKey: "currently") as! NSDictionary
                let time: Double = jsonResultcurrently.value(forKey: "time") as! Double
                let summary: String = jsonResultcurrently.value(forKey: "summary") as! String
                let icon: String = jsonResultcurrently.value(forKey: "icon") as! String
                let precipIntensity :Double = jsonResultcurrently.value(forKey: "precipIntensity") as! Double
                let precipProbability: Double = jsonResultcurrently.value(forKey: "precipProbability") as! Double
                let temperature : Double = jsonResultcurrently.value(forKey: "temperature") as! Double
                let apparentTemperature : Double = jsonResultcurrently.value(forKey: "apparentTemperature") as! Double
                let dewPoint : Double = jsonResultcurrently.value(forKey: "dewPoint") as! Double
                let humidity: Double = jsonResultcurrently.value(forKey: "humidity") as! Double
                let pressure : Double = jsonResultcurrently.value(forKey: "pressure") as! Double
                let windSpeed : Double = jsonResultcurrently.value(forKey: "windSpeed") as! Double
                let windGust: Double = jsonResultcurrently.value(forKey: "windGust") as! Double
                let windBearing: Double = jsonResultcurrently.value(forKey: "windBearing") as! Double
                let cloudCover: Double = jsonResultcurrently.value(forKey: "cloudCover") as! Double
                let uvIndex: Double = jsonResultcurrently.value(forKey: "uvIndex") as! Double
                let visibility : Double = jsonResultcurrently.value(forKey: "visibility") as! Double
                let ozone: Double = jsonResultcurrently.value(forKey: "ozone") as! Double
                currentlyObj = Currently(time: time, summary: summary, icon: icon, precipIntensity: precipIntensity, precipProbability: precipProbability, temperature: temperature, apparentTemperature: apparentTemperature, dewPoint: dewPoint, humidity: humidity, pressure: pressure, windSpeed: windSpeed, windGust: windGust, windBearing: windBearing, cloudCover: cloudCover, uvIndex: uvIndex, visibility: visibility, ozone: ozone)
                
                let hourlyJson : NSDictionary =  jsonResult!.value(forKey: "hourly") as! NSDictionary
                let summaryH: String = hourlyJson.value(forKey: "summary") as! String
                let iconH: String = hourlyJson.value(forKey: "icon") as! String
                var data = [Currently]()
                let dataArray : NSArray =  hourlyJson.value(forKey: "data") as! NSArray
                for dictonary in dataArray {
                    let dict : NSDictionary = dictonary as! NSDictionary
                    let time: Double = dict.value(forKey: "time") as! Double
                    let summary: String = dict.value(forKey: "summary") as! String
                    let icon: String = dict.value(forKey: "icon") as! String
                    var pi = 0.0
                    if (dict.object(forKey: "precipIntensity") != nil) {
                        pi = dict.value(forKey: "precipIntensity") as! Double
                    }
                    let precipIntensity :Double = pi
                    let precipProbability: Double = dict.value(forKey: "precipProbability") as! Double
                    let temperature : Double = dict.value(forKey: "temperature") as! Double
                    let apparentTemperature : Double = dict.value(forKey: "apparentTemperature") as! Double
                    let dewPoint : Double = dict.value(forKey: "dewPoint") as! Double
                    let humidity: Double = dict.value(forKey: "humidity") as! Double
                    let pressure : Double = dict.value(forKey: "pressure") as! Double
                    let windSpeed : Double = dict.value(forKey: "windSpeed") as! Double
                    let windGust: Double = dict.value(forKey: "windGust") as! Double
                    let windBearing: Double = dict.value(forKey: "windBearing") as! Double
                    let cloudCover: Double = dict.value(forKey: "cloudCover") as! Double
                    let uvIndex: Double = dict.value(forKey: "uvIndex") as! Double
                    let visibility : Double = dict.value(forKey: "visibility") as! Double
                    let ozone: Double = dict.value(forKey: "ozone") as! Double
                    let localHourly = Currently(time: time, summary: summary, icon: icon, precipIntensity: precipIntensity, precipProbability: precipProbability, temperature: temperature, apparentTemperature: apparentTemperature, dewPoint: dewPoint, humidity: humidity, pressure: pressure, windSpeed: windSpeed, windGust: windGust, windBearing: windBearing, cloudCover: cloudCover, uvIndex: uvIndex, visibility: visibility, ozone: ozone)
                    data.append(localHourly)
                }
                hourlyObj = Hourly(summary: summaryH, icon: iconH, data: data)
                
                let dailyJson : NSDictionary =  jsonResult!.value(forKey: "daily") as! NSDictionary
                let summaryD: String = dailyJson.value(forKey: "summary") as! String
                let iconD: String = hourlyJson.value(forKey: "icon") as! String
                var dataD = [Datum]()
                let dailyArray : NSArray =  dailyJson.value(forKey: "data") as! NSArray
                for dictonary in dailyArray {
                    let dict : NSDictionary = dictonary as! NSDictionary
                    let time: Double = dict.value(forKey: "time") as! Double
                    let summary: String = dict.value(forKey: "summary") as! String
                    let icon: String = dict.value(forKey: "icon") as! String
                    let sunriseTime: Double = dict.value(forKey: "sunriseTime") as! Double
                    let sunsetTime: Double = dict.value(forKey: "sunsetTime") as! Double
                    let moonPhase: Double = dict.value(forKey: "moonPhase") as! Double
                    let precipIntensity :Double = dict.value(forKey: "precipIntensity") as! Double
                    let precipIntensityMax :Double = dict.value(forKey: "precipIntensityMax") as! Double
                    
                    var pimt = 0.0
                    if (dict.object(forKey: "precipIntensityMaxTime") != nil) {
                        pimt = dict.value(forKey: "precipIntensityMaxTime") as! Double
                    }
                    let precipIntensityMaxTime: Double = pimt
                    let precipProbability: Double = dict.value(forKey: "precipProbability") as! Double
                    let temperatureHigh : Double = dict.value(forKey: "temperatureHigh") as! Double
                    let temperatureHighTime : Double = dict.value(forKey: "temperatureHighTime") as! Double
                   
                    let temperatureLowTime: Double = dict.value(forKey: "temperatureHighTime") as! Double
                    let apparentTemperatureHighTime: Double = dict.value(forKey: "apparentTemperatureHighTime") as! Double
                    let apparentTemperatureLowTime: Double = dict.value(forKey: "apparentTemperatureLowTime") as! Double
                    let temperatureLow : Double = dict.value(forKey: "temperatureLow") as! Double
                    let apparentTemperatureHigh : Double = dict.value(forKey: "apparentTemperatureHigh") as! Double
                    let apparentTemperatureLow : Double = dict.value(forKey: "apparentTemperatureLow") as! Double
                    let dewPoint : Double = dict.value(forKey: "dewPoint") as! Double
                    let humidity: Double = dict.value(forKey: "humidity") as! Double
                    let pressure : Double = dict.value(forKey: "pressure") as! Double
                    let windSpeed : Double = dict.value(forKey: "windSpeed") as! Double
                    let windGust: Double = dict.value(forKey: "windGust") as! Double
                    let windBearing: Double = dict.value(forKey: "windBearing") as! Double
                    let cloudCover: Double = dict.value(forKey: "cloudCover") as! Double
                    let uvIndex: Double = dict.value(forKey: "uvIndex") as! Double
                    let uvIndexTime: Double = dict.value(forKey: "uvIndexTime") as! Double
                    let windGustTime: Double = dict.value(forKey: "windGustTime") as! Double
                    let visibility : Double = dict.value(forKey: "visibility") as! Double
                    let ozone: Double = dict.value(forKey: "ozone") as! Double
                    let temperatureMin: Double = dict.value(forKey: "temperatureMin") as! Double
                    let temperatureMinTime: Double = dict.value(forKey: "temperatureMinTime") as! Double
                    let temperatureMax: Double = dict.value(forKey: "temperatureMax") as! Double
                    let temperatureMaxTime: Double = dict.value(forKey: "temperatureMaxTime") as! Double
                    let apparentTemperatureMin: Double = dict.value(forKey: "apparentTemperatureMin") as! Double
                    let apparentTemperatureMinTime: Double = dict.value(forKey: "apparentTemperatureMinTime") as! Double
                    let apparentTemperatureMax: Double = dict.value(forKey: "apparentTemperatureMax") as! Double
                    let apparentTemperatureMaxTime: Double = dict.value(forKey: "apparentTemperatureMaxTime") as! Double
                    let datum = Datum(time: time, summary: summary, icon: icon, sunriseTime: sunriseTime, sunsetTime: sunsetTime, moonPhase: moonPhase, precipIntensity: precipIntensity, precipIntensityMax: precipIntensityMax, precipIntensityMaxTime: precipIntensityMaxTime, precipProbability: precipProbability, temperatureHigh: temperatureHigh, temperatureHighTime: temperatureHighTime, temperatureLow: temperatureLow, temperatureLowTime: temperatureLowTime, apparentTemperatureHigh: apparentTemperatureHigh, apparentTemperatureHighTime: apparentTemperatureHighTime, apparentTemperatureLow: apparentTemperatureLow, apparentTemperatureLowTime: apparentTemperatureLowTime, dewPoint: dewPoint, humidity: humidity, pressure: pressure, windSpeed: windSpeed, windGust: windGust, windGustTime: windGustTime, windBearing: windBearing, cloudCover: cloudCover, uvIndex: uvIndex, uvIndexTime: uvIndexTime, visibility: visibility, ozone: ozone, temperatureMin: temperatureMin, temperatureMinTime: temperatureMinTime, temperatureMax: temperatureMax, temperatureMaxTime: temperatureMaxTime, apparentTemperatureMin: apparentTemperatureMin, apparentTemperatureMinTime: apparentTemperatureMinTime, apparentTemperatureMax: apparentTemperatureMax, apparentTemperatureMaxTime: apparentTemperatureMaxTime)
                    dataD.append(datum)
                }
                dailyObj = Daily(summary: summaryD, icon: iconD, data: dataD)
                
                let latitude : Double = jsonResult!.value(forKey: "latitude") as! Double
                let longitude : Double = jsonResult!.value(forKey: "longitude") as! Double
                let timezone : String = jsonResult!.value(forKey: "timezone") as! String
                let offset : Double = jsonResult!.value(forKey: "offset") as! Double
                self.temperature = Temperatures(latitude: latitude, longitude: longitude, timezone: timezone, currently: currentlyObj, hourly: hourlyObj, daily: dailyObj, flags: Flags(sources: [],nearestStation: 00.00,units: "nil"), offset: offset)
                
                DispatchQueue.main.sync  {
                    self.updatedWhen.text = "Just Updated"
                    let y = Double(round(10*self.temperature.currently.temperature)/10)
                    self.temperatureLabel.text = String(y)
                    self.activityIndicator.stopAnimating()
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                self.activityIndicator.stopAnimating()
            }
        }
        task.resume()
    }
    
    fileprivate func presentLocation() {
        let url = URL(string: "http://ip-api.com/json")!
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    if let lat = jsonResult.value(forKey: "lat") as? Double {
                        if let lon = jsonResult.value(forKey: "lon") as? Double{
                            let city = jsonResult.value(forKey: "city") as! String
                            self.location = Location(lat: lat,lon: lon,city:city)
                            Global.sharedInstance.locationList.append(self.location!)
                            DispatchQueue.main.sync  {
                                 self.cityName.text = self.location?.city == nil ? "" : self.location?.city
                            }
                            self.temperatureCall()
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                self.activityIndicator.stopAnimating()
            }
        }
        task.resume()
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y:values[i],data:dataPoints[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "Temperature Variation")
        let chartData = LineChartData(dataSet: chartDataSet)
        barChartView.data = chartData
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.delegate = nil
    }
    
}

protocol NewViewControllerAdded {
    func onNewLocationAdded(locationIndex: Int)
}
