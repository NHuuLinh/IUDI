//
//  CollectionViewCell.swift
//  IUDI
//
//  Created by Quoc on 28/02/2024.
//

import UIKit
import Alamofire

class CollectionViewCell: UICollectionViewCell, ServerImageHandle {
    
    var didSelectItem: (() -> Void)?
    var groupName: String?
    
    @IBOutlet weak var numberOfMembers: UILabel!
    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var imageGroup: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var collectionView: UIView!
    @IBOutlet weak var groupIDLabel: UILabel!
    var groupData: GroupData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageGroup.layer.cornerRadius = imageGroup.frame.size.width / 2
        collectionView.layer.cornerRadius = 20
        collectionView.isUserInteractionEnabled = true
        
    }
    func bindData(data: Datum){
        groupName = data.groupName
        groupName = "\(data.groupID)"

        numberOfMembers.text = "\(data.userNumber ?? 0) Thành viên"
        nameGroup.text = data.groupName ?? ""
        imageGroup.image = convertStringToImage(imageString: data.avatarLink ?? "")
        time.text = data.createAt ?? ""
//        groupIDLabel.text = "\(data.groupID ?? 0)"
    }
}
