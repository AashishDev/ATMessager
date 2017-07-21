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
import SDWebImage


class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var userList = [User]()
    var loginUser = [User]()
    var imagePicker = UIImagePickerController()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPhotoImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1 Activity Indicator
        indicator.center = self.view.center
        view.addSubview(indicator)
        
        //2 UserImageview
        userPhotoImg.layer.cornerRadius = 15
        userPhotoImg.layer.masksToBounds = true;
        userPhotoImg.layer.borderColor = UIColor.white.cgColor
        userPhotoImg.layer.borderWidth = 0.4
        
        //3 Table Height & Get User listing
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
                let user = User.init(dictionary: data as! Dictionary<String, AnyObject>)
                if userID != keyName{
                    
                    self.userList.append(user)
                }
                else{
                    self.loginUser.append(user);
                    let imageUrlString = user.userphoto
                    if imageUrlString.characters.count > 0{
                        self.userPhotoImg.sd_setImage(with: URL(string: imageUrlString))
                    }
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
        
        let loginUser = self.loginUser[0]
        let imageUrlString = loginUser.userphoto
      /*  if imageUrlString.characters.count > 0{
        
        userPhotoImg.sd_setImage(with: URL(string: imageUrlString))
            
        }
        else{
           */
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                print("Button capture")
                
                imagePicker.delegate = self
                imagePicker.sourceType = .savedPhotosAlbum;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        //}
        print("Profile Button Clicked !!");
    }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            uploadUserImage(selectedImg: image)
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func uploadUserImage(selectedImg: UIImage)
    {
        
        indicator.startAnimating()
        var storageRootRef: FIRStorageReference!
        if  let userID:String = FIRAuth.auth()?.currentUser?.uid {
            
            storageRootRef = FIRStorage.storage().reference(forURL:"gs://atmessager.appspot.com")
            storageRootRef = storageRootRef.child("ProfileImages").child(userID + ".png")
            
            if let imageData = UIImagePNGRepresentation(selectedImg)
            {
                storageRootRef.put(imageData, metadata: nil, completion: { (metadata: FIRStorageMetadata?, error: Error?) in
                    
                    if let storageError = error
                    {
                        self.indicator.stopAnimating()
                        print("Firebase Upload Error")
                        print(storageError.localizedDescription)
                        return
                    }
                    else if let storageMetadata = metadata
                    {
                        if let imageURL = storageMetadata.downloadURL()
                        {
                            print(imageURL.absoluteString)
                            //let userData = ["ImageUrl":imageURL.absoluteString]
                            let dbRef = FIRDatabase.database().reference()
                            dbRef.child("Users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["userPhoto": imageURL.absoluteString])
                            self.userPhotoImg.sd_setImage(with: URL(string: imageURL.absoluteString))
                            self.indicator.stopAnimating()
                        }
                    }
                })
            }
        }
    }
    
}
