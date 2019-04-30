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
    
    let K_ID = "id"
    let K_NICK = "username"
    let K_HIGHSCORE = "highscore"
    let RANKINGS_PATH = "Rankings/Highscores"
    let K_SCORES = "scores"
    let K_USERNAMES = "usernames"
    
    private init() {
        
    }
    
    //FIRESTORE
    func createUser(username: String) { //Swift no soporta hacer upload de custom clases
        
        let userID = getUserId()
        
        collectionScores
            .document(userID)
            .setData([
                K_ID: userID,
                K_NICK: username,
                K_HIGHSCORE: 0])
    }
    func updateHighscore (score: Int) {
        
        var savedHighscore = 0
        var savedUsername = "Anonymous"
        
        //1. comprobar si hay highscore y recuperarla
        collectionScores.document(getUserId()).getDocument { (document, error) in
            if let document = document, document.exists {
        
                guard let highscore = (document.get(self.K_HIGHSCORE) as? Int) else {
                   print("Highscore is nil")
                   return
                }
                savedHighscore = highscore
                
                guard let username = (document.get(self.K_NICK) as? String) else {
                    print("username is nil")
                    return
                }
                savedUsername = username
                
                //2. Si hemos mejorado la score la subo
                if score > savedHighscore {
                    self.collectionScores.document(self.getUserId()).updateData([self.K_HIGHSCORE: score])
                    self.updateRankings(score: score, username: savedUsername)
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    func updateRankings(score: Int, username: String) {
        let docRef = Firestore.firestore().document(RANKINGS_PATH)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var scores:[Int] = document.get(self.K_SCORES) as! [Int]
                var usernames:[String] = document.get(self.K_USERNAMES) as! [String]
                
                if scores.count == 0 {
                    scores.insert(score, at: 0)
                    usernames.insert(username, at: 0)
                }
                
                docRef.updateData([self.K_SCORES: scores])
                docRef.updateData([self.K_USERNAMES: usernames])
                
            } else {
                print("Document does not exist")
            }
        }
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
    func isNewUser() -> Bool {
        
        //Current user metadata reference
        let newUserRref = Auth.auth().currentUser?.metadata
        
        /*Check if the automatic creation time of the user is equal to the last
         sign in time (Which will be the first sign in time if it is indeed
         their first sign in)*/
        
        let creationDate = newUserRref?.creationDate?.timeIntervalSince1970
        let lastSignInDate = newUserRref?.lastSignInDate?.timeIntervalSince1970
        
        if creationDate?.truncate(places: 1) == lastSignInDate?.truncate(places: 1){
            //user is new user
            print("Hello new user")
            return true
        }
        
        //user is returning user
        print("Welcome back!")
        return false
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
        
        //Mostrem popup del username si cal
        if FirebaseManager.instance.isNewUser() {
            usernamePopup()
        } else{
            goToMenu(sender: nil)
        }
        
    }
}

//Remove cancel Button
extension FUIAuthBaseViewController{
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
    }
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
