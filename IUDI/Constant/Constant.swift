//
//  c.swift
//  IUDI
//
//  Created by LinhMAC on 22/02/2024.
//

import Foundation
import UIKit

class Constant{
    let currentDate = Date()
    static let currentYear = Calendar.current.component(.year, from: Date())

    static let baseUrl = "https://api.iudi.xyz/api/"
    static let cornerRadius = 10.0
    static let borderWidth = 1.5
    static let mainColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00)
    
    static let mainBorderColor = UIColor(red: 0.08, green: 0.57, blue: 0.34, alpha: 1.00)
    static let gender: [String] = ["Nam", "Nữ", "Đồng tính nam", "Đồng tính nữ"]
    static let filterGender: [String] = ["Nam", "Nữ", "Đồng tính nam", "Đồng tính nữ",""]
    static let filterProvinces: [String] = [
        "",
        "Hà Nội",
        "Hồ Chí Minh",
        "Hải Phòng",
        "Đà Nẵng",
        "Cần Thơ",
        "Hải Dương",
        "Hà Nam",
        "Hà Tĩnh",
        "Hòa Bình",
        "Hưng Yên",
        "Thanh Hóa",
        "Nghệ An",
        "Hà Tây",
        "Thái Bình",
        "Thái Nguyên",
        "Lai Châu",
        "Lào Cai",
        "Lạng Sơn",
        "Nam Định",
        "Ninh Bình",
        "Sơn La",
        "Tây Ninh",
        "Đồng Tháp",
        "Bắc Giang",
        "Bắc Kạn",
        "Bạc Liêu",
        "Bắc Ninh",
        "Bến Tre",
        "Bình Định",
        "Bình Dương",
        "Bình Phước",
        "Bình Thuận",
        "Cà Mau",
        "Đắk Lắk",
        "Đắk Nông",
        "Điện Biên",
        "Đồng Nai",
        "Đồng Nai",
        "Gia Lai",
        "Hà Giang",
        "Hà Giang",
        "Hà Nam",
        "Hà Tĩnh",
        "Hải Dương",
        "Hậu Giang",
        "Hoà Bình",
        "Hưng Yên",
        "Khánh Hòa",
        "Kiên Giang",
        "Kon Tum",
        "Lai Châu",
        "Lâm Đồng",
        "Lạng Sơn",
        "Lào Cai",
        "Long An",
        "Nam Định",
        "Nghệ An",
        "Ninh Bình",
        "Ninh Thuận",
        "Phú Thọ",
        "Phú Yên",
        "Quảng Bình",
        "Quảng Nam",
        "Quảng Ngãi"
    ]
    static let provinces: [String] = [
        "",
        "Hà Nội",
        "Hồ Chí Minh",
        "Hải Phòng",
        "Đà Nẵng",
        "Cần Thơ",
        "Hải Dương",
        "Hà Nam",
        "Hà Tĩnh",
        "Hòa Bình",
        "Hưng Yên",
        "Thanh Hóa",
        "Nghệ An",
        "Hà Tây",
        "Thái Bình",
        "Thái Nguyên",
        "Lai Châu",
        "Lào Cai",
        "Lạng Sơn",
        "Nam Định",
        "Ninh Bình",
        "Sơn La",
        "Tây Ninh",
        "Đồng Tháp",
        "Bắc Giang",
        "Bắc Kạn",
        "Bạc Liêu",
        "Bắc Ninh",
        "Bến Tre",
        "Bình Định",
        "Bình Dương",
        "Bình Phước",
        "Bình Thuận",
        "Cà Mau",
        "Đắk Lắk",
        "Đắk Nông",
        "Điện Biên",
        "Đồng Nai",
        "Đồng Nai",
        "Gia Lai",
        "Hà Giang",
        "Hà Giang",
        "Hà Nam",
        "Hà Tĩnh",
        "Hải Dương",
        "Hậu Giang",
        "Hoà Bình",
        "Hưng Yên",
        "Khánh Hòa",
        "Kiên Giang",
        "Kon Tum",
        "Lai Châu",
        "Lâm Đồng",
        "Lạng Sơn",
        "Lào Cai",
        "Long An",
        "Nam Định",
        "Nghệ An",
        "Ninh Bình",
        "Ninh Thuận",
        "Phú Thọ",
        "Phú Yên",
        "Quảng Bình",
        "Quảng Nam",
        "Quảng Ngãi"
    ]
    static let maleAvatar = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS9Zde21fi2AnY9_C17tqYi8DO25lRM_yAa7Q&usqp=CAU&fbclid=IwAR16g1ONptpUiKuDIt37LRxU3FTZck1cv9HDywe9VWxWSQBwcuGNfB7JUw4"
    static let femaleAvatar = "https://media.istockphoto.com/id/950861780/vi/vec-to/avatar-n%E1%BB%AF-kh%C3%B4ng-c%C3%B3-khu%C3%B4n-m%E1%BA%B7t-vector-ph%E1%BA%B3ng-minh-h%E1%BB%8Da.jpg?s=612x612&w=0&k=20&c=R0-mkw8PSn8EXscWUPW8Q_zMYNBtW2e1qyOVhaVkh4I%3D&fbclid=IwAR29rkioK4DFIpRGAfcFwnqlOu8yeJuWVl142GfaisHa6XF9hWmRvgLwMdI"
}
