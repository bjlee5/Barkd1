//
//  CurrentUsersVC.swift
//  Barkd1
//
//  Created by MacBook Air on 4/3/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase 

class CurrentUsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var users = [Users]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        retrieveUser()
        
    }
    
    func retrieveUser() {
        DataService.ds.REF_BASE.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            self.users = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                }
            }
        })
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
