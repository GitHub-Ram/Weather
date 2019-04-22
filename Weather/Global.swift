//
//  Global.swift
//  Weather
//
//  Created by Ram Kumar on 21/04/19.
//  Copyright © 2019 Ram Kumar. All rights reserved.
//

import Foundation
import CoreLocation

final class Global{
    static let sharedInstance = Global()
    public var locationList = [Location]()
    private init() {
        getShavedLocation()
    }
    func getShavedLocation() {
        let loca = UserDefaults.standard.data(forKey: "LAST_LOCATIONS")
        if let loca = loca {
            let locaArray = NSKeyedUnarchiver.unarchiveObject(with: loca) as? [Location]
            
            if let locaArray = locaArray {
                locationList = locaArray
                print(locationList.count)
            }
            
        }
    }
    
}
