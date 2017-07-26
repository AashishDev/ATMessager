//
//  ChatViewController.swift
//  ATMessager
//
//  Created by MOBILE MAC1 on 7/24/17.
//  Copyright © 2017 MOBILE MAC1. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {
    
    
    let ref = FIRDatabase.database().reference(withPath: "Conversation")
    private var newMessageRefHandle: FIRDatabaseHandle?

    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var chatUser: User?
    var loginUser: User?
    var messages = [JSQMessage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.senderDisplayName
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        observeMessages()
        
        // No avatars
        // collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        // collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 40, height: 45)
        //collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 40, height: 45)
        collectionView!.collectionViewLayout.minimumLineSpacing = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        //        self.navigationController?.navigationBar.barTintColor = UIColor(red: 74/255, green: 166/255, blue: 125/255, alpha: 1)
        //        self.navigationController?.navigationBar.tintColor = UIColor.white
        //        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func observeMessages() {
        
        let user1 = self.senderId
        let user2 = self.chatUser?.id
        let roomName = "chat_"+(user1!<user2! ? user1!+"_"+user2! : user2!+"_"+user1!);
        let messageQuery = ref.child(roomName).queryLimited(toLast:25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                // 5
                self.finishReceivingMessage()
                
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }

    // MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        let ref = FIRDatabase.database().reference(withPath: "Users").child(message.senderId)
        ref.observe(.value, with: { snapshot in
            
            let value = snapshot.value as? NSDictionary
            let imageUrlString = value?["userPhoto"] as! String
            let url = URL(string: imageUrlString)
            if imageUrlString.characters.count > 0 {
                cell.avatarImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "App-Default"), options: []) { (image, error, imageCacheType, imageUrl) in
                    
                    cell.avatarImageView.image = JSQMessagesAvatarImageFactory.circularAvatarImage(image, withDiameter: 88)
                }
            }
        })

        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
       
        
        
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        //return 15
        
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         */
  
        /**
         *  iOS7-style sender name labels
         */
        let currentMessage = self.messages[indexPath.item]
        
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    
    
    // MARK: Pressed Send Button
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let user1 = self.senderId
        let user2 = self.chatUser?.id
        let roomName = "chat_"+(user1!<user2! ? user1!+"_"+user2! : user2!+"_"+user1!);
        let itemRef = ref.child(roomName).childByAutoId() // 1
        
        let imageUrlString = loginUser?.userphoto
        var photoUrl = ""
        if (imageUrlString?.characters.count)! > 0 {
            photoUrl = imageUrlString!
        }
        
        // Get Current date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MMM/yy HH:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let dateString = formatter.string(from: Date())
        
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "userPhoto": photoUrl,
            "timeStamp": dateString,
            ]
        itemRef.setValue(messageItem) // 3
        
        /* let message = JSQMessage(senderId: self.senderId, displayName:"Rohan", text: "I am fine, How's You")
         self.messages.append(message!)*/
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
    }
    
    // MARK: UI and User Interaction
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
       
        //let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let bubbleImageFactory = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularTailless(), capInsets: UIEdgeInsets.zero)
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(red: 74/255, green: 166/255, blue: 125/255, alpha: 1))
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        //let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        let bubbleImageFactory = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularTailless(), capInsets: UIEdgeInsets.zero)
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
