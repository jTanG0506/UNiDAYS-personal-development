//
//  AppDelegate.swift
//  GitFeed
//
//  Created by Jonathan Tang on 15/08/2018.
//  Copyright © 2018 Jonathan Tang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

func cachedFileURL(_ fileName: String) -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask)
        .first!.appendingPathComponent(fileName)
}

class ActivityController: UITableViewController {
    
    private let repo = "ReactiveX/RxSwift"
    private let eventsFileURL = cachedFileURL("events.plist")
    
    private let modifiedFileURL = cachedFileURL("modified.txt")
    private let lastModified = Variable<NSString?>(nil)
    
    private let events = Variable<[Event]>([])
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = repo
        
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        let eventsArray = (NSArray(contentsOf: eventsFileURL)) as? [[String: Any]] ?? []
        events.value = eventsArray.compactMap(Event.init)
        lastModified.value = try? NSString(contentsOf: modifiedFileURL, usedEncoding: nil)
        
        refresh()
    }
    
    @objc func refresh() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fetchEvents(repo: strongSelf.repo)
        }
    }
    
    func fetchEvents(repo: String) {
        let response = Observable.from(["https://api.github.com/search/repositories?q=language:swift&per_page=5"])
            .map { urlString -> URL in
                return URL(string: urlString)!
            }
            .flatMap { url -> Observable<Any> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.json(request: request)
            }
            .flatMap { response -> Observable<String> in
                guard let response = response as? [String: Any], let items = response["items"] as? [[String: Any]] else {
                    return Observable.empty()
                }
                return Observable.from(items.map { $0["full_name"] as! String })
            }
            .map { urlString -> URL in
                return URL(string: "https://api.github.com/repos/\(urlString)/events")!
            }
            .map { [weak self] url -> URLRequest in
                var request = URLRequest(url: url)
                if let modifiedHeader = self?.lastModified.value {
                    request.addValue(modifiedHeader as String, forHTTPHeaderField: "Last-Modified")
                }
                return request
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .share(replay: 1, scope: .whileConnected)
        
        response
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [[String: Any]] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                    let result = jsonObject as? [[String: Any]] else {
                        return []
                }
                return result
            }
            .filter { objects in
                return objects.count > 0
            }
            .map { objects in
                return objects.compactMap(Event.init)
            }
            .subscribe(onNext: { [weak self] newEvents in
                self?.processEvents(newEvents)
            })
            .disposed(by: bag)
        
        response
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            .flatMap { response, _ -> Observable<NSString> in
                guard let value = response.allHeaderFields["Last-Modified"] as? NSString else {
                    return Observable.empty()
                }
                return Observable.just(value)
            }
            .subscribe(onNext: { [weak self] modifiedHeader in
                guard let strongSelf = self else { return }
                strongSelf.lastModified.value = modifiedHeader
                try? modifiedHeader.write(to: strongSelf.modifiedFileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            })
            .disposed(by: bag)
    }
    
    func processEvents(_ newEvents: [Event]) {
        var updatedEvents = newEvents + events.value
        if updatedEvents.count > 50 {
            updatedEvents = Array<Event>(updatedEvents.prefix(50))
        }
        
        events.value = updatedEvents
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        
        let eventsArray = updatedEvents.map { $0.dictionary } as NSArray
        eventsArray.write(to: eventsFileURL, atomically: true)
    }
    
    // MARK: - Table Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events.value[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
        cell.imageView?.kf.setImage(with: event.imageUrl, placeholder: UIImage(named: "blank-avatar"))
        return cell
    }
}


