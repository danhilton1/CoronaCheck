//
//  AnnotationTitleLabel.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 17/04/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

class AnnotationTitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(text: String) {
        self.init(frame: .zero)
        self.text = text
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .label
        font = UIFont.systemFont(ofSize: 12, weight: .bold)
    }

}
