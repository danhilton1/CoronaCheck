//
//  CountriesController.swift
//  CoronaCheck
//
//  Created by Daniel Hilton on 18/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit
import FlagKit

class CountriesController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Country>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Country>
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var dataSource: DataSource!
    private var snapshot: DataSourceSnapshot!
    
    var delegate: CountryDelegate?
    
    var countries: [Country]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateCountriesArray()
        
        collectionView.register(UINib(nibName: "CountryCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        searchBar.delegate = self
        
        configureCollectionViewDataSource()
        createSnapshot(from: countries!)
        
        
        collectionView.backgroundColor = .darkGray
        view.backgroundColor = .darkGray
          
    }
    
    func populateCountriesArray() {
        
        countries = [Country]()
        
        for code in NSLocale.isoCountryCodes  {
            if Flag(countryCode: code) != nil {
                
                let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
                let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
                let flag = Flag(countryCode: code)
                if let confirmedFlag = flag {
                    let flagImage = confirmedFlag.image(style: .circle)
                    countries?.append(Country(name: name, code: code, flagImage: flagImage))
                }
            }
        }
        countries = countries?.sorted { $0.name < $1.name }
    }
    
}

extension CountriesController: UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    enum Section {
        case main
    }
    
    
    private func configureCollectionViewDataSource() {
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, country) -> CountryCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CountryCell
            
            cell.countryImageView.image = country.flagImage
            cell.countryLabel.text = country.name
            
            return cell
        })
        
    }
    
    private func createSnapshot(from countries: [Country]) {
        
        snapshot = DataSourceSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(countries)
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
    

    //MARK: CollectionView Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 130)
    }
    
    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let country = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.loadDataFromCountry(country: country)

        self.dismiss(animated: true)
    }
    
    // MARK: SearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let filteredCountries: [Country]
        if !searchText.isEmpty {
            filteredCountries = countries!.filter { $0.name.contains(searchText) }
        } else {
            filteredCountries = countries!
        }
        createSnapshot(from: filteredCountries)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}


