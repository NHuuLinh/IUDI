//
//  ConverseViewController.swift
//  IUDI
//
//  Created by LinhMAC on 18/03/2024.

import UIKit
import SocketIO

class ConverseViewController: UIViewController {
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageLb: UILabel!
    @IBOutlet weak var messagePlaceholdText: UILabel!
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var emojiBtn: UIButton!
    @IBOutlet weak var attachBtn: UIButton!
    @IBOutlet weak var microBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.delegate = self
        messageTextView.textContainer.lineBreakMode = .byWordWrapping
        SocketIOManager.shared.establishConnection()
    }
//    override func viewWillAppear(_ animated: Bool) {
//        SocketIOManager.shared.establishConnection()
//    }

    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case sendBtn:
            SocketIOManager.sharedInstance.sendTextMessage1()
            print("sendBtn")
        case emojiBtn:
            SocketIOManager.shared.establishConnection()
            print("emojiBtn")
        case attachBtn:
            print("attachBtn")
        case microBtn:
            print("microBtn")
        default:
            break
        }
    }
}

extension ConverseViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Kiểm tra nếu UITextView không rỗng
        if let text = textView.text, !text.isEmpty {
            // Nếu có nội dung, kích hoạt nút lưu
            messageLb.text = messageTextView.text
            messagePlaceholdText.isHidden = true
        } else {
            // Nếu không có nội dung, vô hiệu hóa nút lưu
            messageLb.text = messageTextView.text
            messagePlaceholdText.isHidden = false

        }
    }
}
