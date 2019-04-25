//
//  FirestoreRepository.swift
//  Memory
//
//  Created by Pau Blanes on 25/4/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirestoreRepository {
    
    let collectionScores = Firestore.firestore().collection("scores")
    
    func writeUserScore (score: Int, username: String?, userId: String) {
        
        collectionScores
            .document(userId)
            .setData([
                "score": score,
                "username": username ?? "Anonymous",
                "userId": userId],
            merge: true)
        
        //Aixo aniria creant documents
        /*collectionScores.addDocument(data: [
            "score": score,
            "username": username ?? "empty",
            "userId": userId])*/
    }
    
    func getUserScore () {
        collectionScores
            .whereField("score", isGreaterThan: 0)
            .order(by: "score", descending: true)
            .getDocuments{(snapshot, error) in
                
                if let error = error {
                    print(error)
                    return
                }
                snapshot?.documents.forEach({print($0.data())})
            }
    }
}
