//
//  LogoLoadingScreen.swift
//  HexWars
//
//  Created by Aleksandr Grin on 8/5/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import SpriteKit
import UIKit

class MainScreen: UIViewController{
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.view.bounds.size = CGSize(width: 375, height: 667)
    }
    
    override func loadView() {
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

//            view.showsFPS = true
//            view.showsNodeCount = true
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