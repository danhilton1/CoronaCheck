//
//  CardView.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 25/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

class CardView: UIView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview.frame.contains(point) {
                return true
            }
        }
        return false
    }

}
