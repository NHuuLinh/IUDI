import UIKit
import SwiftyJSON
import CollectionViewPagingLayout
import Alamofire
import ReadMoreTextView
import KeychainSwift

class HomeViewController: UIViewController{
    @IBOutlet weak var userCollectionView: UICollectionView!
    var userDistance = [Distance]()
    var stackTransformOptions = StackTransformViewOptions()
    var keychain = KeychainSwift()
    let coreData = FilterUserCoreData.share
    let coreDataMaxDistance = (FilterUserCoreData.share.getUserFilterValueFromCoreData(key: "maxDistance") as? Double ?? 30) * 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        getNearUser()
        setupCollectionView()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    func setupView(){
        userCollectionView.layer.cornerRadius = 32
        userCollectionView.clipsToBounds = true
        userCollectionView.layer.masksToBounds = true
        userCollectionView.layer.shadowColor = UIColor.black.cgColor
        userCollectionView.layer.shadowOpacity = 1
        userCollectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        userCollectionView.layer.shadowRadius = 4
    }
    func filterDistances(_ distances: [Distance]) -> [Distance] {
        let filterGender = coreData.getUserFilterValueFromCoreData(key: "gender") as? String ?? ""
        
        let coreDataMinAge = coreData.getUserFilterValueFromCoreData(key: "minAge") as? Int ?? 18
        let filterMinAge = Int(Constant.currentYear) - coreDataMinAge
        
        let coreDataMaxAge = coreData.getUserFilterValueFromCoreData(key: "maxAge") as? Int ?? 70
        let filterMaxAge = Int(Constant.currentYear) - coreDataMaxAge
        
//        let coreDataMaxDistance = coreData.getUserFilterValueFromCoreData(key: "maxDistance") as? Double ?? 30
//        let filterMaxDistance = coreDataMaxDistance * 1000
        
        let coreDataMinDistance = coreData.getUserFilterValueFromCoreData(key: "minDistance") as? Double ?? 0
        let filterMinDistance = coreDataMinDistance * 1000
        
        let filterAddress = coreData.getUserFilterValueFromCoreData(key: "currentAddress") as? String ?? ""
        
        return distances.filter { distance in
            guard let gender = distance.gender,
                  let birthDateStr = distance.birthDate,
                  let currentAdd = distance.currentAdd else {
                return false
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let birthDate = dateFormatter.date(from: birthDateStr),
                  let birthYear = Calendar.current.dateComponents([.year], from: birthDate).year else {
                return false
            }
            let distanceInMeters = distance.distance ?? 0.0
            
            if filterGender.count < 1 && filterAddress.count > 1{
                print("no gender")
                return (filterMaxAge...filterMinAge).contains(birthYear) && currentAdd == filterAddress && (filterMinDistance...coreDataMaxDistance).contains(distanceInMeters)
            } else if filterGender.count > 1 && filterAddress.count < 1 {
                print("no Address")
                return gender == filterGender && (filterMaxAge...filterMinAge).contains(birthYear) && (filterMinDistance...coreDataMaxDistance).contains(distanceInMeters)
            } else if filterGender.count < 1 && filterAddress.count < 1 {
                print("no gender, no Address")
                return (filterMaxAge...filterMinAge).contains(birthYear) && (filterMinDistance...coreDataMaxDistance).contains(distanceInMeters)
            }else {
                print("full")
                return gender == filterGender && (filterMaxAge...filterMinAge).contains(birthYear) && currentAdd == filterAddress && (filterMinDistance...coreDataMaxDistance).contains(distanceInMeters)
            }
        }
    }
    
    func getNearUser(){
        guard let userID = keychain.get("userID") else {
            print("userID Nil")
            return
        }
        showLoading(isShow: true)
        let apiService = APIService.share
        let subUrl = "location/\(userID)/\(String(Int(coreDataMaxDistance)))"
        print("url:\(subUrl)")
        apiService.apiHandleGetRequest(subUrl: subUrl,data: UserDistances.self) { result in
            switch result {
            case .success(let data):
                guard let distanceData = data.distances else {
                    self.showLoading(isShow: false)
                    return
                }
                // Sử dụng hàm `filterDistances(_:with:)` để lọc mảng `distances`
                let filterData = self.filterDistances(distanceData)
                self.userDistance = filterData
                DispatchQueue.main.async {
                    self.userCollectionView.reloadData()
                }
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
    
    @IBAction func profileBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension HomeViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        userCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        let layout = CollectionViewPagingLayout()
        layout.scrollDirection = .vertical
        layout.numberOfVisibleItems = nil
        userCollectionView.collectionViewLayout = layout
        userCollectionView.isPagingEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("userDistance.count:\(userDistance.count)")
        return userDistance.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        let data = userDistance[indexPath.item]
        cell.blindata(data: data)
        return cell
    }
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "UserIntroduceViewController") as! UserIntroduceViewController
            let data = userDistance[indexPath.row]
            print("indexPath.row: \(indexPath.row)")
            let userID : Int = data.userID ?? 0
            let test = String(userID)
            print("userID: \(test)")
            vc.getAllImage(userID: String(userID))
            vc.blindata(data: data)
            navigationController?.pushViewController(vc, animated: true)
        }
    
}
    
