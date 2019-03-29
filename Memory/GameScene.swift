//
//  GameScene.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Directions {
    var top:CGFloat
    let bottom:CGFloat
    let left:CGFloat
    let right:CGFloat
}

class GameScene: SKScene, CardSpriteDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var cardSprites = [CardSprite]()
    
    private var gameLogic = GameLogic()
    
    var grid = (rows:4, columns:4)
    
    //var swipeRightGesture = UISwipeGestureRecognizer()
    
    override func didMove(to view: SKView) {
        
        gameLogic.Start(numPairs: (grid.rows*grid.columns)/2, startingPoints: 0, pointsPerMatch: 10, pointsToWin: 60)
        
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
        
        //Defino margenes
        let gameFieldmargins = Directions(
            top: 0, //en este caso soolo utilizo el bottom porque no quiero deformar las texturas
            bottom: 100,
            left: view.frame.width*0.02,
            right: view.frame.width*0.02)
        let cardMargins = Directions(
            top: 0,
            bottom: 10,
            left: view.frame.width*0.02,
            right: 0)
        
        //Calculo aspect ratio de la textura para no deformarla
        let cardTextureSize = SKTexture(imageNamed: "back").size()
        let cardTextureAspectRatio = cardTextureSize.height / cardTextureSize.width
        
        //Defino tamaño de cartas
        let gameFieldWidth = view.frame.width - gameFieldmargins.left - gameFieldmargins.right
        let cardWidth = (gameFieldWidth - (cardMargins.left*CGFloat(grid.columns-1)))/CGFloat(grid.columns)
        let cardHeight = cardWidth * cardTextureAspectRatio
        let newSize = CGSize(width: cardWidth, height: cardHeight)
        
        //Create cards
        for i in 0..<grid.rows {
            
            for j in 0..<grid.columns{
                let index = i*grid.columns + j
                
                cardSprites.insert(CardSprite(), at: index)
                cardSprites[index].card = cards[index]
                cardSprites[index].delegate = self
                //el back texture ya lo tienen todos igual pero si hay temas se pondria aqui
                cardSprites[index].frontTexture = SKTexture(imageNamed: "card\(cards[index].pairId+1)")
                
                let cardPosX = gameFieldmargins.left + cardWidth/2 + CGFloat(j) * (cardWidth + cardMargins.left)
                let cardPosY = gameFieldmargins.bottom + CGFloat(i) * (cardHeight + cardMargins.bottom)
                cardSprites[index].setCard(newSize: newSize, position : CGPoint(x: cardPosX, y:cardPosY))
                
                addChild(cardSprites[index])
            }
            
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func onTap(sender: CardSprite) { //¡esto pasa una vez la carta ya ha sido girada y está boca arriba!
        
        //1A. Habia alguna seleccionada y la actual està boca arriba
        if let selected = gameLogic.selected {
            
            //2A. No es match
            if sender.card.id != selected.id, !gameLogic.tryMatch(cardToMath: sender.card) {
                for sprite in cardSprites {
                    if selected.id == sprite.card.id {
                        
                        //las volvemos a girar
                        sprite.run(
                            SKAction.sequence([
                                SKAction.run{
                                    sprite.card.state = CardState.turning
                                    sender.card.state = CardState.turning
                                },
                                SKAction.wait(forDuration: 0.5),
                                SKAction.run {
                                    sprite.card.state = CardState.uncovered
                                    sender.card.state = CardState.uncovered
                                    sprite.flip()
                                    sender.flip()
                                    return
                                }]))
                    }
                }
            }
        }
        //1B. No habia ninguna seleccionada
        else {
            gameLogic.selected = sender.card
        }
    
    }
}
