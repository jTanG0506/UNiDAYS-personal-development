//
//  MainViewController.swift
//  Combinestagram
//
//  Created by Jonathan Tang on 09/08/2018.
//  Copyright © 2018 Jonathan Tang. All rights reserved.
//

import UIKit
import RxSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    private var imageCache = [Int]()
    
    private let bag = DisposeBag()
    private let images = Variable<[UIImage]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images.asObservable().throttle(0.5, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] photos in
            guard let preview = self?.imagePreview else { return }
            preview.image = UIImage.collage(images: photos, size: preview.frame.size)
        }).disposed(by: bag)
        
        images.asObservable().subscribe(onNext: { [weak self] photos in
            self?.updateUI(photos: photos)
        }).disposed(by: bag)
    }
    
    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    @IBAction func actionClear() {
        images.value = []
        imageCache = []
    }
    
    @IBAction func actionSave() {
        guard let image = imagePreview.image else { return }
        
        PhotoWriter.save(image).subscribe(
            onSuccess: { [weak self] id in
                self?.showMessage("Saved with id :\(id)")
                self?.actionClear()
            }, onError: { [weak self] error in
                self?.showMessage("Error", description: error.localizedDescription)
        }).disposed(by: bag)
    }
    
    @IBAction func actionAdd() {
        let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        let newPhotos = photosViewController.selectedPhotos.share()
        
        newPhotos.takeWhile({ [weak self] image in
            return (self?.images.value.count ?? 0) < 6
        }) .filter({ newImage in
            return newImage.size.width > newImage.size.height
        }).filter({ [weak self] newImage in
            let len = UIImagePNGRepresentation(newImage)?.count ?? 0
            guard self?.imageCache.contains(len) == false else {
                return false
            }
            self?.imageCache.append(len)
            return true
        }).subscribe(
            onNext: { [weak self] newImage in
                guard let images = self?.images else { return }
                images.value.append(newImage)
            }, onDisposed: {
                print("Completed photo selection")
        }).disposed(by: bag)
        
        newPhotos.ignoreElements().subscribe(onCompleted: { [weak self] in
            self?.updateNavigationIcon()
        }).disposed(by: bag)
        
        navigationController!.pushViewController(photosViewController, animated: true)
    }
    
    private func updateNavigationIcon() {
        let icon = imagePreview.image?.scaled(CGSize(width: 22.0, height: 22.0)).withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done, target: nil, action: nil)
    }
    
    func showMessage(_ title: String, description: String? = nil) {
        alert(title: title, description: description).subscribe().disposed(by: bag)
    }
}

extension UIViewController {
    func alert(title: String, description: String? = nil) -> Completable {
        return Completable.create(subscribe: { [weak self] completable in
            let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {  _ in
                completable(.completed)
            }))
            self?.present(alert, animated: true, completion: nil)
            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
        })
    }
}
