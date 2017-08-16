//
//  DetailsMapViewController.swift
//  NerarByDemo
//
//  Created by Subhankar Singha on 8/13/17.
//  Copyright © 2017 Subhankar Singha. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailsMapViewController: UIViewController,UIGestureRecognizerDelegate {

    
    var myNewView = UIView()
    var selectedIndex: Int = 0
    var distanceBetweenPlaces: Double = 0
    var istouched = false
    
    let codedLabel:UILabel = UILabel()
    let codedLabel1:UILabel = UILabel()
    let currentStatus:UILabel = UILabel()
    let distance:UILabel = UILabel()
    
    @IBOutlet weak var detailsView: UIView!
    var locationManager: CLLocationManager = CLLocationManager()
    
    let mapView = GMSMapView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        loadMapView()
        getDistanceBetweenTwoCoOrdinates()
        loadDetailsView()
    }
    
    func getDistanceBetweenTwoCoOrdinates() {
        let coordinate₀ = CLLocation(latitude: CurrentCoordinates.currentLatitude, longitude: CurrentCoordinates.currentLongitude)
        let coordinate₁ = CLLocation(latitude: Double(Geometry.lat[selectedIndex])!, longitude:Double(Geometry.long[selectedIndex])!)
        
        distanceBetweenPlaces = coordinate₀.distance(from: coordinate₁) // result is in meters
    }
    
    func loadMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: CurrentCoordinates.currentLatitude, longitude: CurrentCoordinates.currentLongitude, zoom: 8.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        // Creates a marker in the center of the map.
        for item in 0...1 {
            let marker = GMSMarker()
            if item == 0 {
                marker.position = CLLocationCoordinate2D(latitude: CurrentCoordinates.currentLatitude, longitude: CurrentCoordinates.currentLongitude);
                marker.title = "Current Location"
                marker.snippet = ""
            }
            else {
                marker.position = CLLocationCoordinate2D(latitude: Double(Geometry.lat[selectedIndex])!, longitude: Double(Geometry.long[selectedIndex])!)
                marker.title = ServiceData.palceName[selectedIndex]
                marker.snippet = ""
            }
        
            let imageName = "mapPin"
            let image = UIImage(named: imageName)
            marker.icon = image
            marker.map = mapView
        }

    }
    
    override func loadView() {
    }
    
    func swipe(sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.right:
            selectedIndex += 1
            
        case UISwipeGestureRecognizerDirection.left:
            selectedIndex -= 1
            
        default:
            break
        }
        loadMapView()
        codedLabel.text = ServiceData.palceName[selectedIndex]
        codedLabel1.text = ServiceData.vicinity[selectedIndex]
        if ServiceData.openNow[selectedIndex] == 0 {
            currentStatus.text = "Open"
        } else {
            currentStatus.text = "Closed"
        }
        distance.text = "Distance = 3000"
        
    }
    
    func loadDetailsView() {
        myNewView = UIView(frame: CGRect(x: 4, y: 460, width: 365, height: 200))
        myNewView.backgroundColor=UIColor.lightGray
        
        // Add rounded corners to UIView
        myNewView.layer.cornerRadius=15
        
        // Add border to UIView
        myNewView.layer.borderWidth=2
        
        // Change UIView Border Color to Red
        myNewView.layer.borderColor = UIColor.red.cgColor
        
        
        myNewView.isUserInteractionEnabled = true
        
        
        //let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipe:"))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        //swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft.direction = .left
        myNewView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        //swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.direction = .right
        myNewView.addGestureRecognizer(swipeRight)
        
        swipeRight.delegate = self
        swipeLeft.delegate = self
        
       // myNewView.addGestureRecognizer(swipeLeft)
       // myNewView.addGestureRecognizer(swipeRight)
        

        
        self.view.addSubview(myNewView)
        
        //First Label
        codedLabel.frame = CGRect(x: 0, y: 20, width: 400, height: 30)
        codedLabel.textAlignment = .center
        codedLabel.text = ServiceData.palceName[selectedIndex]
        codedLabel.numberOfLines=1
        codedLabel.textColor=UIColor.red
        codedLabel.font=UIFont.systemFont(ofSize: 17)
        //codedLabel.backgroundColor=UIColor.lightGray
        
       // myNewView.addSubview(codedLabel)
        codedLabel.translatesAutoresizingMaskIntoConstraints = false
        codedLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        codedLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
       
        //second label
        codedLabel1.frame = CGRect(x: 50, y: 20, width: 320, height: 30)
        codedLabel1.textAlignment = .center
        codedLabel1.text = ServiceData.vicinity[selectedIndex]
        codedLabel1.numberOfLines=3
        codedLabel1.textColor=UIColor.red
        codedLabel1.font=UIFont.systemFont(ofSize: 12)
       // codedLabel1.backgroundColor=UIColor.lightGray
        
        codedLabel1.translatesAutoresizingMaskIntoConstraints = false
        codedLabel1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        codedLabel1.widthAnchor.constraint(equalToConstant: 300).isActive = true

        
        //Third label
        
        //second label
        currentStatus.frame = CGRect(x: 50, y: 20, width: 300, height: 30)
        currentStatus.textAlignment = .center
        if ServiceData.openNow[selectedIndex] == 0 {
            currentStatus.text = "Open"
        } else {
            currentStatus.text = "Closed"
        }
        currentStatus.numberOfLines=2
        currentStatus.textColor=UIColor.red
        currentStatus.font=UIFont.systemFont(ofSize: 17)
       // currentStatus.backgroundColor=UIColor.lightGray
        
        currentStatus.translatesAutoresizingMaskIntoConstraints = false
        currentStatus.heightAnchor.constraint(equalToConstant: 30).isActive = true
        currentStatus.widthAnchor.constraint(equalToConstant: 200).isActive = true
        

        //Fourth Label
        distance.frame = CGRect(x: 200, y: 20, width: 300, height: 30)
        currentStatus.textAlignment = .center
        distance.text = "Distance = \(distanceBetweenPlaces) metres"
        distance.numberOfLines=1
        distance.textColor=UIColor.red
        distance.font=UIFont.systemFont(ofSize: 17)
        distance.backgroundColor=UIColor.lightGray
        
        distance.translatesAutoresizingMaskIntoConstraints = false
        distance.leadingAnchor.constraint(equalTo: myNewView.leadingAnchor, constant: 250)
        distance.trailingAnchor.constraint(equalTo: myNewView.trailingAnchor, constant: 150)
        distance.heightAnchor.constraint(equalToConstant: 30).isActive = true
        distance.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        //Stack View
        let stackView   = UIStackView()
        stackView.axis  = UILayoutConstraintAxis.vertical
        stackView.distribution  = UIStackViewDistribution.equalSpacing
        stackView.alignment = UIStackViewAlignment.center
        stackView.spacing   = 16.0
        
        stackView.addArrangedSubview(codedLabel)
        stackView.addArrangedSubview(codedLabel1)
        stackView.addArrangedSubview(currentStatus)
        stackView.addArrangedSubview(distance)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        myNewView.addSubview(stackView)
        
        //Constraints
        stackView.centerXAnchor.constraint(equalTo: myNewView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: myNewView.centerYAnchor).isActive = true
        
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print("in shouldReceiveTouch")
        gestureRecognizer.delegate = self
        if (touch.view == myNewView){
            print("Yupii")
           // return false
        let position :CGPoint = touch.location(in: view)
        print(position.x)
        print(position.y)
        
        //let count = ServiceData.palceName.count -1
        if position.x > 185.0 {
            guard selectedIndex < ServiceData.palceName.count-1 else {
                return false
            }
            selectedIndex += 1
            loadMapView()
            getDistanceBetweenTwoCoOrdinates()
            loadDetailsView()
            codedLabel.text = ServiceData.palceName[selectedIndex]
            codedLabel1.text = ServiceData.vicinity[selectedIndex]
            if ServiceData.openNow[selectedIndex] == 0 {
                currentStatus.text = "Open"
            } else {
                currentStatus.text = "Closed"
            }
            distance.text = "Distance = \(distanceBetweenPlaces) metres"
        } else {
           // selectedIndex <= 0 ?? selectedIndex=0:selectedIndex-=1
            
            guard selectedIndex >= 0 && istouched == false else {
                istouched = false
                return false
            }
            selectedIndex -= 1
            istouched = true
            if selectedIndex >= 0 {
                loadMapView()
                getDistanceBetweenTwoCoOrdinates()
                loadDetailsView()
                codedLabel.text = ServiceData.palceName[selectedIndex]
                codedLabel1.text = ServiceData.vicinity[selectedIndex]
                if ServiceData.openNow[selectedIndex] == 0 {
                    currentStatus.text = "Open"
                } else {
                    currentStatus.text = "Closed"
                }
                distance.text = "Distance = \(distanceBetweenPlaces) metres"
                

                }
            }
        }
        return true
    }
        
 }
