//
//  CardViewController.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 24/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts

class CardViewController: UIViewController {

    //MARK:- IBOutlets
    
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
    @IBOutlet weak var casesChangeLabel: UILabel!
    @IBOutlet weak var deathsChangeLabel: UILabel!
    @IBOutlet weak var activeChangeLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        updateViewForUserInterfaceStyle()
        
    }
    
    func setUpViews() {
        lineView.backgroundColor = .secondaryLabel
        handleAreaView.backgroundColor = .systemGray4
        mainView.backgroundColor = .systemGray5
        
        casesBackgroundLabel.layer.masksToBounds = true
        deathsBackgroundLabel.layer.masksToBounds = true
        recoveriesBackgroundLabel.layer.masksToBounds = true
        
        casesBackgroundLabel.layer.cornerRadius = 18
        deathsBackgroundLabel.layer.cornerRadius = 18
        recoveriesBackgroundLabel.layer.cornerRadius = 18
        
        barChartView.highlightPerTapEnabled = false
        barChartView.highlightPerDragEnabled = false
        barChartView.leftAxis.drawAxisLineEnabled = true
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.centerAxisLabelsEnabled = true
        barChartView.xAxis.drawAxisLineEnabled = true
        barChartView.xAxis.drawGridLinesEnabled = true
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.axisMinimum = 0
        barChartView.xAxis.labelTextColor = .label
        barChartView.leftAxis.labelTextColor = .label
        barChartView.legend.enabled = false
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
