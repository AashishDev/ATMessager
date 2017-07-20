//
//  SignupViewController.swift
//  ATMessager
//
//  Created by MOBILE MAC1 on 7/20/17.
//  Copyright © 2017 MOBILE MAC1. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignupViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var mobileField: UITextField!
    @IBOutlet weak var currentLocationField: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        emailField.text = ""
        passwordField.text = ""
    }
    
    // MARK: Button Action
    //1] Submit
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        
        if emailField.text == "" || passwordField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            
            createNewAccount()
        }
    }
    
    //2] Back
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion:nil)
    }
    
   // MARK: UserDefined Function
    func createNewAccount() {
        
        FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            
            if error == nil { //1 Successfully Signup
                
                self.saveUserDetails(user:user)
            }
            else {
                //2 Failure in account creation
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    // Save user details in Firebase Database
    func saveUserDetails(user:FIRUser?){
        
        if let userId = user?.uid { //3 Get User Id
            
            let userEmail = emailField.text
            let userName = fullNameField.text
            let userMobile = mobileField.text
            let userLocation = currentLocationField.text
            
          let userData = ["id":userId,"name":userName, "email":userEmail, "mobile": userMobile, "location":userLocation]
          let dbRef = FIRDatabase.database().reference()
            dbRef.child("Users").child(userId).setValue(userData)
          self.dismiss(animated: true, completion: nil)
        }
    }
    
}


