
import UIKit

class FilterViewController: UIViewController {

    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var subviewLocation: NSLayoutConstraint!
    
    let itemNumber = 4.0
    let minimumLineSpacing = 10.0
    var userDistance : UserDistances?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ádasdasda")
        setupCollectionView()
        registerCollectionView()
        getNearUser()
        subviewHandle()
    }
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case filterBtn:
            checkBoxHandle()
        default :
            break
        }
    }
    
    func checkBoxHandle(){
        filterBtn.isSelected = !filterBtn.isSelected
        UIView.animate(withDuration: 1, animations: {
            self.subviewLocation.constant = self.filterBtn.isSelected ? 0 : -550
            self.view.layoutIfNeeded()
        })
    }

    func subviewHandle(){
        let childVC = FilterSettingUIViewController()
        addChild(childVC)
        subView.addSubview(childVC.view)
        childVC.view.frame = subView.bounds
        childVC.didMove(toParent: self)
        subviewLocation.constant = -550
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
    func getNearUser(){
        let apiService = APIService.share
        let url = "location/37/30000"
        print("url:\(url)")
        apiService.apiHandleGetRequest(subUrl: url,data: UserDistances.self) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.userDistance = data
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
        return 4

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        if let data = userDistance?.distances?[indexPath.item] {
            cell.blindata(data: data)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("user select :\(indexPath.row)")

    }

}
