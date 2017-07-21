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
import FirebaseCore
import FirebaseStorage

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var userList = [User]()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1 Activity Indicator
        indicator.center = self.view.center
        view.addSubview(indicator)
        
        //2 Table Height & Get User listing
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 65
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        getUserList()
    }
    
    
    // MARK: Fetch user list 
    func getUserList(){
       
        indicator.startAnimating()
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
            self.indicator.stopAnimating()
            //2] Reload Table Cell
            self.tableView.reloadData()
            
        }) { (error) in
            
            self.indicator.stopAnimating()
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
    
    // MARK: UIButton Action
    
    //1] Logout Button
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
    
    //2] Profile Button
    @IBAction func profileImgBtnTapped(_ sender: UIButton) {
        
        print("Profile Button Clicked !!");
        uploadUserImage()
    }
    
    
    func uploadUserImage()
    {
        
        var storageRootRef: FIRStorageReference!
        if  let userID:String = FIRAuth.auth()?.currentUser?.uid {
            
            storageRootRef = FIRStorage.storage().reference(forURL:"gs://atmessager.appspot.com")
            storageRootRef = storageRootRef.child("ProfileImages").child(userID + ".png")
            
            let img = UIImage(named: "Sticker.png")
            if let imageData = UIImagePNGRepresentation(img!)
            {
                storageRootRef.put(imageData, metadata: nil, completion: { (metadata: FIRStorageMetadata?, error: Error?) in
                    
                    if let storageError = error
                    {
                        print("Firebase Upload Error")
                        print(storageError.localizedDescription)
                        return
                    }
                    else if let storageMetadata = metadata
                    {
                        if let imageURL = storageMetadata.downloadURL()
                        {
                            print(imageURL.absoluteString)
                            //1 Save in User DataBase 
                            
                            //let userData = ["ImageUrl":imageURL.absoluteString]
                            let dbRef = FIRDatabase.database().reference()
                            dbRef.child("Users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["userPhoto": imageURL.absoluteString])
                        }
                    }
                })
            }
        }
    }
    
}
