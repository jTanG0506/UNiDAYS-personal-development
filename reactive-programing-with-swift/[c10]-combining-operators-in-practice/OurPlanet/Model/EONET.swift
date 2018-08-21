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
    
    static var categories: Observable<[EOCategory]> = {
        return EONET.request(endpoint: categoriesEndpoint).map { data in
            let categories = data["categories"] as? [[String: Any]] ?? []
            return categories.compactMap(EOCategory.init).sorted { $0.name < $1.name }
            }
            .catchErrorJustReturn([])
            .share(replay: 1, scope: .forever)
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
    
    fileprivate static func events(forLast days: Int, closed: Bool) -> Observable<[EOEvent]> {
        return request(endpoint: eventsEndpoint, query: [
            "days": NSNumber(value: days),
            "status": (closed ? "closed" : "open")
            ])
            .map { json in
                guard let raw = json["events"] as? [[String: Any]] else {
                    throw EOError.invalidJSON(eventsEndpoint)
                }
                return raw.compactMap(EOEvent.init)
            }
            .catchErrorJustReturn([])
    }
    
    static func request(endpoint: String, query: [String: Any] = [:]) -> Observable<[String: Any]> {
        do {
            guard let url = URL(string: API)?.appendingPathComponent(endpoint),
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    throw EOError.invalidURL(endpoint)
            }
            
            components.queryItems = try query.compactMap { (key, value) in
                guard let v = value as? CustomStringConvertible else {
                    throw EOError.invalidParameter(key, value)
                }
                return URLQueryItem(name: key, value: v.description)
            }
            
            guard let finalURL = components.url else {
                throw EOError.invalidURL(endpoint)
            }
            
            let request = URLRequest(url: finalURL)
            
            return URLSession.shared.rx.response(request: request).map { _, data -> [String: Any] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                    let result = jsonObject as? [String: Any] else {
                        throw EOError.invalidJSON(finalURL.absoluteString)
                }
                return result
            }
        } catch {
            return Observable.empty()
        }
    }
    
}
