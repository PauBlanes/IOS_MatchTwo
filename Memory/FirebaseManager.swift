//
//  FirebaseManager.swift
//  Memory
//
//  Created by Pau Blanes on 29/4/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import Foundation
import FirebaseUI
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let instance = FirebaseManager()
    
    static var controller: GameViewController?
    
    let collectionScores = Firestore.firestore().collection("Users")
    
    private init() {
        
    }
    
    //FIRESTORE
    func createUser(user: User) {
        guard let user = Auth.auth().currentUser else {
            print("There is no user")
            return
        }        
        collectionScores
            .document(user.uid)
            .setData(user,merge: true) //Fer serializable, com?
    }
    
    //AUTH
    func tryLogin(){
        
        if Auth.auth().currentUser != nil {
            FirebaseManager.controller?.goToMenu(sender: nil)
        } else {
            guard let authUI = FUIAuth.defaultAuthUI() else {
                
                return
            }
            // You need to adopt a FUIAuthDelegate protocol to receive callback
            authUI.delegate = FirebaseManager.controller
            
            let providers: [FUIAuthProvider] = [
                FUIGoogleAuth()
            ]
            authUI.providers = providers
            
            let authViewController = authUI.authViewController()
            FirebaseManager.controller?.goToAuthScene(controller: authViewController)
        }
    }
    func logOut() {
        guard let authUI = FUIAuth.defaultAuthUI() else {
            return
        }
        
        do {
            try authUI.signOut()
        } catch {
            print(error)
        }
        
        tryLogin()
    }
    func getUserId() -> String {
        guard let id = Auth.auth().currentUser?.uid else {
            print("User is nil")
            return ""
        }
        return id
    }
}

//Callback for the sign in
extension GameViewController: FUIAuthDelegate {
    
    //Callback
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        //Check if there was an error
        if error != nil {
            print("AQUI ERROR : " + error.debugDescription)
            return
        }
        
        goToMenu(sender: nil)
    }
}

//Remove cancel Button
extension FUIAuthBaseViewController{
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
    }
}
