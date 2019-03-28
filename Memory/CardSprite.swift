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
    }
    
    func setMargin (margins:Directions){
        position.x += margins.left
        position.x -= margins.right
        position.y += margins.bottom
        position.y -= margins.top
    }
    
    func flip () {
        
        if card.state == CardState.covered {
            self.card.state = CardState.uncovered
            self.texture = frontTexture
        }else if card.state == CardState.uncovered {
            self.card.state = CardState.covered
            self.texture = backTexture
        }//i si está matched no hace nada
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, let parent = parent {
            
            if frame.contains(touch.location(in: parent)) {
                if let delegate = delegate {
                    delegate.onTap(sender: self)
                }
            }
            
        }
    }
}
