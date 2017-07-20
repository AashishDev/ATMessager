//
//  UserListViewController.swift
//  ATMessager
//
//  Created by MOBILE MAC1 on 7/19/17.
//  Copyright © 2017 MOBILE MAC1. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
