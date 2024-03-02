
import UIKit
import CollectionViewPagingLayout

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellUiView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userDistanceLb: UILabel!
    @IBOutlet weak var userDistanceView: UIView!
    @IBOutlet weak var userNameLb: UILabel!
    @IBOutlet weak var userAgeLb: UILabel!
    @IBOutlet weak var userLocationLb: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var loveBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func blindata(name: String){
        userImage.image = UIImage(named: name)
//        userDistanceLb.text = String(format: "%.1f", userDistance.distance ?? "")
//        userNameLb.text =
    }
    func setupView(){
        userImage.layer.cornerRadius = 32
        userImage.clipsToBounds = true
        cellUiView.layer.cornerRadius = 32
        cellUiView.clipsToBounds = true
        userDistanceView.layer.cornerRadius = userDistanceView.frame.height/2
        userDistanceView.layer.borderWidth = Constant.borderWidth
        userDistanceView.layer.borderColor = UIColor.white.cgColor //UIColor.red.cgColor
        userDistanceView.clipsToBounds = true
    }
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case removeBtn:
            print("removeBtn")
        case likeBtn:
            print("likeBtn")
        case loveBtn:
            print("loveBtn")
        default:
            break
        }
    }
}
    
extension HomeCollectionViewCell: StackTransformView {
    func applyScaleTransform(progress: CGFloat) {
        let alpha = 1 - abs(progress)
        contentView.alpha = alpha
    }
    
    var stackOptions: StackTransformViewOptions {
//        .layout(.vortex)
        .layout(.transparent)
    }
}
