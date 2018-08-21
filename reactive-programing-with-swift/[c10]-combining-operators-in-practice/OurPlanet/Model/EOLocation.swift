//
//  EOLocation.swift
//  OurPlanet
//
//  Created by Jonathan Tang on 21/08/2018.
//  Copyright © 2018 Jonathan Tang. All rights reserved.
//

import UIKit
import CoreLocation

struct EOLocation {
    enum GeometryType {
        case position
        case point
        case polygon
        
        static func fromString(string: String) -> GeometryType? {
            switch string {
            case "Point": return .point
            case "Position": return .position
            case "Polygon": return .polygon
            default: return nil
            }
        }
    }
    
    let type: GeometryType
    let date: Date?
    let coordinates: [CLLocationCoordinate2D]
    
    init?(json: [String: Any]) {
        guard let typeString = json["type"] as? String,
            let geoType = GeometryType.fromString(string: typeString),
            let coords = json["coordinates"] as? [Any],
            (coords.count % 2) == 0 else {
                return nil
        }
        if let dateString = json["date"] as? String {
            date = EONET.ISODateReader.date(from: dateString)
        } else {
            date = nil
        }
        type = geoType
        coordinates = stride(from: 0, to: coords.count, by: 2).compactMap { index in
            guard let lat = coords[index] as? Double,
                let long = coords[index + 1] as? Double else {
                    return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
    }
}

