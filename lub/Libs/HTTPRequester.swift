//
//  HTTPRequester.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import Foundation

public class HTTPRequester {
    static var baseURL = "https://youtuber-dl.herokuapp.com/"
    
    public static func request(url: String, method: String, body: [String: Any]?, onSuccess: @escaping (_ successResponse: String?) -> (), onError: @escaping (_ errorResponse: HTTPURLResponse?) -> ()) {
        let requestedURL = URL(string: baseURL + url)!
        var request = URLRequest(url: requestedURL)
        
        request.setValue("application/json", forHTTPHeaderField: "ContentType")
        request.httpMethod = method
        
        if body != nil {
            let jsonData = try? JSONSerialization.data(withJSONObject: body as Any)
            request.httpBody = jsonData
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                onError(response)
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            onSuccess(responseString)
        }
        
        task.resume()
    }
    
    public static func downloadTaskText(_ urlString: String, completionHandler: @escaping (_ response: HTTPURLResponse?) -> (), onFinishDownload: @escaping (_ data: Data) -> ()) {
        let fileURL = URL(string: self.baseURL + urlString)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        let request = URLRequest(url:fileURL!)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            completionHandler((response as? HTTPURLResponse))
            
            // Success
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                print("Successfully downloaded. Status code: \(statusCode)")
            }
        }
        task.resume()
    }
    
    public static func downloadFile(_ url: String, onFinishDownload: @escaping (_ data: Data) -> () ) {
        guard let videoUrl = URL(string: baseURL + url) else {
           return
        }
        
        DispatchQueue.global(qos: .utility).async {
            var videoData: Data
            
            do {
                videoData = try Data(contentsOf: videoUrl)
                
                DispatchQueue.main.async {
                    onFinishDownload(videoData)
                }
            } catch {
                print("Could not download data")
            }
        }
            
        //let fm = FileManager.default

        //guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
        //   print("Unable to reach the documents folder")
        //   return
        //}

        //let localUrl = docUrl.appendingPathComponent("test.mp4")

        //try videoData.write(to: localUrl)

        //let fileManager = FileManager.default
        //let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //do {
        //    let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        //    print(fileURLs)
            // process files
        //} catch {
        //    print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        //}
    }
}
