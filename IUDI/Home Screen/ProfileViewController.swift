//
//  ProfileViewController.swift
//  IUDI
//
//  Created by LinhMAC on 26/02/2024.
//

import UIKit
import Alamofire
import iOSDropDown
import KeychainSwift
import SwiftyJSON

class ProfileViewController: UIViewController {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userNameLb: UILabel!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userEmailTF: UITextField!
    let datePicker = UIDatePicker()
    @IBOutlet weak var genderTF: DropDown!
    @IBOutlet weak var dateOfBirthTF: UITextField!
    @IBOutlet weak var pickDateBtn: UIButton!
    @IBOutlet weak var birthAddressTF: DropDown!
    @IBOutlet weak var currentAddressTF: DropDown!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var userNameBoxView: UIView!
    @IBOutlet weak var userEmailBoxView: UIView!
    @IBOutlet weak var genderBoxView: UIView!
    @IBOutlet weak var dateOfBirthBoxView: UIView!
    @IBOutlet weak var birthAddressBoxView: UIView!
    @IBOutlet weak var currentAddressBoxView: UIView!
    
    let gender: [String] = ["Nam", "Nữ", "Đồng tính nam", "Đồng tính nữ"]
    let provinces: [String] = [
        "Hà Nội",
        "Hồ Chí Minh",
        "Hải Phòng",
        "Đà Nẵng",
        "Cần Thơ",
        "Hải Dương",
        "Hà Nam",
        "Hà Tĩnh",
        "Hòa Bình",
        "Hưng Yên",
        "Thanh Hóa",
        "Nghệ An",
        "Hà Tây",
        "Thái Bình",
        "Thái Nguyên",
        "Lai Châu",
        "Lào Cai",
        "Lạng Sơn",
        "Nam Định",
        "Ninh Bình",
        "Sơn La",
        "Tây Ninh",
        "Đồng Tháp",
        "Bắc Giang",
        "Bắc Kạn",
        "Bạc Liêu",
        "Bắc Ninh",
        "Bến Tre",
        "Bình Định",
        "Bình Dương",
        "Bình Phước",
        "Bình Thuận",
        "Cà Mau",
        "Đắk Lắk",
        "Đắk Nông",
        "Điện Biên",
        "Đồng Nai",
        "Đồng Nai",
        "Gia Lai",
        "Hà Giang",
        "Hà Giang",
        "Hà Nam",
        "Hà Tĩnh",
        "Hải Dương",
        "Hậu Giang",
        "Hoà Bình",
        "Hưng Yên",
        "Khánh Hòa",
        "Kiên Giang",
        "Kon Tum",
        "Lai Châu",
        "Lâm Đồng",
        "Lạng Sơn",
        "Lào Cai",
        "Long An",
        "Nam Định",
        "Nghệ An",
        "Ninh Bình",
        "Ninh Thuận",
        "Phú Thọ",
        "Phú Yên",
        "Quảng Bình",
        "Quảng Nam",
        "Quảng Ngãi"
    ]
    let keychain = KeychainSwift()
    var userProfile : User?
    var userID: Int?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        createDatePicker()
        dropDownHandle(texfield: genderTF, inputArray: gender)
        dropDownHandle(texfield: birthAddressTF, inputArray: provinces)
        dropDownHandle(texfield: currentAddressTF, inputArray: provinces)
        getUserProfile()
    }
    func setupView(){
        standardViewCornerRadius(uiView: userNameBoxView)
        standardViewCornerRadius(uiView: userNameBoxView)
        standardViewCornerRadius(uiView: userEmailBoxView)
        standardViewCornerRadius(uiView: genderBoxView)
        standardViewCornerRadius(uiView: dateOfBirthBoxView)
        standardViewCornerRadius(uiView: birthAddressBoxView)
        standardViewCornerRadius(uiView: currentAddressBoxView)
        standardBtnCornerRadius(button: saveBtn)
    }


    func getUserProfile(){
        showLoading(isShow: true)
        guard let userName = keychain.get("username") else {
            print("không có userName")
            return
        }
        let url = Constant.baseUrl + "profile/" + userName
        print("\(url)")
        AF.request(url, method: .get)
            .validate(statusCode: 200...299)
            .responseDecodable(of: User.self) { response in
                switch response.result {
                    // Xử lý dữ liệu nhận được từ phản hồi (response)
                case .success(let data):
                        self.userProfile = data
                    guard let user = self.userProfile?.users?.first else {
                            print("dữ liệu nil")
                            return
                        }
                    self.loadDataToView(user: user)
                    self.showLoading(isShow: false)
                case .failure(let error):
                    print("\(error.localizedDescription)")
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            let errorMessage = json["message"].stringValue
                            print(errorMessage)
                            self.showAlert(title: "Lỗi", message: errorMessage + "1")
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                            self.showAlert(title: "Lỗi", message: "Đã xảy ra lỗi, vui lòng thử lại sau.")
                        }
                    } else {
                        print("Không có dữ liệu từ server")
                        self.showAlert(title: "Lỗi", message: "Đã xảy ra lỗi, vui lòng thử lại sau.")
                    }
                    self.showLoading(isShow: false)
                }
            }
    }
    func loadDataToView(user: Users){
//        guard let user = user.users?.first else {
//            print("user nil")
//            return
//        }
        userNameLb.text = user.fullName
        userNameTF.text = user.fullName
        userEmailTF.text = user.email
        genderTF.text = user.gender
        dateOfBirthTF.text = user.birthDate
        phoneNumber.text = user.phone
        self.userID = user.userID
        print("self.userID : \(self.userID)")

    }
    func saveDataToServer() {
        guard let userName = keychain.get("username") else {
            print("không có userName")
            return
        }
        
        let subUrl = "profile/change_profile/" + "\(userID)"
        let parameters : [String:Any] = [
            "BirthDate": dateOfBirthTF.text ?? "",
            "BirthTime": dateOfBirthTF.text ?? "",
            "Email": userEmailTF.text ?? "",
            "FullName": userNameTF.text ?? "",
            "Gender": genderTF.text ?? "",
            "Phone": phoneNumber.text,
            "Username": userName,
            "ProvinceID": "1"
        ]

        APIService.share.apiHandle(method: .put ,subUrl: subUrl, parameters: parameters, data: User.self) { result in
            DispatchQueue.main.async {
                self.showLoading(isShow: false)
                switch result {
                case .success(let data):
                    self.showAlert(title: "Thông báo", message: "Đã cập nhật dữ liệu thành công")
                    self.showLoading(isShow: false)
                case .failure(let error):
                    switch error {
                    case .server(let message), .network(let message):
                        self.showAlert(title: "Lỗi", message: message)
                        print("\(message)")
                    }
                }
            }
        }
    }

    
    func dropDownHandle(texfield: DropDown, inputArray: [String]){
        texfield.optionArray = inputArray
        texfield.didSelect{(selectedText , index ,id) in
        }
    }


    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case pickDateBtn :
            dateOfBirthTF.becomeFirstResponder()
        case saveBtn:
            saveDataToServer()
            print("saved")
        default :
            break
        }
    }
}
extension ProfileViewController {
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        // thêm nút done
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtn))
        // thêm khoảng trống
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // thêm nút cancel
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBtn))
        //  cài đặt thứ tự nút
        toolbar.setItems([doneButton, flexibleSpace, cancelButton], animated: true)
        return toolbar
    }
    func createDatePicker() {
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        dateOfBirthTF.inputView = datePicker
        dateOfBirthTF.inputAccessoryView = createToolbar()
        print("createDatePicker")
    }
    @objc func doneBtn(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.dateOfBirthTF.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    @objc func cancelBtn() {
        self.view.endEditing(true)
    }
}

