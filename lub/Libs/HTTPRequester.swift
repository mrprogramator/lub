//
//  HTTPRequester.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import Foundation

class HTTPRequester {
    static var baseURL = "https://lub-service.herokuapp.com"
    
    public static func request(url: String, method: String, body: [String: Any]?, onSuccess: @escaping (_ successResponse: String?) -> (), onError: @escaping (_ errorResponse: HTTPURLResponse?) -> ()) {
        let requestedURL = URL(string: baseURL + "/" + url)!
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
}
