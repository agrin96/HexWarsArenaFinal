//
//  OptionsMenuScene.swift
//  HexWars
//
//  Created by Aleksandr Grin on 9/30/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit


class OptionsMenuScene: SKScene {
    weak var parentViewController:OptionsMenu?
    var menuButtonRecognizer:UITapGestureRecognizer?
    var tapSoundMaker:SKAudioNode?
    let fadeDuration = 0.25
    var possiblePlayerColors:Array<SKColor> = [.red, .blue, .green, .yellow, .purple, .orange, .cyan, .magenta, .brown]
    
    override func didMove(to view: SKView) {
        setupBackGround(for: view)
        setupMenuStyle(for: view){
            self.setupTopMenuButtons(for: view){}
            self.setupOptionsButtons(for: view){}
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
        let backGroundStyleImage = SKSpriteNode(texture: SKTexture(imageNamed: "BackGroundStyleV1"), size: view.frame.size)
        backGroundStyleImage.zPosition = -1
        backGroundStyleImage.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backGroundStyleImage.colorBlendFactor = 1.0
        backGroundStyleImage.blendMode = .add
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

        let animation = SKAction.repeatForever(SKAction.follow(path, asOffset: false, orientToPath: false, speed: 7))
        bkg1.run(animation)
    }

    private func setupMenuStyle(for view: SKView, completion: @escaping ()->()){
        let trackBarAnimationTime = 0.20
        
        var moveIn = SKAction.move(to: CGPoint(x: 0, y: view.frame.height - 80), duration: trackBarAnimationTime)
        var entryAnimation = SKAction.sequence([SKAction.group([SKAction.fadeAlpha(to: 1, duration: trackBarAnimationTime), moveIn])])
        let setupTopArray = [[1, 1, 1],
                             [1, 1, 1]]
        
        let setupBotArray = [[0, 0, 1],
                             [1, 1, 1],
                             [1, 1, 1],
                             [1, 1, 1],
                             [1, 1, 1],
                             [1, 1, 0]]
        
        let topTrackBar = tileUIBuilder.createTileBar(scene: self, enterFromLeft: false, name: "topBar", yPosition: view.frame.height - 80)
        topTrackBar.run(entryAnimation){
            tileUIBuilder.generateTilesUsingArray(scene: self, configuration: setupTopArray, atTrack: topTrackBar, evenIndented: false, enterFromLeft: false, offset: nil){ }
        }
        
        moveIn = SKAction.move(to: CGPoint(x: 0, y: view.frame.height / 2 ), duration: trackBarAnimationTime)
        entryAnimation = SKAction.sequence([SKAction.wait(forDuration: 0.3), SKAction.group([SKAction.fadeAlpha(to: 1, duration: trackBarAnimationTime), moveIn])])
        
        let bottomTrackBar1 = tileUIBuilder.createTileBar(scene: self, enterFromLeft: true, name: "midBar", yPosition: view.frame.height / 2 )
        bottomTrackBar1.run(entryAnimation){
            tileUIBuilder.generateTilesUsingArray(scene: self, configuration: setupBotArray, atTrack: bottomTrackBar1, evenIndented: false, enterFromLeft: false, offset: 60){
            }
        }
        
        moveIn = SKAction.move(to: CGPoint(x: 0, y: bottomTrackBar1.position.y - 120), duration: trackBarAnimationTime)
        entryAnimation = SKAction.sequence([SKAction.wait(forDuration: 1.2), SKAction.group([SKAction.fadeAlpha(to: 1, duration: trackBarAnimationTime), moveIn])])
        
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
        
        returnButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration)){
            completion()
        }
    }
    
    private func setupOptionsButtons(for view: SKView, completion: @escaping ()->()){
        let soundOnButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        soundOnButton.setButtonText(text: "Sound \n\nON")
        soundOnButton.setButtonTextFont(size: 18)
        soundOnButton.text!.position.y += 5
        self.addChild(soundOnButton)
        soundOnButton.name = "SoundOnButton"
        soundOnButton.alpha = 0
        soundOnButton.zPosition = 2
        soundOnButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        soundOnButton.addButtonVariation(text: "Sound \n\nOFF")
        if let buttonPosition = self.childNode(withName: "transparent_c0_r1_midBar")?.position{
            soundOnButton.position = buttonPosition
        }
        
        let playerColorButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        playerColorButton.setButtonText(text: "Player \n\nColor")
        playerColorButton.setButtonTextFont(size: 18)
        playerColorButton.text!.position.y += 5
        self.addChild(playerColorButton)
        playerColorButton.name = "playerColorButton"
        playerColorButton.alpha = 0
        playerColorButton.zPosition = 2
        playerColorButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c2_r0_midBar")?.position{
            playerColorButton.position = buttonPosition
        }
        
        
        let playerPieceButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        playerPieceButton.setButtonText(text: "Theme")
        playerPieceButton.setButtonTextFont(size: 20)
        playerPieceButton.text!.position.y += 5
        self.addChild(playerPieceButton)
        playerPieceButton.name = "playerPieceButton"
        playerPieceButton.alpha = 0
        playerPieceButton.zPosition = 2
        playerPieceButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c2_r4_midBar")?.position{
            playerPieceButton.position = buttonPosition
        }

        let playerWallButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        playerWallButton.setButtonText(text: "Wall \n\nType")
        playerWallButton.setButtonTextFont(size: 18)
        playerWallButton.text!.position.y += 5
        self.addChild(playerWallButton)
        playerWallButton.name = "playerWallButton"
        playerWallButton.alpha = 0
        playerWallButton.zPosition = 2
        playerWallButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c1_r3_midBar")?.position{
            playerWallButton.position = buttonPosition
        }
        
        let playerColorCycle = SpriteButton(button: SKTexture(imageNamed: "ColorCycleWhitened"), buttonTouched: SKTexture(imageNamed: "ColorCycleWhitened_TouchUpInside"))
        self.addChild(playerColorCycle)
        playerColorCycle.name = "playerColorCycle"
        playerColorCycle.alpha = 1
        playerColorCycle.zPosition = 2
        playerColorCycle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        playerColorCycle.isHidden = true
        playerColorCycle.blendMode = .alpha
        playerColorCycle.colorBlendFactor = 1.0
        playerColorCycle.color = GameState.sharedInstance().mainPlayerOptions!.chosenPlayerColor!.getColorFromCode()
        
        if let buttonPosition = self.childNode(withName: "transparent_c1_r1_midBar")?.position{
            playerColorCycle.position = buttonPosition
        }

        soundOnButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        playerWallButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        playerColorButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        playerPieceButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration)){
            completion()
        }

        let playerPieceCycle = SpriteButton(button: SKTexture(imageNamed: "RegularHexRTab"), buttonTouched: SKTexture(imageNamed: "RegularHexRTab_TouchUpInside"))
        playerPieceCycle.setButtonText(text: "Medieval")
        playerPieceCycle.setButtonTextFont(size: 14)
        playerPieceCycle.text!.position.y += 5
        self.addChild(playerPieceCycle)
        playerPieceCycle.name = "playerPieceCycle"
        playerPieceCycle.alpha = 1
        playerPieceCycle.zPosition = 2
        playerPieceCycle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        playerPieceCycle.isHidden = true
        playerPieceCycle.addButtonVariation(text: "Sci-FI")
        playerPieceCycle.addButtonVariation(text: "Modern")
        playerPieceCycle.iterateButtonVariation(toPosition: GameState.sharedInstance().mainPlayerOptions!.chosenGameTheme!.rawValue){}

        if let buttonPosition = self.childNode(withName: "transparent_c1_r5_midBar")?.position{
            playerPieceCycle.position = buttonPosition
        }

        let playerWallCycle = SpriteButton(button: SKTexture(imageNamed: "RegularHexRTab"), buttonTouched: SKTexture(imageNamed: "RegularHexRTab_TouchUpInside"))
        playerWallCycle.setButtonText(text: "Wall A")
        playerWallCycle.setButtonTextFont(size: 14)
        playerWallCycle.text!.position.y += 5
        self.addChild(playerWallCycle)
        playerWallCycle.name = "playerWallCycle"
        playerWallCycle.alpha = 1
        playerWallCycle.zPosition = 2
        playerWallCycle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        playerWallCycle.isHidden = true
        playerWallCycle.addButtonVariation(text: "Wall B")
        playerWallCycle.addButtonVariation(text: "Wall C")
        playerWallCycle.iterateButtonVariation(toPosition: GameState.sharedInstance().mainPlayerOptions!.chosenWallType!.rawValue){}

        if let buttonPosition = self.childNode(withName: "transparent_c1_r4_midBar")?.position{
            playerWallCycle.position = buttonPosition
        }
    }
    
    func resetCycleButtons(){
        self.childNode(withName: "playerPieceCycle")?.isHidden = true
        self.childNode(withName: "playerColorCycle")?.isHidden = true
        self.childNode(withName: "playerWallCycle")?.isHidden = true
    }
    
    @objc func handleMenuTap(_ sender: UITapGestureRecognizer){
        let tapped = sender.location(in: self.scene?.view)
        let locationInScene = self.convertPoint(fromView: tapped)
        
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
                    case "SoundOnButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).iterateButtonVariation(toPosition: nil){
                            (self.childNode(withName: "SoundOnButton")! as! SpriteButton).buttonTouchedUpInside(){
                                if (button as! SpriteButton).currentVariation == 1{
                                    // SoundOff
                                    GameState.sharedInstance().mainPlayerOptions!.chosenSoundToggle = SoundToggle.soundOff
                                    self.tapSoundMaker = nil
                                    for vc in self.parentViewController!.navigationController!.childViewControllers {
                                        if vc is MainScreen {
                                            (((vc as! MainScreen).view as! SKView).scene as! MainMenuScene).backGroundMusicMaker!.run(SKAction.pause())
                                            (((vc as! MainScreen).view as! SKView).scene as! MainMenuScene).tapSoundMaker = nil
                                        }
                                    }
                                }else{
                                    // SoundOn
                                    GameState.sharedInstance().mainPlayerOptions!.chosenSoundToggle = SoundToggle.soundOn
                                    if let path = Bundle.main.url(forResource: "TapSound", withExtension: "wav", subdirectory: "Sounds"){
                                        self.tapSoundMaker = SKAudioNode(url: path)
                                        self.tapSoundMaker!.autoplayLooped = false
                                        self.tapSoundMaker!.isPositional = false
                                        self.tapSoundMaker!.run(SKAction.changeVolume(to: 0.10, duration: 0))
                                        self.addChild(self.tapSoundMaker!)
                                    }
                                    for vc in self.parentViewController!.navigationController!.childViewControllers {
                                        if vc is MainScreen {
                                            (((vc as! MainScreen).view as! SKView).scene as! MainMenuScene).backGroundMusicMaker!.run(SKAction.play())
                                            (((vc as! MainScreen).view as! SKView).scene as! MainMenuScene).reinitSoundMaker()
                                        }
                                    }
                                }
                            }
                        }
                        return
                    case "playerColorButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "playerColorCycle")?.isHidden == true {
                                self.childNode(withName: "playerColorCycle")?.isHidden = false
                            }else{
                                self.childNode(withName: "playerColorCycle")?.isHidden = true
                            }
                        }
                        return
                    case "playerWallButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "playerWallCycle")?.isHidden == true {
                                self.childNode(withName: "playerWallCycle")?.isHidden = false
                            }else{
                                self.childNode(withName: "playerWallCycle")?.isHidden = true
                            }
                        }
                        return
                    case "playerWallCycle":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).iterateButtonVariation(toPosition: nil){
                            (self.childNode(withName: "playerWallCycle")! as! SpriteButton).buttonTouchedUpInside(){
                                if self.childNode(withName: "playerWallCycle")?.isHidden == false {
                                    if (button as! SpriteButton).currentVariation != nil{
                                        GameState.sharedInstance().mainPlayerOptions!.chosenWallType = WallType(rawValue: (button as! SpriteButton).currentVariation!)
                                    }
                                }
                            }
                        }
                        return
                    case "playerPieceButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "playerPieceCycle")?.isHidden == true {
                                self.childNode(withName: "playerPieceCycle")?.isHidden = false
                            }else{
                                self.childNode(withName: "playerPieceCycle")?.isHidden = true
                            }
                        }
                        return
                    case "playerPieceCycle":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).iterateButtonVariation(toPosition: nil){
                            (self.childNode(withName: "playerPieceCycle")! as! SpriteButton).buttonTouchedUpInside(){
                                if self.childNode(withName: "playerPieceCycle")?.isHidden == false {
                                    if (button as! SpriteButton).currentVariation != nil{
                                        GameState.sharedInstance().mainPlayerOptions!.chosenGameTheme = GameTheme(rawValue: (button as! SpriteButton).currentVariation!)
                                    }
                                }
                            }
                        }
                        return
                    case "playerColorCycle":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (self.childNode(withName: "playerColorCycle")! as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "playerColorCycle")?.isHidden == false {
                                let currentColor:UIColor = (self.childNode(withName: "playerColorCycle")! as! SKSpriteNode).color
                                var currentIndex = self.possiblePlayerColors.index(of: currentColor)
                                if currentIndex == nil {
                                    currentIndex = 8    //Deals with the floating point rounding error on brown
                                }
                                if currentIndex! + 1 >= self.possiblePlayerColors.count {
                                    currentIndex = 0
                                    (self.childNode(withName: "playerColorCycle")! as! SKSpriteNode).color = self.possiblePlayerColors[currentIndex!]
                                }else{
                                    currentIndex! += 1
                                    (self.childNode(withName: "playerColorCycle")! as! SKSpriteNode).color = self.possiblePlayerColors[currentIndex!]
                                }

                                if currentIndex != nil {
                                    GameState.sharedInstance().mainPlayerOptions!.chosenPlayerColor = PlayerColor(rawValue: currentIndex!)
                                    (self.childNode(withName: "//backGroundStyleImage") as! SKSpriteNode).color = PlayerColor(rawValue: currentIndex!)!.getColorFromCode()
                                }
                            }
                        }
                        return
                    default:
                        break
                    }
                }
            }
        }

        if self.childNode(withName: "playerPieceCycle") != nil && self.childNode(withName: "playerColorCycle") != nil {
            if self.nodes(at: locationInScene).contains(self.childNode(withName: "playerPieceCycle")!) == false {
                if self.nodes(at: locationInScene).contains(self.childNode(withName: "playerColorCycle")!) == false {
                    resetCycleButtons()
                }
            }
        }
    }
}
