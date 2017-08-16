//
//  ViewController.swift
//  NerarByDemo
//
//  Created by Subhankar Singha on 8/12/17.
//  Copyright © 2017 Subhankar Singha. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire


class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tblNearbyCategory: UITableView!
    
    var categoryItems = [String()]
    
    let apiKey = "AIzaSyCAG1V8521CMXG0MFzkt5-KysNnajo27_8"
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    var placesClient: GMSPlacesClient!
    
    
    var googleMapView: GMSMapView!
    var latitude: Double!
    var longitude: Double!
    
    var nameLabel = ""
    var addressLabel = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Category"
        tblNearbyCategory.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        currentCategoryItems()
}
    
    func currentCategoryItems() {
       categoryItems = CateGoryItems().getInitialCategoryItems()
    }

    func getCurrentLocation()  {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            // self.nameLabel.text = "No current place"
            //self.addressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.nameLabel = place.name
                    self.addressLabel = (place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n"))!
                    
                    let actionSheetController: UIAlertController = UIAlertController(title: self.nameLabel, message: self.addressLabel, preferredStyle: .alert)
                    actionSheetController.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                        
                    })
                    self.present(actionSheetController, animated: true, completion: nil)
                }
            }
        })

    }
    
    @IBAction func showCurrentLocation(_ sender: Any) {
        
        getCurrentLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
        placesClient = GMSPlacesClient.shared()

    }
    
    func navigateToDetailsPage() {
        let detailsPage: CategoryDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryDetailsViewController") as! CategoryDetailsViewController
        self.navigationController?.pushViewController(detailsPage, animated: true)
    }
    
    func suffleCategoryOrder(selectedIndex: Int) {
        let item = categoryItems[selectedIndex]
        categoryItems.remove(at: selectedIndex)
        categoryItems.insert(item, at: 0)
        CateGoryItems().setReorderedCategoryItems(orderedArray: categoryItems)
        categoryItems = CateGoryItems().getInitialCategoryItems()
        tblNearbyCategory.reloadData()
        
    }
    
    //MARK: - UITableView DataSource & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel!.text = categoryItems[indexPath.row]//"Subhankar"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.latitude = locationManager.location?.coordinate.latitude
        CurrentCoordinates.currentLatitude = self.latitude
        self.longitude = locationManager.location?.coordinate.longitude
        CurrentCoordinates.currentLongitude = self.longitude
        
        let locationDetails = String(self.latitude) + "," + String(self.longitude)
        let radius = "5000&type="
        let keyword = categoryItems[indexPath.row].lowercased()//"atm"
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + locationDetails + "&radius=" + radius + keyword/*"atm"*/ + "&keyword=" + keyword + "&key=" + apiKey
        AlamofireNetworkConnection().getNearbyPlaces(url : urlString, methodType: .get, encodingType: URLEncoding.default, params : Dictionary(), postHeader : Dictionary(), success: { (responseJson) in
            print(responseJson)
            self.suffleCategoryOrder(selectedIndex: indexPath.row)
            self.navigateToDetailsPage()
        }) { (error) in
            print(error)
            let actionSheetController: UIAlertController = UIAlertController(title: "Server Alert", message: "Google places api not responding", preferredStyle: .alert)
            actionSheetController.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                
            })
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
}

extension ViewController  {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations.last!
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        
        // 2
        let coordinates = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        let marker = GMSMarker(position: coordinates)
        marker.title = "I am here"
        marker.map = self.googleMapView
        self.googleMapView.animate(toLocation: coordinates)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
       print("An error occurred while tracking location changes : \(error.description)")
    }
}
