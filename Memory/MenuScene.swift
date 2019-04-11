//
//  MenuScene.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol SceneControllerDelegate: class {
    func goToGame(sender: SKScene, grid:Grid)
    func goToSettings(sender: MenuScene)
    func goToMenu (sender: SKScene)
}

class MenuScene: SKScene, ButtonDelegate, ImageButtonDelegate {
    
    weak var sceneControllerDelegate: SceneControllerDelegate?
    
    private var title : SKLabelNode = SKLabelNode(fontNamed: "Futura")
    
    private var settingsButton = ImageButton(imageNamed: "settings_icon")
    private var rankingsButton = ImageButton(imageNamed: "leaderboard_icon")
    
    //Dificulty
    private var difficultyLabel : SKLabelNode = SKLabelNode(fontNamed: "Verdana")
    private var leftArrowButton = ImageButton(imageNamed: "left_arrow")
    private var rightArrowButton = ImageButton(imageNamed: "right_arrow")
    private var difficultyButton = Button(rect: CGRect(x: 0, y: 0, width: 200, height: 200), cornerRadius: 10)
    
    static var diffIndex = Preferences.getDifficulty()
    static var difficulties:[Difficulty] = [
        Difficulty(tag: "EASY",description: "6 Diferent Pairs!",grid: Grid(rows: 4, columns: 3)),
        Difficulty(tag: "MEDIUM",description: "10 Diferent Pairs!" ,grid: Grid(rows: 5, columns: 4)),
        Difficulty(tag: "HARD",description: "15 Diferent Pairs!" , grid: Grid(rows: 6, columns: 5))
    ]
    
    //var swipeRightGesture = UISwipeGestureRecognizer()
    
    //Musica
    
    
    override func didMove(to view: SKView) {
        
        //Background
        self.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1)
        //AudioController.shared.play()
        
        //Set the butons
        rankingsButton.position = CGPoint(x: view.frame.width/2, y: view.frame.height * 0.15)
        rankingsButton.isUserInteractionEnabled = true
        rankingsButton.delegate = self
        rankingsButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(rankingsButton)
        
        settingsButton.position = CGPoint(x: view.frame.width*0.1, y: view.frame.height * 0.90)
        settingsButton.isUserInteractionEnabled = true
        settingsButton.delegate = self
        settingsButton.setScale(0.5)
        settingsButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(settingsButton)
        
        //TRIAR DIFICULTAT
        difficultyButton.fillColor = SKColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1.0)
        difficultyButton.isUserInteractionEnabled = true
        difficultyButton.delegate = self
        difficultyButton.position = CGPoint(x: (view.frame.width / 2.0) - (difficultyButton.frame.width / 2.0), y: view.frame.height * 0.30)
        addChild(difficultyButton)
        
        difficultyLabel.fontSize = 22
        difficultyLabel.position = CGPoint(x: view.center.x, y: difficultyButton.position.y + difficultyButton.frame.height + 5)
        addChild(difficultyLabel)
        
        leftArrowButton.position = CGPoint(x: view.frame.width * 0.1, y: difficultyButton.position.y + difficultyButton.frame.height/2)
        leftArrowButton.isUserInteractionEnabled = true
        leftArrowButton.delegate = self
        leftArrowButton.setScale(0.5)
        leftArrowButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(leftArrowButton)
        rightArrowButton.position = CGPoint(x: view.frame.width * 0.9, y: difficultyButton.position.y + difficultyButton.frame.height/2)
        rightArrowButton.isUserInteractionEnabled = true
        rightArrowButton.delegate = self
        rightArrowButton.setScale(0.5)
        rightArrowButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(rightArrowButton)
        
        //Posem dificultat inicial
        updateDifficultyUI()
        
        //Title
        addChild(title)
        title.text = "MATCH TWO!"
        title.fontSize = 36
        title.position = CGPoint(x: view.center.x, y: view.frame.height * 0.75)
        title.alpha = 0.0
        title.run(SKAction.repeatForever(
            SKAction.sequence([
            SKAction.fadeIn(withDuration: 1.5),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 1)
                ])))
        
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
    
    func onTap(sender: Button) {
        if sender == difficultyButton {
            sceneControllerDelegate?.goToGame(sender: self, grid: MenuScene.difficulties[MenuScene.diffIndex].grid)
        }
    }
    func onTap(sender: ImageButton) {
        if sender == settingsButton {
            sceneControllerDelegate?.goToSettings(sender: self)
        }
        else if sender == rankingsButton {
            print("FIREBASE")
        }else if sender == leftArrowButton {
            MenuScene.diffIndex -= 1
            if MenuScene.diffIndex < 0 {
                MenuScene.diffIndex = MenuScene.difficulties.count-1
            }
            updateDifficultyUI()
        }
        else if sender == rightArrowButton {
            MenuScene.diffIndex = (MenuScene.diffIndex + 1)%MenuScene.difficulties.count
            updateDifficultyUI()
        }
    }
    
    func updateDifficultyUI () {
        difficultyButton.setText(text: MenuScene.difficulties[MenuScene.diffIndex].description)
        difficultyLabel.text = MenuScene.difficulties[MenuScene.diffIndex].tag
        Preferences.setDifficulty(value: MenuScene.diffIndex)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
