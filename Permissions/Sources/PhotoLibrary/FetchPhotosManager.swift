//
//  FetchPhotosManager.swift
//  Permissions
//
//  Created by Văn Tiến Tú on 06/07/2021.
//

import UIKit
import Photos

extension PHImageRequestOptions {
    static var `default`: PHImageRequestOptions {
        let options = PHImageRequestOptions()
         options.isSynchronous = false
        // Enable fetching image from iCloud
        // options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        return options
    }
}

class FetchPhotosManager {
    
    class PhotoAsset {
        let asset: PHAsset
        
        var localIdentifier: String {
            return self.asset.localIdentifier
        }
        
        init(asset: PHAsset) {
            self.asset = asset
        }
    }
    
    let cachingManager: PHCachingImageManager = PHCachingImageManager()
    
    let fetchOptions = PHFetchOptions()
    private var _assets: [PhotoAsset] = []
    var assets: [PhotoAsset] {
        return self._assets
    }
    
    private var isFetching = false
    private var isLoadMore = false
    
    init (sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key:"creationDate",
                                                                  ascending: false)],
          predicate: NSPredicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)) {
        fetchOptions.sortDescriptors = sortDescriptors
        fetchOptions.predicate = predicate
    }
    
    func reloadAssets(fetchLimit: Int = 100, completion: (() -> ())) {
        // Fetch the image assets
        self.fetchOptions.fetchLimit = fetchLimit
        self._assets = []
        self.isFetching = true
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: self.fetchOptions)
        fetchResult.enumerateObjects { asset, index, _ in
            let passet = PhotoAsset(asset: asset)
            self._assets.append(passet)
        }
        completion()
        self.isFetching = false
    }
    
    func loadMoreAssets(offset: Int = 100, completion: ((Int) -> ())) {
        // if fetching or loading more then return
        guard self.isFetching == false,
              self.isLoadMore == false else { return }
        if self._assets.count < self.fetchOptions.fetchLimit {
            completion(0)
            return
        }
        
        self.isLoadMore = true
        self.fetchOptions.fetchLimit = self._assets.count + offset
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: self.fetchOptions)
        
        let addedItemsCount = fetchResult.count - self._assets.count
        
        for index in (self._assets.count..<self._assets.count + offset) {
            if index < fetchResult.count {
                let asset = fetchResult.object(at: index)
                let pAsset = PhotoAsset(asset: asset)
                self._assets.append(pAsset)
            }
            
        }
        completion(addedItemsCount)
        self.isLoadMore = false
    }
    
    func localIdentifier(at index: Int) -> String {
        return self.assets[index].localIdentifier
    }
    
    func requestImage(at indexPath: IndexPath, size: CGSize, completion: ((UIImage?) -> ())?) {
        let options = PHImageRequestOptions.default
        cachingManager.requestImage(for: self.assets[indexPath.row].asset,
                                              targetSize: size,
                                              contentMode: .aspectFill,
                                              options: options) { image, _ in
            completion?(image)
        }
    }
    
    func updateCaching(addedIndexPaths: [IndexPath], removedIndexPaths: [IndexPath]) {
        let options = PHImageRequestOptions.default
        let addedAssets = addedIndexPaths
            .filter { $0.item != 0 }
            .map { self.assets[$0.item].asset }
        let removedAssets = removedIndexPaths
            .filter { $0.item != 0 }
            .map { self.assets[$0.item].asset }
        
        self.cachingManager.startCachingImages(
            for: addedAssets,
            targetSize: CGSize.r1080p,
            contentMode: .aspectFill,
            options: options)
        
        self.cachingManager.stopCachingImages(
            for: removedAssets,
            targetSize: CGSize.r1080p,
            contentMode: .aspectFill,
            options: options)
    }
}

extension CGSize {
    static let rd1 = CGSize(width: 704, height: 480)
    static let r960h = CGSize(width: 480, height: 960)
    static let r720ahd = CGSize(width: 1280, height: 720)
    static let r1080p = CGSize(width: 1080, height: 1920)
    static let r4mp = CGSize(width: 2560, height: 1440)
    static let r5mp = CGSize(width: 2560, height: 1920)
    static let r4k = CGSize(width: 3840, height: 2160)
}
