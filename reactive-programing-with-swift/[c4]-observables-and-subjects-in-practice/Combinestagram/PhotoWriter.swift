//
//  PhotoWriter.swift
//  Combinestagram
//
//  Created by Jonathan Tang on 09/08/2018.
//  Copyright © 2018 Jonathan Tang. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift

class PhotoWriter {
    enum Errors: Error {
        case couldNotSavePhoto
    }
    
    static func save(_ image: UIImage) -> Observable<String> {
        return Observable.create({ observer in
            var savedAssetId: String?
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success, let id = savedAssetId {
                        observer.onNext(id)
                        observer.onCompleted()
                    } else {
                        observer.onError(error ?? Errors.couldNotSavePhoto)
                    }
                }
            })
            return Disposables.create()
        })
    }
}
