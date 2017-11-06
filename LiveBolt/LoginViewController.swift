//
//  LoginViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/16/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func loginButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.manager.requestLocation()
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
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

}
