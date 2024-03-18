//
//  SocketManager.swift
//  IUDI
//
//  Created by LinhMAC on 18/03/2024.
//

import Foundation
import SocketIO

class SocketIOManager1: NSObject {
    static let sharedInstance = SocketIOManager()

    let manager1 = SocketManager(socketURL: URL(string: "https://api.iudi.xyz")!, config: [.log(true), .connectParams([:])])
    let manager = SocketManager(socketURL: URL(string: "https://api.iudi.xyz")!,
                                    config: [
                                        .log(true),
                                        .compress,
                                        .forceWebsockets(true)])

    var socket: SocketIOClient!

    override init() {
    super.init()
    
        socket = manager.defaultSocket
    
        //Listener to capture any message that your server emits for "emitMessage" key. You can add multiple listeners to capture various emits from your server.
        socket.on("emitMessage") { (data, ack) in
            print("Socket Ack: \(ack)")
            print("Emitted Data: \(data)")
            //Do something with the data you got back from your server.
        }
    }

    //Function for your app to emit some information to your server.
    func emit(message: [String: Any]){
        print("Sending Message: \([message])")
        socket.emit("send_message", with: [message], completion:nil)
    }

    //Function to establish the socket connection with your server. Generally you want to call this method from your `Appdelegate` in the `applicationDidBecomeActive` method.
    func establishConnection() {
        socket.connect()
        print("Connected to Socket !")
    }

    //Function to close established socket connection. Call this method from `applicationDidEnterBackground` in your `Appdelegate` method.
    func closeConnection() {
        socket.disconnect()
        print("Disconnected from Socket !")
    }
}
