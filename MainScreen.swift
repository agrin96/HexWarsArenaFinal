//
//  LogoLoadingScreen.swift
//  HexWars
//
//  Created by Aleksandr Grin on 8/5/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import SpriteKit
import UIKit
import GoogleMobileAds
import DeviceKit


//Control the ads.
fileprivate let topBannerAdd:String = "ca-app-pub-5462309909970544/6750410601"
fileprivate let bottomBannerAdd:String = "ca-app-pub-5462309909970544/6750410601"

class MainScreen: UIViewController{

    var topBannerViewAd:GADBannerView?
    var bottomBannerViewAd:GADBannerView?

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.view.bounds.size = CGSize(width: 375, height: 667)
    }
    
    override func loadView() {
        super.loadView()
        self.view = SKView()
        self.view.bounds.size = CGSize(width: 375, height: 667)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            let scene = MainMenuScene()
            scene.scaleMode = .fill

            scene.size = CGSize(width: 375, height: 667)
            scene.parentViewController = self
            // Present the scene
            view.presentScene(scene)
            view.ignoresSiblingOrder = true

            //The ad setup can be run async just to make sure no performance is impacted.
            DispatchQueue.main.async { [unowned self] in
                self.initializeBannerAds()
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func transitionToSinglePlayer(){
        let singlePlayerMenu = SinglePlayerMenu()

        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            ((self.view as! SKView).scene as! MainMenuScene).animationToggle(pause: true)
            self.navigationController?.pushViewController(singlePlayerMenu, animated: true)
        })
    }

    func transitionToOptions(){
        let optionsMenu = OptionsMenu()
        
        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            ((self.view as! SKView).scene as! MainMenuScene).animationToggle(pause: true)
            self.navigationController?.pushViewController(optionsMenu, animated: true)
        })
    }

    func transitionToHistory(){
        let historyMenu = HistoryScreen()
        
        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            ((self.view as! SKView).scene as! MainMenuScene).animationToggle(pause: true)
            self.navigationController?.pushViewController(historyMenu, animated: true)
        })
    }

    func transitionToTutorial(){
        let tutorialMenu = TutorialScreen()

        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            ((self.view as! SKView).scene as! MainMenuScene).animationToggle(pause: true)
            self.navigationController?.pushViewController(tutorialMenu, animated: true)
        })
    }

    func updateBackGround(){
        ((self.view as! SKView).scene as!MainMenuScene).updateBackGround()
    }
}

extension MainScreen:GADBannerViewDelegate {

    private func initializeBannerAds(){
        //Initialize top banner ad
        self.topBannerViewAd = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        self.topBannerViewAd!.delegate = self
        //Banner is initially hidden.
        self.topBannerViewAd!.alpha = 0.0
        self.view.addSubview(self.topBannerViewAd!)

        //These two constraints will center the ad banner and place it at the top safe area of the app.
        NSLayoutConstraint(item: self.topBannerViewAd!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true

        if Device.allDevicesWithSensorHousing.contains(Device.current){
            self.topBannerViewAd!.frame.origin.y = self.topBannerViewAd!.frame.height/1.8
        }else{
            self.topBannerViewAd!.frame.origin.y = 0
        }
        self.topBannerViewAd!.adUnitID = topBannerAdd
        self.topBannerViewAd!.rootViewController = self
        self.topBannerViewAd!.load(GADRequest())

        //Initialize bottom banner ad
        self.bottomBannerViewAd = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        self.bottomBannerViewAd!.delegate = self
        //Banner is initially hidden.
        self.bottomBannerViewAd!.alpha = 0.0
        self.view.addSubview(self.bottomBannerViewAd!)

        //These two constraints will center the ad banner and place it at the top safe area of the app.
        NSLayoutConstraint(item: self.bottomBannerViewAd!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true

        if Device.allDevicesWithSensorHousing.contains(Device.current){
            self.bottomBannerViewAd!.frame.origin.y = self.view.frame.height - self.bottomBannerViewAd!.frame.height*1.2
        }else{
            self.bottomBannerViewAd!.frame.origin.y = self.view.frame.height - self.bottomBannerViewAd!.frame.height
        }
        self.bottomBannerViewAd!.adUnitID = bottomBannerAdd
        self.bottomBannerViewAd!.rootViewController = self
        self.bottomBannerViewAd!.load(GADRequest())
    }

    func resetBannerAds(){
        self.topBannerViewAd = nil
    }

    //Check if the app has recieved an ad. If it has then fade the ad banner in and display the ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            bannerView.alpha = 1
        })
    }

    //If an ad has not appeared
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    }
}
