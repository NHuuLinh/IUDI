//
//  FriendListCollectionViewCell.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//

import UIKit

class FriendListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var friendListCV: UICollectionView!
    var frameWidth : CGFloat?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        registerCollectionView()
//        print("friendListCV.frame.width\(friendListCV.frame.width)")
//        print("frameWidth\(frameWidth)")
    }
    
}
extension FriendListCollectionViewCell : UICollectionViewDataSource, UICollectionViewDelegate,CellSizeCaculate {
    
    func setupCollectionView() {
        if let flowLayout = friendListCV.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.itemSize.width = friendListCV.frame.width
        }
    }
    
    func registerCollectionView(){
        friendListCV.dataSource = self
        friendListCV.delegate = self
        let userActiveCell = UINib(nibName: "FriendListCell", bundle: nil)
        friendListCV.register(userActiveCell, forCellWithReuseIdentifier: "FriendListCell")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendListCell", for: indexPath) as! FriendListCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("FriendListCell select: \(indexPath.row)")
    }
    
    
}
