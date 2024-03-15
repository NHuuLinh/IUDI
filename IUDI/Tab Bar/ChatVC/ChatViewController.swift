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
            return cell
        case .userFriendList:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendListCollectionViewCell", for: indexPath) as! FriendListCollectionViewCell
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
            return CGSize(width: collectionView.frame.width, height: 88*20)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    //        return 100 // Set the spacing between sections
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //        return 100 // Set the minimum interitem spacing within sections
    //    }
}
