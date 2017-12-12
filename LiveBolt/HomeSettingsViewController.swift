//
//  HomeSettingsViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/23/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit
import CoreLocation

class HomeSettingsViewController: UIViewController {

    @IBOutlet weak var homeNickNameTextField: UITextField!
    @IBOutlet weak var deleteHomeButtonProperties: UIButton!
    @IBOutlet weak var editHomeNameButtonProperties: UIButton!
    @IBOutlet weak var logoutButtonProperties: UIButton!
    @IBOutlet weak var submitButtonProperties: UIButton!
    @IBAction func editHomeName(_ sender: Any) {
        deleteHomeButtonProperties.isHidden = true;
        editHomeNameButtonProperties.isHidden = true;
        logoutButtonProperties.isHidden = true;
        homeNickNameTextField.isHidden = false;
        submitButtonProperties.isHidden = false;
    }
    
    @IBAction func submitHomeName(_ sender: Any) {
        if(homeNickNameTextField.text! == "")
        {
            deleteHomeButtonProperties.isHidden = false;
            editHomeNameButtonProperties.isHidden = false;
            logoutButtonProperties.isHidden = false;
            homeNickNameTextField.isHidden = true;
            submitButtonProperties.isHidden = true;
            return
        }
        let request = ServerRequest(type: "POST", endpoint: "/home/editNickname", postString: "nickname=\(homeNickNameTextField.text!)")
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        if(request.statusCode! == 200)
        {
            print("Home Nickname Change Accepted")
        }
        else
        {
            print("Home Nickname Change Failed")
        }
        deleteHomeButtonProperties.isHidden = false;
        editHomeNameButtonProperties.isHidden = false;
        logoutButtonProperties.isHidden = false;
        homeNickNameTextField.isHidden = true;
        submitButtonProperties.isHidden = true;
    }
    @IBAction func logoutButton(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "Logout", style: .destructive) { (alert: UIAlertAction!) -> Void in
            let request = ServerRequest(type: "POST", endpoint: "/account/logout", postString: "")
            let defaults = UserDefaults.standard
            request.makeRequest(cookie: defaults.string(forKey: "cookie"))
            
            if(request.statusCode! == 200)
            {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                for region in appDelegate.manager.monitoredRegions
                {
                    appDelegate.manager.stopMonitoring(for: region)
                }
                defaults.set(nil, forKey: "homeName")
                defaults.set(nil, forKey: "homePassword")
                defaults.set(nil, forKey: "email")
                defaults.set(nil, forKey: "password")
                defaults.set(nil, forKey: "cookie")
                defaults.set(nil, forKey: "homeLatitiude")
                defaults.set(nil, forKey: "homeLongitude")
                defaults.set(nil, forKey: "homeRadius")
                defaults.set(nil, forKey: "deviceToken")
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "homeDeleted", sender: nil)
                }
            }
            else
            {
                //bad logout
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            //print("You pressed Cancel")
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
    }
    
    @IBAction func deleteHomeButton(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Home", message: "Are you sure you want to delete your home?", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "Delete", style: .destructive) { (alert: UIAlertAction!) -> Void in
            let request = ServerRequest(type: "DELETE", endpoint: "/home/remove", postString: nil)
            let defaults = UserDefaults.standard
            request.makeRequest(cookie: defaults.string(forKey: "cookie"))
            
            if(request.statusCode! == 200)
            {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                for region in appDelegate.manager.monitoredRegions
                {
                    appDelegate.manager.stopMonitoring(for: region)
                }
                defaults.set(nil, forKey: "homeName")
                defaults.set(nil, forKey: "homePassword")
                defaults.set(nil, forKey: "homeLatitiude")
                defaults.set(nil, forKey: "homeLongitude")
                defaults.set(nil, forKey: "homeRadius")
                defaults.set(nil, forKey: "deviceToken")
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "homeDeleted", sender: nil)
                }
            }
            else
            {
                //home delete erroe
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            //print("You pressed Cancel")
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)
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
