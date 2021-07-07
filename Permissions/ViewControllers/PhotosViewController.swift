//
//  PhotosViewController.swift
//  Permissions
//
//  Created by Văn Tiến Tú on 06/07/2021.
//

import UIKit
import Photos

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let photosManager = FetchPhotosManager()
    private var previousPreheatRect = CGRect.zero
    private let offset = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PhotoLibraryPermission.getAutherizeStatus() == .limited {
            let button = UIBarButtonItem(title: "Manager", style: .plain, target: self, action: #selector(self.showSelectPhotos))
            self.navigationItem.rightBarButtonItem = button
        }
        
        self.setup()
        // Do any additional setup after loading the view.
        PhotoLibraryPermission.requestPermission(from: self,
                                                 hasAlertIfPermissionDenied: true) { granted in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.photosManager.reloadAssets(fetchLimit: self.offset) { [weak self] in
                    UIView.performWithoutAnimation {
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func showSelectPhotos() {
        if #available(iOS 14, *) {
            PhotoLibraryPermission.shared
                .onDidSelectPhotos { [weak self] in
                    self?.photosManager.reloadAssets(fetchLimit: 100) { [weak self] in
                        DispatchQueue.main.async {
                            UIView.performWithoutAnimation {
                                self?.collectionView.reloadData()
                            }
                        }
                    }
                }
                .managePhotos(from: self)
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateCachedRect()
    }
    
    private func setup() {
        self.collectionView.registerCellByNib(PhotoCell.self)
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flow.minimumLineSpacing = 10
        flow.minimumInteritemSpacing = 0
        self.collectionView.setCollectionViewLayout(flow, animated: true)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.prefetchDataSource = self
    }
    
    // Update cached rect
    func updateCachedRect() {
        let visibleRect = CGRect(
            origin: collectionView.contentOffset,
            size: collectionView.bounds.size)
        
        var preheatRect: CGRect
        var delta: CGFloat
        
        preheatRect = visibleRect.insetBy(
            dx: 0,
            dy: -0.5 * visibleRect.height)
        delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > self.view.bounds.height / 3 else { return }
        
        let (addedRects, removedRects) =
            differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedIndexPaths = addedRects.flatMap { [unowned self] rect in
            self.collectionView.indexPathsForElements(in: rect)
        }
        let removedIndexPaths = removedRects.flatMap { [unowned self] rect in
            self.collectionView.indexPathsForElements(in: rect)
        }
        self.photosManager.updateCaching(addedIndexPaths: addedIndexPaths, removedIndexPaths: removedIndexPaths)
        
        previousPreheatRect = preheatRect
    }
    
    // Calculate diff between rects
    func differencesBetweenRects(_ old: CGRect,_ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateCachedRect()
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            print(" you reached end of the table")
            // then we are at the end
            let prefetchIndex = self.offset
            self.photosManager.loadMoreAssets(offset: prefetchIndex) { [weak self] addedItemsCount in
                guard addedItemsCount > 0 else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
                    guard let self = self else { return }
                    let indexPaths = ((self.photosManager.assets.count - addedItemsCount)..<self.photosManager.assets.count).map { return IndexPath(row: $0, section: 0) }
                    UIView.performWithoutAnimation {
                        self.collectionView.insertItems(at: indexPaths)
                    }
                }
            }
        }
    }
}

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosManager.assets.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(PhotoCell.self, forIndexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let asset = self.photosManager.assets[indexPath.row].asset
        
        cell.representedAssetIdentifier = self.photosManager.localIdentifier(at: indexPath.row)
        self.photosManager.requestImage(at: indexPath, size: .r1080p) { image in
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.photoImageView.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = UIScreen.main.bounds.size
        let width = ceil((size.width - 10 * 4) / 3)
        return CGSize(width: width, height: width)
    }
}

extension PhotosViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
}

public extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
