//
//  UserViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 11/13/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    
    var userID = -1

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var isHomeLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func editButtonAction(_ sender: Any) {
        firstNameTextField.text = firstNameLabel.text;
        lastNameTextField.text = lastNameLabel.text;
        firstNameLabel.isHidden = true;
        lastNameLabel.isHidden = true;
        editButton.isHidden = true;
        cancelButton.isHidden = false;
        submitButton.isHidden = false;
        firstNameTextField.isHidden = false;
        lastNameTextField.isHidden = false;
    }
    
    private func lockUI()
    {
        firstNameLabel.isHidden = false;
        lastNameLabel.isHidden = false;
        editButton.isHidden = false;
        cancelButton.isHidden = true;
        submitButton.isHidden = true;
        firstNameTextField.isHidden = true;
        lastNameTextField.isHidden = true;
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        if(firstNameTextField.text! == "" || lastNameTextField.text! == "")
        {
            lockUI()
            refreshUI()
            return
        }
        let request = ServerRequest(type: "POST", endpoint: "/account/editName", postString: "firstName=\(firstNameTextField.text!)&lastname=\(lastNameTextField.text!)")
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        if(request.statusCode! == 200)
        {
            print("User name Change Accepted")
        }
        else
        {
            print("User name Change Failed")
        }
        lockUI()
        refreshUI()
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        lockUI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUI()
        // Do any additional setup after loading the view.
    }
    
    private func refreshUI()
    {
        let request = ServerRequest(type: "GET", endpoint: "/home/status", postString: nil)
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        
        if(request.statusCode! == 200)
        {
            let jsonDecoder = JSONDecoder()
            let home = try? jsonDecoder.decode(Home.self, from: request.data!)
            DispatchQueue.main.async(){
                self.firstNameLabel.text = home?.users[self.userID].firstName
                self.lastNameLabel.text = home?.users[self.userID].lastName
                self.usernameLabel.text = home?.users[self.userID].username
                self.isHomeLabel.text = "Status: \(((home?.users[self.userID].isHome)! ? "Home" : "Not Home"))"
            }
        }
        else
        {
            DispatchQueue.main.async(){
                self.firstNameLabel.text = "User request bad. Fix this"
            }
        }
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
