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
    func blinData(data: Photo ,width: CGFloat){        
        imageWidth.constant = CGFloat(Int(width))
//        if let newsImageString = data.photoURL {
//            let newsImageUrl = URL(string: newsImageString)
//            userImage.kf.setImage(with: newsImageUrl)
//        } else {
//            userImage.image = UIImage(systemName: "person")
//        }
        guard let url = data.photoURL else {
            return
        }
        let imageUrl = URL(string: url)
        userImage.kf.setImage(with: imageUrl, placeholder: UIImage(systemName: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                self.imageWidth.constant = CGFloat(Int(width))

                // Ảnh đã tải thành công
                break
            case .failure(let error):
                // Xảy ra lỗi khi tải ảnh
                self.userImage.image = UIImage(systemName: "person")
//                print("Lỗi khi tải ảnh: \(error.localizedDescription)")
            }
        })
        
    }
    func transData(image: UIImage){
        let image = userImage.image
    }
    @IBAction func btnHandle(_ sender: Any) {
        print("???")
    }
}
