//
//  SelectImageViewController.swift
//  IUDI
//
//  Created by LinhMAC on 28/02/2024.
//

import UIKit

class SelectImageViewController: UIViewController {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    let screenSize = UIScreen.main.bounds.width/10
    override func viewDidLoad() {
        
        super.viewDidLoad()
        registerCollectionView()
        setupCollectionView()
        print("screenWidth : \(screenSize)")

        // Do any additional setup after loading the view.
    }
    private func setupCollectionView() {
        if let flowLayout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.scrollDirection = .vertical
        }
    }
    func registerCollectionView(){
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        let cell = UINib(nibName: "SelectImageCollectionViewCell", bundle: nil)
        imageCollectionView.register(cell, forCellWithReuseIdentifier: "SelectImageCollectionViewCell")
    }
    


}
extension SelectImageViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectImageCollectionViewCell", for: indexPath) as! SelectImageCollectionViewCell
        cell.blinData(userImageUrl: "", width: screenSize)
        return cell
        
    }
    
}
