//
//  EventCell.swift
//  OurPlanet
//
//  Created by Jonathan Tang on 21/08/2018.
//  Copyright © 2018 Jonathan Tang. All rights reserved.
//

import UIKit

class EventCell : UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var details: UILabel!
    
    func configure(event: EOEvent) {
        title.text = event.title
        details.text = event.description
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let when = event.closeDate {
            date.text = formatter.string(for: when)
        } else {
            date.text = ""
        }
    }
}

