//
//  SinglePlayerMenuScene.swift
//  HexWars
//
//  Created by Aleksandr Grin on 9/24/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import UIKit
import SpriteKit

//Note, the way that the aray access works for the transparent tile positions is with a column/row system.
// Each row of transparent tiles should be thought of as its own distinct entity for purpose of counting.
// For example, c1_r1 will be the second tile in the second row of tiles. DO NOT count the staggered tile from
// the row above.

class SinglePlayerMenuScene: SKScene {
    weak var parentViewController:SinglePlayerMenu?
    var menuButtonRecognizer:UITapGestureRecognizer?
    var presetMapScrollRecognizer:UIPanGestureRecognizer?
    var tapSoundMaker:SKAudioNode?

    let fadeDuration = 0.25
    //For the top and bottom row
    let setupArray:[[Int]] = [[1, 1, 1],
                              [1, 1, 1]]
    //For the middle row with the map presets.
    let midArray:[[Int]] = [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]

    
    override func didMove(to view: SKView) {
        setupBackGround(for: view)
        setupMenuStyle(for: view){
            self.setupTopMenuButtons(for: view){}
            self.setupMidMenuButtons(for: view){}
            self.setupBottomMenuButtons(for: view){
                self.createMapsPanRegion(for: view){}
            }
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
        let backGroundStyleImage = SKSpriteNode(texture: SKTexture(imageNamed: "BackGroundStyle"), size: view.frame.size)
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

        let animation = SKAction.repeatForever(SKAction.follow(path, asOffset: false, orientToPath: false, speed: 4))
        bkg1.run(animation)
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
        if let buttonPosition = self.childNode(withName: "transparent_c2_r0_topBar")?.position{
            returnButton.position = buttonPosition
        }
        
        returnButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration)){
            completion()
        }
    }
    
    private func setupMidMenuButtons(for view: SKView, completion: @escaping ()->()){
        let presetOne = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        presetOne.setButtonText(text: "Invader")
        presetOne.setButtonTextFont(size: 18)
        presetOne.text!.position.y += 5
        self.addChild(presetOne)
        presetOne.name = "midBar_preset_1"
        presetOne.alpha = 0
        presetOne.zPosition = 2
        presetOne.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c0_r1_midBar")?.position{
            presetOne.position = buttonPosition
        }
        
        let presetTwo = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        presetTwo.setButtonText(text: "Earth \n\nSimple")
        presetTwo.setButtonTextFont(size: 18)
        presetTwo.text!.position.y += 5
        self.addChild(presetTwo)
        presetTwo.name = "midBar_preset_2"
        presetTwo.alpha = 0
        presetTwo.zPosition = 2
        presetTwo.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c1_r0_midBar")?.position{
            presetTwo.position = buttonPosition
        }
        
        let presetThree = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        presetThree.setButtonText(text: "Earth \n\nV \n\nMars")
        presetThree.setButtonTextFont(size: 16)
        presetThree.text!.position.y += 5
        self.addChild(presetThree)
        presetThree.name = "midBar_preset_3"
        presetThree.alpha = 0
        presetThree.zPosition = 2
        presetThree.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c1_r1_midBar")?.position{
            presetThree.position = buttonPosition
        }

        let presetFour = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        presetFour.setButtonText(text: "Great \n\nWall")
        presetFour.setButtonTextFont(size: 16)
        presetFour.text!.position.y += 5
        self.addChild(presetFour)
        presetFour.name = "midBar_preset_4"
        presetFour.alpha = 0
        presetFour.zPosition = 2
        presetFour.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c2_r0_midBar")?.position{
            presetFour.position = buttonPosition
        }

        let presetFive = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        presetFive.setButtonText(text: "Two \n\nTowers")
        presetFive.setButtonTextFont(size: 16)
        presetFive.text!.position.y += 5
        self.addChild(presetFive)
        presetFive.name = "midBar_preset_5"
        presetFive.alpha = 0
        presetFive.zPosition = 2
        presetFive.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c2_r1_midBar")?.position{
            presetFive.position = buttonPosition
        }

        let presetSix = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        presetSix.setButtonText(text: "Spiral \n\n8 Arm")
        presetSix.setButtonTextFont(size: 16)
        presetSix.text!.position.y += 5
        self.addChild(presetSix)
        presetSix.name = "midBar_preset_6"
        presetSix.alpha = 0
        presetSix.zPosition = 2
        presetSix.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c3_r0_midBar")?.position{
            presetSix.position = buttonPosition
        }

        let presetSeven = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        presetSeven.setButtonText(text: "Island \n\nHopping")
        presetSeven.setButtonTextFont(size: 16)
        presetSeven.text!.position.y += 5
        self.addChild(presetSeven)
        presetSeven.name = "midBar_preset_7"
        presetSeven.alpha = 0
        presetSeven.zPosition = 2
        presetSeven.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c3_r1_midBar")?.position{
            presetSeven.position = buttonPosition
        }

        let presetEight = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        presetEight.setButtonText(text: "Urban \n\nWarfare")
        presetEight.setButtonTextFont(size: 16)
        presetEight.text!.position.y += 5
        self.addChild(presetEight)
        presetEight.name = "midBar_preset_8"
        presetEight.alpha = 0
        presetEight.zPosition = 2
        presetEight.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c4_r0_midBar")?.position{
            presetEight.position = buttonPosition
        }

        let presetNine = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        presetNine.setButtonText(text: "Thermo- \n\npylae")
        presetNine.setButtonTextFont(size: 16)
        presetNine.text!.position.y += 5
        self.addChild(presetNine)
        presetNine.name = "midBar_preset_9"
        presetNine.alpha = 0
        presetNine.zPosition = 2
        presetNine.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c4_r1_midBar")?.position{
            presetNine.position = buttonPosition
        }

        let presetTen = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        presetTen.setButtonText(text: "Three \n\nKings")
        presetTen.setButtonTextFont(size: 16)
        presetTen.text!.position.y += 5
        self.addChild(presetTen)
        presetTen.name = "midBar_preset_10"
        presetTen.alpha = 0
        presetTen.zPosition = 2
        presetTen.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c5_r0_midBar")?.position{
            presetTen.position = buttonPosition
        }
        
        presetOne.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        presetTwo.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        presetThree.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        presetFour.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        presetFive.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        presetSix.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        presetSeven.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        presetEight.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        presetNine.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        presetTen.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration)){
            completion()
        }
        
    }
    
    private func setupBottomMenuButtons(for view: SKView, completion: @escaping ()->()){
        let newRandomButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        newRandomButton.setButtonText(text: "New \n\nRandom \n\nMap")
        newRandomButton.setButtonTextFont(size: 16)
        newRandomButton.text!.position.y += 5
        self.addChild(newRandomButton)
        newRandomButton.name = "newRandomButton"
        newRandomButton.alpha = 0
        newRandomButton.zPosition = 2
        newRandomButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c1_r0_lowBar")?.position{
            newRandomButton.position = buttonPosition
        }
        
        let newCustomButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        newCustomButton.setButtonText(text: "New \n\nCustom \n\nMap")
        newCustomButton.setButtonTextFont(size: 16)
        newCustomButton.text!.position.y += 5
        self.addChild(newCustomButton)
        newCustomButton.name = "newCustomButton"
        newCustomButton.alpha = 0
        newCustomButton.zPosition = 2
        newCustomButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
        if let buttonPosition = self.childNode(withName: "transparent_c1_r1_lowBar")?.position{
            newCustomButton.position = buttonPosition
        }
        
        let newRandomBeginButton = SpriteButton(button: SKTexture(imageNamed: "RegularHexUTab"), buttonTouched: SKTexture(imageNamed: "RegularHexUTab_TouchUpInside"))
        newRandomBeginButton.setButtonText(text: "Begin \n\nGame")
        newRandomBeginButton.setButtonTextFont(size: 18)
        self.addChild(newRandomBeginButton)
        newRandomBeginButton.isUserInteractionEnabled = true
        newRandomBeginButton.isHidden = true
        newRandomBeginButton.name = "newRandomBeginButton"
        newRandomBeginButton.alpha = 1
        newRandomBeginButton.zPosition = 2
        newRandomBeginButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newRandomBeginButton.position = CGPoint(x: newRandomButton.position.x, y: newRandomButton.position.y - newRandomButton.frame.height / 1.15)
        
        newRandomButton.run(SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: fadeDuration)]))
        newCustomButton.run(SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: fadeDuration)]))
        
        completion()
    }
    
    private func setupMenuStyle(for view: SKView, completion: @escaping ()->()){
        let trackBarAnimationTime = 0.20
        
        var moveIn = SKAction.move(to: CGPoint(x: 0, y: view.frame.height - 80), duration: trackBarAnimationTime)
        var entryAnimation = SKAction.sequence([SKAction.group([SKAction.fadeAlpha(to: 1, duration: trackBarAnimationTime), moveIn])])
        
        let topTrackBar = tileUIBuilder.createTileBar(scene: self, enterFromLeft: false, name: "topBar", yPosition: view.frame.height - 80)
        topTrackBar.run(entryAnimation){
            tileUIBuilder.generateTilesUsingArray(scene: self, configuration: self.setupArray, atTrack: topTrackBar, evenIndented: false, enterFromLeft: true, offset: nil){ }
        }
        
        moveIn = SKAction.move(to: CGPoint(x: 0, y: view.frame.height / 2 ), duration: trackBarAnimationTime)
        entryAnimation = SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.group([SKAction.fadeAlpha(to: 1, duration: trackBarAnimationTime), moveIn])])
        
        let midTrackBar = tileUIBuilder.createTileBar(scene: self, enterFromLeft: true, name: "midBar", yPosition: view.frame.height / 2 )
        midTrackBar.run(entryAnimation){
            tileUIBuilder.generateTilesUsingArray(scene: self, configuration: self.midArray, atTrack: midTrackBar, evenIndented: false, enterFromLeft: false, offset: nil){}
        }
        
        moveIn = SKAction.move(to: CGPoint(x: 0, y: 120), duration: trackBarAnimationTime)
        entryAnimation = SKAction.sequence([SKAction.wait(forDuration: 0.5),SKAction.group([SKAction.fadeAlpha(to: 1, duration: trackBarAnimationTime), moveIn])])
        
        let lowTrackBar = tileUIBuilder.createTileBar(scene: self, enterFromLeft: false, name: "lowBar", yPosition: 120)
        lowTrackBar.run(entryAnimation){
            tileUIBuilder.generateTilesUsingArray(scene: self, configuration: self.setupArray, atTrack: lowTrackBar, evenIndented: false, enterFromLeft: true, offset: nil){
                completion()
            }
        }
        
    }
    
    private func createMapsPanRegion(for view: SKView, completion: @escaping ()->()){
        let trackForPan = self.childNode(withName: "midBar")
        let rightEndNode = self.childNode(withName: "transparent_c5_r1_midBar")?.position.x
        let leftEndNode = self.childNode(withName: "transparent_c0_r0_midBar")?.position.x
        
        let convertedPosition = self.convertPoint(toView: trackForPan!.frame.origin)
        let panFrame = CGRect(x: convertedPosition.x, y: convertedPosition.y - trackForPan!.frame.height * 1.3, width: rightEndNode! - leftEndNode!, height: trackForPan!.frame.height * 1.5)
        let panView = UIView(frame: panFrame)
        panView.tag = 1
        view.addSubview(panView)
        
        presetMapScrollRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePresetScroll))
        for v in self.scene!.view!.subviews {
            if v.tag == 1{
                v.addGestureRecognizer(presetMapScrollRecognizer!)
            }
        }
        completion()
    }
    
    @objc func handleMenuTap(_ sender: UITapGestureRecognizer){
        let tapped = sender.location(in: self.scene?.view)
        let locationInScene = self.convertPoint(fromView: tapped)
        
        for button in (self.scene?.children)! {
            self.childNode(withName: "newRandomBeginButton")?.isHidden = true
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
                    case "midBar_preset_1":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            GameState.sharedInstance().currentGameMap = GameState.sharedInstance().savedMaps[0]
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = .hard
                            GameState.sharedInstance().mainPlayerOptions!.isGamePreset = true    //Used in GameScene()
                            self.parentViewController!.beginRandomGame()
                        }
                        return
                    case "midBar_preset_2":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            GameState.sharedInstance().currentGameMap = GameState.sharedInstance().savedMaps[1]
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = .hard
                            GameState.sharedInstance().mainPlayerOptions!.isGamePreset = true    //Used in GameScene()
                            self.parentViewController!.beginRandomGame()
                        }
                        return
                    case "midBar_preset_3":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            GameState.sharedInstance().currentGameMap = GameState.sharedInstance().savedMaps[2]
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = .hard
                            GameState.sharedInstance().mainPlayerOptions!.isGamePreset = true    //Used in GameScene()
                            self.parentViewController!.beginRandomGame()
                        }
                        return
                    case "midBar_preset_4":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            GameState.sharedInstance().currentGameMap = GameState.sharedInstance().savedMaps[3]
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = .hard
                            GameState.sharedInstance().mainPlayerOptions!.isGamePreset = true    //Used in GameScene()
                            self.parentViewController!.beginRandomGame()
                        }
                        return
                    case "midBar_preset_5":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            GameState.sharedInstance().currentGameMap = GameState.sharedInstance().savedMaps[4]
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = .hard
                            GameState.sharedInstance().mainPlayerOptions!.isGamePreset = true    //Used in GameScene()
                            self.parentViewController!.beginRandomGame()
                        }
                        return
                    case "midBar_preset_6":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            GameState.sharedInstance().currentGameMap = GameState.sharedInstance().savedMaps[5]
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = .hard
                            GameState.sharedInstance().mainPlayerOptions!.isGamePreset = true    //Used in GameScene()
                            self.parentViewController!.beginRandomGame()
                        }
                        return
                    case "midBar_preset_7":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            GameState.sharedInstance().currentGameMap = GameState.sharedInstance().savedMaps[6]
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = .hard
                            GameState.sharedInstance().mainPlayerOptions!.isGamePreset = true    //Used in GameScene()
                            self.parentViewController!.beginRandomGame()
                        }
                        return
                    case "midBar_preset_8":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            GameState.sharedInstance().currentGameMap = GameState.sharedInstance().savedMaps[7]
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = .hard
                            GameState.sharedInstance().mainPlayerOptions!.isGamePreset = true    //Used in GameScene()
                            self.parentViewController!.beginRandomGame()
                        }
                        return
                    case "midBar_preset_9":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            GameState.sharedInstance().currentGameMap = GameState.sharedInstance().savedMaps[8]
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = .hard
                            GameState.sharedInstance().mainPlayerOptions!.isGamePreset = true    //Used in GameScene()
                            self.parentViewController!.beginRandomGame()
                        }
                        return
                    case "midBar_preset_10":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            GameState.sharedInstance().currentGameMap = GameState.sharedInstance().savedMaps[9]
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = .hard
                            GameState.sharedInstance().mainPlayerOptions!.isGamePreset = true    //Used in GameScene()
                            self.parentViewController!.beginRandomGame()
                        }
                        return
                    case "newRandomButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            let beginButton = self.childNode(withName: "newRandomBeginButton")
                            beginButton?.isHidden = false
                        }
                        return
                    case "newCustomButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            self.parentViewController?.launchCustomGame()
                        }
                        return
                    case "newRandomBeginButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if GameState.sharedInstance().wasGameSaved != nil {
                                GameState.sharedInstance().wasGameSaved = false
                            }
                            self.parentViewController?.beginRandomGame()
                        }
                        return
                    default:
                        break
                    }
                }
            }
        }
    }
    
    @objc func handlePresetScroll(_ sender: UIPanGestureRecognizer){
        print("Here")
        switch sender.state {
            case .began:
                break
            case .changed:
                var panView:UIView!
                findView: for view in (self.view?.subviews)! {
                    if view.tag == 1 {
                        panView = view
                        break findView
                    }
                }
                //Get all the middle tiles that we will be moving.
                let tilesToMove:Array<SKSpriteNode> = self.children.filter({
                    if $0.name != nil {
                        if $0.name == "midBar" {
                            return false    //We do not want to move the blue bar indicating the middle.
                        }else{
                            return $0.name!.contains("midBar")
                        }
                    }else{ return false }
                }) as! [SKSpriteNode]

                //Use the two edge menu tiles to signify the bounds of the panning.
                let rightEndNode = self.childNode(withName: "transparent_c\(self.midArray[0].count - 1)_r\(self.midArray.count - 1)_midBar")
                let leftEndNode = self.childNode(withName: "transparent_c0_r0_midBar")

                let toMove:CGFloat = sender.translation(in: panView).x

                //Check for out of bounds movement.
                if (rightEndNode?.position.x)! + toMove > self.view!.frame.width {
                    if leftEndNode!.position.x + toMove < CGFloat(0) {
                        for tile in tilesToMove {
                            tile.position.x += toMove
                        }
                    }
                }

                sender.setTranslation(CGPoint.zero, in: panView)
                break
        case .ended:
                break
        default:
                break
        }
    }
}
