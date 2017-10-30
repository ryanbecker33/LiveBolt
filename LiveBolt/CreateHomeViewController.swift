//
//  CreateHomeViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/22/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit

class CreateHomeViewController: UIViewController {

    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var homeNicknameTextField: UITextField!
    @IBOutlet weak var homeNameTextField: UITextField!
    @IBOutlet weak var homePasswordTextField: UITextField!
    @IBOutlet weak var homeConfirmPasswordTextField: UITextField!
    @IBAction func createHomeButton(_ sender: Any) {
        if(homePasswordTextField.text! != homeConfirmPasswordTextField.text!)
        {
            self.errorMessageLabel.text! = "Passwords do not match."
            return
        }
        
        let postString = "name=\(homeNameTextField.text!)&nickName=\(homeNicknameTextField.text!)&password=\(homePasswordTextField.text!)&confirmPassword=\(homeConfirmPasswordTextField.text!)"
        let request = ServerRequest(type: "POST", endpoint: "/home/create", postString: postString)
        let home = homeNameTextField.text!
        let password = homePasswordTextField.text!
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        
        if(request.statusCode == 200)
        {
            defaults.set(home, forKey: "homeName")
            defaults.set(password, forKey: "homePassword")
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "homeCreated", sender: self)
            }
        }
        else
        {
            let jsonDecoder = JSONDecoder()
            let status = try? jsonDecoder.decode(Status.self, from: request.data!)
            DispatchQueue.main.async(execute: {
                self.errorMessageLabel.text = status!.ErrorMessage[0]
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
