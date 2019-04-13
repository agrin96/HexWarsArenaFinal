//
// Created by Aleksandr Grin on 10/12/17.
// Copyright (c) 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit


class GameOverScreen: UIViewController {
    var winningPlayer:Player?
    var winningTurns:Int?
    var didPlayerSurrender:Bool?

    override func loadView() {
        self.view = SKView()
        self.view.bounds.size = CGSize(width: 375, height: 667)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {

            let scene = GameOverScene()
            scene.scaleMode = .fill
            scene.size = CGSize(width: 375, height: 667)
            scene.parentViewController = self
            // Present the scene
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }


    func loadWinning(player: Player, turns: Int, didSurrender:Bool){
        self.winningPlayer = player
        self.winningTurns = turns
        self.didPlayerSurrender = didSurrender
    }

    func returnToMainScreen() {
        GameState.sharedInstance().resetCurrentMap()

        for vc in self.navigationController!.childViewControllers {
            if vc is MainScreen {
                (vc as! MainScreen).updateBackGround()
                (((vc as! MainScreen).view as! SKView).scene as! MainMenuScene).animationToggle(pause: false)
            }
        }
        let launchTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            self.navigationController?.popToRootViewController(animated: true)
        })
    }
}