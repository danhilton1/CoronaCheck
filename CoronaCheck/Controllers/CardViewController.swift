//
//  CardViewController.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 24/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    
    @IBOutlet weak var handleAreaView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var casesBackgroundView: UIView!
    @IBOutlet weak var deathsBackgroundView: UIView!
    @IBOutlet weak var recoveriesBackgroundView: UIView!
    @IBOutlet weak var casesBackgroundLabel: UILabel!
    @IBOutlet weak var deathsBackgroundLabel: UILabel!
    @IBOutlet weak var recoveriesBackgroundLabel: UILabel!
    @IBOutlet weak var casesLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    @IBOutlet weak var recoveriesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lineView.backgroundColor = .secondaryLabel
        handleAreaView.backgroundColor = .systemGray4
        mainView.backgroundColor = .systemGray5
        
        updateViewForUserInterfaceStyle()
        
        casesBackgroundLabel.layer.masksToBounds = true
        deathsBackgroundLabel.layer.masksToBounds = true
        recoveriesBackgroundLabel.layer.masksToBounds = true
        
        casesBackgroundLabel.layer.cornerRadius = 18
        deathsBackgroundLabel.layer.cornerRadius = 18
        recoveriesBackgroundLabel.layer.cornerRadius = 18
    }
    
    func updateViewForUserInterfaceStyle() {
            if traitCollection.userInterfaceStyle == .dark {
                mainView.backgroundColor = .systemGray5
                handleAreaView.backgroundColor = .systemGray4
            }
            else {
                mainView.backgroundColor = .white
                handleAreaView.backgroundColor = .systemGray6
            }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateViewForUserInterfaceStyle()
    }
    



}
