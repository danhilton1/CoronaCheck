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
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var countriesButton: UIButton!
    
    let inputFormatter = DateFormatter()
    let outputFormatter = DateFormatter()
    
    var finishedDownloading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateNumbersInLabels()
        setUpViews()
        
        
        
    }
    
    
    func setUpViews() {
        
        navigationController?.isNavigationBarHidden = true
        
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        outputFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        
        countriesButton.layer.cornerRadius = 22
        
        refreshButton.rotate(duration: 1)
        
        downloadData()
    }
    
    func downloadData() {
        
        NetworkingServices.downloadData(for: nil) { (corona) in
            DispatchQueue.main.async {
                self.finishedDownloading = true
                self.refreshButton.layer.removeAllAnimations()
                
                self.confirmedCasesNumberLabel.text = "\(corona.confirmed)"
                self.confirmedDeathsNumberLabel.text = "\(corona.deaths)"
                self.confirmedRecoveriesNumberLabel.text = "\(corona.recovered)"
                let date = self.inputFormatter.date(from: corona.lastUpdate) ?? Date()
                self.lastUpdatedLabel.text = self.outputFormatter.string(from: date)
            }
        }
        
    }
    

    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        refreshButton.rotate(duration: 1)
        finishedDownloading = false
        animateNumbersInLabels()
        downloadData()
        
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


extension UIView {
    func rotate(duration: CFTimeInterval = 3) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
