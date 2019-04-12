//
//  NewCustomGame.swift
//  HexWars
//
//  Created by Aleksandr Grin on 9/30/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import UIKit
import SpriteKit

class NewCustomGame: UIViewController {

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 11.0, *), let view = self.view {
            print(self.view.safeAreaLayoutGuide.layoutFrame)
            view.frame = CGRect(x: 0, y: 44, width: 375, height: 734)
        }
        view.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func loadView() {
        self.view = SKView()
        self.view.bounds.size = CGSize(width: 375, height: 667)
        self.view.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            print("\(self.view.bounds.size)")
            let scene = NewCustomGameScene()
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

    func returnToSinglePlayerMenu(){
        for vc in self.navigationController!.childViewControllers {
            if vc is SinglePlayerMenu {
                ((vc as! SinglePlayerMenu).view as! SKView).isPaused = false
            }
        }

        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func beginGame(){
        //Make sure all the options are saved before we exit
        ((self.view as! SKView).scene as! NewCustomGameScene).saveCustomOptionsToState()

        let gameScreen = GameViewController()

        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            (self.view as! SKView).isPaused = true
            self.navigationController?.pushViewController(gameScreen, animated: true)
        })
    }
}
