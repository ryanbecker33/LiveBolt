//
//  ModuleViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 11/12/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit

class ModuleViewController: UIViewController {

    var home = HomeStatusViewController.Home()
    var id : Int = -1
    var isIdm = false
  
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var lockButton: UIButton!
    @IBAction func cancelButtonAction(_ sender: Any) {
        lockUI()
        updateUI()
    }
    
    private func lockUI()
    {
        nameLabel.isHidden = false
        lockButton.isHidden = false
        deleteButton.isHidden = false
        editButton.isHidden = false
        submitButton.isHidden = true
        cancelButton.isHidden = true
        nameTextField.isHidden = true
    }
    
    
    @IBAction func deleteModuleAction(_ sender: Any) {
        var endpoint = ""
        if(isIdm)
        {
            endpoint = "/idm/remove"
        }
        else
        {
            endpoint = "/dlm/remove"
        }
        
        let alert = UIAlertController(title: "Delete Module", message: "Are you sure you want to delete this module?", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "Delete", style: .destructive) { (alert: UIAlertAction!) -> Void in
            let request = ServerRequest(type: "POST", endpoint: endpoint, postString: "guid=\(self.isIdm ? self.home.idMs[self.id].id : self.home.dlMs[self.id].id)")
            let defaults = UserDefaults.standard
            request.makeRequest(cookie: defaults.string(forKey: "cookie"))
            
            if(request.statusCode! == 200)
            {
                
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "moduleRemoved", sender: nil)
                }
            }
            else
            {
                //bad remove
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            //print("You pressed Cancel")
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        if(nameTextField.text! == "")
        {
            lockUI()
            updateUI()
            return
        }
        if(self.isIdm)
        {
            let idm = self.home.idMs[self.id]
            let request = ServerRequest(type: "POST", endpoint: "/idm/editNickname", postString: "guid=\(idm.id)&nickname=\(nameTextField.text!)")
            let defaults = UserDefaults.standard
            request.makeRequest(cookie: defaults.string(forKey: "cookie"))
            if(request.statusCode! == 200)
            {
                print("IDM Nickname Change Accepted")
            }
            else
            {
                print("IDM Nickname Change Failed")
            }
        }
        else
        {
            let dlm = self.home.dlMs[self.id]
            let request = ServerRequest(type: "POST", endpoint: "/dlm/editNickname", postString: "guid=\(dlm.id)&nickname=\(nameTextField.text!)")
            let defaults = UserDefaults.standard
            request.makeRequest(cookie: defaults.string(forKey: "cookie"))
            if(request.statusCode! == 200)
            {
                print("DLM Nickname Change Accepted")
            }
            else
            {
                print("DLM Nickname Change Failed")
            }
        }
        lockUI()
        updateUI()
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        nameLabel.isHidden = true
        lockButton.isHidden = true
        deleteButton.isHidden = true
        editButton.isHidden = true
        submitButton.isHidden = false
        cancelButton.isHidden = false
        nameTextField.isHidden = false
        nameTextField.text = nameLabel.text
    }
    
    
    @IBAction func lockButtonAction(_ sender: Any) {
        let action = self.home.dlMs[self.id].isLocked ? "Unlock" : "Lock"
        let alert = UIAlertController(title: self.home.dlMs[self.id].nickname, message: "Are you sure you want to \(action) the deadbolt?", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: action, style: .destructive) { (alert: UIAlertAction!) -> Void in
            let dlm = self.home.dlMs[self.id]
            let request = ServerRequest(type: "POST", endpoint: "/home/setDLMState", postString: "dlmID=\(dlm.id)&locked=\(!dlm.isLocked)")
            let defaults = UserDefaults.standard
            request.makeRequest(cookie: defaults.string(forKey: "cookie"))
            if(request.statusCode! == 200)
            {
                print("Locked State Change Accepted")
            }
            else
            {
                print("Locked State Change Failed")
            }
            self.updateUI()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            //print("You pressed Cancel")
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
    }
    
    private func updateUI()
    {
        let request = ServerRequest(type: "GET", endpoint: "/home/status", postString: nil)
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        
        if(request.statusCode! == 200)
        {
            let jsonDecoder = JSONDecoder()
            home = try! jsonDecoder.decode(HomeStatusViewController.Home.self, from: request.data!)
            DispatchQueue.main.async(){
                if(self.isIdm)
                {
                    self.nameLabel.text = self.home.idMs[self.id].nickname
                    self.typeLabel.text = "Type: IDM"
                    self.statusLabel.text = "Status: \(((self.home.idMs[self.id].isClosed) ? "Closed" : "Open"))"
                    self.lockButton.isHidden = true
                }
                else
                {
                    self.nameLabel.text = self.home.dlMs[self.id].nickname
                    self.typeLabel.text = "Type: DLM"
                    self.statusLabel.text = "Status: \(((self.home.dlMs[self.id].isLocked) ? "Locked" : "Unlocked"))"
                    self.lockButton.isHidden = false
                    self.lockButton.setTitle((self.home.dlMs[self.id].isLocked) ? "Unlock Door" : "Lock Door", for: .normal)
                }
            }
        }
        else
        {
            DispatchQueue.main.async(){
                self.nameLabel.text = "Module request bad. Fix this"
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
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
