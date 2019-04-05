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

class GameScene: SKScene, CardSpriteDelegate, ImageButtonDelegate {
    
    weak var sceneControllerDelegate: SceneControllerDelegate?
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var cardSprites = [CardSprite]()
    
    private var gameLogic = GameLogic()
    
    var grid = Grid(rows:4, columns:4)
    
    private var backButton = ImageButton(imageNamed: "back_icon")
    private var pointsLabel : SKLabelNode = SKLabelNode(fontNamed: "Verdana")
    private var comboLabel : SKLabelNode = SKLabelNode(fontNamed: "Verdana")
    var numCombos = 1
    
    //Timer
    var levelTimerLabel = SKLabelNode(fontNamed: "Verdana")
    var matchEnded = false
    
    
    override func didMove(to view: SKView) {
        
        gameLogic.Start(numPairs: (grid.rows*grid.columns)/2, startingPoints: 0, pointsPerMatch: 10, levelTimerInSeconds: 10)
        spawnCards(view: view, cards : gameLogic.cards)
        
        //PUNTUACIÓN
        let coinIcon = SKSpriteNode(imageNamed: "coin_icon")
        coinIcon.setScale(0.3)
        coinIcon.anchorPoint = CGPoint(x: 0,y: 1)
        coinIcon.position = CGPoint(x: view.frame.width*0.38, y: view.frame.height*0.95)
        addChild(coinIcon)
        
        pointsLabel.text = "\(gameLogic.points)"
        pointsLabel.fontSize = 38
        pointsLabel.position = CGPoint(x: view.frame.width*0.47 + pointsLabel.frame.width/2,
                                       y: coinIcon.position.y - coinIcon.frame.height/2 - pointsLabel.frame.height/2)
        addChild(pointsLabel)
        
        comboLabel.text = "COMBO \n X\(gameLogic.consecutiveMatches)"
        comboLabel.fontSize = 48
        comboLabel.position = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        comboLabel.alpha = 0
        addChild(comboLabel)
        numCombos = gameLogic.consecutiveMatches
        
        //GO BACK
        backButton.position = CGPoint(x: view.frame.width * 0.1, y: view.frame.height*0.95)
        backButton.isUserInteractionEnabled = true
        backButton.delegate = self
        backButton.setScale(0.5)
        backButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(backButton)
        
        //Timer
        levelTimerLabel.fontSize = 20
        levelTimerLabel.position = CGPoint(x: view.frame.width*0.8,
                                           y: coinIcon.position.y - coinIcon.frame.height/2 - levelTimerLabel.frame.height/2)
        setTimerText()
        addChild(levelTimerLabel)
        
        let wait = SKAction.wait(forDuration: 1) //esperar 1 segon
        let block = SKAction.run({ //actualizar valor timer i text
            
            if self.gameLogic.levelTimerValue > 0{
                self.gameLogic.levelTimerValue = self.gameLogic.levelTimerValue-1
            }
                
                //ha llegado a 0 por lo tanto salimos del bucle
            else{
                self.removeAction(forKey: "countdown")
            }
            self.setTimerText()
        })
        let sequence = SKAction.sequence([wait,block])
        run(SKAction.repeatForever(sequence), withKey: "countdown")
        
    }
    
    func spawnCards (view: SKView, cards:[Card]) {
        
        //Defino margenes
        let gameFieldmargins = Directions(
            top: 0, //en este caso solo utilizo el bottom porque no quiero deformar las texturas
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
    func findCardAndFlip(cardId: Int, cardState: CardState, delay: Double) {
        for sprite in self.cardSprites {
            if sprite.id == cardId{
                sprite.flip(to: cardState, withDelay: delay)
            }
        }
    }
    
    //INTERFFACES
    func onTap(card: CardSprite) {
        
        if !matchEnded {
            
            gameLogic.cardSelected(cardId: card.id, flipAnimation: findCardAndFlip)
            updateUI()
        }
    }
    func onTap(sender: ImageButton) {
        if sender == backButton, !matchEnded{
            sceneControllerDelegate?.goToMenu(sender: self)
        }
    }
    
    //UI
    func setTimerText() {
        self.levelTimerLabel.text = "Time: \(Int(self.gameLogic.levelTimerValue/60)):\(self.gameLogic.levelTimerValue%60)"
    }
    func updateUI () {
        //Actualiazr puntuación
        pointsLabel.text = "\(gameLogic.points)"
        if let view = self.view {
            pointsLabel.position.x = view.frame.width*0.47 + pointsLabel.frame.width/2
        }
        
        //Actualizar combos
        if gameLogic.consecutiveMatches == 0 {
            numCombos = 0
        }
        else if gameLogic.consecutiveMatches > numCombos, gameLogic.consecutiveMatches > 1 {
            comboLabel.text = "COMBO \n X\(gameLogic.consecutiveMatches)"
            comboLabel.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.wait(forDuration: 1),
                SKAction.fadeOut(withDuration: 0.5)]))
            
            numCombos = gameLogic.consecutiveMatches
        }
        
        //Actualizar timer text por si aumentamos el timer por acertar
        setTimerText()
    }
    func endMatch(won: Bool) {
        
        matchEnded = true
        
        if let view = self.view {
            
            var endText = ""
            if won {
                endText = "YOU WIN!"
                
                let bgLabel = SKShapeNode(rectOf: CGSize(width: view.frame.width*0.85, height: view.frame.height/2))
                bgLabel.fillColor = SKColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 0.75)
                bgLabel.position = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
                addChild(bgLabel)
                
                let scoreLabel = SKLabelNode(fontNamed: "Verdana")
                scoreLabel.text = "Your score is: \(gameLogic.points)"
                scoreLabel.fontSize = 35
                scoreLabel.position = CGPoint(x: view.frame.width/2, y: view.frame.height*0.4)
                scoreLabel.alpha = 0
                addChild(scoreLabel)
                
                scoreLabel.run(SKAction.fadeIn(withDuration: 1))
                
                let timeLabel = SKLabelNode(fontNamed: "Verdana")
                timeLabel.text = "Time left: \(Int(self.gameLogic.levelTimerValue/60)):\(self.gameLogic.levelTimerValue%60)"
                timeLabel.fontSize = 35
                timeLabel.position = CGPoint(x: view.frame.width/2, y: view.frame.height*0.35)
                timeLabel.alpha = 0
                addChild(timeLabel)
                
                timeLabel.run(SKAction.fadeIn(withDuration: 1))
                
            } else {
                endText = "YOU LOSE..."
                
                let bgLabel = SKShapeNode(rectOf: CGSize(width: view.frame.width*0.85, height: view.frame.height*0.25))
                bgLabel.fillColor = SKColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 0.75)
                bgLabel.position = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
                addChild(bgLabel)
            }
            
            let endMatchLabel = SKLabelNode(fontNamed: "Verdana")
            endMatchLabel.text = endText
            endMatchLabel.fontSize = 54
            endMatchLabel.position = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
            endMatchLabel.alpha = 0
            addChild(endMatchLabel)
            
            endMatchLabel.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 1),
                SKAction.wait(forDuration: 5),
                SKAction.run{self.sceneControllerDelegate?.goToMenu(sender: self)}]))
            
            levelTimerLabel.removeAllActions()
            comboLabel.removeAllActions()
            comboLabel.alpha = 0
        }
        
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        //WIN?
        if !matchEnded {
            if gameLogic.levelTimerValue <= 0 {
                endMatch(won: false)
            }
            else if gameLogic.pairsMatched >= ((grid.rows*grid.columns)/2) {
                endMatch(won: true)
            }
        }
    }
}
