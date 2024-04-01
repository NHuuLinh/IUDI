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
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!

    var messageUserData: MessageUserData?
    var otherUserName: String?
    var otherAvatar: UIImage?
    var otherStatus: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
//        loadDataToView()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    func bindData(data: MessageUserData){
        self.messageUserData = data
        
    }
    func loadData(){
        targerName.text = messageUserData?.otherUserFullName
        targerAvatar.image = messageUserData?.otherUserAvatar
        targetStatus.text = messageUserData?.otherLastActivityTime
    }
    func loadDataToView(){
        showLoading(isShow: true)
        guard let userName = otherUserName else {
            print("không có userName")
            return
        }
        let url = "profile/" + userName
        APIService.share.apiHandleGetRequest(subUrl: url, data: User.self) { result in
            switch result {
            case .success(let data):
                guard let user = data.users?.first else {
                    print("dữ liệu nil")
                    return
                }
                DispatchQueue.main.async {
                    self.loadDataToView(user: user)
                }
                self.showLoading(isShow: false)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                self.showLoading(isShow: false)
                switch error{
                case .server(let message):
                    self.showAlert(title: "lỗi", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi", message: message)
                }
            }
        }
    }
    
    func loadDataToView(user: Users){
        print("---loadDataToView---")
        let currentDate  = Date()
        let dateString = user.lastActivityTime ?? "\(currentDate)"
        print("user:\(user.userID)")

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
        targerName.text = user.fullName
        if ((user.isLoggedIn) != nil) {
            targetStatus.text = "đang hoạt động"
            targetStatus.textColor = Constant.mainBorderColor
        } else {
            targetStatus.text = lastOnlineDate
            targetStatus.textColor = UIColor.lightGray
        }
        targetStatus.text = lastOnlineDate
        targerAvatar.image = otherAvatar
        
//        let url = user.avatarLink
//        loadAvatarImage(url: url)
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
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case backBtn :
            print("backBtn")

            navigationController?.popToRootViewController(animated: true)
        case callBtn:
            print("callBtn")
        default:
            break
        }
    }
}

