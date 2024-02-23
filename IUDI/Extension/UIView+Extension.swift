

import Foundation
import UIKit

extension UIView {
    // thêm bo góc ở storyboard
//    @IBInspectable var cornerRadius : CGFloat {
//        get {
//            return self.cornerRadius
//        }
//        set {
//            self.layer.cornerRadius = newValue
//        }
//    }
}
extension UIViewController {
    func standardBorder(textField: UITextField) {
        textField.layer.cornerRadius = Constant.cornerRadius
        textField.layer.borderWidth = Constant.borderWidth
        textField.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00).cgColor
    }
    func buttonCornerRadius(button: UIButton) {
        button.layer.cornerRadius = 10  // Thay đổi số này để điều chỉnh độ bo của góc
        button.clipsToBounds = true
    }
}

class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "App Icone")! as UIImage
    let uncheckedImage = UIImage(named: "Rectangle 8")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
        
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
        
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
   // thêm màu của viền ở storyboard
//   @IBInspectable var borderColor: UIColor {
//       get {
//           if let color = layer.borderColor {
//               return UIColor(cgColor: color)
//           } else {
//               return UIColor.clear
//           }
//       }
//       set {
//           layer.borderColor = newValue.cgColor
//       }
//   }
//   // thêm chiều dày của viền ở storyboard
//   @IBInspectable var borderWidth: CGFloat {
//       get {
//           return layer.borderWidth
//       }
//       set {
//           layer.borderWidth = newValue
//       }
//   }
//}
//extension UIView {
//
//   // thêm màu của viền dưới ở storyboard
//    @IBInspectable var bottomBorderColor: UIColor {
//        set {
//            addBottomBorderWithColor(color: newValue, width: bottomBorderWidth)
//        }
//        get {
//            return UIColor.clear
//        }
//    }
//
//   // thêm chiều dày của viền dưới ở storyboard
//    @IBInspectable var bottomBorderWidth: CGFloat {
//        set {
//            addBottomBorderWithColor(color: bottomBorderColor, width: newValue)
//        }
//        get {
//            return 0.0
//        }
//    }
//
//    private func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
//        let bottomBorder = CALayer()
//        bottomBorder.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
//        bottomBorder.backgroundColor = color.cgColor
//        self.layer.addSublayer(bottomBorder)
//    }



