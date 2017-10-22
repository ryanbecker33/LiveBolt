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
        let url = URL(string: "https://livebolt.rats3g.net/account/login")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let postString = "email=\(email)&password=\(password)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
                DispatchQueue.main.async(execute: {
                    self.warningLabel.text = String(data: data, encoding: .utf8)
                })
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {           // check for http errors
                print("statusCode is \(httpStatus.statusCode)")
                let defaults = UserDefaults.standard
                defaults.set(httpStatus.allHeaderFields["Set-Cookie"]!, forKey: "cookie")
                defaults.set(email, forKey: "email")
                defaults.set(password, forKey: "password")
                print(httpStatus.allHeaderFields["Set-Cookie"]!)
                if let home = defaults.string(forKey: "homeName")
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
        task.resume()
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

}
