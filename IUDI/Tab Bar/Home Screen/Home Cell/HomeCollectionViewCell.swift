
import UIKit
import CollectionViewPagingLayout

class HomeCollectionViewCell: UICollectionViewCell,DateConvertFormat {
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
    var options = StackTransformViewOptions()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        
//        let currentScaleFactor = options.

        // Thay đổi giá trị của biến
    }
    
    func blindata(data: Distance){
        let imageUrl = URL(string: data.avatarLink ?? "")
        userImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder_image"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                // Ảnh đã tải thành công
                break
            case .failure(let error):
                // Xảy ra lỗi khi tải ảnh
                self.userImage.image = UIImage(systemName: "person")
                print("Lỗi khi tải ảnh: \(error.localizedDescription)")
            }
        })
        let rawKilometers = (data.distance ?? 1.0) / 1000.0
        let roundedKilometers = round(rawKilometers * 10) / 10
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        let userDistant = formatter.string(from: NSNumber(value: roundedKilometers)) ?? ""
        userDistanceLb.text = "Khoảng cách " + userDistant + " km"
        userNameLb.text = data.fullName
        let yearOfBirth = convertDate(date: data.birthDate ?? "", inputFormat: "yyyy-MM-dd", outputFormat: "**yyyy**")
        let userAge = Int(Constant.currentYear) - (Int(yearOfBirth) ?? 0)
        userAgeLb.text = String(userAge)
        userLocationLb.text = data.currentAdd
    }
    func setupView(){
        userImage.layer.cornerRadius = 32
        userImage.clipsToBounds = true
        cellUiView.layer.cornerRadius = 32
        cellUiView.layer.borderWidth = 0.5
        cellUiView.layer.borderColor = UIColor.black.cgColor
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
    
    private func applyScaleTransform(progress: CGFloat) {
        let alpha = 1 - abs(progress)
        contentView.alpha = alpha
    }
    var stackOptions: StackTransformViewOptions {
        .layout(.transparent)
    }

//    var test: StackTransformViewOptions {
//        .init(reverse: false)
//    }
//    var test: StackTransformViewOptions {
//        StackTransformViewOptions(stackPosition: CGPoint(x: 1, y: -1))
//    }
}
