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
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var overviewTitleLabel: UILabel!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var casesView: UIView!
    @IBOutlet weak var casesTextLabel: UILabel!
    @IBOutlet weak var confirmedCasesNumberLabel: UILabel!

    @IBOutlet weak var deathsView: UIView!
    @IBOutlet weak var deathsTextLabel: UILabel!
    @IBOutlet weak var confirmedDeathsNumberLabel: UILabel!

    @IBOutlet weak var activesView: UIView!
    @IBOutlet weak var activeTextLabel: UILabel!
    @IBOutlet weak var confirmedRecoveriesNumberLabel: UILabel!
    
    @IBOutlet weak var lastUpdatedTextLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var countriesButton: UIButton!
    
    // Constraints
    @IBOutlet weak var appTitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var countryLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var countryLabelBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var countriesButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var countriesButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var countriesButtonHeightConstraint: NSLayoutConstraint!
    
    let inputFormatter = DateFormatter()
    let outputFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    
    var countryCode: String?
    var finishedDownloading = false
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateNumbersInLabels()
        setUpViews()
        checkDeviceAndUpdateConstraintsIfNeeded()
        
    }
    
    
    func setUpViews() {
        
        navigationController?.isNavigationBarHidden = true

        updateViewForUserInterfaceStyle()
        
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        outputFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        numberFormatter.numberStyle = .decimal
        
        casesView.layer.cornerRadius = 18
        deathsView.layer.cornerRadius = 18
        activesView.layer.cornerRadius = 18
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
    
    func checkDeviceAndUpdateConstraintsIfNeeded() {
        
        if UIScreen.main.bounds.height < 700 {
            if UIScreen.main.bounds.height < 600 {
                stackView.heightAnchor.constraint(equalToConstant: 180).isActive = true
                appTitleLabel.font = appTitleLabel.font.withSize(30)
                overviewTitleLabel.font = overviewTitleLabel.font.withSize(20)
                casesTextLabel.font = casesTextLabel.font.withSize(18)
                confirmedCasesNumberLabel.font = confirmedCasesNumberLabel.font.withSize(18)
                deathsTextLabel.font = deathsTextLabel.font.withSize(18)
                confirmedDeathsNumberLabel.font = confirmedDeathsNumberLabel.font.withSize(18)
                activeTextLabel.font = confirmedDeathsNumberLabel.font.withSize(18)
                confirmedRecoveriesNumberLabel.font = confirmedRecoveriesNumberLabel.font.withSize(18)
                
                appTitleLabelTopConstraint.constant = 15
                countryLabelTopConstraint.constant = 10
                stackViewBottomConstraint.constant = 10
                countriesButtonTopConstraint.constant = 10
                countriesButtonHeightConstraint.constant = 39
                countriesButton.layer.cornerRadius = 20
                
                stackView.spacing = 8
            }
            imageViewWidthConstraint.constant = 40
            imageViewHeightConstraint.constant = 40
            countryLabelTopConstraint.constant = 10
            stackViewBottomConstraint.constant = 20
            countriesButtonTopConstraint.constant = 30
            
            appTitleLabel.font = appTitleLabel.font.withSize(32)
            overviewTitleLabel.font = overviewTitleLabel.font.withSize(24)
            lastUpdatedTextLabel.font = lastUpdatedTextLabel.font.withSize(16)
            lastUpdatedLabel.font = lastUpdatedLabel.font.withSize(14.5)
            
            stackView.heightAnchor.constraint(equalToConstant: 230).isActive = true
        }
        else if UIScreen.main.bounds.height < 850 {
            appTitleLabel.font = appTitleLabel.font.withSize(36)
            overviewTitleLabel.font = overviewTitleLabel.font.withSize(26)
            
            countryLabelTopConstraint.constant = 15
            imageViewWidthConstraint.constant = 60
            imageViewHeightConstraint.constant = 60
            stackViewBottomConstraint.constant = 25
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
                    self.confirmedCasesNumberLabel.text = self.numberFormatter.string(from: NSNumber(value: corona.confirmed))
                    self.confirmedDeathsNumberLabel.text = self.numberFormatter.string(from: NSNumber(value: corona.deaths))
                    self.confirmedRecoveriesNumberLabel.text = self.numberFormatter.string(from: NSNumber(value: corona.activeOrRecovered))
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


