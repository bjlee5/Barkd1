//
//  FriendsVC.swift
//  Barkd1
//
//  Created by MacBook Air on 4/13/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase 

class FriendsVC: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var users = [Friend]()
    var filteredArray = [Friend]()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    
    @IBOutlet weak var friendsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveUser()
        configureSearchController()
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
                        if let username = value["username"] as? String {
//                        let imagePath = value["photoURL"] as? String
                        
                            
                            userToShow.username = username
//                            userToShow.imagePath = imagePath
                            userToShow.userID = uid
                            self.users.append(userToShow)
                        }
                    }
                }
            }
            
            self.friendsTableView.reloadData()
            
        })
        
        ref.removeAllObservers()
        
    }

    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray.count
        }
        else {
            return users.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.friendsTableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        
        var friend = Friend()
        
        if shouldShowSearchResults {
            
            friend = filteredArray[indexPath.row]
        }
        else {
            friend = users[indexPath.row]
        }
        
        cell.userName.text = friend.username
        cell.userID = friend.userID
//        cell.userImage.downloadImage(from: friend.imagePath!)
        checkFollowing(indexPath: indexPath)
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
                        
                        
                        self.friendsTableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            
            if !isFollower {
                let following = ["following/\(key)" : self.users[indexPath.row].userID]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.users[indexPath.row].userID).updateChildValues(followers)
                
                self.friendsTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                
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
                        self.friendsTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        
        ref.removeAllObservers()
        
    }
    
    // MARK: - Search Controller
    

    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        filteredArray = users.filter({ (friend: Friend) -> Bool in
            let friendText = friend.username as NSString
            
            return (friendText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        // Reload the tableview.
       friendsTableView.reloadData()
    }

    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Find Friends..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        friendsTableView.tableHeaderView = searchController.searchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("BRIAN: Search Bar text is being run")
        shouldShowSearchResults = true
        friendsTableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        friendsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            friendsTableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
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

