//
//  UIViewController+Ext.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 13/04/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func show(activityIndicator: UIActivityIndicatorView, in view: UIView) {
        activityIndicator.style = .large
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        activityIndicator.startAnimating()
    }
    
    
    func showErrorAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
        
    }
    
}
