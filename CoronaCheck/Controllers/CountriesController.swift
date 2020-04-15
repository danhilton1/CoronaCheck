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
    
    enum Section {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Country>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Country>
    
    @IBOutlet weak var searchBar: UISearchBar!
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var snapshot: DataSourceSnapshot!
    
    var delegate: CountryDelegate?
    
    var countries: [Country] = [] {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.createSnapshot(from: self.countries)
            }
        }
    }
    
    let cache = NSCache<NSString, UIImage>()
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureView()
        configureCollectionViewDataSource()
        searchBar.delegate = self
        
    }
    
    
    private func configureView() {
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemGray6
            collectionView.backgroundColor = .systemGray6
        }
        else {
            view.backgroundColor = .white
            collectionView.backgroundColor = .white
        }
    }
    
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "CountryCell", bundle: nil), forCellWithReuseIdentifier: CountryCell.reuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    private func configureCollectionViewDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, country) -> CountryCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CountryCell.reuseID, for: indexPath) as! CountryCell
            cell.configure(with: country)
            
            return cell
        })
        createSnapshot(from: countries)
    }
    
    
    private func createSnapshot(from countries: [Country]) {
        snapshot = DataSourceSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(countries)

        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureView()
    }
    
    
}

//MARK:- Extensions for CollectionView and SearchBar methods

extension CountriesController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let country = dataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.loadDataFromCountry(country: country)

        self.dismiss(animated: true)
    }
    
}

// MARK:- SearchBar Delegate

extension CountriesController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let filteredCountries: [Country]
        if !searchText.isEmpty {
            filteredCountries = countries.filter { $0.name.contains(searchText) }
        } else {
            filteredCountries = countries
        }
        createSnapshot(from: filteredCountries)
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

}


