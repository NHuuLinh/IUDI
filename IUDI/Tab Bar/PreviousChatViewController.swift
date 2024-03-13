//
//  PreviousChatViewController.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//
protocol PreviousChatDelegate: AnyObject {
    func loadAvatarImage(url:String?,uiImage: UIImageView)
}
import UIKit
import KeychainSwift

class PreviousChatViewController: UIViewController,PreviousChatDelegate {
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userHeartImg: UIImageView!
    @IBOutlet weak var targetAvatar: UIImageView!
    @IBOutlet weak var targetHeartImg: UIImageView!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    let keychain = KeychainSwift()
    var testImage : UIImage?
    var userProfile : User?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        setupView()
        targetAvatar.image = testImage
        print("image: \(testImage)")
        getUserProfile()
    }
    
    func rotationImage(angle: CGFloat) -> CGFloat {
        let angleInDegrees: CGFloat = angle // Điều chỉnh góc theo nhu cầu của bạn
        let angleInRadians = angleInDegrees * .pi / 180.0
        return angleInRadians
    }
    func setupView(){
        userAvatar.layer.cornerRadius = 8
        targetAvatar.layer.cornerRadius = 8
        userAvatar.transform = CGAffineTransform(rotationAngle: rotationImage(angle: -19))
        userHeartImg.transform = CGAffineTransform(rotationAngle: rotationImage(angle: -19))
        targetAvatar.transform = CGAffineTransform(rotationAngle: rotationImage(angle: 10))
        targetHeartImg.transform = CGAffineTransform(rotationAngle: rotationImage(angle: 10))
        standardBtnCornerRadius(button: chatBtn)
        standardBtnCornerRadius(button: backBtn)
        backBtn.layer.borderColor = Constant.mainBorderColor.cgColor
        backBtn.layer.borderWidth = Constant.borderWidth
        backBtn.clipsToBounds = true
    }
    
    func getUserProfile(){
        showLoading(isShow: true)
        guard let userName = keychain.get("username") else {
            print("không có userName")
            return
        }
        let url = "profile/" + userName
        APIService.share.apiHandleGetRequest(subUrl: url, data: User.self) { result in
            switch result {
            case .success(let data):
                guard let avatarUrl = data.users?.first?.avatarLink else {
                    print("dữ liệu nil")
                    return
                }
                DispatchQueue.main.async {
                    self.loadAvatarImage(url: avatarUrl, uiImage: self.userAvatar)
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
    
    func loadAvatarImage(url:String?,uiImage: UIImageView) {
        print("loadAvatarImage1: \(url)")
        guard let urlString = url, let imageUrl = URL(string: urlString) else {
            return
        }
        uiImage.kf.setImage(with: imageUrl, placeholder: UIImage(systemName: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                // Ảnh đã tải thành công
                break
            case .failure(let error):
                // Xảy ra lỗi khi tải ảnh
                uiImage.image = UIImage(systemName: "person")
            }
        })
    }

    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case chatBtn :
            print("chatBtn")
        case backBtn:
            print("backBtn")
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
}


