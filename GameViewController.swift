//
//  GameViewController.swift
//  HexWars
//
//  Created by Aleksandr Grin on 8/5/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

var sceneFilePath: String {
//1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
    let manager = FileManager.default
//2 - this returns an array of urls from our documentDirectory and we take the first path
    let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
//3 - creates a new path component and creates a new file called "Data" which is where we will store our Data array.
    return (url!.appendingPathComponent("GameScene").path)
}

var stateFilePath: String {
//1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
    let manager = FileManager.default
//2 - this returns an array of urls from our documentDirectory and we take the first path
    let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
//3 - creates a new path component and creates a new file called "Data" which is where we will store our Data array.
    let pathOut = url!.appendingPathComponent("GameState").path
    return pathOut
}

class GameViewController: UIViewController {
    var gameScene: GameScene?

    override func loadView() {
        self.view = SKView()
        self.view.bounds.size = CGSize(width: 375, height: 667)
        self.navigationController!.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {

            if self.gameScene != nil {
                view.presentScene(self.gameScene)
                self.gameScene!.parentViewController = self
            }else{
                let scene = GameScene(size: CGSize(width: 375, height: 667))
                scene.scaleMode = .fill
                scene.size = CGSize(width: 375, height: 667)
                scene.parentViewController = self
                // Present the scene
                view.presentScene(scene)
                view.ignoresSiblingOrder = true

//                view.showsFPS = true
//                view.showsNodeCount = true
//                view.showsDrawCount = true
                self.gameScene = scene
            }

        }
    }
    func saveCurrentGame(){
        if self.gameScene != nil {
            NSKeyedArchiver.archiveRootObject(self.gameScene!, toFile: sceneFilePath)
            GameState.sharedInstance().wasGameSaved = true
        }else{
            GameState.sharedInstance().wasGameSaved = false
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    func presentGameOver(){
    let gameOver = GameOverScreen()
    let numTurns = self.gameScene!.currentTurn
    if self.gameScene!.gameModel!.players!.count > 1 {
        let winningPlayer = self.gameScene!.gameModel!.players!.first as! Player
        gameOver.loadWinning(player: winningPlayer, turns: numTurns, didSurrender: true)
    }else{
        let winningPlayer = self.gameScene!.gameModel!.players!.first as! Player
        gameOver.loadWinning(player: winningPlayer, turns: numTurns, didSurrender: false)
    }

    if GameState.sharedInstance().playerStatistics!.isGameBeingTracked == true{
        self.updatePlayerStatistics()
    }

    let launchTime = DispatchTime.now() + 0.2
    DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
        self.navigationController?.pushViewController(gameOver, animated: true)
    })
}

    func showTutorial(){
        let tutorial = TutorialScreen()

        let launchTime = DispatchTime.now() + 0.2
        self.gameScene!.isPaused = true
        DispatchQueue.main.asyncAfter(deadline: launchTime, execute: {
            self.navigationController?.pushViewController(tutorial, animated: true)
        })
    }

    func updatePlayerStatistics(){
        GameState.sharedInstance().playerStatistics!.gamesPlayedTotal! += 1

        if (self.gameScene!.gameModel!.players!.first! as! Player).isPlayerHuman == true && self.gameScene!.gameModel!.players!.count == 1 {
            GameState.sharedInstance().playerStatistics!.gamesWonTotal! += 1
            if GameState.sharedInstance().playerStatistics!.fastestGameWin! != 0 {
                GameState.sharedInstance().playerStatistics!.fastestGameWin! = min(self.gameScene!.currentTurn, GameState.sharedInstance().playerStatistics!.fastestGameWin!)
            }else{
                GameState.sharedInstance().playerStatistics!.fastestGameWin! = self.gameScene!.currentTurn
            }
        }else{
            GameState.sharedInstance().playerStatistics!.gamesLostTotal! += 1
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}