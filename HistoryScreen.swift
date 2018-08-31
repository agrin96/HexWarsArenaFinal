//
//  HistoryScreen.swift
//  HexWars
//
//  Created by Aleksandr Grin on 10/2/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import UIKit
import SpriteKit

class HistoryScreen: UIViewController {

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