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
import Kingfisher
import ReadMoreTextView

protocol DataDelegate: AnyObject {
    func loadAvatarImage(url:String?)
}

class ProfileViewController: UIViewController,DataDelegate,DateConvertFormat {
    
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
    @IBOutlet weak var userIntroduct: UITextView!
    @IBOutlet weak var userIntroductLb: UILabel!
    
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
    @IBOutlet weak var userIntroductBoxView: UIView!
    
    let datePicker = UIDatePicker()
    let keychain = KeychainSwift()
    var userProfile : User?
    var userID: Int?
    var imagePicker = UIImagePickerController()
    var hi:ImgModel = ImgModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        userIntroduct.delegate = self
        setupView()
        setupScrollView()
        createDatePicker()
        dropDownHandle(texfield: genderTF, inputArray: Constant.gender)
        dropDownHandle(texfield: birthAddressTF, inputArray: Constant.provinces)
        dropDownHandle(texfield: currentAddressTF, inputArray: Constant.provinces)
        getUserProfile()
        avatarImageTap()
        checkUserInfo()
    }
    
    func setupUserIntroduct(textView: ReadMoreTextView){
        textView.shouldTrim = true
        textView.maximumNumberOfLines = 2
        let readLessText = NSAttributedString(string: "Ẩn bớt", attributes: [NSAttributedString.Key.foregroundColor: Constant.mainBorderColor])
        textView.attributedReadLessText = readLessText
        let readMoreText = NSAttributedString(string: "... Xem thêm", attributes: [NSAttributedString.Key.foregroundColor: Constant.mainBorderColor])
        textView.attributedReadMoreText = readMoreText
    }
    func dropDownHandle(texfield: DropDown, inputArray: [String]){
        texfield.arrowColor = UIColor .red
        texfield.selectedRowColor = UIColor .red
        texfield.optionArray = inputArray
        texfield.inputView = UIView()
    }
    func avatarImageTap(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userAvatar.isUserInteractionEnabled = true
        userAvatar.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        checkUserInfo()
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
                self.uploadImageToServer1(imageUrl: self.hi.display_url)
            }
        }
    }
    
    func uploadImageToServer1(imageUrl: String) {
        let parameters: [String: Any] = [
            "PhotoURL": imageUrl,
            "SetAsAvatar":true
        ]
        guard let userID = keychain.get("userID") else {
            print("userID rỗng")
            return
        }
        let subUrl = "profile/add_image/" + userID
        APIService.share.apiHandle(method:.post ,subUrl: subUrl, parameters: parameters, data: UserData.self) { result in
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
        standardViewCornerRadius(uiView: userIntroductBoxView)
        userAvatar.layer.cornerRadius = userAvatar.frame.width/2
    }
    
    func getUserProfile(){
        showLoading(isShow: true)
        guard let userName = keychain.get("username") else {
            print("không có userName")
            return
        }
        let url = "profile/" + userName
        APIService.share.apiHandleGetRequest(subUrl: url, data: User.self) { result in
            switch result {
            case .success(let data):
                self.userProfile = data
                guard let user = self.userProfile?.users?.first else {
                    print("dữ liệu nil")
                    return
                }
                self.loadDataToView(user: user)
                self.showLoading(isShow: false)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                self.showLoading(isShow: false)
                switch error{
                case .server(let message):
                    self.showAlert(title: "lỗi", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi", message: message)
                }
            }
        }
    }
    
    func loadAvatarImage(url:String?) {
        print("loadAvatarImage1: \(url)")
        guard let urlString = url, let imageUrl = URL(string: urlString) else {
            return
        }
        userAvatar.kf.setImage(with: imageUrl, placeholder: UIImage(systemName: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                // Ảnh đã tải thành công
                break
            case .failure(let error):
                // Xảy ra lỗi khi tải ảnh
                self.userAvatar?.image = UIImage(systemName: "person")
            }
        })
    }
    
    func loadDataToView(user: Users){
        userNameLb.text = user.fullName
        userNameTF.text = user.fullName
        userEmailTF.text = user.email
        genderTF.text = user.gender
        dateOfBirthTF.text = user.birthDate
        phoneNumber.text = user.phone
        if user.birthDate?.count ?? 0 < 1 {
            birthAddressTF.text = "Hà Nội"
        } else {
            birthAddressTF.text = user.birthPlace
        }
        if user.currentAdd?.count ?? 0 < 1 {
            currentAddressTF.text = "Hà Nội"
        } else {
            currentAddressTF.text = user.currentAdd
        }
        userIntroduct.text = user.bio
        userIntroductLb.text = userIntroduct.text
        self.userID = user.userID
        let url = user.avatarLink
        loadAvatarImage(url: url)
    }
    func changeAvatar(){
        struct SetAvatar: Codable {
            let photoID: String?
            let setAsAvatar: Bool?
            let userID: String?
            
            enum CodingKeys: String, CodingKey {
                case photoID = "PhotoID"
                case setAsAvatar = "SetAsAvatar"
                case userID = "UserID"
            }
        }
        guard let photoID = UserDefaults.standard.string(forKey: "photoID"), let userID = UserDefaults.standard.string(forKey: "UserID")  else {
            print("user image không có ID")
            return
        }
        let subUrl = "profile/setAvatar/" + "\(userID)"
        print("subUrl: \(subUrl)")
        
        let parameters : [String:Any] = [
            "PhotoID":photoID,
            "SetAsAvatar":true
        ]
        print("parameters: \(parameters)")
        APIService.share.apiHandle(method: .patch ,subUrl: subUrl, parameters: parameters, data: SetAvatar.self) { result in
            switch result {
            case .success(let data):
                print("success")
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
    
    func saveDataToServer() {
        guard let userName = keychain.get("username") else {
            print("không có userName")
            return
        }
        guard let userID = userID else {
            return
        }
        let subUrl = "profile/change_profile/" + "\(userID)"
        let parameters : [String:Any] = [
            "BirthDate": dateOfBirthTF.text ?? "",
            "BirthTime": "00:00:00",
            "Email": userEmailTF.text ?? "",
            "FullName": userNameTF.text ?? "",
            "Gender": genderTF.text ?? "",
            "Phone": phoneNumber.text ?? "",
            "Bio": userIntroduct.text ?? "",
            "BirthPlace": birthAddressTF.text ?? "",
            "CurrentAdd": currentAddressTF.text ?? "",
            "Username": userName,
            "ProvinceID": "24"
        ]
        
        APIService.share.apiHandle(method: .put ,subUrl: subUrl, parameters: parameters, data: User.self) { result in
            DispatchQueue.main.async {
                self.showLoading(isShow: false)
                switch result {
                case .success(_):
                    if UserDefaults.standard.willUploadImage {
                        print("uploadImageToServer")
                        self.uploadImageToServer()
                    } else {
                        print("changeAvatar")
                        self.changeAvatar()
                    }
                    self.showLoading(isShow: false)
                    if UserDefaults.standard.didOnMain {
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        UserDefaults.standard.didOnMain = true
                        AppDelegate.scene?.setupTabBar()
                    }
                    self.navigationController?.popToRootViewController(animated: true)
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
            showAlertAndAction(title: "Cảnh báo", message: "Bạn có muốn cập nhật thay đổi không ?",completionHandler: saveDataToServer) {
                print("saved")
            }
        case genderBtn:
            genderTF.showList()
        case birthAddressBtn:
            birthAddressTF.showList()
        case currentAddressBtn:
            currentAddressTF.showList()
            print("saved")
        case backBtn:
            navigationController?.popToRootViewController(animated: true)
            self.tabBarController?.tabBar.isHidden = false
        default :
            break
        }
    }
    @IBAction func userInfoDidChanged(_ sender: UITextField) {
        checkUserInfo()
    }
    func checkUserInfo() {
        guard let userBio = userIntroduct.text,
              let userName = userNameTF.text,
              let userEmail = userEmailTF.text,
              let userBirthDate = dateOfBirthTF.text,
              let userPhoneNumber = phoneNumber.text else {
            return
        }
        // Kiểm tra nếu bất kỳ giá trị nào là rỗng, nếu có, thoát khỏi hàm
        guard !userName.isEmpty, !userBio.isEmpty, !userEmail.isEmpty, !userBirthDate.isEmpty, !userPhoneNumber.isEmpty else {
            saveBtn.layer.opacity = 0.5
            saveBtn.isEnabled = false
            return
        }
        // Nếu tất cả các giá trị đều không rỗng, cập nhật trạng thái của nút lưu
        saveBtn.layer.opacity = 1
        saveBtn.isEnabled = true
    }
}
extension ProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Kiểm tra nếu UITextView không rỗng
        if let text = textView.text, !text.isEmpty {
            // Nếu có nội dung, kích hoạt nút lưu
            checkUserInfo()
        } else {
            // Nếu không có nội dung, vô hiệu hóa nút lưu
            checkUserInfo()
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
        let birthDate = convertDate(date: dateFormatter.string(from: datePicker.date), inputFormat: "dd MM yyyy", outputFormat: "yyyy-MM-dd")
        self.dateOfBirthTF.text = birthDate
        self.view.endEditing(true)
        self.checkUserInfo()
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
            UserDefaults.standard.willUploadImage = true
            self.openCamera()
        }
        let galleryText = NSLocalizedString("Gallery", comment: "")
        let gallery = UIAlertAction(title: galleryText,
                                    style: .default) { (_) in
            UserDefaults.standard.willUploadImage = true
            self.openGallary()
        }
        let selectImageText = NSLocalizedString("Select Image", comment: "")
        let selectImage = UIAlertAction(title: selectImageText,
                                        style: .default) { (_) in
            UserDefaults.standard.willUploadImage = false
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
    func sendDataBack(data: String) {
        print("Data received:  \(data)")
    }
    func gotoSelectImage(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(identifier: "SelectImageViewController") as? SelectImageViewController {
            viewController.delegate = self
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

