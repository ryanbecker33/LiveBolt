//
//  HomeStatusViewController.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/22/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit

class HomeStatusViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var home : Home = Home()
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return home.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        let user = home.users[indexPath.row]
        cell.textLabel?.text = user.firstName + " " + user.lastName
        if(user.isHome)
        {
            cell.imageView?.image = UIImage(named: "home.png")
        }
        else
        {
            cell.imageView?.image = UIImage(named: "away.png")
        }
        return cell
    }
    
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var homeNameLabel: UILabel!
    @IBAction func homeSettingsButton(_ sender: Any) {
        
    }
    @IBAction func refreshHomeButton(_ sender: Any) {
        let request = ServerRequest(type: "GET", endpoint: "/home/status", postString: nil)
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        
        if(request.statusCode! == 200)
        {
            let jsonDecoder = JSONDecoder()
            print(request.responseString!)
            let home = try? jsonDecoder.decode(Home.self, from: request.data!)
            self.home = home!
            DispatchQueue.main.async(){
                self.homeNameLabel.text = home?.nickname
            }
            self.userTable.reloadData()
        }
        else
        {
            DispatchQueue.main.async(){
                self.homeNameLabel.text = "Home request bad. Fix this"
            }
        }
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
        userTable.dataSource = self
        userTable.delegate = self
        userTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        let request = ServerRequest(type: "GET", endpoint: "/home/status", postString: nil)
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        
        if(request.statusCode! == 200)
        {
            let jsonDecoder = JSONDecoder()
            print(request.responseString!)
            let home = try? jsonDecoder.decode(Home.self, from: request.data!)
            self.home = home!
            DispatchQueue.main.async(){
                self.homeNameLabel.text = home?.nickname
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
        let latitude: Double
        let longitude: Double
        
        init()
        {
            name = ""
            nickname = ""
            users = [User]()
            latitude = 0
            longitude = 0
        }
        
        struct User: Codable
        {
            var username: String
            var email: String
            var firstName: String
            var lastName: String
            var isHome: Bool
            
            init()
            {
                username = ""
                email = ""
                firstName = ""
                lastName = ""
                isHome = false
            }
        }
    }
}
