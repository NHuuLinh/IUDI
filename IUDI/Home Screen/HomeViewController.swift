import UIKit
import SwiftyJSON
import CollectionViewPagingLayout
import Alamofire
import ReadMoreTextView

class HomeViewController: UIViewController{
    @IBOutlet weak var userCollectionView: UICollectionView!
    
    let dataImage = ["anh1","anh2","anh3","anh4","anh5"]
    var userDistance : UserDistances?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
        getNearUser()
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
    func getNearUser(){
        let apiService = APIService.share
        let url = "location/37/5000"
        print("url:\(url)")
        apiService.apiHandleGetRequest(subUrl: url,data: UserDistances.self) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.userDistance = data
                    self.userCollectionView.reloadData()
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

    @IBAction func profileBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension HomeViewController:UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        if let data = userDistance?.distances?[indexPath.item] {
            cell.blindata(data: data)
        }
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserIntroduceViewController") as! UserIntroduceViewController
        guard let data = userDistance?.distances?[indexPath.row] else {
            print("user nil")
            return
        }
        print("indexPath.row: \(indexPath.row)")
        let userID : Int = data.userID ?? 0
        let test = String(userID)
        print("userID: \(test)")
        vc.getAllImage(userID: String(userID))
        vc.blindata(data: data)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
