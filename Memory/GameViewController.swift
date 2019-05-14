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
import CoreLocation
import UserNotifications

class GameViewController: UIViewController, SceneControllerDelegate/*, GADBannerViewDelegate*/ {
    
    let locationManager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    
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
        
        initLocation()
        initNotifications()
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
    
    func usernamePopup() {
        
        //1. Mostrar popup
        let ac = UIAlertController(title: "Enter Username", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned ac] _ in
            let playerName = ac.textFields![0]
            FirebaseManager.instance.createUser(username: playerName.text ?? "Anonymous")
        })
        
        self.present(ac, animated: true, completion: nil)
        
    }
    
    func goToRankings(sender: SKScene?) {
        //LOAD MENU
        if let view = self.view as? SKView {
            let scene = RankingsScene(size: view.frame.size)
            scene.sceneControllerDelegate = self
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
        }
    }
    
    func goToMenu(sender: SKScene?){
        
        //LOAD MENU
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
    
    func initLocation() {
        //Setejar delegate
        locationManager.delegate = self
        
        //per estalviarnos cridar la funcio de autoritzacio, que no farà res si el permis ja està demanat
        if CLLocationManager.authorizationStatus() == .authorizedAlways
            || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            locationManager.requestLocation() //pq no li caldra fer un update aixi
            locationManager.startUpdatingLocation()
        } else{
            //Demanar permis la primera vegada
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func initNotifications() {
       
        notificationCenter.requestAuthorization(options: [.alert]) {
            (isAccepted, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if isAccepted  {
                //Do nothing
            }
        }
    }
    
    func showHello() {
        
        notificationCenter.getNotificationSettings(completionHandler: {
            [weak self] (settings) in //avisem que self pot ser que no existeixi
            if settings.authorizationStatus == .authorized {
                //Send notification
                self?.sendHelloNotification()
            } else {
                //Show popup, pro al ser asincrono podria ser que la aplicacio ja s'hagués tancat i petaria
                self?.showHelloPopup()
            }
        })
        
        
    }
    
    func sendHelloNotification() {
        //ID
        let id = "Hello Notification"
        
        //Content
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Hello_dialog_title", comment: "")
        content.body = NSLocalizedString("Hello_dialog_msg", comment: "")
        
        //Trigger : send in X seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        //Notification request
        let notificationRequest = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        //Send
        notificationCenter.add(notificationRequest) { error in
            print("send notification")
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func showHelloPopup() {
        //Crear popup, El coment del localied string es per donar context per els traductors
        let dialog = UIAlertController(title: NSLocalizedString("Hello_dialog_title", comment: ""), message: NSLocalizedString("Hello_dialog_msg", comment: ""), preferredStyle: .alert)
        
        //Añadir botón
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        dialog.addAction(okButton)
        
        //Mostrarlo
        present(dialog, animated: true, completion: nil)
    }
    
}

//Ho fem separat per no tenir-ho tot junt. Això és de la localitzacio
extension GameViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()//cada vegada que s'acuaitza t'avisa
        case .denied:
            print("denied")
            //no podem tornar-ho a demanar aqui, nomes si usuari va a settings i ho activa
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            print("")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let officeLocation = CLLocation(latitude: +51.50998000, longitude: -0.13370000)
        if let lastLocation = locations.last {
            print(lastLocation)
            
            //if location in office
            if lastLocation.distance(from: officeLocation) < 50 { //unitats estan en metres
                //Show welcome
                print("user in location")
                showHello()
            }
        }
    }
    
    //Pq no peti si hi ha localitzacio
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //do nothing
        print(error.localizedDescription)
    }
}



