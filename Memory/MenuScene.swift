//
//  MenuScene.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

protocol SceneControllerDelegate: class {
    func goToGame(sender: SKScene, grid:Grid)
    func goToSettings(sender: MenuScene)
    func goToMenu (sender: SKScene?)
    func goToRankings (sender: SKScene?)
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
        Difficulty(tag: NSLocalizedString("diff_easy_title", comment: ""),
                   description: NSLocalizedString("diff_easy_description", comment: ""),
                   grid: Grid(rows: 4, columns: 3), pointsPerMatch: 7),
        Difficulty(tag: NSLocalizedString("diff_medium_title", comment: ""),
                   description: NSLocalizedString("diff_medium_description", comment: ""),
                   grid: Grid(rows: 5, columns: 4),
                   pointsPerMatch: 10),
        Difficulty(tag: NSLocalizedString("diff_hard_title", comment: ""),
                   description: NSLocalizedString("diff_hard_description", comment: ""),
                   grid: Grid(rows: 6, columns: 5),
                   pointsPerMatch: 15)
    ]
    
    //Swipe
    var swipeRightGesture = UISwipeGestureRecognizer()
    var swipeLeftGesture = UISwipeGestureRecognizer()
    
    //Acelerometer
    let manager = CMMotionManager()
    let maxDistance = CGFloat(10.0)
    private var maracasIcon = SKSpriteNode(imageNamed: "maracas_icon")
    
    
    override func didMove(to view: SKView) {
        
        //PARALAX
        let numLayers = 3
        for i in 0..<numLayers {
            let node = createLayer(depth: CGFloat(numLayers-i), screenSize: view.frame.size)
            addChild(node)
        }
        
        //Background
        let background = SKSpriteNode(imageNamed: "bg")
        background.size = frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = CGFloat(-numLayers)
        addChild(background)
        
        
        //Music
        Preferences.setSound(to: Preferences.isSoundOn())
        AudioController.shared.play()
        
        //Acelerometer
        useAccelerometer()
        maracasIcon.position = CGPoint(x: view.frame.width/2, y: view.frame.height*0.9)
        maracasIcon.setScale(0.5)
        maracasIcon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(maracasIcon)
        
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
        title.text = NSLocalizedString("game_title", comment: "")
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
        swipeRightGesture =
         UISwipeGestureRecognizer(target: self,
         action: #selector(swipeRight(sender:)))
         swipeRightGesture.direction = .right
         view.addGestureRecognizer(swipeRightGesture)
        swipeLeftGesture =
            UISwipeGestureRecognizer(target: self,
                                     action: #selector(swipeLeft(sender:)))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)
    }
    
    @objc func swipeRight(sender: UISwipeGestureRecognizer){
        onTap(sender: leftArrowButton)
     }
    @objc func swipeLeft(sender: UISwipeGestureRecognizer){
        onTap(sender: rightArrowButton)
    }
     
     override func willMove(from view: SKView) {
     view.removeGestureRecognizer(swipeRightGesture)
     }
    
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
            sceneControllerDelegate?.goToRankings(sender: self)
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

//PARALAX
extension MenuScene {
    func createLayer(depth: CGFloat, screenSize: CGSize) -> SKNode {
        
        let scale = 1.0 / depth
        let node = SKNode()
        // Scale layer to create depth effect
        node.setScale(scale)
        node.zPosition = -depth
        node.position = CGPoint(x:screenSize.width / 2.0, y:screenSize.height / 2.0)
        
        let pi = 3.14159
        
        // Create squares at random positions
        for i in 1..<13 {
            let square = SKSpriteNode(imageNamed: "card\(i)")
            square.setScale(0.25)
            square.anchorPoint = CGPoint(x: 0.5,y: 0.5)
            square.alpha = 0.5
            square.zRotation = CGFloat(Double(Int.random(in: 0 ..< 360)) * pi/180)
            
            let x = CGFloat(arc4random_uniform(UInt32(screenSize.width*0.85))) - (screenSize.width*0.85) / 2.0
            let y = CGFloat(arc4random_uniform(UInt32(screenSize.height*0.8))) - (screenSize.height*0.8) / 2.0
            square.position = CGPoint(x:x, y:y)
            node.addChild(square)
        }
        return node
    }
}

//ACELEROMETER
extension MenuScene {
    
    func useAccelerometer() {
        
        var tiltX: CGFloat = 0.0
        let alpha: CGFloat = 0.15
        
        // Define block to handle accelerometer updates
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.1
            manager.startGyroUpdates(to: .main) { [weak self] (data, error) in
                if let data = data, let view = self?.view {
                    // Low-pass filter to smooth the measurements
                    tiltX = tiltX * (1-alpha) + CGFloat(data.rotationRate.x) * alpha
                    
                    let deltaX = tiltX * 30
                    if view.frame.width/2 + deltaX < view.frame.width*0.8,
                        view.frame.width/2 + deltaX > view.frame.width*0.2 {
                        self?.maracasIcon.position.x = view.frame.width/2 + deltaX
                    }
                }
            }
        }
    }
    
}
