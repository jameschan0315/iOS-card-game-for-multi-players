//
//  LoginModal.swift
//  All4s Pro
//
//  Created by Adrian Bartholomew on 10/27/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

extension RoomsViewController {
    
    func addEmailTextField(_ textField: UITextField!) {
        textField.placeholder = "Email"
        emailField = textField
        if let email = userDefaults.value(forKey: "email") as? String {
            emailField.text = email
        }
    }
    
    func addUsernameTextField(_ textField: UITextField!) {
        textField.placeholder = "Username"
        usernameField = textField
        if let username = userDefaults.value(forKey: "username") as? String {
            usernameField.text = username
        }
    }
    
    func addPasswordTextField(_ textField: UITextField!) {
        textField.placeholder = "Password"
        passwordField = textField
        passwordField.isSecureTextEntry = true
        if let password = userDefaults.value(forKey: "password") as? String {
            passwordField.text = password
        }
    }
    
    func createLoginModal() -> UIAlertController {

        let alertController = UIAlertController(title: "Welcome To Trinidad AllFours!", message:
            "Please login to play", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField(configurationHandler: addEmailTextField)
        alertController.addTextField(configurationHandler: addPasswordTextField)
        alertController.addTextField(configurationHandler: addUsernameTextField)
        alertController.addAction(UIAlertAction(title: "Signup", style: UIAlertAction.Style.default, handler: {[weak self](action: UIAlertAction) in
            //send to firebase here
            guard let email = self?.emailField?.text else {return}
            guard let password = self?.passwordField?.text else {return}
            guard let username = self?.usernameField?.text else {return}
            
            if self?.authListener != nil {
                Auth.auth().removeStateDidChangeListener((self?.authListener)!)
            }
            self?.authListener =  Auth.auth().addStateDidChangeListener { (auth, user) in
                guard let user = user else { return }
                self?.createUserRecord(user.uid)
                print("Sign Up Successfully. \(user.uid)")
                self?.UID = user.uid
                self?.storeMyEmail(user.email)
                self?.storeMyPassword(password)
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges(completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    self?.storeMyUserName(user.displayName)

                    self?.getRooms() {
                        self?.rooms = $0?.documents.map{$0}
                        self?.tableView.reloadData()
                    }
                })
            }
            
            Auth.auth().createUser(withEmail: email, password: password)
        }))

        alertController.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: {[weak self](action: UIAlertAction) in
            //send to firebase here
            
            guard let email = self?.emailField?.text else {return}
            guard let password = self?.passwordField?.text else {return}
            if self?.authListener != nil {
                Auth.auth().removeStateDidChangeListener((self?.authListener)!)
            }
            self?.authListener = Auth.auth().addStateDidChangeListener { (auth, user) in
                guard let user = user else {
                    print("Problem signing in.")
                    return
                }
                self?.createUserRecord(user.uid)
                print("Signed in Successfully. \(user.displayName ?? "")")
                self?.UID = user.uid
                self?.storeMyUID(user.uid)
                self?.storeMyUserName(user.displayName)
                self?.storeMyEmail(user.email)
                self?.storeMyPassword(password)
                self?.getRooms() {
                    self?.rooms = $0?.documents.map{$0}
                    self?.tableView.reloadData()
                }
            }
            Auth.auth().signIn(withEmail: email, password: password)
        }))
        return alertController
    }
    
    func createUserRecord(_ uid: String) {
        let db = Firestore.firestore()
        let rtDb = Database.database().reference()
        rtDb.child("users/\(uid)").setValue(["dummyKey": true])
        db.collection("users").document(uid).setData(["online": true, "room": "", "game": "", "seat": "", "timestamp": Timestamp(date: Date())], merge: true) { err in
            if let err = err {
                print("Error writing Firestore User: \(err)")
            } else {
                print("Firestore User successfully written!")
            }
        }
        rtDb.child("users/\(uid)/dummyKey").onDisconnectRemoveValue { error, reference in
          if let error = error {
            print("Could not establish onDisconnect event: \(error)")
          }
        }
    }

    func logout() {
        storeMyEmail("")
        storeMyPassword("")
        storeMyUserName("")
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                print("Successfully SIGNED OUT")
            }
            catch {
                print("Problem signing out")
            }
        }
    }
    
    func getFirstAvailableGame(cb: @escaping (QueryDocumentSnapshot?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("rooms/\(ROOM_ID!)/games").whereField("available", isEqualTo: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting available games: \(err)")
                } else {
                    let games = querySnapshot!.documents
                    for gameRef in games {
                        print("available games \(gameRef.documentID) => \(gameRef.data())")
                    }
                    if games.count > 0 {
                        cb(querySnapshot?.documents[0])
                    } else {
                        cb(nil)
                    }
                }
        }
    }
    
    func storeMyUID(_ uid: String?) {
        userDefaults.set(uid, forKey: "uid")
    }
    
    func storeMyUserName(_ username: String?) {
        userDefaults.set(username, forKey: "username")
    }
    
    func storeMyEmail(_ email: String?) {
        userDefaults.set(email, forKey: "email")
    }
    
    func storeMyPassword(_ password: String?) {
        userDefaults.set(password, forKey: "password")
    }
}
