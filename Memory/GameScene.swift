//
//  GameScene.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import FirebaseAnalytics

struct Directions {
    var top:CGFloat
    var bottom:CGFloat
    var left:CGFloat
    var right:CGFloat
}
struct Grid {
    var rows:Int
    var columns:Int
}

class GameScene: SKScene, CardSpriteDelegate, ImageButtonDelegate {

    weak var sceneControllerDelegate: SceneControllerDelegate?
    
    private var cardSprites = [CardSprite]()
    
    private var gameLogic = GameLogic()
    
    var grid = Grid(rows:0, columns:0)
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var backButton = ImageButton(imageNamed: "back_icon")
    private var pointsLabel : SKLabelNode = SKLabelNode(fontNamed: "Verdana")
    private var comboLabel : SKLabelNode = SKLabelNode(fontNamed: "Verdana")
    var numCombos = 1
    
    //Timer
    var levelTimerLabel = SKLabelNode(fontNamed: "Verdana")
    var matchEnded = false
    
    //End game buttons
    let toMenu = ImageButton(imageNamed: "back_icon")
    let restart = ImageButton(imageNamed: "restart_icon")
    let nextLevel = ImageButton(imageNamed: "next_icon")
    
    //Music
    let matchSound = AVPlayer(url: Bundle.main.url(forResource: "correct.wav", withExtension: nil)!)
    let comboSound = AVPlayer(url: Bundle.main.url(forResource: "combo.mp3", withExtension: nil)!)
    let incorrectSound = AVPlayer(url: Bundle.main.url(forResource: "incorrect.wav", withExtension: nil)!)
    let deniedSound = AVPlayer(url: Bundle.main.url(forResource: "denied.wav", withExtension: nil)!)
    let defeatSound = AVPlayer(url: Bundle.main.url(forResource: "defeat.wav", withExtension: nil)!)
    let victorySound = AVPlayer(url: Bundle.main.url(forResource: "victory.mp3", withExtension: nil)!)
    
    override func didMove(to view: SKView) {        
        
        //Background
        let background = SKSpriteNode(imageNamed: "bg")
        background.size = frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
        
        //Start game Logic
        gameLogic.Start(
            numPairs: (grid.rows*grid.columns)/2,
            startingPoints: 0,
            pointsPerMatch: MenuScene.difficulties[MenuScene.diffIndex].pointsPerMatch,
            levelTimerInSeconds: 120)
        
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
        
        
        //GO BACK
        backButton.position = CGPoint(x: view.frame.width * 0.1, y: coinIcon.position.y - coinIcon.frame.height/2)
        backButton.isUserInteractionEnabled = true
        backButton.delegate = self
        backButton.setScale(0.5)
        backButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(backButton)
        
        //TIMER
        setTimerText()
        levelTimerLabel.fontSize = 20
        levelTimerLabel.position = CGPoint(x: view.frame.width*0.8,
                                           y: coinIcon.position.y - coinIcon.frame.height/2-levelTimerLabel.frame.height/2)
        
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
        levelTimerLabel.run(SKAction.repeatForever(sequence), withKey: "countdown")
        
        //COMBOS
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
            top: view.frame.height*0.12, //para que quede por debajo del contador
            bottom: view.frame.height*0.04,
            left: view.frame.width*0.02,
            right: view.frame.width*0.02)
        var cardMargins = Directions(
            top: 0,
            bottom: 0,
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
        
        //Así la grid siempre ocupara la misma height de pantalla independientemente de las cartas
        cardMargins.bottom = (view.frame.height - gameFieldmargins.top - gameFieldmargins.bottom
                            - (cardHeight*CGFloat(grid.rows)))/CGFloat(grid.rows-1)
        
        
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
    func findCardAndFlip(cardId: Int, to cardState: CardState) {
        for sprite in self.cardSprites {
            if sprite.id == cardId{
                sprite.flip(to: cardState)
            }
        }
    }
    
    //INTERFFACES
    func onTap(card: CardSprite) {
        
        if !matchEnded {
            
            //1. coger el selected por si es match, pq sino ya estará a nil al terminar el gamelogic de comprobar
            var selectedId:Int?
            if let selected = gameLogic.selected {
                selectedId = selected.id
            }
            
            //2. Cojer el resultado
            let result = gameLogic.cardSelected(cardId: card.id)
            
            //3. Hacer animación
            switch (result) {
                
                case CardSelectedResult.alreadyMatched:
                    deniedSound.seek(to: CMTime.zero)
                    deniedSound.play()
                
                case CardSelectedResult.flipDown:
                    card.flip(to: CardState.covered)
                
                case CardSelectedResult.flipUp:
                    card.flip(to: CardState.uncovered)
                
                case CardSelectedResult.match:
                    card.flip(to: CardState.uncovered)
                    
                    self.run(SKAction.sequence([
                        SKAction.wait(forDuration: CardSprite.flipTime),
                        SKAction.run{
                            self.matchSound.seek(to: CMTime.zero)
                            self.matchSound.play()
                        }]))
                
                case CardSelectedResult.failMatch:
                    
                    //1. Ponemos la actual boca arriba
                    card.flip(to:  CardState.uncovered)
                    
                    //2.Esperamos y giramos las dos
                    self.run(SKAction.sequence([
                        SKAction.wait(forDuration: CardSprite.flipTime + CardSprite.waitUntilFlipBack),
                        SKAction.run{
                            //sonido fail
                            self.incorrectSound.seek(to: CMTime.zero)
                            self.incorrectSound.play()
                            
                            //volver a girar
                            card.flip(to: CardState.covered)
                            if let id = selectedId {
                                self.findCardAndFlip(cardId: id, to: CardState.covered)
                            }
                        }]))
                
                case CardSelectedResult.error:
                    print("Something went wrong : Card is not match, covered or uncovered")
            }
            
            //Actualizar HUD
            updateUI()
        }
    }
    func onTap(sender: ImageButton) {
        
        switch sender {
            case backButton:
                sceneControllerDelegate?.goToMenu(sender: self)
            case toMenu:
                sceneControllerDelegate?.goToMenu(sender: self)
            case restart:
                sceneControllerDelegate?.goToGame(sender: self, grid: grid)
            case nextLevel:
                MenuScene.diffIndex += 1
                sceneControllerDelegate?.goToGame(sender: self, grid: MenuScene.difficulties[MenuScene.diffIndex].grid)
            default:
                    print("something went wrong")
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
            comboSound.seek(to: CMTime.zero)
            comboSound.play()
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
            
            //Equivalente a pause
            levelTimerLabel.removeAllActions()
            comboLabel.removeAllActions()
            comboLabel.alpha = 0
            backButton.isUserInteractionEnabled = false
            for sprite in cardSprites {
                sprite.isUserInteractionEnabled = false
            }
            
            let fadeInAction = SKAction.fadeIn(withDuration: 1)
            
            //CANVAS
            let bgLabel = SKShapeNode(rectOf: CGSize(width: view.frame.width*0.85, height: view.frame.height/2))
            bgLabel.fillColor = SKColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 0.75)
            bgLabel.position = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
            bgLabel.alpha = 0
            addChild(bgLabel)
            
            //textos
            let winTextLabel = SKLabelNode(fontNamed: "Verdana")
            winTextLabel.fontSize = 54
            winTextLabel.position = CGPoint(x: 0, y: bgLabel.frame.height*0.15)
            winTextLabel.alpha = 0
            bgLabel.run(fadeInAction)
            winTextLabel.run(fadeInAction)
            bgLabel.addChild(winTextLabel)
            
            let scoreLabel = SKLabelNode(fontNamed: "Verdana")
            scoreLabel.text = "Your score is: \(gameLogic.points)"
            scoreLabel.fontSize = 35
            scoreLabel.position = CGPoint(x: 0, y: -bgLabel.frame.height*0.10)
            scoreLabel.alpha = 0
            scoreLabel.run(fadeInAction)
            bgLabel.addChild(scoreLabel)
            
            if won {
                
                //Labels
                let timeLabel = SKLabelNode(fontNamed: "Verdana")
                timeLabel.text = "Time left: \(Int(self.gameLogic.levelTimerValue/60)):\(self.gameLogic.levelTimerValue%60)"
                timeLabel.fontSize = 35
                timeLabel.position = CGPoint(x: 0, y: -bgLabel.frame.height*0.20)
                timeLabel.alpha = 0
                timeLabel.run(fadeInAction)
                bgLabel.addChild(timeLabel)
                
                winTextLabel.text = "YOU WIN!"
                victorySound.seek(to: CMTime.zero)
                victorySound.play()
                
                //Firebase
                FirebaseManager.instance.updateScore(score: gameLogic.points)
                
            } else {
                winTextLabel.text = "YOU LOSE..."
                defeatSound.seek(to: CMTime.zero)
                defeatSound.play()
                
                bgLabel.run(SKAction.resize(toWidth: view.frame.height*0.25, duration: 0))
            }
            
            //Botones
            toMenu.position = CGPoint(x: -bgLabel.frame.width*0.3, y: -bgLabel.frame.height*0.4)
            toMenu.isUserInteractionEnabled = true
            toMenu.delegate = self
            toMenu.setScale(0.5)
            toMenu.alpha = 0
            toMenu.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            toMenu.run(fadeInAction)
            bgLabel.addChild(toMenu)
            
            restart.position = CGPoint(x: 0, y: -bgLabel.frame.height*0.4)
            restart.isUserInteractionEnabled = true
            restart.delegate = self
            restart.setScale(0.5)
            restart.alpha = 0
            restart.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            restart.run(fadeInAction)
            bgLabel.addChild(restart)
            
            
            if (MenuScene.diffIndex < MenuScene.difficulties.count-1 && won) {
                nextLevel.position = CGPoint(x: bgLabel.frame.width*0.3, y: -bgLabel.frame.height*0.4)
                nextLevel.isUserInteractionEnabled = true
                nextLevel.delegate = self
                nextLevel.setScale(0.5)
                nextLevel.alpha = 0
                nextLevel.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                nextLevel.run(fadeInAction)
                bgLabel.addChild(nextLevel)
            }
        }
        
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        //WIN CONDITIONS
        if !matchEnded { //para o continuar entrando una vez ya se ha entrado
            if gameLogic.didLose() {
                endMatch(won: false)
            }
            else if gameLogic.didWin() {
                endMatch(won: true)
            }
        }
    }
    
    func goToLevel(level: Int) {
        Analytics.logEvent("nextLevel", parameters: ["levelname": level])
    }
    
    func changeBackTextures() {
        for card in cardSprites {
            card.run(SKAction.setTexture(CardSprite.backTexture))
        }
    }
}
