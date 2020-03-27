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

    enum CardState {
        case partExpanded
        case fullExpanded
        case collapsed
    }
    
    enum StatisticDetail {
        case cases
        case deaths
        case recoveries
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var keyButton: UIButton!
    
    //MARK:- Properties
    
    let locationManager = CLLocationManager()
    
    // Properties for card view
    var cardViewController: CardViewController!
    var visualEffectView: UIVisualEffectView!
    
    var cardHeight: CGFloat!
    let cardHandleAreaHeight: CGFloat = 40
    
    var cardPartExpanded = false
    var cardFullyExpanded = false
    
    var nextState: CardState {
        if cardPartExpanded {
            return .fullExpanded
        }
        else if cardFullyExpanded {
            return .collapsed
        }
        else {
            return .partExpanded
        }
    }
    
    var previousState: CardState {
        if cardFullyExpanded {
            return .partExpanded
        }
        else {
            return .collapsed
        }
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    var allStatistics: [CoronaStatistic]?
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCard()
        setUpCardViewLabels()
        checkLocationServices()
        addAnnotations(forStatistic: .cases)
        
    }
    
    //MARK:- Card View Methods
    
    func setUpCard() {
        
        cardHeight = self.view.frame.height - 100
        
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        cardViewController = CardViewController(nibName: "CardView", bundle: nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: self.view.bounds.height - ((self.tabBarController?.tabBar.frame.height ?? 100) + cardHandleAreaHeight), width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(_:)))
        
        cardViewController.view.addGestureRecognizer(panGestureRecognizer)
        
        cardViewController.view.layer.cornerRadius = 16
        cardViewController.lineView.layer.cornerRadius = 3
        visualEffectView.alpha = 0
        
    }
    
    func setUpCardViewLabels() {
        cardViewController.countryLabel.text = "Worldwide"
        
        NetworkingServices.downloadData(forCountryCode: nil) { [weak self] (statistic) in
            DispatchQueue.main.async {
                self?.cardViewController.casesLabel.text = "\(statistic.confirmed)"
                self?.cardViewController.deathsLabel.text = "\(statistic.deaths)"
                self?.cardViewController.recoveriesLabel.text = "\(statistic.activeOrRecovered)"
            }
        }
    }
    
    
    @objc func handleCardPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if recognizer.velocity(in: cardViewController.view).y < 0 {
                startInteractiveTransition(state: nextState, duration: 0.9)
            }
            else {
                startInteractiveTransition(state: previousState, duration: 0.9)
            }
        case .changed:
            let translation = recognizer.translation(in: cardViewController.view)
            
//            recognizer.view!.center = CGPoint(x: recognizer.view!.center.x, y: recognizer.view!.center.y + translation.y)
//            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: cardViewController.view)
            
            var fractionComplete = translation.y / (cardHeight - 300)

            if translation.y < 0 && !cardFullyExpanded {
                fractionComplete = -fractionComplete
            }

            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .partExpanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - (self.cardHeight - 400)
                case .fullExpanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight - (self.tabBarController?.tabBar.frame.height ?? 100)
                }
            }
            frameAnimator.addCompletion { _ in
                if state == .partExpanded {
                    self.cardPartExpanded = true
                    self.cardFullyExpanded = false
                }
                else if state == .fullExpanded {
                    self.cardPartExpanded = false
                    self.cardFullyExpanded = true
                }
                else {
                    self.cardPartExpanded = false
                    self.cardFullyExpanded = false
                }
                
                self.runningAnimations.removeAll()
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .partExpanded:
                    self.visualEffectView.alpha = 0
                    self.visualEffectView.effect = nil
                case .fullExpanded:
                    self.visualEffectView.alpha = 1
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffectView.alpha = 0
                    self.visualEffectView.effect = nil
                }
            }
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
        }
    }
    
    
    func startInteractiveTransition(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    //MARK:- Map/Location Methods
    
    func centerViewOnUserLocation() {
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
            centerViewOnUserLocation()
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
            self.allStatistics = statistics
            
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
                        annotation.title = "\(statistic.activeOrRecovered)"
                    }
                    
                    annotation.subtitle = statistic.province
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    annontations.append(annotation)
                }
            }
            self.mapView.addAnnotations(annontations)
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        centerViewOnUserLocation()
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
        
        ac.addAction(UIAlertAction(title: "Active or Recovered", style: .default) { _ in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.addAnnotations(forStatistic: .recoveries)
            self.keyButton.setTitle("🔴 Active or Recovered", for: .normal)
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    

}

// MARK:- Extension for CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationServices()
        }
        
    }
    
}

// MARK:- Extension for MapView Delegate Methods

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideCardView), object: nil)
        for statistic in allStatistics! {
            if statistic.province == view.annotation?.subtitle {
                let changeInConfirmed = statistic.changeInConfirmed ?? 0
                let changeInDeaths = statistic.changeInDeaths ?? 0
                cardViewController.countryLabel.text = statistic.province
                cardViewController.casesLabel.text = "\(statistic.confirmed)"
                cardViewController.deathsLabel.text = "\(statistic.deaths)"
                cardViewController.recoveriesLabel.text = "\(statistic.activeOrRecovered)"
                cardViewController.casesChangeLabel.text = "(+\(changeInConfirmed))*"
                cardViewController.deathsChangeLabel.text = "(+\(changeInDeaths))*"
                cardViewController.activeChangeLabel.text = "(+\(changeInConfirmed - changeInDeaths))*"
            }
        }
        startInteractiveTransition(state: .partExpanded, duration: 0.8)
        continueInteractiveTransition()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        perform(#selector(hideCardView), with: nil, afterDelay: 0)
    }
    
    @objc func hideCardView() {
        startInteractiveTransition(state: .collapsed, duration: 0.9)
        continueInteractiveTransition()
    }
}
