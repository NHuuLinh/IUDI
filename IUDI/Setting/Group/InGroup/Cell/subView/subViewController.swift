//
//  subViewController.swift
//  IUDI
//
//  Created by Quoc on 08/03/2024.
//

import UIKit
import Alamofire

protocol FilterSettingDelegate: AnyObject{
        func getNear()
}

class subViewController: UIViewController {
    
    var didSelectItem: (() -> Void)?
    var deleteCompletion: (() -> Void)?
    var postId: Int?
    
    @IBOutlet weak var hiddenPost: UIButton!
    @IBOutlet weak var deletePost: UIButton!
    
    weak var delegate : FilterSettingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func deletePostTapper(_ sender: Any) {
        deleteData()
    }
    
    @IBAction func hiddenPostTapper(_ sender: Any) {
    }
    
    func deleteData(){
        guard let postId = postId else {
            print("khoong co post id")
            return
        }
        
        let deleteURL = "https://api.iudi.xyz/api/forum/delete_post/\(postId)"
        
        AF.request(deleteURL, method: .delete).validate(statusCode: 200...299).responseDecodable(of: GroupDataPosts.self){response
            in
            switch response.result {
            case .success:
                // Xóa bài đăng thành công
                // Có thể cập nhật giao diện hoặc thực hiện hành động khác sau khi xóa
                print("Bài đăng đã được xóa thành công")
                self.deleteCompletion?()
                // Gọi closure để thông báo cho controller biết rằng một bài đăng đã được xóa
                self.didSelectItem?()
                
            case .failure(let error):
                // Xảy ra lỗi khi xóa bài đăng
                print("Lỗi khi xóa bài đăng: \(error.localizedDescription)")
            }
        }
    }
}
