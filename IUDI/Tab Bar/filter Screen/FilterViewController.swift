
import UIKit

class FilterViewController: UIViewController,FilterSettingDelegate {

    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var subviewLocation: NSLayoutConstraint!
    @IBOutlet weak var hideSubViewBtn: UIButton!
    
    private var isMenuOpen = false
    let itemNumber = 4.0
    let minimumLineSpacing = 10.0
    var userDistance = [Distance]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        registerCollectionView()
        getNearUser()
        subviewHandle()
        getNearUser()
    }
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case filterBtn:
            displayMenu()
        case hideSubViewBtn:
            displayMenu()
            print("display")
        default :
            break
        }
    }
    // display menu
    private func displayMenu() {
        isMenuOpen.toggle()
        hideSubViewBtn.isHidden = !isMenuOpen
        UIView.animate(withDuration: 0.5, animations: {
            self.hideSubViewBtn.alpha = self.isMenuOpen ? 0.5 : 0
            self.subviewLocation.constant = self.isMenuOpen ? 0 : -550
            self.view.layoutIfNeeded()
        })
        self.tabBarController?.tabBar.isHidden = self.isMenuOpen
    }
    func subviewHandle(){
        let childVC = FilterSettingUIViewController()
        addChild(childVC)
        subView.addSubview(childVC.view)
        childVC.view.frame = subView.bounds
        childVC.didMove(toParent: self)
        childVC.delegate = self
        subviewLocation.constant = -550
        hideSubViewBtn.isHidden = true
    }
    private func setupCollectionView() {
        if let flowLayout = filterCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = minimumLineSpacing
            flowLayout.minimumInteritemSpacing = minimumLineSpacing
            flowLayout.itemSize.width = filterCollectionView.frame.size.width
        }
    }
    
    func registerCollectionView(){
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        let cell = UINib(nibName: "FilterCell", bundle: nil)
        filterCollectionView.register(cell, forCellWithReuseIdentifier: "FilterCell")
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

            if filterGender.count < 2 && filterAddress.count > 2{
                print("no gender")
                return (filterMaxAge...filterMinAge).contains(birthYear) && currentAdd == filterAddress && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            } else if filterGender.count > 2 && filterAddress.count < 2 {
                print("no Address")
                print("filterValue: \(filterGender.count),\(filterMinAge),\(filterMaxAge),\(filterMaxDistance),\(filterMinDistance),\(filterAddress.count)")
                return gender == filterGender && (filterMaxAge...filterMinAge).contains(birthYear) && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            } else if filterGender.count < 2 && filterAddress.count < 2 {
                print("no gender, no Address")
                return (filterMaxAge...filterMinAge).contains(birthYear) && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            }else {
                print("full")
                return gender == filterGender && (filterMaxAge...filterMinAge).contains(birthYear) && currentAdd == filterAddress && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            }
//                        return gender == "Nam" && (0...2024).contains(birthYear) && currentAdd == "" && (100...30000).contains(distanceInMeters)
        }
    }
    struct FilterCriteria {
        let gender: String?
        let birthYearRange: ClosedRange<Int>?
        let currentAdd: String?
        let distanceRange: ClosedRange<Double>?
    }

    func filterDistances(_ distances: [Distance], with criteria: FilterCriteria) -> [Distance] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return distances.filter { distance in
            if let gender = criteria.gender, distance.gender != gender {
                return false
            }

            if let birthYearRange = criteria.birthYearRange,
               let birthDateStr = distance.birthDate,
               let birthDate = dateFormatter.date(from: birthDateStr),
               let birthYear = Calendar.current.dateComponents([.year], from: birthDate).year,
               !birthYearRange.contains(birthYear) {
                return false
            }

            if let currentAdd = criteria.currentAdd, distance.currentAdd != currentAdd {
                return false
            }

            if let distanceRange = criteria.distanceRange, !distanceRange.contains(distance.distance ?? 0) {
                return false
            }

            return true
        }
    }


    func getNearUser(){
        let apiService = APIService.share
        let url = "location/37/30000"
        print("url:\(url)")
        apiService.apiHandleGetRequest(subUrl: url,data: UserDistances.self) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    guard let distanceData = data.distances else {
                        return
                    }
                    // Sử dụng hàm `filterDistances(_:with:)` để lọc mảng `distances`
                    let filterData = self.filterDistances(distanceData)
                    self.userDistance = filterData

//                    print("userDistance: \(self.userDistance)")
//                    print("filterData: \(filterData)")
                    self.filterCollectionView.reloadData()
                }
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                switch error{
                case .server(let message):
                    self.showAlert(title: "lỗi", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi", message: message)
                }
            }
        }
    }


}

extension FilterViewController : UICollectionViewDataSource, UICollectionViewDelegate,CellSizeCaculate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return userDistance?.distances?.count ?? 4
        return userDistance.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        let data = userDistance[indexPath.row]
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
