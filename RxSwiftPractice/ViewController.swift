//
//  ViewController.swift
//  RxSwiftPractice
//
//  Created by Dinh Thanh An on 4/20/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var shownCities = [String]() // Data source for UITableView
    let allCities = ["New York", "London", "Oslo", "Warsaw", "Berlin", "Praga"] // Our mocked API data source
    let disposeBag = DisposeBag() // Bag of disposables to release them when view is being deallocated
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        tableView.dataSource = self
        searchBar
            .rx.text // Observable property thanks to RxCocoa
            .orEmpty // Make it non-optional
            .debounce(0.5, scheduler: MainScheduler.instance) // Wait 0.5 for changes.
            .distinctUntilChanged() // If they didn't occur, check if the new value is the same as old.
            .filter { !$0.isEmpty } // If the new value is really new, filter for non-empty query.
            .subscribe(onNext: { [unowned self] query in // Here we subscribe to every new value, that is not empty (thanks to filter above).
                self.shownCities = self.allCities.filter { $0.hasPrefix(query) } // We now do our "API Request" to find cities.
                self.tableView.reloadData() // And reload table view data.
            })
            .addDisposableTo(disposeBag) // Don't forget to add this to disposeBag. We want to dispose it on deinit.
    }
    
}

// MARK: - UITableViewDataSource
/// Here we have standard data source extension for ViewController
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityPrototypeCell", for: indexPath)
        cell.textLabel?.text = shownCities[indexPath.row]
        
        return cell
    }
}

