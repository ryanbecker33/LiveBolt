//
//  SignUpController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/16/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit
import Foundation

class SignUpViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var reEnterPasswordLabel: UILabel!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBAction func createAccountButton(_ sender: Any) {
        if(passwordTextField.text! != confirmPasswordTextField.text!)
        {
            self.warningLabel.text! = "Passwords do not match."
            return
        }
        let postString = "firstName=\(firstNameTextField.text!)&lastName=\(lastNameTextField.text!)&email=\(emailTextField.text!)&password=\(passwordTextField.text!)&confirmPassword=\(confirmPasswordTextField.text!)"
        let request = ServerRequest(type: "POST", endpoint: "/account/register", postString: postString)
        request.makeRequest(cookie: nil)
        
        if(request.statusCode! == 200)
        {
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "registerSucceed", sender: self)
            }
        }
        else
        {
            let jsonDecoder = JSONDecoder()
            let status = try? jsonDecoder.decode(Status.self, from: request.data!)
            DispatchQueue.main.async(execute: {
                if status!.Password != nil
                {
                    self.warningLabel.text = status!.Password![0]
                }
                else if status!.ConfirmPassword != nil
                {
                    self.warningLabel.text = status!.ConfirmPassword![0]
                }
                else if status!.ErrorMessage != nil
                {
                    self.warningLabel.text = status!.ErrorMessage![0]
                }
                else
                {
                    self.warningLabel.text = "Bad"
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

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
        var ErrorMessage: [String]?
        var Password: [String]?
        var ConfirmPassword: [String]?
    }

}
