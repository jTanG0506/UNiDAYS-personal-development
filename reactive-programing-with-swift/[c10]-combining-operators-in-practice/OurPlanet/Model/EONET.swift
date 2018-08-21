//
//  EONET.swift
//  OurPlanet
//
//  Created by Jonathan Tang on 21/08/2018.
//  Copyright © 2018 Jonathan Tang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EONET {
    static let API = "https://eonet.sci.gsfc.nasa.gov/api/v2.1"
    static let categoriesEndpoint = "/categories"
    static let eventsEndpoint = "/events"
    
    static var ISODateReader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return formatter
    }()
    
    static func filteredEvents(events: [EOEvent], forCategory category: EOCategory) -> [EOEvent] {
        return events.filter { event in
            return event.categories.contains(category.id) &&
                !category.events.contains {
                    $0.id == event.id
            }
            }
            .sorted(by: EOEvent.compareDates)
    }
    
}

