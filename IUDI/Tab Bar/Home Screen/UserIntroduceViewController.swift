//
//  UserIntroduceViewController.swift
//  IUDI
//
//  Created by LinhMAC on 01/03/2024.
//

import UIKit
import Alamofire
import ReadMoreTextView
import SwiftyJSON
import Kingfisher

class UserIntroduceViewController: UIViewController,ServerImageHandle {
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userNameLb: UILabel!
    @IBOutlet weak var userLocationLb: UILabel!
    @IBOutlet weak var userIntroduct: ReadMoreTextView!
    @IBOutlet weak var userImageCollectionView: UICollectionView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var fullsizeImage: UIImageView!
    @IBOutlet weak var exitFullSizeImage: UIButton!
    @IBOutlet weak var fullsizeImageScrollView: UIScrollView!
    
    
    var userPhotos = [Photo]()
    let itemNumber = 4
    let minimumLineSpacing = 5.0
    let apiService = APIService.share
    var dataUser : Distance?
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        registerCollectionView()
        setupUserIntroduct()
        fullsizeImageHandle(isHidden: true)
        setupZoomImage()
        avatarImageTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        userAvatar.layer.cornerRadius = 32
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case backBtn:
            navigationController?.popToRootViewController(animated: true)
        case chatBtn:
            gotoChatVC()
            print("chatBtn")
        case exitFullSizeImage:
            fullsizeImageHandle(isHidden: true)
        default:
            break
        }
    }
    func fullsizeImageHandle(isHidden: Bool){
        fullsizeImage.isHidden = isHidden
        exitFullSizeImage.isHidden = isHidden
        backBtn.isHidden = !isHidden
        fullsizeImageScrollView.isHidden = isHidden
    }
    func gotoChatVC(){
        let vc = MessageViewController()
        // Khởi tạo một instance của struct MessageUserData
        var messageUserData = MessageUserData(
            otherUserAvatar: userAvatar.image!, // Ảnh đại diện của người dùng khác
            otherUserFullName: dataUser?.fullName ?? "",
            otherUserId: "\(dataUser?.userID ?? 0)", otherLastActivityTime: dataUser?.lastActivityTime ?? "Wed, 27 Mar 2024 11:43:58 GMT"
        )
        vc.messageUserData = messageUserData
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupUserIntroduct(){
        backBtn.layer.cornerRadius = 10
        backBtn.layer.borderColor = UIColor.black.cgColor
        backBtn.layer.borderWidth = 1
        backBtn.clipsToBounds = true
        userIntroduct.showsLargeContentViewer = true
        userIntroduct.shouldTrim = true
        userIntroduct.maximumNumberOfLines = 2
        let readLessText = NSAttributedString(string: " Ẩn bớt", attributes: [NSAttributedString.Key.foregroundColor: Constant.mainBorderColor])
        userIntroduct.attributedReadLessText = readLessText
        let readMoreText = NSAttributedString(string: "... Xem thêm", attributes: [NSAttributedString.Key.foregroundColor: Constant.mainBorderColor])
        userIntroduct.attributedReadMoreText = readMoreText
        // chỉnh scroll view
        userIntroduct.onSizeChange = { _ in
            DispatchQueue.main.async { // Ensure UI updates on main thread
                self.calculateScrollView(totalItemNumber: self.userPhotos.count, itemSize: 91.75, lineSpacing: self.minimumLineSpacing)
                print("1")
            }
        }
    }
    
    func calculateScrollView(totalItemNumber: Int, itemSize: CGFloat, lineSpacing: CGFloat) {
        let itemNumber = Int(ceil(Double(totalItemNumber) / Double(itemNumber)))
        let collectionviewLocation = userImageCollectionView.superview?.frame.minY
        let bottomSafeAreaHeight = view.safeAreaInsets.bottom
        
        scrollViewHeight.constant = CGFloat(itemNumber) * itemSize + (CGFloat(itemNumber) * lineSpacing) + CGFloat(collectionviewLocation!) + bottomSafeAreaHeight
    }
    
    func blindata(data: Distance){
        userAvatar.image = convertStringToImage(imageString: data.avatarLink ?? "")
        //        userNameLb.text = data.fullName
        userNameLb.text = "\(data.userID)"
        userLocationLb.text = data.currentAdd
        let mainText = NSAttributedString(string: data.bio ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        //        userIntroduct.text = data.bio
        DispatchQueue.main.async {
            //            self.userIntroduct.text = data.bio
            self.userIntroduct.attributedText = mainText
            //            self.setupUserIntroduct()
        }
    }
    
    func getAllImage(userID: String){
        showLoading(isShow: true)
        print("UserID: \(userID)")
        let subUrl = "profile/viewAllImage/" + userID
        apiService.apiHandleGetRequest(subUrl: subUrl, data: GetPhotos.self) { response in
            switch response {
            case .success(let data):
                if let userdata = data.photos {
                    print("userdata: \(userdata.count)")
                    self.userPhotos = userdata
                    DispatchQueue.main.async {
                        self.userImageCollectionView.reloadData()
                        let frameSize = self.userImageCollectionView.frame.width
                        let imageSize = self.caculateSize(indexNumber: Double(self.userPhotos.count),
                                                          frameSize: frameSize,
                                                          defaultNumberItemOneRow: Double(self.itemNumber),
                                                          minimumLineSpacing: self.minimumLineSpacing)
                        self.calculateScrollView(totalItemNumber: self.userPhotos.count,
                                                 itemSize: imageSize,
                                                 lineSpacing: self.minimumLineSpacing)
                    }
                    print("userImageCollectionView:\(self.userImageCollectionView.frame.height)")
                } else {
                    print("data nill")
                }
                self.showLoading(isShow: false)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                self.showLoading(isShow: false)
//                switch error{
//                case .server(let message):
//                    self.showAlert(title: "lỗi", message: message)
//                case .network(let message):
//                    self.showAlert(title: "lỗi", message: message)
//                }
            }
        }
    }
    
}
extension UserIntroduceViewController : UICollectionViewDataSource, UICollectionViewDelegate,CellSizeCaculate {
    
    func setupCollectionView() {
        if let flowLayout = userImageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = minimumLineSpacing
            flowLayout.minimumInteritemSpacing = minimumLineSpacing
        }
    }
    
    func registerCollectionView(){
        userImageCollectionView.dataSource = self
        userImageCollectionView.delegate = self
        let cell = UINib(nibName: "SelectImageCollectionViewCell", bundle: nil)
        userImageCollectionView.register(cell, forCellWithReuseIdentifier: "SelectImageCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectImageCollectionViewCell", for: indexPath) as! SelectImageCollectionViewCell
        // trả về kích thước ảnh quyết định màn hình sẽ load bao nhiêu ảnh theo chiều ngang
        let data = userPhotos[indexPath.item]
        let frameSize = userImageCollectionView.frame.width
        let indexNumber = Double(userPhotos.count)
        let imageSize = caculateSize(indexNumber: indexNumber,
                                     frameSize: frameSize,
                                     defaultNumberItemOneRow: 4,
                                     minimumLineSpacing: minimumLineSpacing)
        print("imagesize:\(imageSize)")
        print("userPhotos.count:\(userPhotos.count)")

        cell.blinData(data: data, width: imageSize)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoID = userPhotos[indexPath.item].photoURL
//        print("user chọn ảnh có id là : \(photoID) ")
        fullsizeImageHandle(isHidden: false)
        fullsizeImage.image = convertStringToImage(imageString: photoID ?? "")
    }
}
extension UserIntroduceViewController: UIScrollViewDelegate {
    func setupZoomImage(){
        fullsizeImageScrollView.delegate = self
        // Thiết lập thuộc tính zoom của scroll view
        fullsizeImageScrollView.minimumZoomScale = 1.0
        fullsizeImageScrollView.maximumZoomScale = 6.0
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullsizeImage
    }
    func setupFullSizeImage() {
        // Thiết lập thuộc tính contentMode của fullsizeImage
        fullsizeImage.contentMode = .scaleAspectFit
    }
    func avatarImageTap(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userAvatar.isUserInteractionEnabled = true
        userAvatar.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        fullsizeImage.image = userAvatar.image
        fullsizeImageHandle(isHidden: false)
        // Your action
    }
}

