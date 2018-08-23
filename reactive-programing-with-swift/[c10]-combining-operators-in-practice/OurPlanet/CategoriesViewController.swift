//
//  CategoriesViewController.swift
//  OurPlanet
//
//  Created by Jonathan Tang on 21/08/2018.
//  Copyright © 2018 Jonathan Tang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    let categories = Variable<[EOCategory]>([])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories.asObservable().subscribe(onNext: { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
        
        startDownload()
    }
    
    func startDownload() {
        let eoCategories = EONET.categories
        let downloadedEvents = EONET.event(forLast: 360)
        
        let updatedCategories = Observable.combineLatest(eoCategories, downloadedEvents) {
            (categories, events) -> [EOCategory] in
            return categories.map { category in
                var cat = category
                cat.events = events.filter {
                    $0.categories.contains(category.id)
                }
                return cat
            }
        }
        
        eoCategories.concat(updatedCategories).bind(to: categories).disposed(by: disposeBag)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
        
        let category = categories.value[indexPath.row]
        cell.textLabel?.text = category.name
        cell.detailTextLabel?.text = category.description
        
        return cell
    }
    
}


