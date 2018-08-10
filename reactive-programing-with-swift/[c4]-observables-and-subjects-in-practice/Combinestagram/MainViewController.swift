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
    
    private let bag = DisposeBag()
    private let images = Variable<[UIImage]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images.asObservable().subscribe(onNext: { [weak self] photos in
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
    }
    
    @IBAction func actionSave() {
        
    }
    
    @IBAction func actionAdd() {
        let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        
        photosViewController.selectedPhotos.subscribe(
            onNext: { [weak self] newImage in
                guard let images = self?.images else { return }
                images.value.append(newImage)
            }, onDisposed: {
                print("Completed photo selection")
            }
        )
        
        navigationController!.pushViewController(photosViewController, animated: true)
    }
    
    func showMessage(_ title: String, description: String? = nil) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
        present(alert, animated: true, completion: nil)
    }
}
