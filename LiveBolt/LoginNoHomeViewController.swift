//
//  LoginNoHomeViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/25/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit

class LoginNoHomeViewController: UIViewController {

    @IBAction func logoutButton(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "Logout", style: .destructive) { (alert: UIAlertAction!) -> Void in
            let request = ServerRequest(type: "POST", endpoint: "/account/logout", postString: "")
            let defaults = UserDefaults.standard
            request.makeRequest(cookie: defaults.string(forKey: "cookie"))
            
            if(request.statusCode! == 200)
            {
                defaults.set(nil, forKey: "homeName")
                defaults.set(nil, forKey: "homePassword")
                defaults.set(nil, forKey: "email")
                defaults.set(nil, forKey: "password")
                defaults.set(nil, forKey: "cookie")
                defaults.set(nil, forKey: "homeLatitiude")
                defaults.set(nil, forKey: "homeLongitude")
                defaults.set(nil, forKey: "homeRadius")
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "logout", sender: nil)
                }
            }
            else
            {
               print("Bad")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
