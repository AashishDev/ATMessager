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
import GoogleMobileAds
import SDWebImage
import DTPhotoViewerController
import MarqueeLabel

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let ref = FIRDatabase.database().reference(withPath: "Users")
    var userList = [User]()
    var loginUser = [User]()
    var imagePicker = UIImagePickerController()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPhotoImg: UIImageView!
    @IBOutlet weak var userPhotoTable: UITableView!
    @IBOutlet weak var newsMarqueLabel: MarqueeLabel!
    
    
    /// The banner view.
    @IBOutlet weak var bannerView: GADBannerView!
    var userPhotoMenu = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // News feed marque Label
        newsMarqueLabel.speed = .rate(60)
        newsMarqueLabel.type = .continuous
        newsMarqueLabel.animationCurve = .easeInOut
        newsMarqueLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin vulputate ex at lorem gravida ultricies. Integer ultrices nunc tellus, eget pharetra ligula pretium sed. Nam iaculis congue nibh, at fermentum dolor. Maecenas laoreet nisl nec est tristique, sit amet pharetra nisl cursus. Praesent finibus dignissim risus. Sed sit amet sollicitudin turpis, ut molestie quam. Curabitur tempus, massa non blandit blandit, ipsum urna elementum orci, eget posuere erat magna nec lacus."
        
        // Add Google Banner
        showGoogleAds()
        userPhotoMenu = ["View Photo", "Upload New"]
        
        //1 Activity Indicator
        indicator.center = self.view.center
        view.addSubview(indicator)
        
        //2 UserImageview
        userPhotoImg.layer.cornerRadius = userPhotoImg.frame.size.height/2
        userPhotoImg.layer.masksToBounds = true;
        userPhotoImg.layer.borderColor = UIColor.white.cgColor
        userPhotoImg.layer.borderWidth = 1.5
        
        //3 Table Height & Get User listing
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 75
        getUserList()
        
        ref.observe(.value, with: { snapshot in
            
            
            var newItems: [User] = []
            let userID = FIRAuth.auth()?.currentUser?.uid
            
            let value = snapshot.value as? NSDictionary
            for (key, data) in value! {
                let keyName = key as! String
                let user = User.init(dictionary: data as! Dictionary<String, AnyObject>)
                if userID != keyName{
                    
                    newItems.append(user)
                }
                else{
                    self.loginUser.append(user);
                    let imageUrlString = user.userphoto
                    if imageUrlString.characters.count > 0{
                        self.userPhotoImg.sd_setImage(with: URL(string: imageUrlString))
                    }
                }
            }
            
            self.userList = newItems
            self.tableView.reloadData()
        })
        
    }
    
    func showGoogleAds()  {
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
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
        
        if tableView == userPhotoTable {
            return userPhotoMenu.count
        }
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == userPhotoTable {
            
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
            
            cell.textLabel?.font = cell.textLabel?.font.withSize(15)
            cell.textLabel?.text = userPhotoMenu[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
            //cell.contentView.backgroundColor =  UIColor(red: 74/255, green: 166/255, blue: 125/255, alpha: 1)
            cell.backgroundColor = UIColor.clear
            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
            
            let user = userList[indexPath.row]
            cell.nameLabel.text = user.name
            cell.locationLabel.text = user.location
            cell.onlineView.layer.cornerRadius = cell.onlineView.frame.size.height/2
            cell.onlineView.clipsToBounds = true
            
            let onlineStatus = user.online
            if onlineStatus == "1" {
                cell.onlineView.isHidden = false;
            }
            else{
                cell.onlineView.isHidden = true;
            }
            
            let imageUrlString = user.userphoto
            if imageUrlString.characters.count > 0 {
                cell.userImageView.sd_setImage(with: URL(string: imageUrlString))
                cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.height/2
                cell.userImageView.clipsToBounds = true
                cell.userImageView.layer.borderColor = UIColor(red: 74/255, green: 166/255, blue: 125/255, alpha: 1).cgColor
                cell.userImageView.layer.borderWidth = 1.5
            }
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        userPhotoTable.isHidden = true
        if tableView == userPhotoTable {
            
            if indexPath.row == 0 {
            
                //1] View Photo in Full Screen
                showImageFullScreen()
            }
            else {
            
                //2] Upload new photo on Server
                uploadPhoto()
            }
        }
        else {
            
            let user = userList[indexPath.row]
            let chatView = ChatViewController()
            chatView.senderDisplayName = user.name
            chatView.chatUser = user
            chatView.loginUser = loginUser[0]
            self.navigationController?.pushViewController(chatView, animated: true)
        }
    }
    
    // MARK: UIButton Action
    
    //1] Logout Button
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        if FIRAuth.auth()?.currentUser != nil {
            do {
                
                // Set Online Status
                let dbRef = FIRDatabase.database().reference()
                dbRef.child("Users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["online": "0"])
                
                try FIRAuth.auth()?.signOut()
                self.navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func showImageFullScreen()  {
      
        if let viewController = DTPhotoViewerController(referencedView: self.userPhotoImg, image: self.userPhotoImg.image) {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    
    //2] Profile Button
    @IBAction func profileImgBtnTapped(_ sender: UIButton) {
        
        userPhotoTable.isHidden = !userPhotoTable.isHidden
    }
    
    func uploadPhoto()  {
        
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
    
    func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [String : Any]) {
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
