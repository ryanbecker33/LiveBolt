//
//  JoinHomeViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/24/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit
import CoreLocation

class JoinHomeViewController: UIViewController {

    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var homeNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func joinHomeButton(_ sender: Any) {
        let name = homeNameTextField.text!
        let password = passwordTextField.text!
        let postString = "name=\(name)&password=\(password)"
        let request = ServerRequest(type: "POST", endpoint: "/home/join", postString: postString)
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        
        if(request.statusCode! == 200)
        {
            let defaults = UserDefaults.standard
            defaults.set(name, forKey: "homeName")
            defaults.set(password, forKey: "homePassword")
            
            let jsonDecoder = JSONDecoder()
            print(request.responseString!)
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
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "homeJoined", sender: nil)
            })
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        init()
        {
            name = ""
            nickname = ""
            users = [User]()
            latitude = 0
            longitude = 0
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
    }

}
