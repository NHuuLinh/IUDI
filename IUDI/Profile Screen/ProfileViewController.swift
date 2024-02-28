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
    @IBOutlet weak var genderTF: DropDown!
    @IBOutlet weak var dateOfBirthTF: UITextField!
    @IBOutlet weak var pickDateBtn: UIButton!
    @IBOutlet weak var birthAddressTF: DropDown!
    @IBOutlet weak var currentAddressTF: DropDown!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var birthAddressBtn: UIButton!
    @IBOutlet weak var currentAddressBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var userNameBoxView: UIView!
    @IBOutlet weak var userEmailBoxView: UIView!
    @IBOutlet weak var genderBoxView: UIView!
    @IBOutlet weak var dateOfBirthBoxView: UIView!
    @IBOutlet weak var birthAddressBoxView: UIView!
    @IBOutlet weak var currentAddressBoxView: UIView!
    @IBOutlet weak var phoneNumberBoxView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let datePicker = UIDatePicker()
    let keychain = KeychainSwift()
    var userProfile : User?
    var userID: Int?
    var imagePicker = UIImagePickerController()
    var hi:ImgModel = ImgModel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        createDatePicker()
        dropDownHandle(texfield: genderTF, inputArray: Constant.gender)
        dropDownHandle(texfield: birthAddressTF, inputArray: Constant.provinces)
        dropDownHandle(texfield: currentAddressTF, inputArray: Constant.provinces)
        getUserProfile()
        avatarImageTap()
        setupScrollView()

    }
    func dropDownHandle(texfield: DropDown, inputArray: [String]){
//        texfield.showList()
        texfield.arrowColor = UIColor .red
        texfield.selectedRowColor = UIColor .red
        texfield.optionArray = inputArray
//        texfield.didSelect{(selectedText , index ,id) in
//        }
        
    }
    func avatarImageTap(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userAvatar.isUserInteractionEnabled = true
        userAvatar.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
//        let tappedImage = tapGestureRecognizer.view as! UIImageView
        pickImage()
        print("pickImage")
    }
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    func uploadImageToServer(){
        let userImage:UIImage = userAvatar.image!
        let imageData:NSData = userImage.pngData()! as NSData
        let dataImage = imageData.base64EncodedString(options: .lineLength64Characters)
        let sonaParam = ["image":dataImage]
        APIServiceImage.shared.PostImageServer(param: imageData as Data){data, error in
            if let data = data{
                self.hi = data
                print("display_url : \(self.hi.display_url)")
                print("description : \(self.hi.description)")
                print("id : \(self.hi.id)")
                print("link : \(self.hi.link)")
                print("time : \(self.hi.time)")
                print("title : \(self.hi.title)")
                print("url : \(self.hi.url)")
                print("url_viewer : \(self.hi.url_viewer)")
                self.uploadImageToServer1(imageUrl: self.hi.display_url)
            }
        }
    }
    
    func uploadImageToServer1(imageUrl: String) {
        let parameters: [String: Any] = [
            "PhotoURL": imageUrl,
            "SetAsAvatar":false
        ]
        APIService.share.apiHandle(method:.post ,subUrl: "profile/add_image/37", parameters: parameters, data: UserData.self) { result in
                self.showLoading(isShow: false)
                switch result {
                case .success(let data):
                    print("data: \(data)")
                case .failure(let error):
                    print(error.localizedDescription)
                    switch error {
                    case .server(let message):
                        self.showAlert(title: "lỗi1", message: message)
                    case .network(let message):
                        self.showAlert(title: "lỗi", message: message)
                    }
                }
            }
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
        standardViewCornerRadius(uiView: phoneNumberBoxView)
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
        guard let userID = userID else {
            return
        }
        
        let subUrl = "profile/change_profile/" + "\(userID)"
        print("subUrl: \(subUrl)")
        
        let parameters : [String:Any] = [
            "BirthDate": dateOfBirthTF.text ?? "",
            "BirthTime": "00:00:00",
            "Email": userEmailTF.text ?? "",
            "FullName": userNameTF.text ?? "",
            "Gender": genderTF.text ?? "",
            "Phone": phoneNumber.text ?? "",
            "Username": userName,
            "ProvinceID": "24"
        ]
        
        print("parameters: \(parameters)")

        APIService.share.apiHandle(method: .put ,subUrl: subUrl, parameters: parameters, data: User.self) { result in
            DispatchQueue.main.async {
                self.showLoading(isShow: false)
                switch result {
                case .success(let data):
//                    self.uploadImageToServer()
                    self.uploadImageToServer()
                    self.showAlert(title: "Thông báo", message: "Đã cập nhật dữ liệu thành công")
                    self.showLoading(isShow: false)
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                    switch error {
                    case .server(let message), .network(let message):
                        self.showAlert(title: "Lỗi", message: message)
                        print("\(message)")
                    }
                }
            }
        }
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case pickDateBtn :
            dateOfBirthTF.becomeFirstResponder()
        case saveBtn:
            saveDataToServer()
        case genderBtn:
            genderTF.showList()
        case birthAddressBtn:
            birthAddressTF.showList()
        case currentAddressBtn:
            currentAddressTF.showList()
            print("saved")
        case backBtn:
            navigationController?.popToRootViewController(animated: true)
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
// MARK: - Load image slectecd
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        // Update the UI with the picked image
        
        userAvatar.image = pickedImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func pickImage() {
        let titleAlert = NSLocalizedString("Choose Image", comment: "")
        let messageAlert = NSLocalizedString("Choose your option", comment: ""
        )
        let alertViewController = UIAlertController(title: titleAlert,
                                                    message: messageAlert,
                                                    preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera",
                                   style: .default) { (_) in
            self.openCamera()
        }
        let galleryText = NSLocalizedString("Gallery", comment: "")
        let gallery = UIAlertAction(title: galleryText,
                                    style: .default) { (_) in
            self.openGallary()
        }
        let selectImageText = NSLocalizedString("Select Image", comment: "")
        let selectImage = UIAlertAction(title: selectImageText,
                                    style: .default) { (_) in
            self.gotoSelectImage()
        }
        let cancelText = NSLocalizedString("Cancel", comment: "")
        let cancel = UIAlertAction(title: cancelText, style: .cancel) { (_) in
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(selectImage)
        alertViewController.addAction(cancel)
        present(alertViewController, animated: true, completion: nil)
    }
    
    func gotoSelectImage(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(identifier: "SelectImageViewController") as? SelectImageViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
// MARK: - ScrollView khi chọn lịch
extension ProfileViewController {
    func setupScrollView(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 50
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}
// MARK: - Alert Choose image
extension ProfileViewController {
    fileprivate func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            /// Cho phép edit ảnh hay là không
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let errorText = NSLocalizedString("Error", comment: "")
            let errorMessage = NSLocalizedString("Divice not have camera", comment: "")
            
            let alertWarning = UIAlertController(title: errorText,
                                                 message: errorMessage,
                                                 preferredStyle: .alert)
            let cancelText = NSLocalizedString("Cancel", comment: "")
            let cancel = UIAlertAction(title: cancelText,
                                       style: .cancel) { (_) in
                print("Cancel")
            }
            alertWarning.addAction(cancel)
            self.present(alertWarning, animated: true, completion: nil)
        }
    }
    fileprivate func openGallary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .photoLibrary
            /// Cho phép edit ảnh hay là không
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        }
    }
}

