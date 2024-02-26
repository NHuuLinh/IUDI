//
//  MyCell.swift
//  IUDI
//
//  Created by LinhMAC on 26/02/2024.
//

import UIKit
import CollectionViewPagingLayout

class MyCell: UICollectionViewCell {
    @IBOutlet weak var testimage: UIImageView!
    
    var card: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        setup()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //        setup()
    }
    func blindata(name: String){
        testimage.image = UIImage(named: name)
    }
}
    
extension MyCell: StackTransformView {
    func applyScaleTransform(progress: CGFloat) {
        let alpha = 1 - abs(progress)
        contentView.alpha = alpha
    }
    
    var stackOptions: StackTransformViewOptions {
        .layout(.vortex)
//        .layout(.transparent)
    }
}
// perspective = đổ bên trái, vuốt xuống cuối là đồng cỏ


//extension MyCell: TransformableView {
//    func transform(progress: CGFloat) {
//        let alpha = 1 - abs(progress)
//        contentView.alpha = alpha
//    }
//}
//extension MyCell: ScaleTransformView {
//    var scaleOptions: ScaleTransformViewOptions {
//        ScaleTransformViewOptions(
//            minScale: 0.6,
//            scaleRatio: 0.4,
//            translationRatio: CGPoint(x: 0.66, y: 0.2),
//            maxTranslationRatio: CGPoint(x: 2, y: 0)
//            )
//    }
//}
