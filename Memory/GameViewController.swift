//
//  GameViewController.swift
//  Memory
//
//  Created by Pau Blanes on 12/3/19.
//  Copyright © 2019 Pau Blanes. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import FirebaseUI
import FirebaseAuth
//import GoogleMobileAds
import FirebaseAnalytics

class GameViewController: UIViewController, SceneControllerDelegate/*, GADBannerViewDelegate*/ {    
    
    /*func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        Analytics.logEvent("bannerClick", parameters: nil)
    }*/
    
    //var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Banner
        /*bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self*/
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) { //Per evitar error whose method is not in the window hierarchy
        super.viewDidAppear(animated)
        
        FirebaseManager.controller = self
        FirebaseManager.instance.tryLogin()
    }
    
    /*func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }*/
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func goToMenu(sender: SKScene?){
        
        let ac = UIAlertController(title: "Enter Username", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned ac] _ in
            let playerName = ac.textFields![0]
            var user = User(FirebaseManager.instance.getUserId(), playerName.text ?? "Anonymus")
            FirebaseManager.instance.createUser(user)
        })
        
        self.present(ac, animated: true, completion: nil)
        
        if let view = self.view as? SKView {
            let scene = MenuScene(size: view.frame.size)
            scene.sceneControllerDelegate = self
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
        }
    }
    
    func goToGame(sender: SKScene, grid:Grid) {
        if let view = self.view as? SKView {
            let scene = GameScene(size: view.frame.size)
            scene.grid.columns = grid.columns
            scene.grid.rows = grid.rows
            scene.sceneControllerDelegate = self
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene, transition: .crossFade(withDuration: 0.2))
        }
    }
    
    func goToSettings(sender: MenuScene) {
        if let view = self.view as? SKView {
            let scene = SettingsScene(size: view.frame.size)
            scene.sceneControllerDelegate = self
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene, transition: .crossFade(withDuration: 0.2))
        }
    }
    
    func goToAuthScene(controller: UIViewController) {
        present(controller, animated: true, completion: nil)
    }
    
}




