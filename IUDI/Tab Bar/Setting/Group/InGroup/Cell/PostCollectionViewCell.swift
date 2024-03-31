//
//  PostCollectionViewCell.swift
//  IUDI
//
//  Created by Quoc on 01/03/2024.
//

import UIKit
import Alamofire

protocol PostCollectionViewCellDelegate: AnyObject {
    func didTapDeleteButton(for postId: Int)
}
protocol PostCellDelegate: AnyObject {
    func deletePost()
}

class PostCollectionViewCell: UICollectionViewCell {
    
    weak var postsGroupVCDelegate: PostsGroupVCDelegate?
    var didSelectItem: (() -> Void)?
    var deleteCompletion: (() -> Void)?
    
    @IBOutlet weak var postsImage: UIImageView!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var hideSubViewBtn: UIButton!
    
    var postId: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.layer.cornerRadius = avatarView.frame.size.width/2
    }
    
    func blindata(data: ListPost){
        postsLabel.text = data.content
        nameLabel.text = data.userFullName
        timeLabel.text = data.postTime
        
        setAvatarImage(uiImage: avatarView, url: data.avatar ?? "")
        setAvatarImage(uiImage: postsImage, url: data.photo ?? "")
        self.postId = data.postID
    }
    
    func setAvatarImage(uiImage: UIImageView, url: String) {
        let imageUrl = URL(string: url)
        uiImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                // Xảy ra lỗi khi tải ảnh
                uiImage.image = UIImage(systemName: "person")
            }
        })
    }
    
        @IBAction func deletePosts(_ sender: Any) {
            print("postsGroupVCDelegate?.subviewHandle()")
            guard let postId = postId else{return}
            postsGroupVCDelegate?.displayMenu()
            postsGroupVCDelegate?.passPostID(postId: postId)
            print("postId : \(postId)")
        }
    }
    
