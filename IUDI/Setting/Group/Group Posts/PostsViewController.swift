//
//  PostsViewController.swift
//  IUDI
//
//  Created by Quoc on 28/02/2024.
//

import UIKit

class PostsViewController: UIViewController {
    
    @IBOutlet weak var displayPosts: UICollectionView!
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var avatarView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsButton.layer.borderWidth = 1
        postsButton.layer.cornerRadius = 20
        postsButton.tintColor = UIColor.clear

        avatarView.layer.cornerRadius = avatarView.frame.size.width / 2
    }
    
    @IBAction func postsButtonTapper(_ sender: Any) {
        let vc = HowAreYouPostsViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
