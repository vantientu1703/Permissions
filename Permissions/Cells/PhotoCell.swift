//
//  PhotoCell.swift
//  Permissions
//
//  Created by Văn Tiến Tú on 06/07/2021.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    var representedAssetIdentifier: String!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = nil
    }
}
