//
//  CountryCell.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 18/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

class CountryCell: UICollectionViewCell {

    static let reuseID = "CountryCell"
    
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    

    
    func configure(with country: Country) {
        countryImageView.image = country.flagImage
        countryLabel.text = country.name
    }
}
