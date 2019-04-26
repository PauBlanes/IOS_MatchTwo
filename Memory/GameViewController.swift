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
import GoogleMobileAds
import FirebaseAnalytics

class GameViewController: UIViewController, SceneControllerDelegate, GADBannerViewDelegate {
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        Analytics.logEvent("bannerClick", parameters: nil)
    }
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Banner
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        tryLogin()
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
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
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func goToMenu(sender: SKScene){
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
    
    //Auth
    func tryLogin() {
        
        guard let authUI = FUIAuth.defaultAuthUI() else {
            return
        }
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
            ]
        authUI.providers = providers
        
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true, completion: nil)
    }
}

extension GameViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        //Check if there was an error
        if error != nil {
            print(error)
            return
        }
        
        //Cargar escena
        if let view = self.view as? SKView {
            // Load the SKScene from 'GameScene.sks'
            let scene = MenuScene(size: view.frame.size)
            scene.sceneControllerDelegate = self
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            //view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}


