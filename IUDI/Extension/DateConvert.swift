//
//  DateConvert.swift
//  IUDI
//
//  Created by LinhMAC on 02/03/2024.
//

import Foundation
import UIKit

protocol DateConvertFormat {
    func convertDate(date: String, inputFormat: String, outputFormat: String) -> String
    func convertDate24h(date: String, inputFormat: String, outputFormat: String) -> String
    func hourToMinutes(hours: String) -> (Float)
    func hourToAngle(riseHours: String ,setHours: String, currentHours: String) -> (CGFloat)
}
extension DateConvertFormat {
    
    func convertDate(date: String, inputFormat: String, outputFormat: String) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = inputFormat
        if let inputDate = dateFormatter.date(from: date) {
            // Định dạng thời gian đầu ra
            dateFormatter.dateFormat = outputFormat
            // Chuyển đổi thành chuỗi
            let formattedDateString = dateFormatter.string(from: inputDate)
            return formattedDateString
        } else {
            return "date error"
        }
    }
    
    func convertDate24h(date: String, inputFormat: String, outputFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Set locale here
        dateFormatter.dateFormat = inputFormat
        if let inputDate = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = outputFormat
            let formattedDateString = dateFormatter.string(from: inputDate)
            return formattedDateString
        } else {
            return "date error"
        }
    }
    
    func hourToMinutes(hours: String) -> (Float){
        let hourToMinuest = (Float(convertDate(date: hours, inputFormat: "HH:mm", outputFormat: "HH")) ?? 0)*60
        let minutes = (Float(convertDate(date: hours, inputFormat: "HH:mm", outputFormat: "mm")) ?? 0)
        let minutesValue = hourToMinuest + minutes
        return minutesValue
    }
    
    func hourToAngle(riseHours: String ,setHours: String, currentHours: String) -> (CGFloat){
        let startHour = hourToMinutes(hours: riseHours)
        let endHour = hourToMinutes(hours: setHours)
        let currentHour = hourToMinutes(hours: currentHours)
        // + giá trị 24h khi thời gian kết thúc chu kì là ngày hôm sau
        var endValue: Float = 1
        if endHour < startHour {
            endValue = endHour + 24*60
        } else {
            endValue = endHour
        }
        
        
        var currentValue: Float = 1
        if currentHour < startHour {
            currentValue = currentHour + 24*60
        } else {
            currentValue = currentHour
        }
        
        let bottomVaule = endValue - startHour + 1
        let headValue = currentValue-startHour + 1
        
        let currentValuePercen = headValue/bottomVaule
        // tham khảo tài liệu về đường tròn https://vi.wikipedia.org/wiki/Đường_tròn_đơn_vị#/media/Tập_tin:Unit_circle_angles.svg
        // trong trường hợp giờ hiện tại lớn hơn giờ chu kì kết thúc, góc sẽ bằng 0 rad- góc bên phải màn hình
        var anggle: CGFloat = 0

        if endValue < currentValue {
             anggle = 1
        } else if startHour > currentValue {
            // trong trường hợp giờ hiện tại lớn hơn giờ chu kì kết thúc, góc sẽ bằng 1 rad - góc bên trái màn hình
             anggle = 0
        } else {
            anggle = CGFloat(1 - currentValuePercen)
        }
        return (CGFloat)(anggle)
    }
}
/*
kiểu dữ liệu thời gian  `dateFormat`:
 
 - **yyyy**: Năm bao gồm cả thế kỷ. Ví dụ: 2023
 - **yy**: Năm không bao gồm thế kỷ. Ví dụ: 23
 - **MM**: Tháng trong năm. Ví dụ: 07
 - **dd**: Ngày trong tháng. Ví dụ: 31
 - **HH**: Giờ trong ngày (định dạng 24 giờ). Ví dụ: 23
 - **hh**: Giờ trong ngày (định dạng 12 giờ). Ví dụ: 11
 - **mm**: Phút trong giờ. Ví dụ: 59
 - **ss**: Giây trong phút. Ví dụ: 59
 - **SSS**: Phần nghìn giây trong giây. Ví dụ: 999
 - **EEEE**: Tên đầy đủ của ngày trong tuần. Ví dụ: Monday
 - **EEE**: Tên viết tắt của ngày trong tuần. Ví dụ: Mon
 - **a**: Chỉ số AM/PM trong ngày. Ví dụ: AM
 "yyyy-MM-dd HH:mm:ss.SSS"
 "hh:mm a"

 */

