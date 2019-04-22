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
   
    @IBOutlet weak var tempRange: UILabel!
    @IBOutlet weak var textStatus: UILabel!
    @IBOutlet weak var typeIcon: UIImageView!
    @IBOutlet weak var weathericon: UIImageView!
    @IBOutlet weak var weatherSubtext1: UILabel!
    @IBOutlet weak var weatherText: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var updatedWhen: UILabel!
    @IBOutlet var cityName: UILabel!
    @IBOutlet weak var barChartView: LineChartView!
    var searchViewController : SearchViewController!
    var delegate : NewViewControllerAdded?
    var months: [String]!
    var location : Location?
    let reachability = Reachability()!
    var temperature : Temperatures!
    public var locationIndex : Int!
    @IBOutlet weak var addCity: UIButton!
    @IBOutlet weak var infoViewChild: UIView!
    var twoMinTimer : Timer!
    var onLaunch : Bool = false
    
    @IBAction func infoButtonClicked(_ sender: Any) {
        if Global.sharedInstance.isConnected && self.infoButton.tag == 200 {
            self.infoView.alpha = 0
            if Global.sharedInstance.locationList.count == 0 {
                self.activityIndicator.startAnimating()
                self.presentLocation()
            }else{
                self.location = Global.sharedInstance.locationList[self.locationIndex]
                self.cityName.text = self.location?.city == nil ? "" : self.location?.city
                self.temperatureCall()
            }
        }else if Global.sharedInstance.isConnected && self.infoButton.tag == 100 {
            goToSearch()
        }
    }
    @IBOutlet weak var infoMsg: UILabel!
    @IBOutlet weak var infoHeader: UILabel!
    @IBOutlet weak var infoView: UIView!
    
    fileprivate func showinfoMsg(msg:String,header:String,fromSearch:Bool) {
        self.activityIndicator.stopAnimating()
        self.infoView.alpha = 1;
        self.infoMsg.text = msg
        self.infoHeader.text = header//"Info"
        if fromSearch {
            self.infoButton.tag = 100
        }else{
            self.infoButton.tag = 200
        }
    }
    
    fileprivate func checkConnection() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            Global.sharedInstance.isConnected = true
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
            Global.sharedInstance.isConnected = false
            var fromSearch : Bool = false
            if self.searchViewController != nil {
                fromSearch = true
                self.searchViewController.dismiss(animated: true, completion: nil)
            }
            self.showinfoMsg(msg:"You are not connected to Internet. Please try again after sometime.",header:"Info",fromSearch:fromSearch)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        setChart(dataPoints:months, values: unitsSold)
        checkConnection()
        if Global.sharedInstance.locationList.count != 0 && Global.sharedInstance.locationList.count >= self.locationIndex{
            self.location = Global.sharedInstance.locationList[self.locationIndex]
        }
        cityName.text = self.location?.city == nil ? "" : self.location?.city
        
        self.infoButton.layer.borderColor = self.infoButton.titleColor(for:UIControl.State.normal)?.cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        self.temperatureLabel.addGestureRecognizer(tap)
        self.temperatureLabel.isUserInteractionEnabled = true
        showBack(show:1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !onLaunch {
            twoMinTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timer), userInfo: nil, repeats: true)
        }
        onLaunch = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if twoMinTimer != nil
        {
            twoMinTimer.invalidate()
            twoMinTimer = nil
        }
        onLaunch = false
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.temperatureLabel.isUserInteractionEnabled = true
        }
        DispatchQueue.main.async  {
            self.temperatureLabel.isUserInteractionEnabled = false
            let radians = 90 * Double.pi / 180
            UIView.animate(withDuration: 1, animations: {
                self.temperatureLabel.layer.transform = CATransform3DMakeRotation(CGFloat(radians), 1, 0, 0);
            }, completion: { (true) in
                let y = Double(round(10*self.temperature.currently.temperature)/10 )
                if Global.sharedInstance.unit == "F"{
                    Global.sharedInstance.unit = "C"
                }else{
                    Global.sharedInstance.unit = "F"
                }
                let min = Double(round(10*self.temperature.daily.data[0].temperatureMin)/10 )
                let height = Double(round(10*self.temperature.daily.data[0].temperatureHigh)/10 )
                self.tempRange.text = String(min) + "°" + Global.sharedInstance.unit + " / " + String(height) + "°" + Global.sharedInstance.unit
                self.temperatureLabel.text = String(y) + "°" + Global.sharedInstance.unit
                UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                    self.temperatureLabel.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0);
                }, completion: nil)
            })
        }
    }
    
    @objc func timer(){
        if Global.sharedInstance.isConnected {
            temperatureCall()
        }
    }
    
    fileprivate func goToSearch() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        searchViewController = (storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController)
        present(searchViewController, animated: true) {
            self.searchViewController.delegate = self
        }
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        goToSearch()
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
        
        DispatchQueue.main.async  {
            self.updatedWhen.text = "Updating.."
        }
        let url = URL(string: "https://api.darksky.net/forecast/53bb398c7d4971848bda0ac96a4b26bf/"+String(Double((self.location?.lat)!))+","+String(Double((self.location?.lon)!)))!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async  {
                    self.updatedWhen.text = "Updated failed"
                    self.activityIndicator.stopAnimating()
                    self.showinfoMsg(msg:"Some error acknowleged while trying request to server. Please try again after sometime.",header:"Error",fromSearch:false)
                }
                return
            }
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
                
                DispatchQueue.main.async  {
                    self.updatedWhen.text = "Just Updated"
                    let y = Double(round(10*self.temperature.currently.temperature)/10 )
                    self.temperatureLabel.text = String(y) + "°" + Global.sharedInstance.unit
                    self.activityIndicator.stopAnimating()
                    self.textStatus.text = self.temperature.currently.summary
                    let min = Double(round(10*self.temperature.daily.data[0].temperatureMin)/10 )
                    let height = Double(round(10*self.temperature.daily.data[0].temperatureHigh)/10 )
                    self.tempRange.text = String(min) + "°" + Global.sharedInstance.unit + " / " + String(height) + "°" + Global.sharedInstance.unit
                    var templist = [Double]()
                    for i in 0...self.temperature.daily.data.count - 1 {
                        templist.append( self.temperature.daily.data[i].temperatureMax)
                    }
                    self.setChart(dataPoints:self.months, values: templist)
                    var getIcon : Bool = false
                    if Global.sharedInstance.icon_list.contains(self.temperature.currently.icon){
                        self.showBack(show: 0)
                        self.typeIcon.image = UIImage(named: self.temperature.currently.icon)
                        getIcon = true
                    }else{
                        for i in 0...Global.sharedInstance.icon_list.count-1 {
                            if Global.sharedInstance.icon_list[i].contains(self.temperature.currently.icon) {
                                self.showBack(show: 0)
                                self.typeIcon.image = UIImage(named: Global.sharedInstance.icon_list[i])
                                getIcon = true
                                break
                            }
                        }
                    }
                    if !getIcon {
                        self.showBack(show: 1)
                    }
                }
            } catch let error as NSError {
                DispatchQueue.main.async  {
                    self.updatedWhen.text = "Updated failed"
                    self.activityIndicator.stopAnimating()
                    self.showinfoMsg(msg:"Some error acknowleged while trying request to server. Please try again after sometime.",header:"Error",fromSearch:false)
                }
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
    fileprivate func presentLocation() {
        DispatchQueue.main.async  {
            self.updatedWhen.text = "Updating.."
        }
        let url = URL(string: "http://ip-api.com/json")!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async  {
                    self.updatedWhen.text = "Updated City failed"
                    self.showinfoMsg(msg:"Some error acknowleged while trying request to server. Please try again after sometime.",header:"Error",fromSearch:false)
                    self.activityIndicator.stopAnimating()
                }
                
                return }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    if let lat = jsonResult.value(forKey: "lat") as? Double {
                        if let lon = jsonResult.value(forKey: "lon") as? Double{
                            let city = jsonResult.value(forKey: "city") as! String
                            self.location = Location(lat: lat,lon: lon,city:city)
                            Global.sharedInstance.locationList.append(self.location!)
                            DispatchQueue.main.async  {
                                self.updatedWhen.text = "Updated City"
                                 self.cityName.text = self.location?.city == nil ? "" : self.location?.city
                            }
                            self.temperatureCall()
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                DispatchQueue.main.async  {
                    self.updatedWhen.text = "Updated City failed"
                    self.showinfoMsg(msg:"Some error acknowleged while trying request to server. Please try again after sometime.",header:"Error",fromSearch:false)
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        task.resume()
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y:values[i],data:dataPoints[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "Temperature Variation")
        let chartData = LineChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        barChartView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.delegate = nil
    }
    
    private func showBack(show:CGFloat){
        self.weatherText.alpha = show
        self.weatherSubtext1.alpha = show
        self.weathericon.alpha = show
        if show == 1{
            self.typeIcon.alpha = 0
        }
        else{
            self.typeIcon.alpha = 1
        }
    }
    
}

protocol NewViewControllerAdded {
    func onNewLocationAdded(locationIndex: Int)
}
