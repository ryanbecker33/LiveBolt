//
//  HomeStatusViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/22/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit

class HomeStatusViewController: UIViewController {

    @IBOutlet weak var usersLabel: UILabel!
    @IBOutlet weak var homeNameLabel: UILabel!
    @IBAction func homeSettingsButton(_ sender: Any) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let request = ServerRequest(type: "GET", endpoint: "/home/status", postString: nil)
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        
        if(request.statusCode! == 200)
        {
            let jsonDecoder = JSONDecoder()
            let home = try? jsonDecoder.decode(Home.self, from: request.data!)
            DispatchQueue.main.async(){
                self.homeNameLabel.text = home?.nickname
                for user in (home?.users)!
                {
                    self.usersLabel.text! += "\(user.firstName) \(user.lastName)\n"
                }
            }
        }
        else
        {
            DispatchQueue.main.async(){
                self.homeNameLabel.text = "Home request bad. Fix this"
            }
        }
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
        
        struct User: Codable
        {
            var username: String
            var email: String
            var firstName: String
            var lastName: String
        }
    }
}
