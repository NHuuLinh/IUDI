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

class MessageViewController: MessagesViewController,MessagesLayoutDelegate, UIDocumentPickerDelegate, MessagesDisplayDelegate {
    let userID = UserInfo.shared.getUserID()
    let currentUser = Sender(senderId: UserInfo.shared.getUserID() ?? "", displayName: UserInfo.shared.getUserFullName() ?? "")
    let otherUser = Sender(senderId: "other", displayName: "lâm")
    var messages = [MessageType]()
    var imagePicker = UIImagePickerController()
    let itemSize = CGSize(width: 24, height: 24)
    let itemSpacing: CGFloat = 15 // Khoảng cách giữa các mục
    let itemNumber :CGFloat = 5
    
    var userProfile : User?
    var userAvatar : UIImage?
    var targetAvatar: UIImage?
    var dataUser : Distance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subviewHandle()
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
        messageInputBar.delegate = self
        addCameraBarButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.shared.establishConnection()

    }
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
        userSubview.frame = CGRect(x: 0, y: safeAreaHeight, width: view.frame.width, height: 50)
        //        userSubview.backgroundColor = .green
        messagesCollectionView.contentInset.top = userSubview.frame.height
        
        let childVC = ConverseViewController()
        addChild(childVC)
        childVC.userAvatar = userAvatar
        childVC.targetAvatar = targetAvatar
        childVC.dataUser = dataUser
        userSubview.addSubview(childVC.view)
        childVC.view.frame = userSubview.bounds
        childVC.didMove(toParent: self)
    }
    
}
extension MessageViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Tạo một tin nhắn mới từ người dùng hiện tại và văn bản đã nhập
        guard let RelatedUserID = dataUser?.userID else {
            print("---userNil---")
            return
        }
        if SocketIOManager.shared.mSocket.status == .connected {
            let messageData: [String: Any] = [
                "room": RelatedUserID , //ví dụ 21423
                "data": [
                    "id": userID,
                    "RelatedUserID": RelatedUserID ,
                    "type": "text",//text/ image/icon-image/muti-image
                    "state":"",
                    "content":text
                ]
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
            
        }
    }
    
}
extension MessageViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            
            let mediaItem = ImageMediaItem(image: image)
            let newMessage = Message(sender: currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .photo(mediaItem))
            
            messages.append(newMessage)
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem(animated: true)
        }
        
        dismiss(animated: true, completion: nil)
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
        
        let photoLibrary = addBarItem(size: itemSize, image: "photo", action: #selector(photoButtonPressed))
        let camera = addBarItem(size: itemSize, image: "camera", action: #selector(openCamera))
        let paperclip = addBarItem(size: itemSize, image: "paperclip", action: #selector(sendFile))
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


    
}

// MARK: - MessagesDisplayDelegate
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
            return Avatar(image:self.userAvatar, initials: initials)
        }else{
            return Avatar(image:self.targetAvatar, initials: initials)
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




