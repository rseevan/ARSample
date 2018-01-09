//
//  ViewController.swift
//  FitsmindSample
//
//  Created by Seevan Ranka on 06/01/18.
//  Copyright © 2018 Seevan Ranka. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    var marker = GMSMarker()
    var lastPositionOfTap: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLocationManagerAndMap()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func setUpLocationManagerAndMap()
    {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        mapView.isHidden = true
        self.view = mapView
        
    }
    @IBAction func goToARView(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: Bundle .main).instantiateViewController(withIdentifier: "ARSceneViewController") as! ARSceneViewController
        vc.position = lastPositionOfTap
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true, completion: nil)
    }
    
    // Updates location of marker and last position of tap
    func updateLocationoordinates(coordinates:CLLocationCoordinate2D) {
    
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            marker.position =  coordinates
            CATransaction.commit()
        lastPositionOfTap = mapView.projection.point(for: coordinates)
    }
}

extension ViewController {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")

        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        currentLocation = location
        lastPositionOfTap = mapView.projection.point(for: location.coordinate)
        marker.position = location.coordinate
        marker.map = mapView
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        locationManager.stopUpdatingLocation()
    }

    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    // action on my location button tap. Put the marker back to current location
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        updateLocationoordinates(coordinates: (currentLocation?.coordinate)!)
        return false
    }
    
    // Put the marker at the new location
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        updateLocationoordinates(coordinates: coordinate)
    }
  
}
