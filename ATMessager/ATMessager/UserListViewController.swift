//
//  UserListViewController.swift
//  ATMessager
//
//  Created by MOBILE MAC1 on 7/19/17.
//  Copyright © 2017 MOBILE MAC1. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var userList = [User]()
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //A Table Height & Get User listing
        tableView.rowHeight = 65
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        getUserList()
    }
    
    
    // MARK: Fetch user list 
    func getUserList(){
        
        let dbRef = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        dbRef.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //1] Print Full data values
            let value = snapshot.value as? NSDictionary
            for (key, data) in value! {
                let keyName = key as! String
                if userID != keyName{
                    
                    let user = User.init(dictionary: data as! Dictionary<String, AnyObject>)
                    self.userList.append(user)
                }
            }
            //2] Reload Table Cell
            self.tableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
// MARK: UITableView Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "UserCell")
        let user = userList[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.location
        return cell
    }
    
    //1] Logout Firebase.
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        if FIRAuth.auth()?.currentUser != nil {
        
            do {
                try FIRAuth.auth()?.signOut()
                self.navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
