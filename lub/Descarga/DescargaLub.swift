//
//  DescargaLub.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/10/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import Foundation
import SocketIO
import MobileCoreServices

class DescargaLub: BasicVC {
    let manager = SocketManager(socketURL: URL(string: "https://youtuber-dl.herokuapp.com")!, config: [.log(true), .compress])
    var socketId = ""
    var expectedContentLength = 0
    var buffer:NSMutableData = NSMutableData()
    var session:URLSession?
    var dataTask:URLSessionDataTask?
    var selectedCell: DescargaCell!
    var selectedResult: Result!
    var vcInvoker: BusquedaVC!
    var pendienteDescarga = true
    
    public func getMedia(onData: @escaping (_ stringMsg: String) -> (), onFinish: @escaping (_ downloadURL: String) -> ()) {
        if expectedContentLength != 0 && (Float(buffer.length) / Float(expectedContentLength)) == 1 {
            self.pendienteDescarga = false
        }
        
        if self.pendienteDescarga {
            self.pendienteDescarga = false
            self.session = URLSession(configuration: URLSessionConfiguration.default, delegate:self, delegateQueue: OperationQueue.main)
            
            let socket = manager.defaultSocket
            socket.on(clientEvent: .connect) {data, ack in
                self.socketId = (socket.manager?.engine?.sid)!
                let folderName = self.getFolderName()
                
                var url = "get-mp4?videoId=" + self.selectedResult.id.videoId;
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
                    socket.disconnect()
                    onFinish(url)
                }
            }
            
            socket.connect()
        }
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

extension DescargaLub: URLSessionDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        expectedContentLength = Int(response.expectedContentLength)
        print(expectedContentLength)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)

        let percentageDownloaded = Float(buffer.length) / Float(expectedContentLength)
        self.selectedCell.lbProgreso.text = String(Int(percentageDownloaded * 100)) + "%"
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        documentPicker.delegate = self
        vcInvoker.present(documentPicker, animated: true)
    }
}

extension DescargaLub: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let urlSelected = urls.first!
        
        guard urlSelected.startAccessingSecurityScopedResource() else {
            return
        }
        
        let localUrl = urlSelected.appendingPathComponent(selectedResult.snippet.title + ".mp4")
        
        do {
            try buffer.write(to: localUrl)
        }
        catch {
            print("Could not save file")
        }
        
        do { urlSelected.stopAccessingSecurityScopedResource() }
    }
}
