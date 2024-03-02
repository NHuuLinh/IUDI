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
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupCollectionView() {
        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        let layout = CollectionViewPagingLayout()
        layout.scrollDirection = .vertical
        layout.numberOfVisibleItems = nil
        userCollectionView.collectionViewLayout = layout
        userCollectionView.isPagingEnabled = true
        userCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
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

    @IBAction func profileBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension HomeViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        let imageName = dataImage[indexPath.row]
        cell.blindata(name: imageName)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserIntroduceViewController") as! UserIntroduceViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
