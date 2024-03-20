//
//  ConverseViewController.swift
//  IUDI
//
//  Created by LinhMAC on 18/03/2024.

import UIKit
import SocketIO
import MessageKit

class ConverseViewController: UIViewController {
    @IBOutlet weak var targerName: UILabel!
    @IBOutlet weak var targerAvatar: UIImageView!
    @IBOutlet weak var targetStatus: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageLb: UILabel!
    @IBOutlet weak var messagePlaceholdText: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var emojiBtn: UIButton!
    @IBOutlet weak var attachBtn: UIButton!
    @IBOutlet weak var microBtn: UIButton!
    var userProfile : User?
    var userAvatar : UIImage?
    var targetAvatar: UIImage?
    var dataUser : Distance?

    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.delegate = self
        messageTextView.textContainer.lineBreakMode = .byWordWrapping
//        SocketIOManager.shared.establishConnection()
        targerAvatar.image = targetAvatar
        loadDataToView()
    }
    func loadDataToView(){
        print("---loadDataToView---")
        let currentDate = Date()
        print("user:\(dataUser?.userID)")
        guard let dateString = dataUser?.lastActivityTime else {
            print("rông rồi")
            return
        }
        var lastOnlineDate : String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss z"
        if let date = dateFormatter.date(from: dateString) {
            // Chuyển đổi thành công
            print("Converted date: \(date)")
            
            // Bây giờ bạn có thể sử dụng các phương thức mở rộng trên đối tượng Date
            lastOnlineDate = date.timeSinceDate(fromDate: date)
            print("Converted date: \(lastOnlineDate)")

        } else {
            lastOnlineDate = ""
            // Xử lý trường hợp không thể chuyển đổi được chuỗi thành đối tượng Date
            print("Failed to convert string to date.")
        }
        targerName.text = dataUser?.fullName
        if ((dataUser?.isLoggedIn) != nil) {
            targetStatus.text = "đang hoạt động"
            targetStatus.textColor = Constant.mainBorderColor
        } else {
            targetStatus.text = lastOnlineDate
            targetStatus.textColor = UIColor.lightGray
        }
        targetStatus.text = lastOnlineDate
        
        let url = dataUser?.avatarLink
        loadAvatarImage(url: url)
    }

    func loadAvatarImage(url:String?) {
        print("loadAvatarImage1: \(url)")
        guard let urlString = url, let imageUrl = URL(string: urlString) else {
            return
        }
        targerAvatar.kf.setImage(with: imageUrl, placeholder: UIImage(systemName: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                // Ảnh đã tải thành công
                print("cập nhật ảnh thành công")
                break
            case .failure(_):
                // Xảy ra lỗi khi tải ảnh
                self.targerAvatar?.image = UIImage(systemName: "person")
            }
        })
    }

    func sendMessageHandle(){
        let userID = UserInfo.shared.getUserID()
        print(userID)
        
        guard let message = messageTextView.text, let RelatedUserID = dataUser?.userID else {
            print("---userNil---")
            return
        }
        let messageData: [String: Any] = [
            "room": RelatedUserID , //ví dụ 21423
            "data": [
                "id": userID,
                "RelatedUserID": RelatedUserID ,
                "type": "text",//text/ image/icon-image/muti-image
                "state":"",
                "content":message
                //"data": "https://i.ibb.co/2MJkg5P/Screenshot-2023-05-07-142345.png"// nếu dữ liệu là loại ảnh
                // Nếu dữ liệu là loại text
            ]
        ]
        print("messageData:\(messageData)")
        SocketIOManager.sharedInstance.sendTextMessage(messageData: messageData)
    }
    
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case backBtn :
            navigationController?.popToRootViewController(animated: true)
        case sendBtn:
            sendMessageHandle()
            print("sendBtn")
        case emojiBtn:
            SocketIOManager.shared.establishConnection()
            print("emojiBtn")
        case attachBtn:
            print("attachBtn")
        case microBtn:
            print("microBtn")
        default:
            break
        }
    }
}

extension ConverseViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Kiểm tra nếu UITextView không rỗng
        if let text = textView.text, !text.isEmpty {
            // Nếu có nội dung, kích hoạt nút lưu
            messageLb.text = messageTextView.text
            messagePlaceholdText.isHidden = true
        } else {
            // Nếu không có nội dung, vô hiệu hóa nút lưu
            messageLb.text = messageTextView.text
            messagePlaceholdText.isHidden = false
        }
    }
}
extension ConverseViewController {
    
}
