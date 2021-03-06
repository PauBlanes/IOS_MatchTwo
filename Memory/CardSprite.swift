//
//  Card.swift
//  Memory
//
//  Created by Pau Blanes on 14/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit
import AVFoundation

protocol CardSpriteDelegate: class {
    func onTap(card: CardSprite)
}

class CardSprite: SKSpriteNode {
    
    //Variables de clase
    static let flipTime = 0.3
    static let waitUntilFlipBack = 0.5
    static var backTexture: SKTexture = SKTexture(imageNamed: "back")
    
    weak var delegate: CardSpriteDelegate?
    
    var id = -1
    
    //sounds
    let flipSound = AVPlayer(url: Bundle.main.url(forResource: "card_flip.wav", withExtension: nil)!)
    
    var frontTexture: SKTexture = SKTexture()
    
    func setCard (newSize:CGSize, position: CGPoint) {
        self.texture = CardSprite.backTexture
        
        self.isUserInteractionEnabled = true
        self.size = newSize
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.position = position
        
        self.anchorPoint = CGPoint(x:0.5,y: 0.5)
    }
    
    func flip (to cardState:CardState){
        
        //1. No dejo que el user interactue mientras está girando
        isUserInteractionEnabled = false
        
        //2. seteo textura
        var newTexture = SKTexture()
        if cardState == CardState.uncovered {
            newTexture = frontTexture
        }
        else if cardState == CardState.covered {
            newTexture = CardSprite.backTexture
        }
        
        //3. Sonido
        self.flipSound.seek(to: CMTime.zero)
        self.flipSound.play()
        
        //4. animación i al terminarla vuelvo a activar interacción
        self.run(SKAction.sequence([
            SKAction.scaleX(to: 0, duration: CardSprite.flipTime/2),
            SKAction.setTexture(newTexture),
            SKAction.scaleX(to: 1, duration: CardSprite.flipTime/2),
            SKAction.run{
                self.isUserInteractionEnabled = true
            }]))
    }    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, let parent = parent {
            
            if frame.contains(touch.location(in: parent)) {
                if let delegate = self.delegate {
                    delegate.onTap(card: self)
                }
            }            
        }
    }
}
