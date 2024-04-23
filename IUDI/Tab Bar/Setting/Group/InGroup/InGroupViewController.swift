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
    func passPostID(postId: Int, isUser: Bool)
    func loadPostGroupFrombegin()
}

class InGroupViewController: UIViewController, PostsGroupVCDelegate,ServerImageHandle {
    
    @IBOutlet weak var displayDataPosts: UICollectionView!
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var hideSubViewBtn: UIButton!
    @IBOutlet weak var subviewLocation: NSLayoutConstraint!
    @IBOutlet weak var deletePost: UIButton!
    @IBOutlet weak var hidePost: UIButton!
    
    var groupID: Int?
    var postData = [ListPost]()
    var groupTitle : String?
    private var isMenuOpen = false
    private var isUserPost = false
    var deletePostID: Int?
    
    private var refeshControl = UIRefreshControl()
    var pageNumber = 1
    var isLoading = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionview()
        subviewHandle()
        loadPostGroupFrombegin()
        setUpView()
        title = groupTitle
        pullToRefesh()
        self.navigationController?.isNavigationBarHidden = false

    }
    func bindData(data: Datum){
        self.groupID = data.groupID
        self.groupTitle = data.groupName
    }
    func setUpView(){
        postsButton.layer.borderWidth = 1
        postsButton.layer.cornerRadius = 22
        postsButton.backgroundColor = UIColor(named: "Black")
        avatarView.layer.cornerRadius = avatarView.frame.size.width / 2
        postsButton.tintColor = UIColor.clear
        title = "Nhóm"
        let userInfo = UserInfoCoreData.shared.fetchProfileFromCoreData()
        avatarView.image = convertStringToImage(imageString: userInfo?.userAvatarUrl ?? "")
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case postsButton :
            let vc = PostsGroupViewController()
            vc.groupID = self.groupID
            vc.postsGroupVCDelegate = self
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
// MARK: - Load post
extension InGroupViewController {
    func pullToRefesh(){
        refeshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        displayDataPosts.addSubview(refeshControl)
    }
    @objc func reloadData(send: UIRefreshControl){
        DispatchQueue.main.async {
            self.loadPostGroupFrombegin()
            print("đã reload data")
            self.refeshControl.endRefreshing()
        }
    }
    func loadPostGroupFrombegin() {
        showLoading(isShow: true)
        guard let groupID = self.groupID else {
            showLoading(isShow: false)
            return // Không có ID nhóm, không thể fetch dữ liệu
        }
        let url = "https://api.iudi.xyz/api/forum/group/\(groupID)/1/10"
        print("groupID: \(groupID)")
        AF.request(url, method: .get).validate(statusCode: 200...299).responseDecodable(of: GroupDataPosts.self) { response in
            switch response.result {
            case .success(let data):
                guard let dataArray = data.listPosts else{
                    self.showLoading(isShow: false)
                    return
                }
                    self.postData = dataArray
//                    self.postData = dataArray.reversed()
                    self.displayDataPosts.reloadData()
                    self.isLoading = false
                    self.showLoading(isShow: false)
            case .failure(let error):
                self.showLoading(isShow: false)
                print("Lỗi khi lấy dữ liệu:", error.localizedDescription)
            }
        }
    }
    func loadPostGroup() {
        showLoading(isShow: true)
        guard let groupID = self.groupID else {
            showLoading(isShow: false)
            return // Không có ID nhóm, không thể fetch dữ liệu
        }
        let url = "https://api.iudi.xyz/api/forum/group/\(groupID)/\(pageNumber)/10"
        print("groupID: \(groupID)")
        print("url: \(url)")

        AF.request(url, method: .get).validate(statusCode: 200...299).responseDecodable(of: GroupDataPosts.self) { response in
            switch response.result {
            case .success(let data):
                guard let dataArray = data.listPosts else{
                    self.showLoading(isShow: false)
                    return
                }
                guard dataArray.count > 0 else {                    self.showLoading(isShow: false)
//                    self.showAlert(title: "Thông báo", message: "Đây là post cuối rồi")
                    print("dataArray.count = 0 :\(dataArray.count)")

                    return
                }
                    self.postData += dataArray
//                    self.postData = dataArray.reversed()
                    self.displayDataPosts.reloadData()
                    self.isLoading = false
                    self.showLoading(isShow: false)
            case .failure(let error):
                self.showLoading(isShow: false)
                print("Lỗi khi lấy dữ liệu:", error.localizedDescription)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height && !isLoading {
            pageNumber += 1 // Tăng trang lên để tải trang tiếp theo
            isLoading = true
            loadPostGroup() // Tải dữ liệu cho trang tiếp theo
            print("scrollViewDidScroll")
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
        if isUserPost {
            print("user đúng")
        } else {
            print("user sai")
        }
        deletePost.isHidden = !isUserPost
        
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
    
    func passPostID(postId: Int, isUser: Bool){
        self.deletePostID = postId
        self.isUserPost = isUser
        print("passPostID : \(postId)")
    }
    
    func deletePosst(){
        guard let postId = deletePostID else {
            print("khong co post id")
            return
        }
        let subUrl = "forum/delete_post/\(postId)"
        print("subUrl : \(subUrl)")

        APIService.share.apiHandle(method: .delete ,subUrl: subUrl, data: GroupDataPosts.self) { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
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

extension InGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            let width : CGFloat
            let height : CGFloat
        let contentHeight = textHeight(text: postData[indexPath.item].content ?? "")
        if let photo = postData[indexPath.item].photo {
            width = displayDataPosts.frame.width
            print("photo:\(photo.count)")
            height = 400 + contentHeight
        }else {
            width = displayDataPosts.frame.width
                height = 85 + contentHeight
            }
            return CGSizeMake(width, height)
    }
    func textHeight(text: String) -> CGFloat{
        
        // Tính toán kích thước của label dựa trên nội dung của nó
        let label = UILabel()
        label.text = text // Đặt nội dung của label từ dữ liệu của cell
        label.numberOfLines = 0 // Cho phép label hiển thị nhiều dòng
        label.font = UIFont.systemFont(ofSize: 16) // Đặt font cho label
        
        // Đặt kích thước tối đa của label (ví dụ: chiều rộng của cell trừ các khoảng trống)
        let maxWidth = displayDataPosts.frame.width - 20 // 20 là khoảng trống nếu muốn
        label.preferredMaxLayoutWidth = maxWidth
        
        // Đo kích thước của label dựa trên nội dung
        let labelSize = label.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude)).height
        return labelSize
    }
}

