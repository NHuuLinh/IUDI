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
    static let gender: [String] = ["Nam", "Nữ", "Đồng tính nam", "Đồng tính nữ",""]
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
}
