//
//  SelectImageCollectionViewCell.swift
//  IUDI
//
//  Created by LinhMAC on 28/02/2024.
//

import UIKit
import Kingfisher

class SelectImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func blinData(userImageUrl: String ,width: CGFloat){
        imageWidth.constant = width
//        userImage.kf.setImage(with: userImageUrl)
    }
    

}
