//
//import UIKit
//import CoreLocation
//import Alamofire
//
//extension UIViewController: CLLocationManagerDelegate {
//
//
//    func getLocationByAPI1(){
//        struct Location: Codable {
//            let lat, lon: Double
//            let city: String
//        }
//        showLoading(isShow: true)
//        let url = "http://ip-api.com/json"
//        AF.request(url).validate().responseDecodable(of: Location.self) { response in
//            switch response.result {
//            case .success(let location):
//
//                self.showLoading(isShow: false)
//            case .failure(let error):
//                print("Error: \(error.localizedDescription)")
//                self.showLoading(isShow: false)
//                self.showAlert(title: "Lỗi", message: error.localizedDescription)
//            }
//        }
//    }
//
//    func fetchCurrentLocation() {
//        let locationManager = CLLocationManager()
//
//        showLoading(isShow: true)
//        // check xem có đia điểm hiện tại không,nếu không thì không làm gì cả
//        guard let currentLocation = locationManager.location else {
//            print("Current location not available.")
//            return
//        }
//        let geocoder = CLGeocoder()
//        // lấy placemark
//        geocoder.reverseGeocodeLocation(currentLocation) { [weak self] (placemarks, error) in
//            if let error = error {
//                print("Reverse geocoding failed: \(error.localizedDescription)")
//                return
//            }
//            let currentLongitude = currentLocation.coordinate.longitude
//            let currentLatitude = currentLocation.coordinate.latitude
//            self?.longitude = String(Int(currentLongitude))
//            self?.latitude = String(Int(currentLatitude))
//            self?.showLoading(isShow: false)
//        }
//    }
//
//    func requestLocation() {
//        let locationManager = CLLocationManager()
//
//        print("requestLocation")
//        // đưa nó vào một luồng khác để tránh làm màn hình người dùng đơ
//        DispatchQueue.global().async {
//            if CLLocationManager.locationServicesEnabled() {
//                // khai báo delegate để nhận thông tin thay đổi trạng thái vị trí
//                locationManager.delegate = self
//                // yêu cầu độ chính xác khi dò vi trí
//                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//                // update vị trí cho các hàm của CLLocationManager
//                locationManager.startUpdatingLocation()
//            }
//        }
//    }
//
//    func checkLocationAuthorizationStatus() {
//        let locationManager = CLLocationManager()
//
//        switch locationManager.authorizationStatus {
//        case .notDetermined:
//            // Yêu cầu quyền sử dụng vị trí khi ứng dụng đang được sử dụng
//            locationManager.requestWhenInUseAuthorization()
//        case .restricted, .denied:
//            getLocationByAPI()
//            break
//        case .authorizedWhenInUse, .authorizedAlways:
//            // Bắt đầu cập nhật vị trí và gọi api nếu được cấp quyền
//            locationManager.startUpdatingLocation()
//            fetchCurrentLocation()
//        @unknown default:
//            break
//        }
//    }
//    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        // Kiểm tra lại trạng thái ủy quyền khi nó thay đổi
//        checkLocationAuthorizationStatus()
//    }
//}
