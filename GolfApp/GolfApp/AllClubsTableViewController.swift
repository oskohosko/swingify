//
//  AllClubsTableViewController.swift
//  GolfApp
//
//  Created by Oskar Hosken on 2/5/2024.
//

import UIKit
import FirebaseFirestore

class AllClubsTableViewController: UITableViewController {
    
    var CELL_CLUB = "clubCell"
    
    var clubs: [Club] = []
    
    var clubsRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    
    // Function that adds a club to Firebase and to the TableView
    @IBAction func addClubAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Club", message: "Add Your Club Below", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Distance"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) {_ in
            let clubName = alertController.textFields![0]
            let clubDistance = alertController.textFields![1]
            var doesExist = false
            
            for club in self.clubs {
                if club.name.lowercased() == clubName.text!.lowercased() {
                    doesExist = true
                }
            }
            
            let newClub = Club(name: clubName.text!, distance: clubDistance.text!)
            
            if !doesExist {
                self.clubsRef?.addDocument(data: ["name": newClub.name,
                                                  "distance": newClub.distance])
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: false, completion: nil)
        }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let database = Firestore.firestore()
        clubsRef = database.collection("clubs")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        databaseListener = clubsRef?.addSnapshotListener() {
            (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            self.clubs.removeAll()
            querySnapshot?.documents.forEach() {
                snapshot in
//                let id = snapshot.documentID
                let name = snapshot["name"] as! String
                let distance = snapshot["distance"] as! String
                let newClub = Club(name: name, distance: distance)
                
                self.clubs.append(newClub)
                self.clubs.sort { $0.distance > $1.distance }
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clubs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CLUB, for: indexPath)

        // Configure the cell...
        let club = clubs[indexPath.row]
        cell.textLabel?.text = club.name
        cell.detailTextLabel?.text = club.distance

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}