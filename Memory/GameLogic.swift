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
    
    var cards = [Card]()
    var selected:Card?
    
    var consecutiveMatches = 1
    
    
    
    func Start(numPairs:Int, startingPoints:Int, pointsPerMatch:Int) {
        
        //Initialize points
        self.points = startingPoints
        self.pointsPerMatch = pointsPerMatch
        self.consecutiveMatches = 1
        
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
            points += (self.pointsPerMatch*self.consecutiveMatches)
            consecutiveMatches += 1
            return true
        }
        else {
            card2.state = CardState.covered
            card1.state = CardState.covered
            consecutiveMatches = 1
            return false
        }
        
    }
    
    func cardSelected(cardId:Int, flipAnimation: ((Int, CardState, Double) -> Void)?) {
        
        let card = findCard(id: cardId)
        
        //1. Está emparejada?
        if card.state == CardState.matched {
            return
        }
        
        //2. está destapada?
        if card.state == CardState.uncovered {
            self.selected = nil
            card.state = CardState.covered
            
            if let flipAnim = flipAnimation {
                flipAnim(card.id, CardState.covered, 0)
            }
            
            return
        }
        
        //3. está tapada?
        if card.state == CardState.covered {
            
            //Si existe selected intentamos match
            if let selected = self.selected {
                
                //Es match? -> boca arriba
                if tryMatch(card1: card, card2: selected) {
                    
                    self.selected = nil
                    
                    //Si tenemos animación giramos
                    if let flipAnim = flipAnimation {
                        flipAnim(card.id, CardState.uncovered, 0)
                    }
                }
                //no es match? giramos las dos
                else {
                    
                    //si tenemos animacion giramos cartas
                    if let flipAnim = flipAnimation {
                        //Ponemos la actual boca arriba
                        flipAnim(card.id, CardState.uncovered, 0)
                        
                        //Esperamos y giramos las dos
                        flipAnim(card.id,CardState.covered,CardSprite.flipTime + CardSprite.waitUntilFlipBack)
                        flipAnim(selected.id,CardState.covered,CardSprite.flipTime + CardSprite.waitUntilFlipBack)
                    }
                    
                    self.selected = nil
                }
            }
            //no hay selected? -> la seteo
            else {
                self.selected = card
                card.state = CardState.uncovered
                
                //Si tenemos animación giramos carta
                if let flipAnim = flipAnimation {
                    flipAnim(card.id, CardState.uncovered, 0)
                }
            }
        }
    }
}
