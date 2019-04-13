//
//  HistoryScreen.swift
//  HexWars
//
//  Created by Aleksandr Grin on 10/2/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds
import DeviceKit

//Control the ads.
fileprivate let bottomBannerAdd:String = "ca-app-pub-5462309909970544/6750410601"

class HistoryScreen: UIViewController {

    var bottomBannerViewAd:GADBannerView?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        
    }
    
    override func loadView() {
        self.view = SKView()
        self.view.bounds.size = CGSize(width: 375, height: 667)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            
            let scene = HistoryScreenScene()
            scene.scaleMode = .fill
            if Device.allDevicesWithSensorHousing.contains(Device.current){
                scene.size = CGSize(width: 375, height: 690)
            }else{
                scene.size = CGSize(width: 375, height: 667)
            }
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
        return true
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
    
    func returnToMenu(){
        for vc in self.navigationController!.childViewControllers {
            if vc is MainScreen {
                (vc as! MainScreen).updateBackGround()
                (((vc as! MainScreen).view as! SKView).scene as! MainMenuScene).animationToggle(pause: false)
            }
        }
        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            self.navigationController?.popViewController(animated: true)
        })
    }
}

extension HistoryScreen:GADBannerViewDelegate {

    private func initializeBannerAds(){
        //Initialize bottom banner ad
        self.bottomBannerViewAd = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        self.bottomBannerViewAd!.translatesAutoresizingMaskIntoConstraints = false
        self.bottomBannerViewAd!.delegate = self
        //Banner is initially hidden.
        self.bottomBannerViewAd!.alpha = 0.0
        self.view.addSubview(self.bottomBannerViewAd!)

        //These two constraints will center the ad banner and place it at the top safe area of the app.
        NSLayoutConstraint(item: self.bottomBannerViewAd!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: self.bottomBannerViewAd!, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottomMargin, multiplier: 1.0, constant: 0.0).isActive = true

        self.bottomBannerViewAd!.adUnitID = bottomBannerAdd
        self.bottomBannerViewAd!.rootViewController = self
        self.bottomBannerViewAd!.load(GADRequest())
    }

    func resetBannerAds(){
        self.bottomBannerViewAd = nil
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

