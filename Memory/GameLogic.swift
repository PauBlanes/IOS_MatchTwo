//
//  GameLogic.swift
//  Memory
//
//  Created by Pau Blanes on 21/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import Foundation

enum CardSelectedResult {
    case alreadyMatched, flipUp, flipDown, match, failMatch, error
}

class GameLogic {
    
    var points = 0
    var pointsPerMatch = 0
    
    var cards = [Card]()
    var selected:Card?
    
    var consecutiveMatches = 0
    var pairsMatched = 0
    
    var levelTimerValue = 0
    
    func Start(numPairs:Int, startingPoints:Int, pointsPerMatch:Int, levelTimerInSeconds: Int) {
        
        //Initialize points
        self.points = startingPoints
        self.pointsPerMatch = pointsPerMatch
        self.levelTimerValue = levelTimerInSeconds
        resetCombos()
        
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
            levelTimerValue += 10
            consecutiveMatches += 1
            pairsMatched += 1
            points += (self.pointsPerMatch*self.consecutiveMatches)
            return true
        }
        else {
            card2.state = CardState.covered
            card1.state = CardState.covered
            resetCombos()
            return false
        }
        
    }
    
    func resetCombos() {
        self.consecutiveMatches = 0
    }
    
    func cardSelected(cardId:Int) -> CardSelectedResult {
        
        let card = findCard(id: cardId)
        
        //1. Está ya emparejada?
        if card.state == CardState.matched {
            return CardSelectedResult.alreadyMatched
        }
        
        //2. está destapada?
        if card.state == CardState.uncovered {
            self.selected = nil
            card.state = CardState.covered
            
            return CardSelectedResult.flipDown
        }
        
        //3. está tapada?
        if card.state == CardState.covered {
            
            //Si habia una seleccionada intentamos match
            if let selected = self.selected {
                
                //Es match? -> boca arriba
                if tryMatch(card1: card, card2: selected) {
                    
                    self.selected = nil
                    return CardSelectedResult.match
                }
                //no es match? tapamos las dos
                else {
                    
                    self.selected = nil
                    return CardSelectedResult.failMatch
                }
            }
            //no hay selected? -> esta será el selected
            else {
                self.selected = card
                card.state = CardState.uncovered
                
                return CardSelectedResult.flipUp
            }
        }
        
        return CardSelectedResult.error
    }
    
    func didWin() -> Bool {
        return pairsMatched >= cards.count/2
    }
    func didLose() -> Bool {
        return levelTimerValue <= 0
    }
}
