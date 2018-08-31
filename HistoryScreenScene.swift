//
//  HistoryScreenScene.swift
//  HexWars
//
//  Created by Aleksandr Grin on 10/2/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit

class HistoryScreenScene: SKScene {
    weak var parentViewController:HistoryScreen?
    var menuButtonRecognizer:UITapGestureRecognizer?
    let fadeDuration = 0.25
    var tapSoundMaker:SKAudioNode?
    
    override func didMove(to view: SKView) {
        setupBackGround(for: view)
        setupMenuStyle(for: view){
            self.setupTopMenuButtons(for: view){}
            self.setupInformationDisplay(for: view){}

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
        backGroundColorImage.zPosition = -2
        backGroundColorImage.anchorPoint = CGPoint(x: 0, y: 0)

        let backGroundStyleImage = SKSpriteNode(texture: SKTexture(imageNamed: "BackGroundStyleV3"), size: view.frame.size)
        backGroundStyleImage.zPosition = -1
        backGroundStyleImage.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backGroundStyleImage.blendMode = .add
        backGroundStyleImage.colorBlendFactor = 1.0
        backGroundStyleImage.name = "backGroundStyleImage"
        backGroundStyleImage.color = GameState.sharedInstance().mainPlayerOptions!.chosenPlayerColor!.getColorFromCode()

        self.addChild(backGroundColorImage)
        self.addChild(backGroundStyleImage)

        animateBackGround(for: view)
    }

    private func animateBackGround(for view: SKView){
        let path = CGMutablePath()
        let refRect = CGRect(x: view.frame.width / 2 - 12, y: view.frame.height / 2 - 12, width: 24, height: 24)
        path.addEllipse(in: refRect)
        let bkg1 = self.childNode(withName: "backGroundStyleImage") as! SKSpriteNode

        let animation = SKAction.repeatForever(SKAction.follow(path, asOffset: false, orientToPath: false, speed: 4))
        bkg1.run(animation)
    }
    
    private func setupMenuStyle(for view: SKView, completion: @escaping ()->()){
        let trackBarAnimationTime = 0.20
        
        var moveIn = SKAction.move(to: CGPoint(x: 0, y: view.frame.height - 80), duration: trackBarAnimationTime)
        var entryAnimation = SKAction.sequence([SKAction.group([SKAction.fadeAlpha(to: 1, duration: trackBarAnimationTime), moveIn])])
        let setupTopArray = [[1, 1, 1],
                             [1, 1, 1],
                             [0, 0, 1]]
        
        let setupBotArray = [[0, 0, 1],
                             [1, 1, 1],
                             [1, 1, 1],
                             [1, 1, 1],
                             [1, 1, 1],
                             [1, 0, 0]]
        
        let topTrackBar = tileUIBuilder.createTileBar(scene: self, enterFromLeft: false, name: "topBar", yPosition: view.frame.height - 80)
        topTrackBar.run(entryAnimation){
            tileUIBuilder.generateTilesUsingArray(scene: self, configuration: setupTopArray, atTrack: topTrackBar, evenIndented: false, enterFromLeft: false, offset: nil){ }
        }
        
        moveIn = SKAction.move(to: CGPoint(x: 0, y: view.frame.height / 2 ), duration: trackBarAnimationTime)
        entryAnimation = SKAction.sequence([SKAction.wait(forDuration: 0.3), SKAction.group([SKAction.fadeAlpha(to: 1, duration: trackBarAnimationTime), moveIn])])
        
        let bottomTrackBar1 = tileUIBuilder.createTileBar(scene: self, enterFromLeft: true, name: "midBar", yPosition: view.frame.height / 2 )
        bottomTrackBar1.run(entryAnimation){
            tileUIBuilder.generateTilesUsingArray(scene: self, configuration: setupBotArray, atTrack: bottomTrackBar1, evenIndented: false, enterFromLeft: false, offset: 80){
            }
        }
        
        moveIn = SKAction.move(to: CGPoint(x: 0, y: bottomTrackBar1.position.y - 120), duration: trackBarAnimationTime)
        entryAnimation = SKAction.sequence([SKAction.wait(forDuration: 1.4), SKAction.group([SKAction.fadeAlpha(to: 1, duration: trackBarAnimationTime), moveIn])])
        
        let bottomTrackBar2 = tileUIBuilder.createTileBar(scene: self, enterFromLeft: false, name: "lowBar", yPosition: bottomTrackBar1.position.y - 120)
        bottomTrackBar2.run(entryAnimation){
            completion()
        }
    }
    
    private func setupTopMenuButtons(for view: SKView, completion: @escaping ()->()){
        let returnButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        returnButton.setButtonText(text: "Return")
        returnButton.setButtonTextFont(size: 18)
        returnButton.text!.position.y += 5
        self.addChild(returnButton)
        returnButton.name = "returnButton"
        returnButton.alpha = 0
        returnButton.zPosition = 2
        returnButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c0_r1_topBar")?.position{
            returnButton.position = buttonPosition
        }
        
        let resetButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        resetButton.setButtonText(text: "Reset \n \nHistory")
        resetButton.setButtonTextFont(size: 18)
        resetButton.text!.position.y += 10
        self.addChild(resetButton)
        resetButton.name = "resetButton"
        resetButton.alpha = 0
        resetButton.zPosition = 2
        resetButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c2_r0_topBar")?.position{
            resetButton.position = buttonPosition
        }
        
        returnButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        resetButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration)){
            completion()
        }
        
        let confirmResetButton = SpriteButton(button: SKTexture(imageNamed: "RegularHexUTab"), buttonTouched: SKTexture(imageNamed: "RegularHexUTab_TouchUpInside"))
        confirmResetButton.setButtonText(text: "Confirm")
        confirmResetButton.setButtonTextFont(size: 18)
        self.addChild(confirmResetButton)
        confirmResetButton.name = "confirmResetButton"
        confirmResetButton.alpha = 1
        confirmResetButton.zPosition = 2
        confirmResetButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        confirmResetButton.isHidden = true
        if let buttonPosition = self.childNode(withName: "transparent_c2_r2_topBar")?.position{
            confirmResetButton.position = buttonPosition
            confirmResetButton.position.y += 5
        }
    }
    
    private func setupInformationDisplay(for view: SKView, completion: @escaping ()->()){
        let gamesPlayed = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        gamesPlayed.setButtonText(text: "Games \n \nPlayed")
        gamesPlayed.setButtonTextFont(size: 14)
        gamesPlayed.text!.position.y += 5
        self.addChild(gamesPlayed)
        gamesPlayed.name = "gamesPlayed"
        gamesPlayed.alpha = 0
        gamesPlayed.zPosition = 2
        gamesPlayed.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c0_r1_midBar")?.position{
            gamesPlayed.position = buttonPosition
        }
        
        let gamesPlayedDisplay = SpriteButton(button: SKTexture(imageNamed: "RegularHexUTab"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        gamesPlayedDisplay.setButtonText(text: "\(GameState.sharedInstance().playerStatistics!.gamesPlayedTotal!)")
        gamesPlayedDisplay.setButtonTextFont(size: 22)
        self.addChild(gamesPlayedDisplay)
        gamesPlayedDisplay.name = "gamesPlayedDisplay"
        gamesPlayedDisplay.alpha = 0
        gamesPlayedDisplay.zPosition = 2
        gamesPlayedDisplay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c0_r3_midBar")?.position{
            gamesPlayedDisplay.position = buttonPosition
            gamesPlayedDisplay.position.y += 5
        }
        
        let gamesWon = SpriteButton(button: SKTexture(imageNamed: "SectionedHex2"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        gamesWon.setButtonText(text: "Games \nWon \n\nGames \nLost")
        gamesWon.setButtonTextFont(size: 12)
        gamesWon.text!.position.y += 5
        self.addChild(gamesWon)
        gamesWon.name = "gamesWon"
        gamesWon.alpha = 0
        gamesWon.zPosition = 2
        gamesWon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c1_r2_midBar")?.position{
            gamesWon.position = buttonPosition
        }
        
        let gamesWonDisplay = SpriteButton(button: SKTexture(imageNamed: "SectionedHex1"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        gamesWonDisplay.setButtonText(text: "\n\(GameState.sharedInstance().playerStatistics!.gamesWonTotal!)\n\n\n\n\(GameState.sharedInstance().playerStatistics!.gamesLostTotal!)")
        gamesWonDisplay.setButtonTextFont(size: 18)
        self.addChild(gamesWonDisplay)
        gamesWonDisplay.name = "gamesWonDisplay"
        gamesWonDisplay.alpha = 0
        gamesWonDisplay.zPosition = 2
        gamesWonDisplay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c1_r4_midBar")?.position{
            gamesWonDisplay.position = buttonPosition
            gamesWonDisplay.position.y += 5
        }
        
        let fastestWin = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        fastestWin.setButtonText(text: "Fastest\n \nWin")
        fastestWin.setButtonTextFont(size: 14)
        self.addChild(fastestWin)
        fastestWin.name = "fastestWin"
        fastestWin.alpha = 0
        fastestWin.zPosition = 2
        fastestWin.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c2_r0_midBar")?.position{
            fastestWin.position = buttonPosition
            fastestWin.position.y += 5
        }
        
        let fastestWinDisplay = SpriteButton(button: SKTexture(imageNamed: "RegularHexUTab"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        fastestWinDisplay.setButtonText(text: "\(GameState.sharedInstance().playerStatistics!.fastestGameWin!)")
        fastestWinDisplay.setButtonTextFont(size: 22)
        self.addChild(fastestWinDisplay)
        fastestWinDisplay.name = "fastestWinDisplay"
        fastestWinDisplay.alpha = 0
        fastestWinDisplay.zPosition = 2
        fastestWinDisplay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c2_r2_midBar")?.position{
            fastestWinDisplay.position = buttonPosition
            fastestWinDisplay.position.y += 5
        }
        
        gamesPlayed.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        gamesPlayedDisplay.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        gamesWon.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        gamesWonDisplay.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        fastestWin.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        fastestWinDisplay.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
    }

    private func resetStatistics(){
        GameState.sharedInstance().playerStatistics!.fastestGameWin! = 0
        GameState.sharedInstance().playerStatistics!.gamesLostTotal! = 0
        GameState.sharedInstance().playerStatistics!.gamesWonTotal! = 0
        GameState.sharedInstance().playerStatistics!.gamesPlayedTotal! = 0
    }
    
    func resetButtons(){
        self.childNode(withName: "confirmResetButton")?.isHidden = true
    }
    
    @objc func handleMenuTap(_ sender: UITapGestureRecognizer){
        let tapped = sender.location(in: self.scene?.view)
        let locationInScene = self.convertPoint(fromView: tapped)

        if self.childNode(withName: "confirmResetButton") != nil {
            if self.nodes(at: locationInScene).contains(self.childNode(withName: "confirmResetButton")!) == false {
                resetButtons()
            }
        }

        for button in (self.scene?.children)! {
            if button.contains(locationInScene){
                if let buttonName = button.name {
                    switch buttonName {
                    case "returnButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            self.parentViewController?.returnToMenu()
                        }
                        return
                    case "resetButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            self.childNode(withName: "confirmResetButton")?.isHidden = false
                        }
                        return
                    case "confirmResetButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            self.resetButtons()
                            self.resetStatistics()
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
