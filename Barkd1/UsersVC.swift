//
//  UsersVC.swift
//  Barkd1
//
//  Created by MacBook Air on 3/23/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase

class UsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // The class of Users compiles, but the struct User does not. The problem seems to be around the "imagePath" variable, will need to look into this further and play around with it.
    
    var users = [Users]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveUser()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func retrieveUser() {
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            self.users.removeAll()
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid != FIRAuth.auth()!.currentUser!.uid {
                        var userToShow = Users(snapshot: snapshot)
                        if let username = value["username"] as? String, let photoURL = value["photoURL"] as? String {
                            userToShow.username = username
                            userToShow.photoURL = photoURL
                            userToShow.uid = uid
                            self.users.append(userToShow)
                            print("BRIAN: All of the users have been retrieved")
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
            
        })
        
        ref.removeAllObservers()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        
        // Code is crashing here - unwrapping the optional value of username?
        
        cell.userName.text = users[indexPath.row].username
        cell.userID = users[indexPath.row].uid
        cell.userImage.downloadImage(from: self.users[indexPath.row].photoURL!)
        checkFollowing(indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let following = snapshot.value as? [String: AnyObject] {
                for (ke, value) in following {
                    if value as! String == self.users[indexPath.row].uid {
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.users[indexPath.row].uid).child("followers/\(ke)").removeValue()
                        
                        
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            
            if !isFollower {
                let following = ["following/\(key)" : self.users[indexPath.row].uid]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.users[indexPath.row].uid).updateChildValues(followers)
                
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                
            }
            
        })
        
        ref.removeAllObservers()
        
    }
    
    func checkFollowing(indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let following = snapshot.value as? [String: AnyObject] {
                for (_, value) in following {
                    if value as! String == self.users[indexPath.row].uid {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        
        ref.removeAllObservers()
        
    }
    
}

extension UIImageView {
    
    func downloadImage(from imageURL: String!) {
        let url = URLRequest(url: URL(string: imageURL)!)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
                
            }
        }
        
        task.resume()
        
    }
    
}

