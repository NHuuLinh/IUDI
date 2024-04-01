//
//  MessageViewController.swift
//  IUDI
//
//  Created by LinhMAC on 20/03/2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import UniformTypeIdentifiers
import SwiftyJSON

class MessageViewController: MessagesViewController,MessagesLayoutDelegate, UIDocumentPickerDelegate, MessagesDisplayDelegate {
    let userID = UserInfo.shared.getUserID()
    let currentUser = Sender(senderId: UserInfo.shared.getUserID() ?? "", displayName: UserInfo.shared.getUserFullName() ?? "")
    
    let otherUser = Sender(senderId: "other", displayName: "lâm")
    var messages = [MessageType]()
    var imagePicker = UIImagePickerController()
    
    var messageUserData : MessageUserData?
    var userAvatar: UIImageView?
    var userFullName: String?

    var hi:ImgModel = ImgModel()
    var chatData = [SingleChat]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserProfile()
        subviewHandle()
        sendUserId()
        SocketIOManager.sharedInstance.establishConnection()
        messages.append(Message(sender: currentUser, messageId: "1", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello Word1")))
        
        messages.append(Message(sender: otherUser, messageId: "2", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello Word2")))
        
        messages.append(Message(sender: otherUser, messageId: "3", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello Word3")))
        
        messages.append(Message(sender: currentUser, messageId: "4", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello Word4")))
        
        messages.append(Message(sender: otherUser, messageId: "5", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello Word5")))
        messages.append(Message(sender: otherUser, messageId: "5", sentDate: Date(), kind: .text("Hello Word6")))
        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.showsVerticalScrollIndicator = false
        messageInputBar.delegate = self
        addCameraBarButton()
        getAllChatData()
    }
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.shared.establishConnection()
        SocketIOManager.shared.mSocket.on("connect") {data, ack in
            self.sendUserId() // Gọi hàm sendUserId() khi kết nối thành công
        }
        navigationController?.navigationBar.isHidden = true
        reloadNewMessage()
    }
//    func bindData(userName: String, userAvatar : UIImage, otherUserAvatar: UIImage, otherUserName: String, otherUserId: String){
//        self.userName = userName
//        self.userAvatar = userAvatar
//        self.otherUserAvatar = otherUserAvatar
//        self.otherUserName = otherUserName
//        self.otherUserId = otherUserId
//    }
    func getAllChatData(){
        guard let userID = UserInfo.shared.getUserID() else {
            print("userID Nil")
            return
        }
        guard let otherUserID = messageUserData?.otherUserId else {
            print("otherUserID")
            return
        }
        showLoading(isShow: true)
        let apiService = APIService.share
        let subUrl = "pairmessage/\(userID)?other_userId=\(otherUserID)"
        print("url:\(subUrl)")
        apiService.apiHandleGetRequest(subUrl: subUrl,data: AllSingleChatData.self) { result in
            switch result {
            case .success(let data):
                self.loadChatHistory(datas: data.data)
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
    func loadChatHistory(datas: [SingleChat] ){
        guard let userID = UserInfo.shared.getUserID() else {
            print("userID Nil")
            return
        }
        for data in datas.reversed() {
            guard let messageText = data.content,
            let senderId = data.senderID,
            let displayName = data.otherUsername,
            let messageId = data.messageID,
                  let messageDate = data.messageTime else {return}
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz" // Specify the format of the string date
            let sentDate = dateFormatter.date(from: messageDate) ?? Date()
            let newMessage = Message(sender: Sender(senderId: "\(senderId)", displayName: displayName),
                                     messageId: "\(messageId)",
                                     sentDate: sentDate,
                                     kind: .text(messageText))
            // Xử lý tin nhắn mới
            
            self.messages.append(newMessage)
        }
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    
}

// MARK: - xử lí subview
extension MessageViewController {
    
    func subviewHandle(){
        var safeAreaHeight : CGFloat
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                safeAreaHeight = window.safeAreaInsets.top// + window.safeAreaInsets.bottom
                print("Chiều cao của safe area: \(safeAreaHeight)")
            } else {
                safeAreaHeight = 60
                print("Không thể lấy được window")
            }
        } else {
            safeAreaHeight = 60
            
            print("Không thể lấy được window scene")
        }
        
        let userSubview = UIView()
        view.addSubview(userSubview)
        userSubview.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50 + safeAreaHeight)
        //        userSubview.backgroundColor = .green
        messagesCollectionView.contentInset.top = userSubview.frame.height
        
        let childVC = ConverseViewController()
        addChild(childVC)
        childVC.messageUserData = messageUserData
        userSubview.addSubview(childVC.view)
        childVC.view.frame = userSubview.bounds
        childVC.didMove(toParent: self)
    }

}
// MARK: - download UserProfile
extension MessageViewController {
    func getUserProfile(){
        showLoading(isShow: true)
        guard let userName = UserInfo.shared.getUserName() else {
            print("không có userName")
            return
        }
        let url = "profile/" + userName
        APIService.share.apiHandleGetRequest(subUrl: url, data: User.self) { result in
            switch result {
            case .success(let data):
                let userData = data.users?.first
                let url = URL(string: "https://example.com/image.jpg")
                self.userAvatar?.kf.setImage(with: url)
                self.userFullName = userData?.fullName
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

// MARK: - testing
extension MessageViewController {
//    func handleNewMessage(message: Message) {
//        // Kiểm tra xem tin nhắn mới có phải từ người dùng hiện tại hay không
//        if message.sender.senderId != currentUser.senderId {
//            // Nếu tin nhắn mới không phải từ người dùng hiện tại, thêm nó vào mảng tin nhắn và cập nhật giao diện
//            messages.append(message)
//            messagesCollectionView.reloadData()
//            messagesCollectionView.scrollToLastItem(animated: true)
//        } else {
//            print("---từ người dùng hiện tại---")
//        }
//    }
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
    func reloadNewMessage(){
        SocketIOManager.shared.mSocket.on("check_message") { data, ack in
            print("co tin nhan moi")
            print("co tin nhan moi: \(data)")
            guard let messageData = data[0] as? [String: Any] else { return }
            guard let displayName = self.userFullName else {return}
            //            let json = try JSON(data: data)
            //            let errorMessage = json["message"].stringValue
            //            if let messageData = data as? [String: Any] {
            // Xử lý dữ liệu tin nhắn mới
            //                let messageId = messageData["messageId"] as? String ?? ""
            let senderId = messageData["senderID"] as? String ?? ""
            //                let senderName = messageData["senderName"] as? String ?? ""
            let messageText = messageData["content"] as? String ?? ""
            // Tạo đối tượng tin nhắn mới từ dữ liệu nhận được
            let newMessage = Message(sender: Sender(senderId: senderId, displayName: displayName),
                                     messageId: senderId,
                                     sentDate: Date(),
                                     kind: .text(messageText))
            // Xử lý tin nhắn mới
            self.messages.append(newMessage)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
            //            }
        }
    }
}

// MARK: - Xử lí khi tin nhắn text
extension MessageViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Tạo một tin nhắn mới từ người dùng hiện tại và văn bản đã nhập
        guard let idReceive = messageUserData?.otherUserId else {
            print("---userNil---")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        
        // Lấy thời gian hiện tại
        let currentTime = Date()
        // Định dạng thời gian hiện tại thành chuỗi
        let MessageTime = dateFormatter.string(from: currentTime)
        if SocketIOManager.shared.mSocket.status == .connected {
            let messageData: [String: Any] = [
                "content": text,
                "MessageTime": MessageTime,
                "idReceive": idReceive,
                "idSend": userID ?? ""
            ]
            SocketIOManager.shared.mSocket.emit("send_message", messageData)
            let newMessage = Message(sender: currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
            print("newMessage:\(newMessage)")
            // Thêm tin nhắn mới vào mảng messages và reload dữ liệu hiển thị
            messages.append(newMessage)
            messagesCollectionView.reloadData()
            // Xóa văn bản đã nhập từ thanh nhập liệu
            inputBar.inputTextView.text = ""
            // Cuộn xuống cuối danh sách tin nhắn để hiển thị tin nhắn mới nhất
            messagesCollectionView.scrollToLastItem(animated: true)
        } else {
            print("Socket is not connected")
            showAlert(title: "Socket is not connected", message: "Socket is not connected")
        }
    }
    
}
// MARK: - Xử lí khi chọn ảnh và tệp
extension MessageViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func resizeImage(image: UIImage, scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            return newImage
        }
        return image
    }
    
    func uploadImageToServer(image: UIImage, completion: @escaping (String?) -> Void) {
        // Resize image to reduce file size (e.g., to 0.5 scale)
        let resizedImage = resizeImage(image: image, scale: 0.5)
        
        // Convert resized image to JPEG format with a lower compression quality
        if let imageData = resizedImage.jpegData(compressionQuality: 0.5) {
            // Convert JPEG data to base64 string
            let dataImage = imageData.base64EncodedString(options: .lineLength64Characters)
            //            let sonaParam = ["image": dataImage]
            
            // Pass the JPEG data to your API service
            APIServiceImage.shared.PostImageServer(param: imageData) { data, error in
                print("===test=== \(String(describing: data?.display_url))")
                guard let imageUrl = data?.display_url else {
                    completion(nil)
                    return
                }
                completion(imageUrl)
            }
        } else {
            // If unable to convert image to JPEG data, return nil
            completion(nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            let mediaItem = ImageMediaItem(image: image)
            uploadImageToServer(image: image) { imageUrl in
                guard let otherUserId = self.messageUserData?.otherUserId else {
                    print("---userNil---")
                    return
                }
                if SocketIOManager.shared.mSocket.status == .connected {
                    let messageData: [String: Any] = [
                        "room": otherUserId , //ví dụ 21423
                        "data": [
                            "id": self.userID ?? "",
                            "RelatedUserID": otherUserId ,
                            "type": "image",
                            "state":"",
                            "data": imageUrl ?? ""
                        ]
                    ]
                    print("==imageUrl== \(imageUrl)")
                    print("==messageData== \(messageData)")
                    
                    SocketIOManager.shared.mSocket.emit("send_message", messageData)
                    let newMessage = Message(sender: self.currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .photo(mediaItem))
                    self.messages.append(newMessage)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                } else {
                    print("Socket is not connected")
                }
            }
            
            dismiss(animated: true, completion: nil)
        }
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if (urls.first?.lastPathComponent) != nil {
            for url in urls {
                let newMessage = Message(sender: currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .custom(url.self))
                messages.append(newMessage)
            }
            // Reload the collection view to display the new messages
            messagesCollectionView.reloadData()
            // Dismiss the document picker
            dismiss(animated: true, completion: nil)
        }
    }
}
// MARK: - thêm icon vào right bar
extension MessageViewController {
    
    func addBarItem(size: CGSize, image: String, action: Selector) -> InputBarButtonItem{
        let item = InputBarButtonItem(type: .system)
        item.image = UIImage(systemName: image)
        item.tintColor = Constant.mainBorderColor
        item.addTarget(
            self,
            action: action,
            for: .primaryActionTriggered)
        item.setSize(size, animated: false)
        return item
    }
    
    private func addCameraBarButton() {
        let itemSize = CGSize(width: 24, height: 24)
        let itemSpacing: CGFloat = 15 // Khoảng cách giữa các mục
        let itemNumber :CGFloat = 5
        
        let photoLibrary = addBarItem(size: itemSize, image: "photo", action: #selector(photoButtonPressed))
        let camera = addBarItem(size: itemSize, image: "camera", action: #selector(sendUserId))
        let paperclip = addBarItem(size: itemSize, image: "paperclip", action: #selector(printSomething1))
        let micro = addBarItem(size: itemSize, image: "mic.fill", action: #selector(printSomething))
        
        messageInputBar.sendButton.image = UIImage(named: "sendmsgicon")
        messageInputBar.sendButton.setSize(itemSize, animated: true)
        messageInputBar.sendButton.title = nil
        
        messageInputBar.rightStackView.alignment = .center
        messageInputBar.rightStackView.spacing = itemSpacing // Đặt khoảng cách giữa các mục
        let messageInputBarSize = (itemSize.width * itemNumber) + (itemSpacing * (itemNumber - 1)) // Tính kích thước của thanh input bar
        messageInputBar.setRightStackViewWidthConstant(to: messageInputBarSize, animated: false)
        messageInputBar.setStackViewItems([messageInputBar.sendButton, photoLibrary, camera,paperclip,micro], forStack: .right, animated: false)
    }
    @objc private func photoButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc fileprivate func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            /// Cho phép edit ảnh hay là không
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let errorText = NSLocalizedString("Error", comment: "")
            let errorMessage = NSLocalizedString("Divice not have camera", comment: "")
            
            let alertWarning = UIAlertController(title: errorText,
                                                 message: errorMessage,
                                                 preferredStyle: .alert)
            let cancelText = NSLocalizedString("Cancel", comment: "")
            let cancel = UIAlertAction(title: cancelText,
                                       style: .cancel) { (_) in
                print("Cancel")
            }
            alertWarning.addAction(cancel)
            self.present(alertWarning, animated: true, completion: nil)
        }
    }
    
    @objc private func sendFile() {
        let contentTypes: [UTType] = [
            .init(filenameExtension: "doc")!,
            .init(filenameExtension: "docx")!,
            .pdf,
            .presentation,
            .spreadsheet,
            .plainText,
            .text
        ]
        
        let documentPicker: UIDocumentPickerViewController
        
        if #available(iOS 14.0, *) {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        } else {
            documentPicker = UIDocumentPickerViewController(documentTypes: contentTypes.map({$0.identifier}), in: .import)
        }
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }
    @objc func printSomething(){
        print("do nothing")
        SocketIOManager.shared.establishConnection()
    }
    @objc func printSomething1(){
        print("do nothing")
        reloadNewMessage()
    }
    
    
    
}

// MARK: - Cấu hình UI của MessageViewController
extension MessageViewController: MessagesDataSource {
    func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue : .red
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = self.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }
    
    func getAvatarFor(sender: SenderType) -> Avatar {
        let firstName = sender.displayName.components(separatedBy: " ").first?.uppercased()
        let lastName = sender.displayName.components(separatedBy: " ").last?.uppercased()
        let initials = "\(firstName?.first ?? "A")\(lastName?.first ?? "A")"
        
        if "self" == sender.senderId{
            return Avatar(image:userAvatar?.image, initials: initials)
        }else{
            return Avatar(image:messageUserData?.otherUserAvatar, initials: initials)
        }
    }
    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        switch message.kind {
        case .photo(let media):
            if let imageURL = media.url {
                imageView.kf.setImage(with: imageURL)
            }else{
                imageView.kf.cancelDownloadTask()
            }
        default:
            break
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        //let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubble
        //        return .bubbleTail(corner, .curved)
    }
}

// MARK: - Cấu hình UI của MessageViewController
extension MessageViewController {
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Format thời gian gửi của tin nhắn
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // Định dạng 24 giờ
        let sentDate = dateFormatter.string(from: message.sentDate)
        
        // Tạo văn bản được định dạng cho thời gian gửi
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray // Màu xám
        ]
        return NSAttributedString(string: sentDate, attributes: attributes)
    }
    //    func cellBottomLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //
    //        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    //    }
    //    func messageTopLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //        let name = message.sender.displayName
    //        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    //    }
    //
    func messageBottomLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name,attributes: [NSAttributedString.Key.font: UIFont(name: "Roboto-Regular",
                                                                                                size: 10) ?? UIFont.preferredFont(forTextStyle: .caption1),
                                                            NSAttributedString.Key.foregroundColor: UIColor.gray])
        //        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    //    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    //        return 10
    //    }
    //
    //    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    //        return 10
    //    }
    //
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
}




