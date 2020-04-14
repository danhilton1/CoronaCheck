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
import Charts

class MapViewController: UIViewController {

    enum CardState {
        case partExpanded
        case fullExpanded
        case collapsed
    }
    
    enum StatisticCategory {
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
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    var allStatistics: [CoronaStatistic]?
    var casesChartData: BarChartData?
    var deathsChartData: BarChartData?
    var casesAxisDates: [String]?
    var deathsAxisDates: [String]?
    
    let numberFormatter = NumberFormatter()
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCard()
        setUpCardViewLabels()
        checkLocationServices()
        addAnnotations(forStatistic: .cases)
        cardViewController.barChartView.delegate = self
        
    }
    
    //MARK:- Card View Methods
    
    func setUpCard() {
        
        if UIScreen.main.bounds.height < 800 {
            cardHeight = self.view.frame.height - 50
        }
        else {
            cardHeight = self.view.frame.height - 100
        }
        
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
        
        cardViewController.segmentedControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        
    }
    
    @objc func segmentDidChange(_ sender: UISegmentedControl) {
        cardViewController.barChartView.highlightValues(nil)
        cardViewController.selectedValueLabel.text = ""
        
        if sender.selectedSegmentIndex == 0 {
            cardViewController.barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: casesAxisDates ?? [])
            cardViewController.barChartView.data = casesChartData
        }
        else {
            cardViewController.barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: deathsAxisDates ?? [])
            cardViewController.barChartView.data = deathsChartData
        }
    }
    
    func setUpCardViewLabels() {
        
        numberFormatter.numberStyle = .decimal
        
        cardViewController.countryLabel.text = "Worldwide"
        
        NetworkingServices.downloadData(forCountryCode: nil) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let statistic):
                DispatchQueue.main.async {
                    self.cardViewController.casesLabel.text = self.numberFormatter.string(from: NSNumber(value: statistic.confirmed))
                    self.cardViewController.deathsLabel.text = self.numberFormatter.string(from: NSNumber(value: statistic.deaths))
                    self.cardViewController.recoveriesLabel.text = self.numberFormatter.string(from: NSNumber(value: statistic.activeOrRecovered))
                }
            case .failure(let error):
                self.showErrorAlert(title: "Error", message: error.rawValue)
            }
            
        }
    }
    
    func updateCardView(statistic: CoronaStatistic, timeline: Array<(key: Date, value: Int)>?, isDisplayingCases: Bool) {
        
        let changeInConfirmed = statistic.changeInConfirmed ?? 0
        let changeInDeaths = statistic.changeInDeaths ?? 0
        cardViewController.countryLabel.text = statistic.province
        cardViewController.casesLabel.text = numberFormatter.string(from: NSNumber(value: statistic.confirmed))
        cardViewController.deathsLabel.text = numberFormatter.string(from: NSNumber(value: statistic.deaths))
        cardViewController.recoveriesLabel.text = numberFormatter.string(from: NSNumber(value: statistic.activeOrRecovered))
        cardViewController.casesChangeLabel.text = "(+\(numberFormatter.string(from: NSNumber(value: changeInConfirmed))!))*"
        cardViewController.deathsChangeLabel.text = "(+\(numberFormatter.string(from: NSNumber(value: changeInDeaths))!))*"
        cardViewController.activeChangeLabel.text = "(+\(numberFormatter.string(from: NSNumber(value: (changeInConfirmed - changeInDeaths)))!))*"
        
        let chartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 0)])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        var datesAsStrings = [String]()
        var x = 0.0
        
        for entry in timeline! {
            if entry.value > 0 {
                chartDataSet.append(BarChartDataEntry(x: x, y: Double(entry.value)))
                datesAsStrings.append(dateFormatter.string(from: entry.key))
                x += 1
            }
        }
        
        cardViewController.barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: datesAsStrings)
        
        chartDataSet.drawValuesEnabled = false
        chartDataSet.valueTextColor = .white
        var chartData: BarChartData
        
        if isDisplayingCases {
            casesAxisDates = datesAsStrings
            chartDataSet.colors = [.systemOrange]
            chartData = BarChartData(dataSet: chartDataSet)
            casesChartData = chartData
        }
        else {
            deathsAxisDates = datesAsStrings
            chartDataSet.colors = [.systemRed]
            chartData = BarChartData(dataSet: chartDataSet)
            deathsChartData = chartData
        }

        cardViewController.barChartView.data = chartData
        
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
                    
                    if UIScreen.main.bounds.height < 600 {
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - (self.cardHeight - 230)
                    }
                    else if UIScreen.main.bounds.height < 700 {
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - (self.cardHeight - 270)
                    }
                    else if UIScreen.main.bounds.height < 850 {
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - (self.cardHeight - 330)
                    }
                    else {
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - (self.cardHeight - 400)
                    }
                    
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
    
    
    private func addAnnotations(forStatistic category: StatisticCategory) {
        
        show(activityIndicator: activityIndicator, in: view)
        
        NetworkingServices.downloadAllLocationData { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let statistics):
                self.updateMapAnnotations(with: statistics, forCategory: category)
                
            case .failure(let error):
                self.showErrorAlert(title: "Error retrieving data", message: error.rawValue)
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
            }
            
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
    
    
    func updateMapAnnotations(with statistics: [CoronaStatistic], forCategory category: StatisticCategory) {
        self.allStatistics = statistics
        
        var annontations = [MKPointAnnotation]()
        
        for statistic in statistics {
            if let lat = statistic.latitude, let lon = statistic.longitude {
                let annotation = MKPointAnnotation()
                if category == .cases {
                    annotation.title = self.numberFormatter.string(from: NSNumber(value: statistic.confirmed))
                }
                else if category == .deaths {
                    annotation.title = self.numberFormatter.string(from: NSNumber(value: statistic.deaths))
                }
                else {
                    annotation.title = self.numberFormatter.string(from: NSNumber(value: statistic.activeOrRecovered))
                }
                
                annotation.subtitle = statistic.province
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                annontations.append(annotation)
            }
        }
        self.mapView.addAnnotations(annontations)
    }

}

// MARK:- Extension for CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
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
                
                updateCardView(statistic: statistic, timeline: statistic.deathsTimeline, isDisplayingCases: false)
                updateCardView(statistic: statistic, timeline: statistic.casesTimeline, isDisplayingCases: true)
                break
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

extension MapViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        if cardViewController.segmentedControl.selectedSegmentIndex == 0 {
            let dateString = casesAxisDates?[Int(entry.x)] ?? ""
                cardViewController.selectedValueLabel.text = "\(dateString):  \(numberFormatter.string(from: NSNumber(value: entry.y))!) cases"
        }
        else {
            let dateString = deathsAxisDates?[Int(entry.x)] ?? ""
                cardViewController.selectedValueLabel.text = "\(dateString):  \(numberFormatter.string(from: NSNumber(value: entry.y))!) deaths"
        }
    }
    
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        cardViewController.selectedValueLabel.text = ""
    }
}
