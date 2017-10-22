//
//  CheckLoginViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/22/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit

class CheckLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        let defaults = UserDefaults.standard
        if let email = defaults.string(forKey: "email") {
            if let home = defaults.string(forKey: "homeName")
            {
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "loginAndHome", sender: nil)
                }
            }
            else
            {
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "loginAndNoHome", sender: nil)
                }
            }
        }
        else
        {
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "noLogin", sender: nil)
            }
        }
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
