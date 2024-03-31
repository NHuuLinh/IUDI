//
//  FriendListCell.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//

import UIKit

class FriendListCell: UICollectionViewCell {
    @IBOutlet weak var otherUserAvatar: UIImageView!
    @IBOutlet weak var otherUserName: UILabel!
    @IBOutlet weak var latestMessageDate: UILabel!
    @IBOutlet weak var latestMessageContent: UILabel!
    @IBOutlet weak var messageStatus: UIButton!
    @IBOutlet weak var isRead: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func blindData(data: ChatData){
        guard let imageUrl = URL(string: data.avatar ?? "") else {
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
        otherUserName.text = "\(data.otherUsername)"
        latestMessageDate.text = data.messageTime
        latestMessageContent.text = data.content
    }

}
