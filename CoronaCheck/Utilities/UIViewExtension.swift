//
//  UIViewExtension.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 26/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation
import UIKit

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
