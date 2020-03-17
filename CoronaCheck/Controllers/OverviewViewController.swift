//
//  OverviewViewController.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 16/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {

    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var overviewTitleLabel: UILabel!
    @IBOutlet weak var confirmedCasesNumberLabel: UILabel!
    @IBOutlet weak var confirmedDeathsNumberLabel: UILabel!
    @IBOutlet weak var confirmedRecoveriesNumberLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var countriesButton: UIButton!
    
    let inputFormatter = DateFormatter()
    let outputFormatter = DateFormatter()
    
    var finishedDownloading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        animateNumbersInLabels()
        
    }
    
    
    func setUpViews() {
        
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        outputFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        
        countriesButton.layer.cornerRadius = 22
        
        NetworkingServices.downloadData(for: nil) { (corona) in
            DispatchQueue.main.async {
                self.finishedDownloading = true
                
                self.confirmedCasesNumberLabel.text = "\(corona.confirmed)"
                self.confirmedDeathsNumberLabel.text = "\(corona.deaths)"
                self.confirmedRecoveriesNumberLabel.text = "\(corona.recovered)"
                let date = self.inputFormatter.date(from: corona.lastUpdate) ?? Date()
                self.lastUpdatedLabel.text = self.outputFormatter.string(from: date)
            }
            
        }
    }
    

    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        
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
    


}
