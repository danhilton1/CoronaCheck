//
//  MapViewController.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 22/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var keyButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    enum StatisticDetail {
        case cases
        case deaths
        case recoveries
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationServices()
        addAnnotations(forStatistic: .cases)
        
    }
    
    func centreViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 50000, longitudinalMeters: 50000)
            mapView.setRegion(region, animated: true)
        }
    }

    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationAuthorization()
        }
        else {
            
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centreViewOnUserLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func addAnnotations(forStatistic detail: StatisticDetail) {
        var annontations = [MKPointAnnotation]()
        
        NetworkingServices.downloadAllLocationData { (statistics) in
            for statistic in statistics {
                if let lat = statistic.latitude, let lon = statistic.longitude {
                    let annotation = MKPointAnnotation()
                    if detail == .cases {
                        annotation.title = "\(statistic.confirmed)"
                    }
                    else if detail == .deaths {
                        annotation.title = "\(statistic.deaths)"
                    }
                    else {
                        annotation.title = "\(statistic.recovered)"
                    }
                    
                    annotation.subtitle = statistic.province
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    annontations.append(annotation)
                }
            }
            self.mapView.addAnnotations(annontations)
        }
    }
    
    @IBAction func keyButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Statistic", message: "Please select which statistic to display.", preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Confirmed Cases", style: .default) { _ in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.addAnnotations(forStatistic: .cases)
            self.keyButton.setTitle("🔴 Confirmed Cases", for: .normal)
        })
        
        ac.addAction(UIAlertAction(title: "Confirmed Deaths", style: .default) { _ in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.addAnnotations(forStatistic: .deaths)
            self.keyButton.setTitle("🔴 Confirmed Deaths", for: .normal)
        })
        
        ac.addAction(UIAlertAction(title: "Confirmed Recoveries", style: .default) { _ in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.addAnnotations(forStatistic: .recoveries)
            self.keyButton.setTitle("🔴 Confirmed Recoveries", for: .normal)
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    

}


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationServices()
        }
        
    }
    
}
