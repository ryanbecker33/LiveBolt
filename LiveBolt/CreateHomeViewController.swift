//
//  CreateHomeViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/22/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit

class CreateHomeViewController: UIViewController {

    @IBOutlet weak var homeNameTextField: UITextField!
    @IBOutlet weak var homePasswordTextField: UITextField!
    @IBOutlet weak var homeConfirmPasswordTextField: UITextField!
    @IBAction func createHomeButton(_ sender: Any) {
        let url = URL(string: "https://livebolt.rats3g.net/home/create")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "name=\(homeNameTextField.text!)&password=\(homePasswordTextField.text!)&password=\(homeConfirmPasswordTextField.text!)"
        let home = homeNameTextField.text!
        let password = homePasswordTextField.text!
        request.httpBody = postString.data(using: .utf8)
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "cookie") {
            request.addValue(token, forHTTPHeaderField: "Cookie")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            defaults.set(home, forKey: "homeName")
            defaults.set(password, forKey: "homePassword")
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "homeCreated", sender: self)
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
