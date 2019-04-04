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
    
    var consecutiveMatches = 0
    
    
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
            
            let chosenPair = i%13 //esto puede ser random de un banco de imágenes
            cards[i].pairId = chosenPair
            cards[i+numPairs].pairId = chosenPair
            
            cards[i].id = i
            cards[i+numPairs].id = i+numPairs
        }
        cards.shuffle()
    }
    
    //FUNCTIONALITY
    func findCard (id: Int) -> Card {
        for card in self.cards {
            if card.id == id {
                return card
            }
        }
        return Card()
    }
    
    func tryMatch(card1:Card, card2:Card) -> Bool {
        
        if card2.pairId == card1.pairId {
            card2.state = CardState.matched
            card1.state = CardState.matched
            self.selected = nil
            points = points+self.pointsPerMatch
            consecutiveMatches += 1
            return true
        }
        else {
            card2.state = CardState.covered
            card1.state = CardState.covered
            consecutiveMatches = 0
            return false
        }
        
    }
    
    func cardSelected(cardId:Int, completed : (_ cardId: Int,_ cardState: CardState,_ delay: Double) -> Void) {
        
        let card = findCard(id: cardId)
        
        //1. Está emparejada?
        if card.state == CardState.matched {
            return
        }
        
        //2. está destapada?
        if card.state == CardState.uncovered {
            self.selected = nil
            card.state = CardState.covered
            completed(card.id, CardState.covered, 0)
            return
        }
        
        //3. está tapada?
        if card.state == CardState.covered {
            
            //Si existe selected intentamos match
            if let selected = self.selected {
                
                //Es match? -> boca arriba
                if tryMatch(card1: card, card2: selected) {
                    completed(card.id, CardState.uncovered, 0)
                }
                //no es match? giramos las dos
                else {
                    //Ponemos la actual boca arriba
                    completed(card.id, CardState.uncovered, 0)
                    
                    //Esperamos y giramos las dos
                    completed(card.id,CardState.covered,CardSprite.flipTime + CardSprite.waitUntilFlipBack)
                    completed(selected.id,CardState.covered,CardSprite.flipTime + CardSprite.waitUntilFlipBack)
                    
                    self.selected = nil
                }
            }
            //no hay selected? -> la seteo
            else {
                self.selected = card
                card.state = CardState.uncovered
                completed(card.id, CardState.uncovered, 0)
            }
        }
    }
}
