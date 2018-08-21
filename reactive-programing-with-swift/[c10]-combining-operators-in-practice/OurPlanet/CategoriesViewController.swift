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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDownload()
    }
    
    func startDownload() {
        
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
        return cell
    }
    
}


