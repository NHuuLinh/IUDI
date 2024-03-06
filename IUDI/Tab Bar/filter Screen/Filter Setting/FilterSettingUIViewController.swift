//
//  FilterSettingUIViewController.swift
//  IUDI
//
//  Created by LinhMAC on 06/03/2024.
//

import UIKit
import SwiftRangeSlider
import iOSDropDown

class FilterSettingUIViewController: UIViewController {
    
    @IBOutlet weak var distanceSlider: RangeSlider!
    @IBOutlet weak var ageSlider: RangeSlider!
    @IBOutlet weak var genderTF: DropDown!
    @IBOutlet weak var currentAddressTF: DropDown!
    
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var currentAddressBtn: UIButton!
    
    @IBOutlet weak var genderBoxView: UIView!
    @IBOutlet weak var currentAddressBoxView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        setupSlider(slider: ageSlider, minimumValue: 18, maximumValue: 70)
        setupSlider(slider: distanceSlider, minimumValue: 0, maximumValue: 60)
        dropDownHandle(texfield: genderTF, inputArray: Constant.gender)
        dropDownHandle(texfield: currentAddressTF, inputArray: Constant.provinces)
        standardViewCornerRadius(uiView: currentAddressBoxView)
        standardViewCornerRadius(uiView: genderBoxView)
    }
    func dropDownHandle(texfield: DropDown, inputArray: [String]){
        texfield.arrowColor = UIColor .red
        texfield.selectedRowColor = UIColor .red
        texfield.optionArray = inputArray
    }
    
    @objc func sliderValueChanged(_ slider: RangeSlider) {
//        print("Selected age range: \(slider.lowerValue) - \(slider.upperValue)")
    }
    
    func setupSlider(slider: RangeSlider,minimumValue: Double, maximumValue: Double){
        // Thiết lập giá trị tối thiểu, tối đa và các giá trị hiện tại
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
        slider.lowerValue = minimumValue
        slider.upperValue = maximumValue
        slider.knobSize = 24
        slider.knobBorderThickness = 1
        slider.knobBorderTintColor = UIColor(red: 0.00, green: 0.53, blue: 0.28, alpha: 1.00)
        slider.labelFontSize = 16
        slider.trackThickness = 5
        slider.trackTintColor = UIColor.gray
        slider.trackHighlightTintColor = UIColor(red: 0.00, green: 0.53, blue: 0.28, alpha: 1.00)
        // Thêm hành động cho sự kiện .valueChanged
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case genderBtn:
            genderTF.showList()
        case currentAddressBtn:
            currentAddressTF.showList()
            print("saved")
        default :
            break
        }
    }
    
}

