import UIKit
import SwiftyJSON
import CollectionViewPagingLayout
import Alamofire
import ReadMoreTextView

class HomeViewController: UIViewController{
    @IBOutlet weak var userCollectionView: UICollectionView!
    var userDistance = [Distance]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getNearUser()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
    }
    private func setupCollectionView() {
        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        userCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        let layout = CollectionViewPagingLayout()
        layout.scrollDirection = .vertical
        layout.numberOfVisibleItems = nil
        userCollectionView.collectionViewLayout = layout
        userCollectionView.isPagingEnabled = true
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
        let coreData = FilterUserCoreData.share
        let filterGender = coreData.getUserFilterValueFromCoreData(key: "gender") as! String
        
        let coreDataMinAge = coreData.getUserFilterValueFromCoreData(key: "minAge") as! Int
        let filterMinAge = Int(Constant.currentYear) - coreDataMinAge
        
        let coreDataMaxAge = coreData.getUserFilterValueFromCoreData(key: "maxAge") as! Int
        let filterMaxAge = Int(Constant.currentYear) - coreDataMaxAge
        
        let coreDataMaxDistance = coreData.getUserFilterValueFromCoreData(key: "maxDistance") as! Double
        let filterMaxDistance = coreDataMaxDistance * 1000
        
        let coreDataMinDistance = coreData.getUserFilterValueFromCoreData(key: "minDistance") as! Double
        let filterMinDistance = coreDataMinDistance * 1000
        
        let filterAddress = coreData.getUserFilterValueFromCoreData(key: "currentAddress") as! String
        
        print("filterValue: \(filterGender.count),\(filterMinAge),\(filterMaxAge),\(filterMaxDistance),\(filterMinDistance),\(filterAddress.count)")
        
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
                return (filterMaxAge...filterMinAge).contains(birthYear) && currentAdd == filterAddress && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            } else if filterGender.count > 1 && filterAddress.count < 1 {
                print("no Address")
                print("filterValue: \(filterGender.count),\(filterMinAge),\(filterMaxAge),\(filterMaxDistance),\(filterMinDistance),\(filterAddress.count)")
                return gender == filterGender && (filterMaxAge...filterMinAge).contains(birthYear) && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            } else if filterGender.count < 1 && filterAddress.count < 1 {
                print("no gender, no Address")
                return (filterMaxAge...filterMinAge).contains(birthYear) && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            }else {
                print("full")
                return gender == filterGender && (filterMaxAge...filterMinAge).contains(birthYear) && currentAdd == filterAddress && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            }
            //                        return gender == "Nam" && (0...2024).contains(birthYear) && currentAdd == "" && (100...30000).contains(distanceInMeters)
        }
    }
    
    func getNearUser(){
        showLoading(isShow: true)
        let apiService = APIService.share
        let url = "location/37/3000"
        print("url:\(url)")
        apiService.apiHandleGetRequest(subUrl: url,data: UserDistances.self) { result in
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
                    self.setupCollectionView()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
