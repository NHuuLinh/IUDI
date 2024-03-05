//
//  SelectImageViewController.swift
//  IUDI
//
//  Created by LinhMAC on 28/02/2024.
//

import UIKit
import Alamofire
import iOSDropDown
import KeychainSwift
import SwiftyJSON

protocol SelectImageVCDelegate: AnyObject {
    func loadAvatarImage(url: String?)
}

class SelectImageViewController: UIViewController {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    let keychain = KeychainSwift()
    var userPhotos = [Photo]()
    let itemNumber = 4.0
    let minimumLineSpacing = 10.0
    private var refeshControl = UIRefreshControl()
    weak var delegate: DataDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllImage()
        registerCollectionView()
        setupCollectionView()
        pullToRefesh()
    }
    private func setupCollectionView() {
        if let flowLayout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = minimumLineSpacing
            flowLayout.minimumInteritemSpacing = minimumLineSpacing
        }
    }
    func registerCollectionView(){
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        let cell = UINib(nibName: "SelectImageCollectionViewCell", bundle: nil)
        imageCollectionView.register(cell, forCellWithReuseIdentifier: "SelectImageCollectionViewCell")
    }
    //https://api.iudi.xyz/api/profile/viewAllImage/37
    func getAllImage(){
        showLoading(isShow: true)
        guard let userid = UserDefaults.standard.string(forKey: "UserID") else {
            showLoading(isShow: false)
            print("không có userName")
            return
        }
        print("UserID: \(userid)")
        let url = Constant.baseUrl + "profile/viewAllImage/" + userid
        print("\(url)")
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
                            self.imageCollectionView.reloadData()
                        }
                    } else {
                        print("data nill")
                    }
                    self.showLoading(isShow: false)
                case .failure(let error):
                    self.showLoading(isShow: false)
                    print("\(error.localizedDescription)")
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            let errorMessage = json["message"].stringValue
                            print(errorMessage)
                            self.showAlert(title: "Lỗi", message: errorMessage + "1")
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
    
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
extension SelectImageViewController : UICollectionViewDataSource, UICollectionViewDelegate,CellSizeCaculate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("userPhotos.count: \(userPhotos.count)")
        return userPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectImageCollectionViewCell", for: indexPath) as! SelectImageCollectionViewCell
        // trả về kích thước ảnh quyết định màn hình sẽ load bao nhiêu ảnh theo chiều ngang
        let data = userPhotos[indexPath.item]
        let indexNumber = Double(userPhotos.count)
        let frameSize = UIScreen.main.bounds.width
        let imageSize = caculateSize(indexNumber: indexNumber, frameSize: frameSize, defaultNumberItemOneRow: 4, minimumLineSpacing: minimumLineSpacing)
        cell.blinData(data: data, width: imageSize)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoURL = userPhotos[indexPath.item].photoURL
        print("user chọn ảnh có photoURL là : \(photoURL) ")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        delegate?.sendDataBack(data: "The quick brown fox jumps over the lazy dog")
        delegate?.loadAvatarImage(url: photoURL)
        navigationController?.popViewController(animated: true)
    }
    
}
extension SelectImageViewController: UIScrollViewDelegate {
    func pullToRefesh(){
        refeshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        imageCollectionView.addSubview(refeshControl)
    }
    @objc func reloadData(send: UIRefreshControl){
        DispatchQueue.main.async {
            self.getAllImage()
            print("đã scroll hết")
            self.refeshControl.endRefreshing()
        }
    }
}
