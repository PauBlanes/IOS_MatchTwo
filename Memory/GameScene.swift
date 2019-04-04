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
struct Grid {
    var rows:Int
    var columns:Int
}

class GameScene: SKScene, CardSpriteDelegate {    
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var cardSprites = [CardSprite]()
    
    private var gameLogic = GameLogic()
    
    var grid = Grid(rows:4, columns:4)
    
    private var pointsLabel : SKLabelNode = SKLabelNode(fontNamed: "Verdana")
    private var comboLabel : SKLabelNode = SKLabelNode(fontNamed: "Verdana")
    var numCombos = 1
    
    override func didMove(to view: SKView) {
        
        gameLogic.Start(numPairs: (grid.rows*grid.columns)/2, startingPoints: 0, pointsPerMatch: 10)
        spawnCards(view: view, cards : gameLogic.cards)
        
        //PUNTUACIÓN
        let coinIcon = SKSpriteNode(imageNamed: "coin_icon")
        coinIcon.setScale(0.5)
        coinIcon.anchorPoint = CGPoint(x: 0,y: 1)
        coinIcon.position = CGPoint(x: view.frame.width*0.38, y: view.frame.height*0.95)
        addChild(coinIcon)
        
        pointsLabel.text = "\(gameLogic.points)"
        pointsLabel.fontSize = 42
        pointsLabel.position = CGPoint(x: view.frame.width*0.5 + pointsLabel.frame.width/2,
                                       y: coinIcon.position.y - coinIcon.frame.height/2 - pointsLabel.frame.height/2)
        addChild(pointsLabel)
        
        comboLabel.text = "COMBO \n X\(gameLogic.consecutiveMatches)"
        comboLabel.fontSize = 48
        comboLabel.position = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        comboLabel.alpha = 0
        addChild(comboLabel)
        numCombos = gameLogic.consecutiveMatches
    }
    
    func spawnCards (view: SKView, cards:[Card]) {
        
        //Defino margenes
        let gameFieldmargins = Directions(
            top: 0, //en este caso soolo utilizo el bottom porque no quiero deformar las texturas
            bottom: view.frame.height*0.04,
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
                cardSprites[index].id = cards[index].id
                cardSprites[index].delegate = self
                //el back texture ya lo tienen todos igual pero si hay temas se pondria aqui
                cardSprites[index].frontTexture = SKTexture(imageNamed: "card\(cards[index].pairId+1)")
                
                let cardPosX = gameFieldmargins.left + cardWidth/2 + CGFloat(j) * (cardWidth + cardMargins.left)
                let cardPosY = gameFieldmargins.bottom + cardHeight/2 + CGFloat(i) * (cardHeight + cardMargins.bottom)
                cardSprites[index].setCard(newSize: newSize, position : CGPoint(x: cardPosX, y:cardPosY))
                
                addChild(cardSprites[index])
            }
            
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func onTap(card: CardSprite) {
        
        gameLogic.cardSelected(cardId: card.id, flipAnimation: findCardAndFlip)
        
        updateUI()
    }
    
    func updateUI () {
        //Actualiazr puntuación
        pointsLabel.text = "\(gameLogic.points)"
        if let view = self.view {
            pointsLabel.position.x = view.frame.width*0.5 + pointsLabel.frame.width/2
        }
        
        //Actualizar combos
        if gameLogic.consecutiveMatches == 1 {
            numCombos = 1
        }
        else if gameLogic.consecutiveMatches > numCombos {
            comboLabel.text = "COMBO \n X\(gameLogic.consecutiveMatches)"
            comboLabel.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.wait(forDuration: 1),
                SKAction.fadeOut(withDuration: 0.5)]))
            
            numCombos = gameLogic.consecutiveMatches
        }
    }
    
    func findCardAndFlip(cardId: Int, cardState: CardState, delay: Double) {
        for sprite in self.cardSprites {
            if sprite.id == cardId{
                sprite.flip(to: cardState, withDelay: delay)
            }
        }
    }
}
