//
//  PageViewController.swift
//  Weather
//
//  Created by Ram Kumar on 21/04/19.
//  Copyright © 2019 Ram Kumar. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class PageViewController : UIPageViewController,NewViewControllerAdded{
    var location : Location!
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        //presentLocation()
        let viewController = self.getViewController()
        viewController.locationIndex = 0
        self.setViewControllers([viewController], direction: .forward, animated: true) { (Bool) in viewController.delegate = self
        }
    }
    
    fileprivate func presentLocation() {
        let url = URL(string: "http://ip-api.com/json")!
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(jsonResult["city"] ?? "value")
                    if let lat = jsonResult.value(forKey: "lat") as? Double {
                        if let lon = jsonResult.value(forKey: "lon") as? Double{
                            let city = jsonResult.value(forKey: "city") as! String
                            self.location = Location(lat: lat,lon: lon,city:city)
                            if Global.sharedInstance.locationList.count > 0 {
                                for i in 0...Global.sharedInstance.locationList.count-1 {
                                    if Global.sharedInstance.locationList[i].city == city {
                                        Global.sharedInstance.locationList.remove(at: i)
                                        break
                                    }
                                }
                                Global.sharedInstance.locationList.insert( self.location,at:0)
                            }else{
                                Global.sharedInstance.locationList.append(self.location)
                            }
                            DispatchQueue.main.sync  {
                                let viewController = self.getViewController()
                                viewController.locationIndex = 0
                                self.setViewControllers([viewController], direction: .forward, animated: true) { (Bool) in viewController.delegate = self
                                }
                            }
                            
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    func onNewLocationAdded(locationIndex: Int) {
        let viewController = getViewController()
        viewController.locationIndex = locationIndex
        self.setViewControllers([viewController], direction: .forward, animated: true) { (Bool) in  viewController.delegate = self}
        
    }
}
extension PageViewController: UIPageViewControllerDataSource {
    
    func getViewController() -> ViewController{
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        return viewController
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        let index = (viewController as! ViewController).locationIndex
        if index == 0 {
            return nil
        }else{
            let viewController = getViewController()
            viewController.locationIndex = (index! - 1)
            return viewController
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        let index = ( viewController as! ViewController).locationIndex
        if index == Global.sharedInstance.locationList.count-1 {
            return nil
        }else{
            let viewController = getViewController()
            viewController.locationIndex = (index! + 1)
            return viewController
        }
    }
    
    
    
}
