//
//  FriendListCell.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//

import UIKit

class FriendListCell: UICollectionViewCell,DateConvertFormat {
    @IBOutlet weak var otherUserAvatar: UIImageView!
    @IBOutlet weak var otherUserName: UILabel!
    @IBOutlet weak var latestMessageDate: UILabel!
    @IBOutlet weak var latestMessageContent: UILabel!
    @IBOutlet weak var messageStatus: UIButton!
    @IBOutlet weak var isRead: UIImageView!
    let userID = UserInfo.shared.getUserID()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        otherUserAvatar.layer.cornerRadius = otherUserAvatar.frame.height / 2

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
        let defaultDate = "Wed, 03 Apr 2024 14:20:53 GMT"
        // Chuỗi thời gian mặc định
        // Thêm múi giờ GMT+7 vào cuối chuỗi
        let dateWithGMTPlus7 = (data.messageTime ?? defaultDate) + "+7"
//        print("dateWithGMTPlus7:\(dateWithGMTPlus7)")
        latestMessageDate.text = convertServerTimeString(data.messageTime)
        latestMessageContent.text = data.content
        let senderId = "\(data.senderID ?? 0)"
        if userID == senderId {
//            print("người gửi chính là chính mình")
            seenTextHandle(isSeen: 1)
        } else {
//            print("kiểm tra đã seen tin nhắn chưa")
            seenTextHandle(isSeen: data.isSeen ?? 0)
        }
    }
    func seenTextHandle(isSeen: Int){
        otherUserName.textColor = (isSeen == 0) ? .black : .gray
        latestMessageDate.textColor = (isSeen == 0) ? .black : .gray
        latestMessageContent.textColor = (isSeen == 0) ? .black : .gray
    }
}
