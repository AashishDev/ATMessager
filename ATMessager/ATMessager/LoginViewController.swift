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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: UIButton Action
    //1] Login
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    if let name = user?.email {
                        print(name)
                    }
                    
                    //Go to the UserListViewController if the login is sucessful
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserList")
                    self.present(vc!, animated: true, completion: nil)
                    
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
    
    //2] SignUp
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Create account for Messager",
                                      message: "",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        let emailField = alert.textFields![0]
                                        let passwordField = alert.textFields![1]
                                        
                                        if emailField.text == "" || passwordField.text == "" {
                                            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
                                            
                                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                            alertController.addAction(defaultAction)
                                            self.present(alertController, animated: true, completion: nil)
                                        }
                                        else{
                                            
                                            //A Firebase Authnication
                                            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                                                
                                                if error == nil {
                                                    
                                                    let name = "Testuser"
                                                    let surname = "Swift"
                                                    if let userId = user?.uid{
                                                        
                                                        let userData = ["name": name,
                                                                        "surname ": surname]
                                                        let ref = FIRDatabase.database().reference()
                                                        ref.child("Users").child(" ").setValue(userData)
                                                        //ref.child("users").child(userId);).setValue(userData)
                                                        
                                                    }
                                                    
                                      
                                                    
                                                    print("You have successfully signed up")
                                                    
                                                    
                                                } else {
                                                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                                                    
                                                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                                    alertController.addAction(defaultAction)
                                                    
                                                    self.present(alertController, animated: true, completion: nil)
                                                }
                                                //-- @ENd
                                            }
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
}
