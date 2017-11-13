//
//  CreateHomeViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/22/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit
import CoreLocation

class CreateHomeViewController: UIViewController {

    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var centerHomeLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var homeNicknameTextField: UITextField!
    @IBOutlet weak var homeNameTextField: UITextField!
    @IBOutlet weak var homePasswordTextField: UITextField!
    @IBOutlet weak var homeConfirmPasswordTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var nextButtonObject: UIButton!
    @IBAction func nextButton(_ sender: Any) {
        homeNicknameTextField.isHidden = true
        homeNameTextField.isHidden = true
        homePasswordTextField.isHidden = true
        homeConfirmPasswordTextField.isHidden = true
        nickNameLabel.isHidden = true
        nameLabel.isHidden = true
        passwordLabel.isHidden = true
        confirmPasswordLabel.isHidden = true
        nextButtonObject.isHidden = true
        errorMessageLabel.isHidden = true
        nickNameLabel.isHidden = true
        centerHomeLabel.isHidden = false
        createButton.isHidden = false
    }
    @IBAction func createHomeButton(_ sender: Any) {
        if(homePasswordTextField.text! != homeConfirmPasswordTextField.text!)
        {
            self.errorMessageLabel.text! = "Passwords do not match."
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.manager.requestLocation()
        guard let coordinate = appDelegate.manager.location?.coordinate else {return}
        let region = CLCircularRegion(center: coordinate, radius: 30, identifier: "User Home")
        let postString = "name=\(homeNameTextField.text!)&nickName=\(homeNicknameTextField.text!)&latitude=\(Double(coordinate.latitude))&longitude=\(Double(coordinate.longitude))&password=\(homePasswordTextField.text!)&confirmPassword=\(homeConfirmPasswordTextField.text!)"
        let request = ServerRequest(type: "POST", endpoint: "/home/create", postString: postString)
        let home = homeNameTextField.text!
        let password = homePasswordTextField.text!
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        
        if(request.statusCode == 200)
        {
            defaults.set(home, forKey: "homeName")
            defaults.set(password, forKey: "homePassword")
            defaults.set(coordinate.latitude, forKey: "homeLatitiude")
            defaults.set(coordinate.longitude, forKey: "homeLongitude")
            defaults.set(30, forKey: "homeRadius")
            print("Here")
            region.notifyOnExit = true;
            region.notifyOnEntry = true;
            appDelegate.manager.startMonitoring(for: region)
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
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
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
