//
// Created by Aleksandr Grin on 1/13/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class TutorialScreen:UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    override func loadView() {
        self.view = SKView()
        self.view.bounds.size = CGSize(width: 375, height: 667)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {

            let scene = TutorialScene()
            scene.parentViewController = self
            scene.scaleMode = .fill
            scene.size = CGSize(width: 375, height: 667)

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

    func returnToMenu(){
        for vc in self.navigationController!.childViewControllers{
            if vc is GameViewController {
                (vc as! GameViewController).gameScene!.isPaused = false

                //If we opened from the gameScene then we resume the game and return to it.
                let launchTime = DispatchTime.now() + 0.2
                DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
                    self.navigationController?.popViewController(animated: true)
                })

                return
            }
        }
        for vc in self.navigationController!.childViewControllers {
            if vc is MainScreen {
                (vc as! MainScreen).updateBackGround()
                (((vc as! MainScreen).view as! SKView).scene as! MainMenuScene).animationToggle(pause: false)

                //If we opened from the mainscreen then we simply return to it.
                let launchTime = DispatchTime.now() + 0.2
                DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
                return
            }
        }
    }

}