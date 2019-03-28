//
//  GameLogic.swift
//  Memory
//
//  Created by Pau Blanes on 21/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import Foundation

class GameLogic {
    
    var points = 0
    var pointsPerMatch = 0
    var pointsToWin = 0
    
    var cards = [Card]()
    var selected:Card?
    
    func Start(numPairs:Int, startingPoints:Int, pointsPerMatch:Int, pointsToWin:Int) {
        
        //Initialize points
        self.points = startingPoints
        self.pointsPerMatch = pointsPerMatch
        self.pointsToWin = pointsToWin
        
        //Initialize cards
        for _ in 0..<numPairs*2 {
            cards.append(Card())
        }
        for i in 0..<numPairs {
            
            let chosenPair = i //esto puede ser random de un banco de imágenes
            cards[i].pairId = chosenPair
            cards[i+numPairs].pairId = chosenPair
            
            cards[i].id = i
            cards[i+numPairs].id = i+numPairs
        }
        cards.shuffle()
    }
    
    //FUNCTIONALITY
    func tryMatch (cardToMath:Card) -> Bool {
        
        if let selected = self.selected {
            if (selected.pairId == cardToMath.pairId && selected.id != cardToMath.id) {
                points = points+self.pointsPerMatch
                selected.state = CardState.matched
                cardToMath.state = CardState.matched
                return true
            }
        }
        return false
    }
}
