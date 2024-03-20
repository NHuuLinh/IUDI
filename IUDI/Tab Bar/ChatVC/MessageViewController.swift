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

class MessageViewController: MessagesViewController,MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate, UIDocumentPickerDelegate {
    
    let currentUser = Sender(senderId: "self", displayName: "Linh")
    let otherUser = Sender(senderId: "other", displayName: "lâm")
    var messages = [MessageType]()
    var imagePicker = UIImagePickerController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: currentUser, messageId: "1", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello Word1")))
        
        messages.append(Message(sender: otherUser, messageId: "2", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello Word2")))
        
        messages.append(Message(sender: otherUser, messageId: "3", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello Word3")))
        
        messages.append(Message(sender: currentUser, messageId: "4", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello Word4")))
        
        messages.append(Message(sender: otherUser, messageId: "5", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello Word5")))
        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        addCameraBarButton()
    }
    
    
    
    func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }


}
extension MessageViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Tạo một tin nhắn mới từ người dùng hiện tại và văn bản đã nhập
        let newMessage = Message(sender: currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
        
        // Thêm tin nhắn mới vào mảng messages và reload dữ liệu hiển thị
        messages.append(newMessage)
        messagesCollectionView.reloadData()
        
        // Xóa văn bản đã nhập từ thanh nhập liệu
        inputBar.inputTextView.text = ""
        
        // Cuộn xuống cuối danh sách tin nhắn để hiển thị tin nhắn mới nhất
        messagesCollectionView.scrollToLastItem(animated: true)
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
        let itemSize = CGSize(width: 24, height: 24)
        let itemSpacing: CGFloat = 15 // Khoảng cách giữa các mục
        let itemNumber :CGFloat = 5
        
        let photoLibrary = addBarItem(size: itemSize, image: "photo", action: #selector(photoButtonPressed))
        let camera = addBarItem(size: itemSize, image: "camera", action: #selector(openCamera))
        let paperclip = addBarItem(size: itemSize, image: "paperclip", action: #selector(sendFile))
        let micro = addBarItem(size: itemSize, image: "mic.fill", action: #selector(sendFile))

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
//        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
//        documentPicker.delegate = self
//        documentPicker.modalPresentationStyle = .formSheet
//        present(documentPicker, animated: true, completion: nil)
//    }
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
    
}



