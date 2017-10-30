//
//  ServerRequest.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/29/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import Foundation

class ServerRequest{
    let type: String
    let endpoint: String
    let postString: String?
    var data: Data?
    var statusCode: Int?
    var response: HTTPURLResponse?
    var responseString: String?
    
    init(type: String, endpoint: String, postString: String?){
        self.type = type;
        self.endpoint = endpoint;
        self.postString = postString;
        self.data = nil;
        self.statusCode = nil;
        self.response = nil;
        self.responseString = nil;
    }
    
    func makeRequest(cookie: String?)
    {
        let url = URL(string: "https://livebolt.rats3g.net\(endpoint)")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = type
        if(type == "POST")
        {
            request.httpBody = postString!.data(using: .utf8)
        }
        
        if(cookie != nil)
        {
            request.addValue(cookie!, forHTTPHeaderField: "Cookie")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            
            print("response = \(response!)")
            if let httpStatus = response as? HTTPURLResponse{           // check for http errors
                self.statusCode = httpStatus.statusCode
                self.response = httpStatus
                let responseString = String(data: data, encoding: .utf8)
                self.responseString = responseString
                self.data = data
                
            }
        }
        task.resume()
        //BAD BAD BAD BAD BAD BAD BAD
        while(self.statusCode == nil)
        {
            
        }
    }
}
