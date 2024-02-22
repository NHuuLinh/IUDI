

import Foundation
import UIKit

extension UIView {
   // thêm bo góc ở storyboard
    @IBInspectable var cornerRadius : CGFloat {
        get {
            return self.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
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
}



