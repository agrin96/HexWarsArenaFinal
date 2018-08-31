//
// Created by Aleksandr Grin on 10/12/17.
// Copyright (c) 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GameOverScene: SKScene{
    let fadeInDuration:Double = 1.0

    weak var parentViewController:GameOverScreen?
    var menuButtonRecognizer:UITapGestureRecognizer?
    var tapSoundMaker:SKAudioNode?

    override func didMove(to view: SKView) {
        self.view!.ignoresSiblingOrder = true
        setupBackGround(for: view)
        displayGameOver(for: view){
            self.createReturnBar(for: view)
        }
        menuButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMenuTap))
        self.scene?.view?.addGestureRecognizer(menuButtonRecognizer!)

        if GameState.sharedInstance().mainPlayerOptions!.chosenSoundToggle! == .soundOn {
            if let path = Bundle.main.url(forResource: "TapSound", withExtension: "wav", subdirectory: "Sounds"){
                self.tapSoundMaker = SKAudioNode(url: path)
                self.tapSoundMaker!.autoplayLooped = false
                self.tapSoundMaker!.isPositional = false
                self.tapSoundMaker!.run(SKAction.changeVolume(to: 0.10, duration: 0))
                self.addChild(self.tapSoundMaker!)
            }
        }
    }

    private func setupBackGround(for view: SKView){
        let backGroundColorImage = SKSpriteNode(texture: SKTexture(imageNamed: "Background"), size: view.frame.size)
        backGroundColorImage.zPosition = -1
        backGroundColorImage.anchorPoint = CGPoint(x: 0, y: 0)

        self.addChild(backGroundColorImage)
    }

    private func displayGameOver(for view: SKView, completion: @escaping ()->()){
        var textToUse:String = "Victory!"
        if self.parentViewController!.didPlayerSurrender! == true{
            textToUse = "Defeat!"
        }


        let gameOverText = SKLabelNode(text: "Player \(self.parentViewController!.winningPlayer!.playerId)")
        gameOverText.alpha = 0.0
        gameOverText.name = "victoryText"
        gameOverText.fontColor = self.parentViewController!.winningPlayer!.color!
        gameOverText.fontSize = 80
        gameOverText.zPosition = 1
        gameOverText.isHidden = false
        gameOverText.fontName = "Arial-BoldMT"
        gameOverText.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        self.addChild(gameOverText)

        let gameOverText2 = SKLabelNode(text: textToUse)
        gameOverText2.alpha = 1.0
        gameOverText2.name = "gameOverText2"
        gameOverText2.zPosition = 1
        gameOverText2.fontColor = self.parentViewController!.winningPlayer!.color!
        gameOverText2.fontSize = 56
        gameOverText2.isHidden = false
        gameOverText2.fontName = "Arial-BoldMT"
        gameOverText2.position.y = gameOverText2.position.y - 70
        gameOverText.addChild(gameOverText2)

        let entryAnimation = SKAction.group([SKAction.fadeAlpha(to: 1.0, duration: fadeInDuration),
                                             SKAction.move(to: CGPoint(x: view.frame.width / 2, y: view.frame.height / 1.25), duration: fadeInDuration)])
        gameOverText.run(entryAnimation){
            completion()
        }

        let NumberOfTurns = SKLabelNode(text: "Number of Turns:")
        NumberOfTurns.alpha = 0.0
        NumberOfTurns.name = "NumberOfTurns"
        NumberOfTurns.fontSize = 26
        NumberOfTurns.zPosition = 1
        NumberOfTurns.isHidden = false
        NumberOfTurns.fontColor = self.parentViewController!.winningPlayer!.color!
        NumberOfTurns.fontName = "Arial-BoldMT"
        NumberOfTurns.position = CGPoint(x: view.frame.width / 2, y: 0)
        self.addChild(NumberOfTurns)

        let NumberOfTurns2 = SKLabelNode(text: "\(self.parentViewController!.winningTurns!)")
        NumberOfTurns2.alpha = 1.0
        NumberOfTurns2.name = "gameOverText2"
        NumberOfTurns2.zPosition = 1
        NumberOfTurns2.fontSize = 28
        NumberOfTurns2.isHidden = false
        NumberOfTurns2.fontColor = self.parentViewController!.winningPlayer!.color!
        NumberOfTurns2.fontName = "Arial-BoldMT"
        NumberOfTurns2.position.y = NumberOfTurns2.position.y - 40
        NumberOfTurns.addChild(NumberOfTurns2)

        let entryAnimation2 = SKAction.group([SKAction.fadeAlpha(to: 1.0, duration: fadeInDuration),
                                             SKAction.move(to: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2), duration: fadeInDuration)])
        NumberOfTurns.run(entryAnimation2){
            completion()
        }
    }

    private func createReturnBar(for view: SKView){
        let bottomBar = SKSpriteNode(texture: SKTexture(imageNamed: "TrackBar"))
        bottomBar.alpha = 0
        bottomBar.name = "saveBar"
        bottomBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        bottomBar.isHidden = false
        bottomBar.zPosition = 1
        bottomBar.yScale = 2
        bottomBar.position = CGPoint(x: 0, y: view.frame.height / 8)
        self.addChild(bottomBar)

        let returnButton = SpriteButton(button: SKTexture(imageNamed: "CrownIndicator"), buttonTouched: SKTexture(imageNamed: "CrownIndicator_TouchUpInside"))
        returnButton.setButtonText(text: "Return to Menu")
        returnButton.setButtonTextFont(size: 16)
        returnButton.text!.position.y += 18
        returnButton.alpha = 1.0
        returnButton.name = "returnButton"
        returnButton.anchorPoint = CGPoint(x: 0.5, y: 0)
        returnButton.isHidden = false
        returnButton.zPosition = 2
        returnButton.xScale = 1.5
        returnButton.position = CGPoint(x: bottomBar.frame.width / 2, y: -bottomBar.frame.height / 6)
        bottomBar.addChild(returnButton)

        bottomBar.run(SKAction.fadeAlpha(to: 1.0, duration: 1.0))
    }

    @objc func handleMenuTap(_ sender: UITapGestureRecognizer){
        let tapped = sender.location(in: self.scene?.view)
        let scenelocation = self.scene!.convertPoint(fromView: tapped)
        let cameralocation = self.convert(scenelocation, from: self.scene!)

        let touchedNodes = self.nodes(at: cameralocation)
        if touchedNodes.isEmpty == false{
            for button in touchedNodes {
                if let buttonName = button.name {
                    switch buttonName {
                    case "returnButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            self.parentViewController!.returnToMainScreen()
                        }
                        return
                    default:
                        break
                    }
                }
            }
        }
    }


}
