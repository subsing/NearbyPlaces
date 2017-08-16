//
//  ServiceDataModel.swift
//  NerarByDemo
//
//  Created by Subhankar Singha on 8/14/17.
//  Copyright © 2017 Subhankar Singha. All rights reserved.
//

import Foundation
import UIKit

struct ServiceData {
    static var placeGeometry = [Geometry]()
    static var palceName = [String]()
    static var icon = [String]()
    static var openNow = [Int]()
    static var vicinity = [String]()
    static var types = [Type.typesArray]
    static var photoReference = [String]()
    static var placesicon = [String]()
}

struct Geometry {
    static var lat = [String]()
    static var long = [String]()
}

struct Type {
    static var typesArray = [String]()
}

struct CurrentCoordinates {
    static var currentLatitude: Double = 0
    static var currentLongitude: Double = 0
    
}
