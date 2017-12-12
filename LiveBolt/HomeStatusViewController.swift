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
    var moduleID : Int = -1
    var isIDM = false
    var userID = -1
    var timer : Timer!

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(tableView == dlmTable)
        {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title = self.home.dlMs[indexPath.row].isLocked ? "Unlock" : "Lock"
        let editAction = UITableViewRowAction(style: .normal, title: title) { (rowAction, indexPath) in
            let action = self.home.dlMs[indexPath.row].isLocked ? "Unlock" : "Lock"
            let alert = UIAlertController(title: self.home.dlMs[indexPath.row].nickname, message: "Are you sure you want to \(action) the deadbolt?", preferredStyle: .alert)
            let clearAction = UIAlertAction(title: action, style: .destructive) { (alert: UIAlertAction!) -> Void in
                let dlm = self.home.dlMs[indexPath.row]
                let request = ServerRequest(type: "POST", endpoint: "/home/setDLMState", postString: "dlmID=\(dlm.id)&locked=\(!dlm.isLocked)")
                let defaults = UserDefaults.standard
                request.makeRequest(cookie: defaults.string(forKey: "cookie"))
                if(request.statusCode! == 200)
                {
                    print("Locked State Change Accepted")
                }
                else
                {
                    print("Locked State Change Failed")
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
                //print("You pressed Cancel")
            }
            
            alert.addAction(clearAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion:nil)
        }
        editAction.backgroundColor = .blue
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            //TODO: Delete the row at indexPath here
        }
        deleteAction.backgroundColor = .red
        
        return [editAction]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == self.userTable)
        {
            return home.users.count
        }
        else if(tableView == self.dlmTable)
        {
            return home.dlMs.count
        }
        else
        {
            return home.idMs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.backgroundColor = UIColor.clear
        if(tableView == self.userTable)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath as IndexPath)
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.white
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
        else if(tableView == self.dlmTable)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dlmCell", for: indexPath as IndexPath)
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.white
            let dlm = home.dlMs[indexPath.row]
            cell.textLabel?.text = dlm.nickname + " : " + (dlm.isLocked ? "Locked" : "Unlocked")
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "idmCell", for: indexPath as IndexPath)
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.white
            let idm = home.idMs[indexPath.row]
            cell.textLabel?.text = idm.nickname + " : " + (idm.isClosed ? "Closed" : "Open")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == userTable)
        {
            self.userID = indexPath.row
            tableView.deselectRow(at: indexPath, animated: true)
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "userSelected", sender: nil)
            }
        }
        else
        {
            if(tableView == idmTable)
            {
                self.isIDM = true
            }
            else if(tableView == dlmTable)
            {
                self.isIDM = false
            }
            moduleID = indexPath.row
            tableView.deselectRow(at: indexPath, animated: true)
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "moduleSelected", sender: nil)
            }
        }
    }
    
    
    
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var dlmTable: UITableView!
    @IBOutlet weak var idmTable: UITableView!
    @IBOutlet weak var homeNameLabel: UILabel!
    @IBAction func homeSettingsButton(_ sender: Any) {
  
    }
    
    @objc func refresh()
    {
        let request = ServerRequest(type: "GET", endpoint: "/home/status", postString: nil)
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        
        if(request.statusCode! == 200 && request.responseString != nil)
        {
            let jsonDecoder = JSONDecoder()
            let home = try? jsonDecoder.decode(Home.self, from: request.data!)
            self.home = home!
            DispatchQueue.main.async(){
                self.homeNameLabel.text = home?.nickname
            }
            self.userTable.reloadData()
            self.idmTable.reloadData()
            self.dlmTable.reloadData()
        }
        else
        {

        }
        print("Refreshed\n")
    }
    
    @IBAction func refreshHomeButton(_ sender: Any) {
        refresh()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        
        userTable.dataSource = self
        userTable.delegate = self
        userTable.register(UITableViewCell.self, forCellReuseIdentifier: "userCell")
        
        dlmTable.dataSource = self
        dlmTable.delegate = self
        dlmTable.register(UITableViewCell.self, forCellReuseIdentifier: "dlmCell")
        
        idmTable.dataSource = self
        idmTable.delegate = self
        idmTable.register(UITableViewCell.self, forCellReuseIdentifier: "idmCell")
        

        let request = ServerRequest(type: "GET", endpoint: "/home/status", postString: nil)
        let defaults = UserDefaults.standard
        request.makeRequest(cookie: defaults.string(forKey: "cookie"))
        
        if(request.statusCode! == 200)
        {
            let jsonDecoder = JSONDecoder()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moduleSelected" {
            let controller = segue.destination as! ModuleViewController
            controller.home = self.home
            controller.id = self.moduleID
            controller.isIdm = self.isIDM
        }
        else if segue.identifier == "userSelected"
        {
            let controller = segue.destination as! UserViewController
            controller.userID = self.userID
        }
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
        var dlMs: [DLM]
        var idMs: [IDM]
        
        init()
        {
            name = ""
            nickname = ""
            users = [User]()
            latitude = 0
            longitude = 0
            dlMs = [DLM]()
            idMs = [IDM]()
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
        
        struct IDM: Codable
        {
            var id: String
            var isClosed: Bool
            var nickname: String
            
            init()
            {
                id = ""
                isClosed = false
                nickname = ""
            }
        }
        
        struct DLM: Codable
        {
            var id: String
            var isLocked: Bool
            var nickname: String
            
            init()
            {
                id = ""
                isLocked = false
                nickname = ""
            }
        }
    }
}
