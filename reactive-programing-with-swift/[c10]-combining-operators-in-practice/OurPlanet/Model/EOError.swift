//
//  EOError.swift
//  OurPlanet
//
//  Created by Jonathan Tang on 21/08/2018.
//  Copyright © 2018 Jonathan Tang. All rights reserved.
//

import Foundation

enum EOError: Error {
    case invalidURL(String)
    case invalidParameter(String, Any)
    case invalidJSON(String)
}
