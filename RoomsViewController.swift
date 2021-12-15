//
//  RoomsViewController.swift
//  All4s Pro
//
//  Created by Adrian Bartholomew on 11/25/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class RoomsViewController: UITableViewController {
    lazy var functions = Functions.functions()
    let userDefaults = UserDefaults.standard

//    let db = Firestore.firestore()
    var gameRef: DocumentReference? = nil
    var ROOM_ID: String!
    var UID: String!
    var OWNER: Bool!
    
    var emailField: UITextField!
    var usernameField: UITextField!
    var passwordField: UITextField!
    
    var authListener: AuthStateDidChangeListenerHandle!
    
    var rooms: [QueryDocumentSnapshot]!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.present(self.createLoginModal(), animated: true, completion: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.authListener != nil {
            Auth.auth().removeStateDidChangeListener(self.authListener)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (rooms ?? []).count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let room = rooms![indexPath.row]
        ROOM_ID = room.documentID
        getFirstAvailableGame() { game in
            if let game = game {
                self.gameRef = game.reference
                self.OWNER = false
                self.performSegue(withIdentifier: "showRootController", sender: self)
            } else {
                self.OWNER = true
                self.createFirebaseGame() {
                    self.performSegue(withIdentifier: "showRootController", sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showRootController") {
            guard let navController = segue.destination as? NavigationViewController else { return }
            if let viewController = navController.topViewController as? RootViewController {
                viewController.GameRef = gameRef
                viewController.RoomId = ROOM_ID
                viewController.OWNER = OWNER
                viewController.UID = UID
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        if rooms != nil {
            let room = rooms[indexPath.row]
            let data = room.data()
            cell.textLabel?.text = data["name"] as? String
            cell.detailTextLabel?.text = data["desc"] as? String
        }

        return cell
    }
    
    func getRooms(_ complete: @escaping (_ querySnapshot: QuerySnapshot?) -> ()) {
        let db = Firestore.firestore()
        db.collection("rooms").getDocuments { (querySnapshot, error) in
            if error != nil { complete(nil) }
            complete(querySnapshot)
        }
    }
    
    func createFirebaseGame(_ complete: @escaping ()->Void) {
        var ref: DocumentReference? = nil
        let db = Firestore.firestore()
        
        let gameData: [String: Any] = [
            "ownerId": UID as Any,
            "timestamp": Date().currentTimeMillis() as Any,
            "available": true
            ]
        ref = db.collection("rooms").document(ROOM_ID).collection("games").addDocument(data:gameData) { err in
            if let err = err {
                print("Error creating new game in Firestore: \(err)")
            } else {
                print("Successfully created new game in Firestore: \(ref!.documentID)")
                self.gameRef = ref
                complete()
            }
        }
        
    }

    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
