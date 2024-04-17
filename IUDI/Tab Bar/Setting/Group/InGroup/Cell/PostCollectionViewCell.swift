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

class PostCollectionViewCell: UICollectionViewCell, ServerImageHandle {
    
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
    var userPostId: String?
    var userID = UserInfo.shared.getUserID()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.layer.cornerRadius = avatarView.frame.size.width/2
    }
    
    func blindata(data: ListPost){
        postsLabel.text = data.content
        nameLabel.text = data.userFullName
        timeLabel.text = data.postTime
        avatarView.image = convertStringToImage(imageString: data.avatar ?? "")
        postsImage.image = convertStringToImage(imageString: data.photo ?? "")
        self.postId = data.postID
        self.userPostId = "\(data.userID ?? 0)"
    }
    
    @IBAction func deletePosts(_ sender: Any) {
        print("postsGroupVCDelegate?.subviewHandle()")
        guard let postId = postId else{return}
        if userID == userPostId {
            postsGroupVCDelegate?.passPostID(postId: postId, isUser: true)
            postsGroupVCDelegate?.displayMenu()
            print("postId : \(postId)")
        } else {
            print("userID không đúng")
            postsGroupVCDelegate?.passPostID(postId: postId, isUser: false)
            postsGroupVCDelegate?.displayMenu()
        }
    }
}

