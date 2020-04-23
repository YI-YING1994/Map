//
//  ViewController.swift
//  Map
//
//  Created by MCUCSIE on 4/20/18.
//  Copyright © 2018 MCUCSIE. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let moveLimit = 55500.0
    var locationManager: CLLocationManager!
    let annotation = MKPointAnnotation()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var regionLatitude: UITextField!
    @IBOutlet weak var regionLongitude: UITextField!
    @IBOutlet weak var regionWidth: UITextField!
    @IBOutlet weak var regionHeight: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        mapView.delegate = self

        let coordinate = CLLocationCoordinate2DMake(Double(regionLatitude.text!)!, Double(regionLongitude.text!)!)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)

        updateLocation()
    }

    @IBAction func updateLocation() {
        guard let latitude = regionLatitude.text,
              let longitude = regionLongitude.text,
              let width = regionWidth.text,
              let height = regionHeight.text else { return }

        let coordinate = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
        annotation.coordinate = coordinate
        let region = mapView.regionThatFits(MKCoordinateRegionMakeWithDistance(coordinate, Double(width)!, Double(height)!))

        mapView.setRegion(region, animated: false)

        print("region inside:\(mapView.region)")

        view.endEditing(true)
    }

    @objc func keyboardWillHide() {
        mapTopConstraint.constant = 0
        bottomConstraint.constant = 0
    }
    @objc func keyboardWillShow(notification: Notification) {
        let keyboardFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! CGRect
        mapTopConstraint.constant = -(keyboardFrame.height + 10)
        bottomConstraint.constant = -(keyboardFrame.height + 10)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myPin")
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            annotationView?.canShowCallout = true
        }
        let leftView = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
        leftView.image = UIImage(named: "Taoyuan")
        annotationView?.leftCalloutAccessoryView = leftView

        return annotationView
    }

    func startStandardUpdates() {
        locationManager = CLLocationManager()
        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        let currentCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let distance = location.distance(from: currentCenter)

        if distance > moveLimit {
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 50, 50)
            mapView.setRegion(region, animated: true)
        }

        print(String(format: "latitude %.6f, longtitude %.6f", location.coordinate.latitude, location.coordinate.longitude))

    }

}

