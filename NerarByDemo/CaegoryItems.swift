//
//  CaegoryItems.swift
//  NerarByDemo
//
//  Created by Subhankar Singha on 8/14/17.
//  Copyright © 2017 Subhankar Singha. All rights reserved.
//

import Foundation

class CateGoryItems: NSObject {
    
    func getInitialCategoryItems() -> [String] {
       // let itemsArray =  ["Bakery", "Doctor", "School", "Taxi_stand", "Hair_care", "Restaurant", "Pharmacy", "Atm", "Doctor", "Gym", "Store", "Spa"]
        var dictRoot: NSDictionary?
        if let path = Bundle.main.path(forResource: "CategoryItems", ofType: "plist") {
            dictRoot = NSDictionary(contentsOfFile: path)
        }
        
        let itemsArray = dictRoot?["items"] as! [String]
        return itemsArray
    }
    
    func setReorderedCategoryItems(orderedArray: [String]) {
        let path = Bundle.main.path(forResource: "CategoryItems", ofType: "plist")
        if let dict = NSMutableDictionary(contentsOfFile: path!) {
            dict.setValue(orderedArray, forKey: "items")
            
            dict.write(toFile: path!, atomically: false)
        }
    }
}
