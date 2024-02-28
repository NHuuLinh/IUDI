//
//  ImageModel.swift
//  IUDI
//
//  Created by LinhMAC on 28/02/2024.
//

import Foundation
import UIKit

class ImgModel: NSObject{
    var link = ""
    var id:String = ""
    var title:String = ""
    var url_viewer:String = ""
    var url:String = ""
    var display_url:String = ""
    var width:Int = 0
    var height:Int = 0
    var size:Int = 0
    var time:Int = 0
    
    func initLoad(_ json:  [String:Any]) -> ImgModel{
        if let data = json["link"] as? String{
            link = data
        }
        if let data = json["id"] as? String{
            id = data
        }
        if let data = json["title"] as? String{
            title = data
        }
        if let data = json["url_viewer"] as? String{
            url_viewer = data
        }
        if let data = json["url"] as? String{
            url = data
        }
        if let data = json["display_url"] as? String{
            display_url = data
        }
        if let data = json["width"] as? Int{
            width = data
        }
        if let data = json["height"] as? Int{
            height = data
        }
        if let data = json["size"] as? Int{
            size = data
        }
        if let data = json["time"] as? Int{
            time = data
        }
        return self
    }
    
}
