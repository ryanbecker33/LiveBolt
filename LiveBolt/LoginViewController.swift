//
//  LoginViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/16/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit
import CoreLocation

class LoginViewController: UIViewController {

    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func loginButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.manager.requestLocation()
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        if(email == "" || password == "")
        {
             self.warningLabel.text = "Email or Password was blank."
            return
        }
        let postString = "email=\(email)&password=\(password)"
        let request = ServerRequest(type: "POST", endpoint: "/account/login", postString: postString)
        request.makeRequest(cookie: nil)
        
        if(request.statusCode! == 200)
        {
            let defaults = UserDefaults.standard
            defaults.set(request.response!.allHeaderFields["Set-Cookie"]!, forKey: "cookie")
            defaults.set(email, forKey: "email")
            defaults.set(password, forKey: "password")
            print(request.response!.allHeaderFields["Set-Cookie"]!)
            let token = defaults.string(forKey: "deviceToken")
            if(token != nil)
            {
                let request = ServerRequest(type: "POST", endpoint: "/Account/UpdateDeviceToken", postString: "DeviceToken=\(token!)")
                request.makeRequest(cookie: defaults.string(forKey: "cookie"))
                if(request.statusCode! == 200)
                {
                    print("Device Token Update")
                }
                else
                {
                    print("Device Update Failed")
                }
            }
            
            if defaults.string(forKey: "homeName") != nil
            {
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "homeExists", sender: nil)
                }
            }
            else
            {
                let request = ServerRequest(type: "GET", endpoint: "/home/status", postString: nil)
                request.makeRequest(cookie: defaults.string(forKey: "cookie"))
                
                
                if(request.statusCode! == 200)
                {
                    let jsonDecoder = JSONDecoder()
                    let home = try? jsonDecoder.decode(Home.self, from: request.data!)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.manager.requestLocation()
                    let coordinate = CLLocationCoordinate2D(latitude: home!.latitude, longitude: home!.longitude)
                    let region = CLCircularRegion(center: coordinate, radius: 30, identifier: "User Home")
                    region.notifyOnExit = true;
                    region.notifyOnEntry = true;
                    appDelegate.manager.startMonitoring(for: region)
                    defaults.set(coordinate.latitude, forKey: "homeLatitiude")
                    defaults.set(coordinate.longitude, forKey: "homeLongitude")
                    defaults.set(30, forKey: "homeRadius")
                    DispatchQueue.main.async(){
                        self.performSegue(withIdentifier: "homeExists", sender: nil)
                    }
                }
                else
                {
                    DispatchQueue.main.async(){
                        self.performSegue(withIdentifier: "loginSucceed", sender: nil)
                    }
                }
            }
        }
        else
        {
            let jsonDecoder = JSONDecoder()
            let status = try? jsonDecoder.decode(Status.self, from: request.data!)
            DispatchQueue.main.async(execute: {
                self.warningLabel.text = status!.ErrorMessage[0]
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    struct Status: Codable
    {
        var ErrorMessage: [String]
    }
    
    struct Home: Codable
    {
        var name: String
        var nickname: String
        var users: [User]
        let latitude: Double
        let longitude: Double
        var dlMs: [DLM]
        var idMs: [IDM]
        
        init()
        {
            name = ""
            nickname = ""
            users = [User]()
            latitude = 0
            longitude = 0
            dlMs = [DLM]()
            idMs = [IDM]()
        }
        
        struct User: Codable
        {
            var username: String
            var email: String
            var firstName: String
            var lastName: String
            var isHome: Bool
            
            init()
            {
                username = ""
                email = ""
                firstName = ""
                lastName = ""
                isHome = false
            }
        }
        
        struct IDM: Codable
        {
            var id: String
            var isClosed: Bool
            var nickname: String
            
            init()
            {
                id = ""
                isClosed = false
                nickname = ""
            }
        }
        
        struct DLM: Codable
        {
            var id: String
            var isLocked: Bool
            var nickname: String
            
            init()
            {
                id = ""
                isLocked = false
                nickname = ""
            }
        }
    }

}
