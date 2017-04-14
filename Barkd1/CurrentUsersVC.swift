//
//  CurrentUsersVC.swift
//  Barkd1
//
//  Created by MacBook Air on 4/3/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase 

class CurrentUsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    var users = [Friend]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var userArray = [NSDictionary?]()
    var filteredUsers = [NSDictionary?]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        retrieveUser()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
//        DataService.ds.REF_USERS.queryOrdered(byChild: "username").observe(.childAdded, with: { (snapshot) in
//            
//            self.userArray.append(snapshot.value as? NSDictionary)
//            
//            // Insert Rows
//            
//        }) { (error) in
//            print(error.localizedDescription)
//        }
        
    }
    
    func retrieveUser() {
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            self.users.removeAll()
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid != FIRAuth.auth()!.currentUser!.uid {
                        let userToShow = Friend()
                        if let username = value["username"] as? String, let imagePath = value["photoURL"] as? String {
                            userToShow.username = username
                            userToShow.imagePath = imagePath
                            userToShow.userID = uid
                            self.users.append(userToShow)
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
            
        })
        
        ref.removeAllObservers()
        
    }
    
    // Do NOT modify the userID in these funcs //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        
        cell.userName.text = users[indexPath.row].username
        cell.userID = users[indexPath.row].userID
//        cell.userImage.downloadImage(from: self.users[indexPath.row].imagePath!)
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
                    if value as! String == self.users[indexPath.row].userID {
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.users[indexPath.row].userID).child("followers/\(ke)").removeValue()
                        
                        
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            
            if !isFollower {
                let following = ["following/\(key)" : self.users[indexPath.row].userID]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.users[indexPath.row].userID).updateChildValues(followers)
                
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
                    if value as! String == self.users[indexPath.row].userID {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        
        ref.removeAllObservers()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
            // Update search results

    }
    
    @IBAction func backPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

//extension UIImageView {
//    
//    func downloadImage(from imageURL: String!) {
//        let url = URLRequest(url: URL(string: imageURL)!)
//        
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            
//            if error != nil {
//                print(error!)
//                return
//            }
//            DispatchQueue.main.async {
//                self.image = UIImage(data: data!)
//                
//            }
//        }
//        
//        task.resume()
//        
//    }
//    
//}
