//
//  LoginViewController.swift
//  ATMessager
//
//  Created by MOBILE MAC1 on 7/19/17.
//  Copyright © 2017 MOBILE MAC1. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Utils.showActivty(vwController: self)
        
        //1 Activity Indicator
        indicator.center = self.view.center
        view.addSubview(indicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Testing Only 
//        emailTextField.text = "a@g.com"
//        passwordTextField.text = "abc123"
//        //validateAndLogin()
    }
    
    // MARK: UIButton Action
    //1] Login
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        validateAndLogin()
    }
    
    //2] SignUp
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUp")
        self.present(vc!, animated: true, completion: nil)
    }
    

    func validateAndLogin()  {
        
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            indicator.startAnimating()
            FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                self.indicator.stopAnimating()
                if error == nil {
                    
                    // Set Online Status
                    let dbRef = FIRDatabase.database().reference()
                    dbRef.child("Users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["online": "1"])
                    
                    print("You have successfully logged in")
                    //Go to the UserListViewController if the login is sucessful
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserList")
                    self.navigationController?.pushViewController(vc!, animated: true)
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
}
