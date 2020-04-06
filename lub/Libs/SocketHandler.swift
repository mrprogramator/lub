//
//  SocketHandler.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import SocketIO

public class SocketHandler {
    let manager = SocketManager(socketURL: URL(string: "https://youtuber-dl.herokuapp.com")!, config: [.log(true), .compress])
    var socketId = ""
    
    public func getMedia(videoId: String, onData: @escaping (_ stringMsg: String) -> (), onFinish: @escaping (_ downloadURL: String) -> ()) {
        let socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {data, ack in
            self.socketId = (socket.manager?.engine?.sid)!
            let folderName = self.getFolderName()
            
            var url = "get-mp4?videoId=" + videoId;
            url = url + "&folderName="
            url = url + folderName
            url = url + "&socketId=" + self.socketId
            
            HTTPRequester.request(url: url, method: "POST", body: nil, onSuccess: { stringResponse in
            }, onError: { errorHTTP in })
            
            socket.on("data") { data, ack in
                let stringData = data[0] as! String
                var socketResponse = ""
                
                if stringData.contains("[download]") {
                    let perc =  stringData.split{ $0 == " " }.map(String.init)[1]
                    
                    if perc.contains("%") {
                        socketResponse = perc
                    }
                }
                
                onData(socketResponse)
            }
            
            socket.on("finish") { data, ack in
                let url = "get-media?folderName=" + folderName
                //HTTPRequester.downloadFile(url, onFinishDownload: onFinish)
                socket.disconnect()
                onFinish(url)
            }
        }
        
        
        
        socket.connect()
    }
    
    func getFolderName() -> String {
        let number = Int.random(in: 1 ... 1000000000)
        var folderName = String(number).split{ $0 == "." }.map(String.init)[0]
        folderName = folderName + "_"
        
        let someDate = Date()
        let timeInterval = someDate.timeIntervalSince1970
        let intDate = Int(timeInterval)
        folderName = folderName + String(intDate)
        return folderName
    }
}


