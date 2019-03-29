//
//  Card.swift
//  Memory
//
//  Created by Pau Blanes on 14/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit

protocol CardSpriteDelegate: class {
    func onTap(sender: CardSprite)
}

class CardSprite: SKSpriteNode {
    
    var card = Card()
    weak var delegate: CardSpriteDelegate?
    
    let backTexture: SKTexture = SKTexture(imageNamed: "back")
    var frontTexture: SKTexture = SKTexture(imageNamed: "card1")
    
    func setCard (newSize:CGSize, position: CGPoint) {
        self.texture = backTexture
        
        self.isUserInteractionEnabled = true
        self.size = newSize
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.position = position
        
        self.anchorPoint = CGPoint(x:0.5,y: 0.5)
    }
    
    func flip () { //devuelve si ha terminado
        //si está emparejada o girando nada
        if self.card.state == CardState.matched || self.card.state == CardState.turning{
            return
        }
        
        //No está girando ni emparejada
        var currentState = self.card.state
        self.card.state = CardState.turning
        var endAction = SKAction()
        var newTexture = SKTexture()
        
        if currentState == CardState.covered {
            newTexture = frontTexture
            currentState = CardState.uncovered
            endAction =
                SKAction.run{
                    if let delegate = self.delegate {
                        delegate.onTap(sender: self) //solo si la hemos puesto boca arriba miramos que hacer
                    }
                }
            
        }else if currentState == CardState.uncovered {
            newTexture = backTexture
            currentState = CardState.covered
        }
        
        var actions = [SKAction.scaleX(to: 0, duration: 0.15),
                       SKAction.setTexture(newTexture),
                       SKAction.scaleX(to: 1, duration: 0.15),
                       SKAction.run{
                            self.card.state = currentState
                       }]
        actions.append(endAction)
        self.run(SKAction.sequence(actions))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, let parent = parent {
            
            if frame.contains(touch.location(in: parent)) {
                flip()
            }            
        }
    }
}
