//
//  HowAreYouPostsViewController.swift
//  IUDI
//
//  Created by Quoc on 29/02/2024.
//

import UIKit

class HowAreYouPostsViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var imageVideoButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var feelingButton: UIButton!
    @IBOutlet weak var gifButton: UIButton!
    @IBOutlet weak var pollButton: UIButton!
    
    
    var placeholderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Thiết lập delegate của UITextView
        textView.delegate = self
        
        // Tạo label placeholder
        placeholderLabel = UILabel()
        placeholderLabel.text = "Gửi bài viết công khai để quản trị viên phê duyệt..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 16) // Font của placeholder với kích thước nhỏ hơn
        placeholderLabel.textColor = UIColor.lightGray // Màu của placeholder
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 5) // Vị trí của placeholder
        placeholderLabel.numberOfLines = 0 // Cho phép hiển thị nhiều dòng
        placeholderLabel.lineBreakMode = .byWordWrapping // Break line theo từng từ
        textView.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        // Thiết lập nút "Đăng" làm rightBarButtonItem
        let publishButton = UIButton(type: .custom)
        publishButton.setTitle("Đăng", for: .normal)
        publishButton.addTarget(self, action: #selector(publishButtonTapped), for: .touchUpInside)
        publishButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        publishButton.setTitleColor(.blue, for: .normal)
        let publishBarButtonItem = UIBarButtonItem(customView: publishButton)
        navigationItem.rightBarButtonItem = publishBarButtonItem
        
        applBorder(to: imageVideoButton)
        applBorder(to: tagButton)
        applBorder(to: cameraButton)
        applBorder(to: checkInButton)
        applBorder(to: feelingButton)
        applBorder(to: pollButton)
        applBorder(to: gifButton)
        
        alignTextLeft(for: imageVideoButton)
        alignTextLeft(for: tagButton)
        alignTextLeft(for: cameraButton)
        alignTextLeft(for: checkInButton)
        alignTextLeft(for: feelingButton)
        alignTextLeft(for: pollButton)
        alignTextLeft(for: gifButton)
        // Do any additional setup after loading the view.
    }
    
    private func applBorder(to button: UIButton){
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: button.bounds.height + 10.0, width: button.bounds.width, height: 0.5)
        bottomBorder.backgroundColor = UIColor.gray.cgColor
        button.layer.addSublayer(bottomBorder)
    }
    
    private func alignTextLeft(for button: UIButton) {
        button.contentHorizontalAlignment = .left
        
        
    }
    
    // Xử lý sự kiện khi nút đăng được nhấn
    @objc func publishButtonTapped() {
        print("Nút Đăng được nhấn")
    }
    
    // Xử lý khi UITextView thay đổi
    func textViewDidChange(_ textView: UITextView) {
        // Hiển thị hoặc ẩn placeholder tùy thuộc vào nội dung của UITextView
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
