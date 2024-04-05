//
//  UserActiveCollectionViewCell.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//

import UIKit

class UserActiveCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var otherUserAvatar: UIImageView!
    @IBOutlet weak var otherUserName: UILabel!
    @IBOutlet weak var otherUserStatus: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        otherUserStatus.layer.cornerRadius = otherUserStatus.frame.width / 2
        otherUserStatus.isHidden = false
        otherUserAvatar.layer.cornerRadius = otherUserAvatar.frame.width / 2
    }
    func bindData(data: ChatData){
        guard let imageUrl = URL(string: data.otherAvatar ?? "") else {
            return
        }
        otherUserAvatar.kf.setImage(with: imageUrl, placeholder: UIImage(systemName: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                // Ảnh đã tải thành công
                break
            case .failure(let error):
                // Xảy ra lỗi khi tải ảnh
                self.otherUserAvatar.image = UIImage(systemName: "person")
            }
        })
        otherUserName.text = data.otherUsername
    }
}
