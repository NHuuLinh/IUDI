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

class UserIntroduceViewController: UIViewController {
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userNameLb: UILabel!
    @IBOutlet weak var userLocationLb: UILabel!
    @IBOutlet weak var userIntroduct: ReadMoreTextView!
    @IBOutlet weak var userImageCollectionView: UICollectionView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    var data : UserDistances?
    var userPhotos = [Photo]()
    let itemNumber = 4
    let minimumLineSpacing = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.isNavigationBarHidden = true
        setupCollectionView()
        registerCollectionView()
        setupUserIntroduct()
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
            print("chatBtn")
        default:
            break
        }
    }
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
    func setupUserIntroduct(){
        userIntroduct.showsLargeContentViewer = true
        userIntroduct.shouldTrim = true
        userIntroduct.maximumNumberOfLines = 2
        let readLessText = NSAttributedString(string: "...Ẩn bớt", attributes: [NSAttributedString.Key.foregroundColor: Constant.mainBorderColor])
        userIntroduct.attributedReadLessText = readLessText
        let readMoreText = NSAttributedString(string: "... Xem thêm", attributes: [NSAttributedString.Key.foregroundColor: Constant.mainBorderColor])
        userIntroduct.attributedReadMoreText = readMoreText
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
        print("scrollViewHeight:\(scrollViewHeight.constant)")
        print("userImageCollectionView.frame.minY:\(collectionviewLocation ?? 0)")
        print("itemNumber:\(itemNumber)")
    }
    
    func blindata(data: Distance){
        let imageUrl = URL(string: data.avatarLink ?? "")
        userAvatar.kf.setImage(with: imageUrl, placeholder: UIImage(named: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                // Ảnh đã tải thành công
                break
            case .failure(let error):
                // Xảy ra lỗi khi tải ảnh
                self.userAvatar.image = UIImage(systemName: "person")
            }
        })
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
        let url = Constant.baseUrl + "profile/viewAllImage/" + userID
        AF.request(url, method: .get)
            .validate(statusCode: 200...299)
            .responseDecodable(of: GetPhotos.self) { response in
                switch response.result {
                    // Xử lý dữ liệu nhận được từ phản hồi (response)
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
                    self.showLoading(isShow: false)
                    self.scrollViewHeight.constant = self.view.frame.height
                    print("\(error.localizedDescription)")
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            let errorMessage = json["message"].stringValue
                            print("errorMessage:\(errorMessage)")
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                            self.showAlert(title: "Lỗi", message: "Đã xảy ra lỗi, vui lòng thử lại sau.")
                        }
                    } else {
                        print("Không có dữ liệu từ server")
                        self.showAlert(title: "Lỗi", message: "Đã xảy ra lỗi, vui lòng thử lại sau.")
                    }
                }
            }
    }
    
}
extension UserIntroduceViewController : UICollectionViewDataSource, UICollectionViewDelegate,CellSizeCaculate {
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
        cell.blinData(data: data, width: imageSize)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoID = userPhotos[indexPath.item].photoID
        print("user chọn ảnh có id là : \(photoID) ")
    }
    
    
}
