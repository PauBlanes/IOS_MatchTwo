//
//  GameScene.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, CardSpriteDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var cardSprites = [CardSprite]()
    
    private var gameLogic = GameLogic()
    
    var measures = (rows:4, columns:3)
    
    //var swipeRightGesture = UISwipeGestureRecognizer()
    
    override func didMove(to view: SKView) {
        
        gameLogic.Start(numPairs: 6, startingPoints: 0, pointsPerMatch: 10, pointsToWin: 60)
        
        spawnCards(view: view, cards : gameLogic.cards)
        
        
        //SWIPE
        /*swipeRightGesture =
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(swipeRight(sender:)))
            swipeRightGesture.direction = .right
            view.addGestureRecognizer(swipeRightGesture)*/
        
    }
    
    /*@objc func swipeRight(sender: UISwipeGestureRecognizer){
        print ("swipe detection")
    }
    
    override func willMove(from view: SKView) {
        view.removeGestureRecognizer(swipeRightGesture)
    }*/
    
    func spawnCards (view: SKView, cards:[Card]) {
        
        //Variables generales de tamaños
        let backTextureSize = SKTexture(imageNamed: "back").size()
        let backTextureAR = backTextureSize.height / backTextureSize.width

        let padding = CGSize(width: view.frame.width*0.01, height: 10)
        let safeArea = CGSize(width: view.frame.width - padding.width*2, height: view.frame.height - padding.height*2)
        let cardWidth = safeArea.width/3 - (padding.width*2)
        let cardHeight = cardWidth * backTextureAR
        let newSize = CGSize(width: cardWidth, height: cardHeight)
        
        //Create cards
        var cardPosX : CGFloat = 0
        var cardPosY : CGFloat = 0
        for i in 0..<cards.count {
            
            cardSprites.insert(CardSprite(), at: i)
            cardSprites[i].card = cards[i]
            cardSprites[i].delegate = self
            //el back texture ya lo tienen todos igual pero si hay temas se pondria aqui
            cardSprites[i].frontTexture = SKTexture(imageNamed: "card\(cardSprites[i].card.pairId+1)")
            
            cardPosX = padding.width*2 + CGFloat(i%measures.columns) * (cardWidth + padding.width*2)
            cardPosY = padding.height*2 + CGFloat(i%measures.rows) * (cardHeight + padding.height*2)
            cardSprites[i].setCard(newSize: newSize, position : CGPoint(x: cardPosX, y:cardPosY))
            
            addChild(cardSprites[i])
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func onTap(sender: CardSprite) {
        
        //la ponemos cara arriba
        sender.flip()
        
        //Si hay alguna seleccionada
        if let selected = gameLogic.selected {
       
            //Si no es match
            if !gameLogic.tryMatch(cardToMath: sender.card) {
                
                //las volvemos a girar
                sender.flip()
                
                for sprite in cardSprites {
                    if selected.id == sprite.card.id {
                        sprite.flip()
                    }
                }
            }
            
            gameLogic.selected = nil
        }
        else {
            //Si no hay ninguna seleccionada
            gameLogic.selected = sender.card
        }
    
    }
        
}
