//
//  ChatViewController.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarConstraint: NSLayoutConstraint!
    var showSearchBar = false
    var chatData = [ChatData]()
    var filterData = [ChatData]()
    
    let userID = UserInfo.shared.getUserID()
    private var refeshControl = UIRefreshControl()
    
    var moreDate = 10
    var isLoading = false
    
    
    enum ChatSection: Int,CaseIterable {
        case userActive = 0
        case userFriendList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
        setupView()
        registerCollectionView()
        pullToRefesh()
    }
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.shared.establishConnection()
        SocketIOManager.shared.mSocket.on("connect") {data, ack in
            self.sendUserId() // Gọi hàm sendUserId() khi kết nối thành công
        }
        reloadNewMessage1()
        getAllChatData()
    }
    
    
    func setupView(){
        backBtn.isEnabled = false
        searchBar.layer.opacity = 0
    }
    
    func searchBarLayout(){
        showSearchBar.toggle()
        backBtn.isEnabled = showSearchBar
        print("showSearchBar:\(showSearchBar)")
        UIView.animate(withDuration: 1, animations: {
            self.searchBarConstraint.constant = self.showSearchBar ? (self.view.frame.width - 32) : 48
            self.searchBar.layer.opacity = self.showSearchBar ? 1 : 0
            self.view.layoutIfNeeded()
        })
    }
    func gotoChatVC(data: ChatData){
        let vc = MessageViewController()
        vc.title = "Chat"
        var avatarImage = UIImageView()
        guard let urlString = data.otherAvatar, let imageUrl = URL(string: urlString) else {
            return
        }
        avatarImage.kf.setImage(with: imageUrl, placeholder: UIImage(systemName: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                // Ảnh đã tải thành công
                print("Ảnh đã tải thành công")
            case .failure(_):
                // Xảy ra lỗi khi tải ảnh
                avatarImage.image = UIImage(systemName: "person")
            }
        })
        
        let messageUserData = MessageUserData(otherUserAvatar: (avatarImage.image)!, otherUserFullName: data.otherFullname ?? "", otherUserId: "\(data.otherUserID ?? 0)", otherLastActivityTime: data.otherLastActivityTime ?? "Wed, 27 Mar 2024 11:43:58 GMT")
        vc.messageUserData = messageUserData
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case searchBtn:
            searchBarLayout()
            print("search")
        case backBtn:
            searchBarLayout()
        default:
            break
        }
    }
    func getAllChatData(){
        guard let userID = UserInfo.shared.getUserID() else {
            print("userID Nil")
            return
        }
        //        showLoading(isShow: true)
        let apiService = APIService.share
        let subUrl = "chat/\(userID)"
        print("url:\(subUrl)")
        apiService.apiHandleGetRequest(subUrl: subUrl,data: AllChatData.self) { result in
            switch result {
            case .success(let data):
                print("getAllChatData success")
                self.chatData = data.data
                self.filterData = data.data
                
                print("self.chatData:\(self.chatData.count)")
                
                DispatchQueue.main.async {
                    self.chatCollectionView.reloadData()
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
    func getAllChatData1(){
        guard let userID = UserInfo.shared.getUserID() else {
            print("userID Nil")
            return
        }
        
        let apiService = APIService.share
        let subUrl = "chat/\(userID)"
        print("url:\(subUrl)")
        
        apiService.apiHandleGetRequest(subUrl: subUrl, data: AllChatData.self) { result in
            switch result {
            case .success(let data):
                print("getAllChatData success")
                
                // Lấy mảng từ 5 đến 10
                let endIndex = min(self.moreDate, data.data.count) // Lấy tối đa 10 phần tử
                let startIndex = min(0, data.data.count) // Bắt đầu từ phần tử thứ 5
                self.chatData = Array(data.data.suffix(from: startIndex).prefix(endIndex-startIndex))
                
                print("self.chatData:\(self.chatData.count)")
                
                DispatchQueue.main.async {
                    self.chatCollectionView.reloadData()
                }
                //                self.moreDate += 1
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
    
}

extension ChatViewController : UICollectionViewDataSource, UICollectionViewDelegate,CellSizeCaculate,UICollectionViewDelegateFlowLayout {
    
    func registerCollectionView(){
        chatCollectionView.dataSource = self
        chatCollectionView.delegate = self
        let userActiveCell = UINib(nibName: "ActiveUserListCollectionViewCell", bundle: nil)
        chatCollectionView.register(userActiveCell, forCellWithReuseIdentifier: "ActiveUserListCollectionViewCell")
        
        let FriendListCell = UINib(nibName: "FriendListCollectionViewCell", bundle: nil)
        chatCollectionView.register(FriendListCell, forCellWithReuseIdentifier: "FriendListCollectionViewCell")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let chatSection = ChatSection.allCases.count
        return chatSection
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let chatSection = ChatSection(rawValue: section)
        switch chatSection {
        case .userActive:
            return 1
        case .userFriendList:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chatSection = ChatSection(rawValue: indexPath.section)
        switch chatSection {
        case .userActive:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActiveUserListCollectionViewCell", for: indexPath) as! ActiveUserListCollectionViewCell
            cell.bindData(data: chatData)
            cell.gotoChatVC = { data in
                self.gotoChatVC(data: data)
            }
            return cell
        case .userFriendList:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendListCollectionViewCell", for: indexPath) as! FriendListCollectionViewCell
            cell.bindData(data: chatData)
            cell.gotoChatVC = { data in
                self.gotoChatVC(data: data)
            }
            return cell
        default:
            return CollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = ChatSection(rawValue: indexPath.section)
        switch section {
        case .userActive:
            // Return the size for items in userActive section
            return CGSize(width: collectionView.frame.width, height: 72)
        case .userFriendList:
            // Return the size for items in userFriendList section
            let height : CGFloat = CGFloat(88 * chatData.count)
            return CGSize(width: collectionView.frame.width, height: height)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
}
extension ChatViewController: UIScrollViewDelegate {
    func pullToRefesh(){
        refeshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        chatCollectionView.addSubview(refeshControl)
    }
    @objc func reloadData(send: UIRefreshControl){
        DispatchQueue.main.async {
            self.getAllChatData()
            print("đã scroll hết")
            self.refeshControl.endRefreshing()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height && !isLoading {
            moreDate += 10 // Tăng trang lên để tải trang tiếp theo
            //            getAllChatData() // Tải dữ liệu cho trang tiếp theo
        }
    }
}
extension ChatViewController {
    @objc func sendUserId(){
        guard let sendID = Int(userID ?? "0") else {
            print("---userNil---")
            return
        }
        if SocketIOManager.shared.mSocket.status == .connected {
            print("Socket is connected")
            let messageData: [String: Int] = [
                "userId": sendID
            ]
            SocketIOManager.shared.mSocket.emit("userId", messageData)
        } else {
            print("Socket is not connected")
        }
    }
    func reloadNewMessage1(){
        // lắng nghe event check_message
        SocketIOManager.shared.mSocket.on("check_message") { data, ack in
            print("co tin nhan moi")
            self.getAllChatData()
        }
    }
}
extension ChatViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            print("searchBar rỗng")
            self.chatData = filterData
        } else {
            self.chatData = filterData
            let filteredChatData = chatData.filter { chat in
                if let otherFullname = chat.otherFullname {
                    return otherFullname.lowercased().contains(searchText.lowercased())
                }
                return false
            }
            self.chatData = filteredChatData
        }
        chatCollectionView.reloadData()
        print("chatData:\(chatData.count)")
        print("filteredChatData:\(filterData.count)")
        
    }
}



