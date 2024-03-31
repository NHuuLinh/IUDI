//
//  InGroupViewController.swift
//  IUDI
//
//  Created by Quoc on 29/02/2024.
//

import UIKit
import Alamofire

protocol PostsGroupVCDelegate: AnyObject {
    func displayMenu()
    func loadPostGroup()
    func passPostID(postId: Int)
}

class InGroupViewController: UIViewController, PostsGroupVCDelegate {

    var groupID: Int?
    var postData: [ListPost] = []
    
    @IBOutlet weak var displayDataPosts: UICollectionView!
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var hideSubViewBtn: UIButton!
    @IBOutlet weak var subviewLocation: NSLayoutConstraint!
    @IBOutlet weak var deletePost: UIButton!
    @IBOutlet weak var hidePost: UIButton!
    
    private var isMenuOpen = false
    var deletePostID: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionview()
        subviewHandle()
        loadPostGroup()
        setUpView()
    }
    func setUpView(){
        postsButton.layer.borderWidth = 1
        postsButton.layer.cornerRadius = 22
        postsButton.backgroundColor = UIColor(named: "Black")
        avatarView.layer.cornerRadius = avatarView.frame.size.width / 2
        postsButton.tintColor = UIColor.clear
    }
    
    func loadPostGroup() {
        guard let groupID = self.groupID else {
            return // Không có ID nhóm, không thể fetch dữ liệu
        }
        let url = "https://api.iudi.xyz/api/forum/group/\(groupID)/1/6"
        print("group: \(groupID)")
        AF.request(url, method: .get).validate(statusCode: 200...299).responseDecodable(of: GroupDataPosts.self) { response in
            switch response.result {
            case .success(let data):
                if let dataArray = data.listPosts {
                    self.postData = dataArray.reversed()
                    self.displayDataPosts.reloadData()
                }
            case .failure(let error):
                print("Lỗi khi lấy dữ liệu:", error.localizedDescription)
            }
        }
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case postsButton :
            let vc = PostsGroupViewController()
            vc.groupID = self.groupID
            navigationController?.pushViewController(vc, animated: true)
        case hideSubViewBtn:
            displayMenu()
        case deletePost:
            deletePostHandle()
            print("deletePost")
        case hidePost:
            print("deletePost")
        default:
            break
        }
    }

}

// MARK: - hàm subview
extension InGroupViewController {
    func subviewHandle(){
        subviewLocation.constant = 100
        hideSubViewBtn.isHidden = true
    }
    func displayMenu() {
        isMenuOpen.toggle()
        hideSubViewBtn.isHidden = !isMenuOpen
        UIView.animate(withDuration: 0.5, animations: {
            self.hideSubViewBtn.alpha = self.isMenuOpen ? 0.5 : 0
            self.subviewLocation.constant = self.isMenuOpen ? 0 : 150
            self.view.layoutIfNeeded()
        })
        self.tabBarController?.tabBar.isHidden = self.isMenuOpen
    }
}

// MARK: - Xóa Post
extension InGroupViewController {
    
    func passPostID(postId: Int){
        self.deletePostID = postId
        print("passPostID : \(postId)")
    }
    
    func deletePosst(){
        guard let postId = deletePostID else {
            print("khong co post id")
            return
        }
        let subUrl = "forum/delete_post/\(postId)"
        print("subUrl : \(subUrl)")

        APIService.share.apiHandle(method: .delete ,subUrl: subUrl, data: GroupDataPosts.self) { result in
            switch result {
            case .success(let data):
                print("data:\(data)")
                DispatchQueue.main.async {
                    self.loadPostGroup()
                }
                self.showAlert(title: "Thông báo", message: "Xóa bài thành công")
            case .failure(let error):
                print(error.localizedDescription)
                switch error {
                case .server(let message):
                    self.showAlert(title: "lỗi1", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi", message: message)
                }
            }
        }
    }
    
    func deletePostHandle(){
        showAlertAndAction(title: "Xác nhận", message: "Bạn có chắc chắn muốn xóa bài đăng này không?", completionHandler:  {
            self.deletePosst()
        }, cancelHandler: {
            print("something")
        })
    }
}
// MARK: - CollectionView

extension InGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func setupCollectionview(){
        displayDataPosts.delegate = self
        displayDataPosts.dataSource = self
        let nib = UINib(nibName: "PostCollectionViewCell", bundle: .main)
        displayDataPosts.register(nib, forCellWithReuseIdentifier: "PostCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexPath:\(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        let postsData = postData[indexPath.row]
        cell.postsGroupVCDelegate = self
        cell.blindata(data: postsData)
        return cell
    }
}

