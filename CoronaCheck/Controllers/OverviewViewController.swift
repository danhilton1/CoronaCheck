//
//  OverviewViewController.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 16/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit
import FlagKit

class OverviewViewController: UIViewController, CountryDelegate {

    //IBOutlets
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var overviewTitleLabel: UILabel!
    @IBOutlet weak var confirmedBackgroundLabel: UILabel!
    @IBOutlet weak var confirmedCasesNumberLabel: UILabel!
    @IBOutlet weak var deathsBackgroundLabel: UILabel!
    @IBOutlet weak var confirmedDeathsNumberLabel: UILabel!
    @IBOutlet weak var recoveriesBackgroundLabel: UILabel!
    @IBOutlet weak var confirmedRecoveriesNumberLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var countriesButton: UIButton!
    
    let inputFormatter = DateFormatter()
    let outputFormatter = DateFormatter()
    
    var countryCode: String?
    var finishedDownloading = false
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateNumbersInLabels()
        setUpViews()
        
    }
    
    
    func setUpViews() {
        
        navigationController?.isNavigationBarHidden = true

        updateViewForUserInterfaceStyle()
        
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        outputFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        
        confirmedBackgroundLabel.layer.masksToBounds = true
        deathsBackgroundLabel.layer.masksToBounds = true
        recoveriesBackgroundLabel.layer.masksToBounds = true
        confirmedBackgroundLabel.layer.cornerRadius = 18
        deathsBackgroundLabel.layer.cornerRadius = 18
        recoveriesBackgroundLabel.layer.cornerRadius = 18
        countriesButton.layer.cornerRadius = 25
        
        refreshButton.rotate(duration: 1)
        
        downloadData(countryCode: countryCode)
    }
    
    func updateViewForUserInterfaceStyle() {
            if traitCollection.userInterfaceStyle == .dark {
                view.backgroundColor = .systemGray6
                countriesButton.setTitleColor(.black, for: .normal)
                refreshButton.imageView?.tintColor = .white
            }
            else {
                view.backgroundColor = .white
                countriesButton.setTitleColor(.white, for: .normal)
                refreshButton.imageView?.tintColor = .black
            }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateViewForUserInterfaceStyle()
    }
    
    func animateNumbersInLabels() {
        DispatchQueue.global(qos: .background).async {
            while !self.finishedDownloading {
                DispatchQueue.main.async {
                    self.confirmedCasesNumberLabel.text = "\(Int.random(in: 10000...500000))"
                    self.confirmedDeathsNumberLabel.text = "\(Int.random(in: 1000...50000))"
                    self.confirmedRecoveriesNumberLabel.text = "\(Int.random(in: 1000...300000))"
                }
                usleep(1000)
            }
        }
    }
    
    //MARK:- Data Methods
    
    func downloadData(countryCode: String?) {
        
        NetworkingServices.downloadData(forCountryCode: countryCode) { (corona) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                
                self.finishedDownloading = true
                
                self.refreshButton.layer.removeAllAnimations()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    self.confirmedCasesNumberLabel.text = "\(corona.confirmed)"
                    self.confirmedDeathsNumberLabel.text = "\(corona.deaths)"
                    self.confirmedRecoveriesNumberLabel.text = "\(corona.activeOrRecovered)"
                }
                NetworkingServices.retrieveDateOfLastUpdate { (date) in
                    let date = self.inputFormatter.date(from: date) ?? Date()
                    DispatchQueue.main.async {
                        self.lastUpdatedLabel.text = self.outputFormatter.string(from: date)
                    }
                }
            }
        }
        
    }
    
    func loadDataFromCountry(country: Country) {
        countryCode = country.code
        finishedDownloading = false
        locationImageView.image = country.flagImage
        refreshButton.rotate(duration: 1)
        animateNumbersInLabels()
        overviewTitleLabel.text = country.name
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.downloadData(countryCode: country.code)
        }
        
    }
    

    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        refreshButton.rotate(duration: 1)
        finishedDownloading = false
        animateNumbersInLabels()
        downloadData(countryCode: countryCode)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToCountries" {
            let destVC = segue.destination as! CountriesController
            destVC.delegate = self
        }
    }
    

}


