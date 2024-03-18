//
//  SocketIOManager.swift
//  ColorNoteRemake
//
//  Created by Đỗ Việt on 19/07/2023.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {
    
    static let shared = SocketIOManager()
    
    static let sharedInstance = SocketIOManager()
    
    let socket = SocketManager(socketURL: URL(string: "https://api.iudi.xyz")!, config: [.log(true), .compress])
    var mSocket: SocketIOClient!
    
    override init() {
        super.init()
        mSocket = socket.defaultSocket
    }
    
    func getSocket() -> SocketIOClient {
        return mSocket
    }
    
    func establishConnection() {
        mSocket.connect()
    }
    
    func closeConnection() {
        mSocket.disconnect()
    }
    
    func joinChatRoom(roomId: Int) {
        mSocket.emit("join", ["room": roomId])
    }
    
    func leaveChatRoom() {
        mSocket.emit("leave", ["room": ""])
    }
    func sendTextMessage() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let message: [String: Any] = [
            "data": [
                "idSend": -1,
                "avt": "https://github.com/sonnh7289/python3-download/raw/main/Screenshot%202023-05-04%20at%205.33.53%20PM.png",
                "name": "",
                "type": "text",
                "content": "message",
                "sendAt": "\(formatter.string(from: Date())) +07:00"
            ] as [String : Any],
            "room": 1
        ]
        
        mSocket.emit("chat_group", message)
    }
    
    func sendTextMessage1() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let messageData: [String: Any] = [
            "room": "1", //ví dụ 21423
            "data": [
                "id": "2",
                "RelatedUserID": "1",
                "type": "text",//text/ image/icon-image/muti-image
                "state":"",
                "content":"adeqwq"
                //"data": "https://i.ibb.co/2MJkg5P/Screenshot-2023-05-07-142345.png"// nếu dữ liệu là loại ảnh
                 // Nếu dữ liệu là loại text
            ]
        ]
        
        mSocket.emit("check_message", messageData)
    }
    
//    func sendIconImageMessage(roonId: Int) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy HH:mm a"
//        formatter.amSymbol = "AM"
//        formatter.pmSymbol = "PM"
//        let message: [String: Any] = [
//            "data": [
//                "idSend": slideMenuVC.user_id,
//                "avt": "https://github.com/sonnh7289/python3-download/raw/main/Screenshot%202023-05-04%20at%205.33.53%20PM.png",
//                "name": slideMenuVC.user_name,
//                "type":"icon-image",
//                "metaData":"/assets/like.png",
//                "sendAt": "\(formatter.string(from: Date())) +07:00"
//            ] as [String : Any],
//            "room": roonId
//        ]
//
//        mSocket.emit("chat_group", message)
//    }
    
//    func sendImageMessage(roonId: Int, linkImage: String) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy HH:mm a"
//        formatter.amSymbol = "AM"
//        formatter.pmSymbol = "PM"
//        let message: [String: Any] = [
//            "data": [
//                "idSend": slideMenuVC.user_id,
//                "avt": "https://github.com/sonnh7289/python3-download/raw/main/Screenshot%202023-05-04%20at%205.33.53%20PM.png",
//                "name": slideMenuVC.user_name,
//                "type": "image",
//                "metaData": linkImage,
//                "sendAt": "\(formatter.string(from: Date())) +07:00"
//            ] as [String : Any],
//            "room": roonId
//        ]
//
//        mSocket.emit("chat_group", message)
//    }
}
