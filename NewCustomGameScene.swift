//
//  NewCustomGame.swift
//  HexWars
//
//  Created by Aleksandr Grin on 9/30/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class NewCustomGameScene: SKScene {
    weak var parentViewController:NewCustomGame?
    var menuButtonRecognizer:UITapGestureRecognizer?
    var tapSoundMaker:SKAudioNode?
    let fadeDuration = 0.25
    var isGameValid:Bool = false
    
    override func didMove(to view: SKView) {
        setupBackGround(for: view)
        setupMenuStyle(for: view){
            self.setupTopMenuButtons(for: view){}
            self.setupOptionsButtons(for: view){}
            self.setupTextFields(for: view)
            self.createGameNotificationLabel(for: view)
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
    private func createGameNotificationLabel(for view: SKView){
        let gameNotificationIndicator = SKLabelNode(text: "")
        gameNotificationIndicator.fontSize = 36
        gameNotificationIndicator.fontColor = UIColor.black
        gameNotificationIndicator.horizontalAlignmentMode = .center
        gameNotificationIndicator.verticalAlignmentMode = .center
        gameNotificationIndicator.fontName = "Arial-BoldMT"

        gameNotificationIndicator.alpha = 1
        gameNotificationIndicator.isHidden = true
        gameNotificationIndicator.position = CGPoint(x: view.frame.width / 2 , y: view.frame.height / 2)
        gameNotificationIndicator.zPosition = 20
        gameNotificationIndicator.name = "gameNotification"
        gameNotificationIndicator.isUserInteractionEnabled = false
        self.addChild(gameNotificationIndicator)
    }
    
    private func setupBackGround(for view: SKView){
        let backGroundColorImage = SKSpriteNode(texture: SKTexture(imageNamed: "Background"), size: view.frame.size)
        backGroundColorImage.zPosition = -2
        backGroundColorImage.anchorPoint = CGPoint(x: 0, y: 0)

        let backGroundStyleImage = SKSpriteNode(texture: SKTexture(imageNamed: "BackGroundStyleV2"), size: view.frame.size)
        backGroundStyleImage.zPosition = -1
        backGroundStyleImage.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backGroundStyleImage.colorBlendFactor = 1.0
        backGroundStyleImage.blendMode = .add
        backGroundStyleImage.name = "backGroundStyleImage"
        backGroundStyleImage.color = GameState.sharedInstance().mainPlayerOptions!.chosenPlayerColor!.getColorFromCode()

        let backGroundStyleImage2 = SKSpriteNode(texture: SKTexture(imageNamed: "BackGroundStyle"), size: view.frame.size)
        backGroundStyleImage2.zPosition = -1
        backGroundStyleImage2.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backGroundStyleImage2.colorBlendFactor = 1.0
        backGroundStyleImage2.blendMode = .add
        backGroundStyleImage2.name = "backGroundStyleImage2"
        backGroundStyleImage2.color = GameState.sharedInstance().mainPlayerOptions!.chosenPlayerColor!.getColorFromCode()
        
        self.addChild(backGroundColorImage)
        self.addChild(backGroundStyleImage)
        self.addChild(backGroundStyleImage2)

        animateBackGround(for: view)
    }

    private func animateBackGround(for view: SKView){
        let path = CGMutablePath()
        let refRect = CGRect(x: view.frame.width / 2 - 12, y: view.frame.height / 2 - 12, width: 24, height: 24)
        path.addEllipse(in: refRect)
        let bkg1 = self.childNode(withName: "backGroundStyleImage") as! SKSpriteNode
        let bkg2 = self.childNode(withName: "backGroundStyleImage2") as! SKSpriteNode

        let animation = SKAction.repeatForever(SKAction.follow(path, asOffset: false, orientToPath: false, speed: 4))
        let animation2 = SKAction.repeatForever(SKAction.follow(path, asOffset: false, orientToPath: false, speed: 7))
        bkg1.run(animation)
        bkg2.run(animation2)
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
                             [1, 1, 0],
                             [0, 1, 1],
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
        
        let BeginButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        BeginButton.setButtonText(text: "Begin \n\nGame")
        BeginButton.setButtonTextFont(size: 18)
        BeginButton.text!.position.y += 5
        self.addChild(BeginButton)
        BeginButton.name = "BeginButton"
        BeginButton.alpha = 0
        BeginButton.zPosition = 2
        BeginButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c2_r0_topBar")?.position{
            BeginButton.position = buttonPosition
        }
        
        BeginButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration)){}
        returnButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration)){
            completion()
        }
    }
    
    private func setupOptionsButtons(for view: SKView, completion: @escaping ()->()){
        let mapTypeButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        mapTypeButton.setButtonText(text: "Map \n\nType")
        mapTypeButton.setButtonTextFont(size: 18)
        mapTypeButton.text!.position.y += 5
        self.addChild(mapTypeButton)
        mapTypeButton.name = "mapTypeButton"
        mapTypeButton.alpha = 0
        mapTypeButton.zPosition = 2
        mapTypeButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c0_r1_midBar")?.position{
            mapTypeButton.position = buttonPosition
        }
        
        let mapSizeButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        mapSizeButton.setButtonText(text: "Map \n\nSize")
        mapSizeButton.setButtonTextFont(size: 18)
        mapSizeButton.text!.position.y += 5
        self.addChild(mapSizeButton)
        mapSizeButton.name = "mapSizeButton"
        mapSizeButton.alpha = 0
        mapSizeButton.zPosition = 2
        mapSizeButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c2_r0_midBar")?.position{
            mapSizeButton.position = buttonPosition
        }
        
        let difficultyButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        difficultyButton.setButtonText(text: "Difficulty")
        difficultyButton.setButtonTextFont(size: 16)
        difficultyButton.text!.position.y += 5
        self.addChild(difficultyButton)
        difficultyButton.name = "difficultyButton"
        difficultyButton.alpha = 0
        difficultyButton.zPosition = 2
        difficultyButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c2_r4_midBar")?.position{
            difficultyButton.position = buttonPosition
        }
        
        let enemyPlayersButton = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        enemyPlayersButton.setButtonText(text: "Number\n\nof\n\nPlayers")
        enemyPlayersButton.setButtonTextFont(size: 15)
        enemyPlayersButton.text!.position.y += 5
        self.addChild(enemyPlayersButton)
        enemyPlayersButton.name = "enemyPlayersButton"
        enemyPlayersButton.alpha = 0
        enemyPlayersButton.zPosition = 2
        difficultyButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c1_r4_midBar")?.position{
            enemyPlayersButton.position = buttonPosition
        }

        let numHumanPlayers = SpriteButton(button: SKTexture(imageNamed: "RegularHex"), buttonTouched: SKTexture(imageNamed: "RegularHex_TouchUpInside"))
        numHumanPlayers.setButtonText(text: "Human \n\nPlayers")
        numHumanPlayers.setButtonTextFont(size: 16)
        numHumanPlayers.text!.position.y += 5
        self.addChild(numHumanPlayers)
        numHumanPlayers.name = "numHumanPlayers"
        numHumanPlayers.alpha = 0
        numHumanPlayers.zPosition = 2
        numHumanPlayers.addButtonVariation(text: "Human")
        numHumanPlayers.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let buttonPosition = self.childNode(withName: "transparent_c0_r5_midBar")?.position{
            numHumanPlayers.position = buttonPosition
        }

        let numHumanPlayersCycle = SpriteButton(button: SKTexture(imageNamed: "RegularHexUTab"), buttonTouched: SKTexture(imageNamed: "RegularHexUTab_TouchUpInside"))
        self.addChild(numHumanPlayersCycle)
        numHumanPlayersCycle.name = "numHumanPlayersCycle"
        numHumanPlayersCycle.alpha = 1
        numHumanPlayersCycle.zPosition = 2
        numHumanPlayersCycle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        numHumanPlayersCycle.isHidden = true

        let numHumanPlayersCountlabel = SKLabelNode(text: "1")
        numHumanPlayersCountlabel.zPosition = 3
        numHumanPlayersCountlabel.fontSize = 32
        numHumanPlayersCountlabel.fontColor = .white
        numHumanPlayersCountlabel.horizontalAlignmentMode = .center
        numHumanPlayersCountlabel.verticalAlignmentMode = .center
        numHumanPlayersCountlabel.position = CGPoint(x: 0, y: 0)
        numHumanPlayersCountlabel.fontName = "AvenirNextCondensed-Heavy"
        numHumanPlayersCountlabel.name = "numHumanPlayersCountlabel"
        numHumanPlayersCycle.addChild(numHumanPlayersCountlabel)
        if let buttonPosition = self.childNode(withName: "transparent_c0_r7_midBar")?.position{
            numHumanPlayersCycle.position = buttonPosition
            numHumanPlayersCycle.position.y += 5
        }

        numHumanPlayers.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        mapTypeButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        mapSizeButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        difficultyButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration))
        enemyPlayersButton.run(SKAction.fadeAlpha(to: 1, duration: fadeDuration)){
            completion()
        }
        
        let mapTypeCycle = SpriteButton(button: SKTexture(imageNamed: "RegularHexUTab"), buttonTouched: SKTexture(imageNamed: "RegularHexUTab_TouchUpInside"))
        mapTypeCycle.setButtonText(text: "Pangea")
        mapTypeCycle.setButtonTextFont(size: 14)
        self.addChild(mapTypeCycle)
        mapTypeCycle.name = "mapTypeCycle"
        mapTypeCycle.alpha = 1
        mapTypeCycle.zPosition = 2
        mapTypeCycle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mapTypeCycle.isHidden = true
        mapTypeCycle.addButtonVariation(text: "Continents")
        mapTypeCycle.addButtonVariation(text: "Islands")
        mapTypeCycle.addButtonVariation(text: "Fractured")
        
        if let buttonPosition = self.childNode(withName: "transparent_c0_r3_midBar")?.position{
            mapTypeCycle.position = buttonPosition
            mapTypeCycle.position.y += 5
        }
        
        let widthField = SpriteButton(button: SKTexture(imageNamed: "RegularHexRTab"), buttonTouched: SKTexture(imageNamed: "RegularHexRTab_TouchUpInside"))
        widthField.setButtonText(text: "Width:")
        widthField.setButtonTextFont(size: 14)
        widthField.text!.position.y += 15
        self.addChild(widthField)
        widthField.name = "widthField"
        widthField.alpha = 1
        widthField.zPosition = 2
        widthField.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        widthField.isHidden = true
        if let buttonPosition = self.childNode(withName: "transparent_c1_r1_midBar")?.position{
            widthField.position = buttonPosition
        }
        
        let heightField = SpriteButton(button: SKTexture(imageNamed: "RegularHexUTab"), buttonTouched: SKTexture(imageNamed: "RegularHexUTab_TouchUpInside"))
        heightField.setButtonText(text: "Height:")
        heightField.setButtonTextFont(size: 14)
        heightField.text!.position.y += 15
        self.addChild(heightField)
        heightField.name = "heightField"
        heightField.alpha = 1
        heightField.zPosition = 2
        heightField.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        heightField.isHidden = true
        
        if let buttonPosition = self.childNode(withName: "transparent_c2_r2_midBar")?.position{
            heightField.position = buttonPosition
            heightField.position.y += 5
        }
        
        let difficultyCycle = SpriteButton(button: SKTexture(imageNamed: "RegularHexUTab"), buttonTouched: SKTexture(imageNamed: "RegularHexUTab_TouchUpInside"))
        difficultyCycle.setButtonText(text: "Easy")
        difficultyCycle.setButtonTextFont(size: 18)
        self.addChild(difficultyCycle)
        difficultyCycle.name = "difficultyCycle"
        difficultyCycle.alpha = 1
        difficultyCycle.zPosition = 2
        difficultyCycle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        difficultyCycle.isHidden = true
        difficultyCycle.addButtonVariation(text: "Medium")
        difficultyCycle.addButtonVariation(text: "Hard")
        difficultyCycle.addButtonVariation(text: "Unfair1")
        difficultyCycle.addButtonVariation(text: "Unfair2")
        
        if let buttonPosition = self.childNode(withName: "transparent_c2_r6_midBar")?.position{
            difficultyCycle.position = buttonPosition
            difficultyCycle.position.y += 5
        }
        
        let enemyCountCycle = SpriteButton(button: SKTexture(imageNamed: "RegularHexUTab"), buttonTouched: SKTexture(imageNamed: "RegularHexUTab_TouchUpInside"))
        self.addChild(enemyCountCycle)
        enemyCountCycle.name = "enemyCountCycle"
        enemyCountCycle.alpha = 1
        enemyCountCycle.zPosition = 2
        enemyCountCycle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        enemyCountCycle.isHidden = true
        
        let enemyCountlabel = SKLabelNode(text: "2")
        enemyCountlabel.zPosition = 3
        enemyCountlabel.fontSize = 32
        enemyCountlabel.fontColor = .white
        enemyCountlabel.horizontalAlignmentMode = .center
        enemyCountlabel.verticalAlignmentMode = .center
        enemyCountlabel.position = CGPoint(x: 0, y: 0)
        enemyCountlabel.fontName = "AvenirNextCondensed-Heavy"
        enemyCountlabel.name = "enemyCountLabel"
        enemyCountCycle.addChild(enemyCountlabel)
        if let buttonPosition = self.childNode(withName: "transparent_c1_r6_midBar")?.position{
            enemyCountCycle.position = buttonPosition
            enemyCountCycle.position.y += 5
        }
    }
    
    private func setupTextFields(for view: SKView){
        let width = self.childNode(withName: "widthField")
        let widthFrame = CGRect(x: view.frame.width / 2, y: view.frame.height / 2.25, width: (width?.frame.width)! / 2 * (view.frame.width / 375), height: (width?.frame.height)! / 4 * (view.frame.height / 667))
        
        let widthText = UITextField(frame: widthFrame)
        widthText.borderStyle = .roundedRect
        widthText.keyboardType = .numberPad
        widthText.textColor = UIColor.black
        widthText.isHidden = true
        widthText.textAlignment = .center
        widthText.tag = 1
        self.view?.addSubview(widthText)

        let heightFrame = CGRect(x: view.frame.width / 1.44, y: view.frame.height / 1.95, width: (width?.frame.width)! / 2 * (view.frame.width / 375), height: (width?.frame.height)! / 4 * (view.frame.height / 667))
        
        let heightText = UITextField(frame: heightFrame)
        heightText.borderStyle = .roundedRect
        heightText.keyboardType = .numberPad
        heightText.textColor = UIColor.black
        heightText.isHidden = true
        heightText.textAlignment = .center
        heightText.tag = 2
        self.view?.addSubview(heightText)

    }

    private func resetCycleButtons(){
        self.childNode(withName: "mapTypeCycle")?.isHidden = true
        self.childNode(withName: "widthField")?.isHidden = true
        self.childNode(withName: "heightField")?.isHidden = true
        self.childNode(withName: "enemyCountCycle")?.isHidden = true
        self.childNode(withName: "difficultyCycle")?.isHidden = true
        self.childNode(withName: "enemyPlayersHumanSelector")?.isHidden = true
        self.childNode(withName: "enemyPlayerColorCycle")?.isHidden = true
        
        for view in (self.view?.subviews)! {
            if view is UITextField {
                view.isHidden = true
                view.endEditing(true)
            }
        }
        saveCustomOptionsToState()
    }

    //Used to display any type of textual notificaiton through the game. Offers feedback for player action.
    func displayGameNotification(text: String, textColor: UIColor?, completion: @escaping ()->()){
        let notifier = self.childNode(withName: "//gameNotification") as! SKLabelNode
        let animation = SKAction.sequence([SKAction.unhide(),
                                           SKAction.wait(forDuration: 1.5),
                                           SKAction.hide(),
                                           SKAction.wait(forDuration: 0.1)])

        notifier.text = text
        notifier.fontColor = textColor ?? .white
        notifier.run(animation)
    }

    func saveCustomOptionsToState(){
        let newBounds:BoardBounds = GameState.sharedInstance().currentGameMap!.mapBounds ?? BoardBounds(columns: 0, rows: 0)
        for view in self.view!.subviews {
            if view is UITextField {
                if view.tag == 2 {
                    if (view as! UITextField).text != nil && (view as! UITextField).text != ""{
                        if let newRow = Int((view as! UITextField).text!) {
                            newBounds.rows = newRow
                        }
                    }
                }else if view.tag == 1 {
                    if (view as! UITextField).text != nil && (view as! UITextField).text != ""{
                        if let newColumn = Int((view as! UITextField).text!) {
                            newBounds.columns = newColumn
                        }
                    }
                }
            }
        }

        //Any map smaller is too small.
        if (newBounds.columns < 8 || newBounds.rows < 8 || (newBounds.columns * newBounds.rows < 64))  {
            displayGameNotification(text: "Invalid Setup!", textColor: .red, completion: {})
            isGameValid = false
            return
        }

        let numPlayers = Int((self.childNode(withName: "//enemyCountLabel") as! SKLabelNode).text ?? "0")!
        let mapFill = MapFillType(rawValue: (self.childNode(withName: "mapTypeCycle")! as! SpriteButton).currentVariation!)

        switch  mapFill! {
            case .pangea:
                if (numPlayers * 10) > Int(Double(newBounds.columns * newBounds.rows) * 0.90){
                    displayGameNotification(text: "Invalid Setup!", textColor: .red, completion: {})
                    isGameValid = false
                    return
                }
                break
            case .continents:
                if (numPlayers * 10) > Int(Double(newBounds.columns * newBounds.rows) * 0.50){
                    displayGameNotification(text: "Invalid Setup!", textColor: .red, completion: {})
                    isGameValid = false
                    return
                }
                break
            case .islands:
                if (numPlayers * 10) > Int(Double(newBounds.columns * newBounds.rows) * 0.20){
                    displayGameNotification(text: "Invalid Setup!", textColor: .red, completion: {})
                    isGameValid = false
                    return
                }
                break
            case .fractured:
                if (numPlayers * 10) > Int(Double(newBounds.columns * newBounds.rows) * 0.05){
                    displayGameNotification(text: "Invalid Setup!", textColor: .red, completion: {})
                    isGameValid = false
                    return
                }
                break
        }

        GameState.sharedInstance().currentGameMap!.mapBounds = newBounds
        GameState.sharedInstance().currentGameMap!.mapFillType = mapFill
        GameState.sharedInstance().currentGameMap!.numPlayers = numPlayers
        GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = Difficulty(rawValue: (self.childNode(withName: "//difficultyCycle") as! SpriteButton).currentVariation!)

        isGameValid = true
    }

    private func dismissTextFields(){
        if self.childNode(withName: "widthField")?.isHidden == false || self.childNode(withName: "heightField")?.isHidden == false{
            for view in (self.view?.subviews)! {
                if view is UITextField {
                    if view.tag == 2 || view.tag == 1 {
                        (view as! UITextField).resignFirstResponder()
                    }
                }
            }
        }
    }
    
    @objc func handleMenuTap(_ sender: UITapGestureRecognizer){
        let tapped = sender.location(in: self.scene?.view)
        let locationInScene = self.convertPoint(fromView: tapped)

        saveCustomOptionsToState()
        for button in (self.scene?.children)! {
            if button.contains(locationInScene){
                if let buttonName = button.name {
                    switch buttonName {
                    case "returnButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        dismissTextFields()
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            self.parentViewController?.returnToSinglePlayerMenu()
                        }
                        return
                    case "BeginButton":
                        if isGameValid == true {
                            if self.tapSoundMaker != nil {
                                self.tapSoundMaker!.run(SKAction.play())
                            }
                            dismissTextFields()
                            (button as! SpriteButton).buttonTouchedUpInside(){
                                self.parentViewController?.beginGame()
                            }
                        }
                        return
                    case "mapTypeButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        dismissTextFields()
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "mapTypeCycle")?.isHidden == true {
                                self.childNode(withName: "mapTypeCycle")?.isHidden = false
                            }else{
                                self.childNode(withName: "mapTypeCycle")?.isHidden = true
                            }
                        }
                        return
                    case "mapSizeButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        dismissTextFields()
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "widthField")?.isHidden == true{
                                self.childNode(withName: "widthField")?.isHidden = false
                                self.childNode(withName: "heightField")?.isHidden = false
                                for view in (self.view?.subviews)! {
                                    if view is UITextField {
                                        if view.tag < 3 {
                                            view.isHidden = false
                                        }
                                    }
                                }
                            }else{
                                self.childNode(withName: "widthField")?.isHidden = true
                                self.childNode(withName: "heightField")?.isHidden = true
                                for view in (self.view?.subviews)! {
                                    if view is UITextField {
                                        if view.tag < 3 {
                                            view.isHidden = true
                                            (view as! UITextField).resignFirstResponder()
                                        }
                                    }
                                }
                            }
                        }
                        return
                    case "difficultyButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        dismissTextFields()
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "difficultyCycle")?.isHidden == true {
                                self.childNode(withName: "difficultyCycle")?.isHidden = false
                            }else{
                                self.childNode(withName: "difficultyCycle")?.isHidden = true
                            }
                        }
                        return
                    case "difficultyCycle":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        dismissTextFields()
                        (button as! SpriteButton).iterateButtonVariation(toPosition: nil){
                            (button as! SpriteButton).buttonTouchedUpInside(){ }
                            GameState.sharedInstance().mainPlayerOptions!.chosenDifficulty = Difficulty(rawValue: (button as! SpriteButton).currentVariation!)
                        }
                        return
                    case "mapTypeCycle":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        dismissTextFields()
                        (button as! SpriteButton).iterateButtonVariation(toPosition: nil){
                            (button as! SpriteButton).buttonTouchedUpInside(){ }
                            GameState.sharedInstance().currentGameMap!.mapFillType = MapFillType(rawValue: (button as! SpriteButton).currentVariation!)
                        }
                        return
                    case "enemyPlayersButton":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        dismissTextFields()
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "enemyCountCycle")?.isHidden == true {
                                self.childNode(withName: "enemyCountCycle")?.isHidden = false
                            }else{
                                self.childNode(withName: "enemyCountCycle")?.isHidden = true
                            }
                        }
                        return
                    case "numHumanPlayers":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        dismissTextFields()
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            if self.childNode(withName: "numHumanPlayersCycle")?.isHidden == true{
                                self.childNode(withName: "numHumanPlayersCycle")?.isHidden = false
                            }else{
                                self.childNode(withName: "numHumanPlayersCycle")?.isHidden = true
                            }
                        }
                        return
                    case "numHumanPlayersCycle":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        dismissTextFields()
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            let label = ((button as! SpriteButton).children[0] as! SKLabelNode)
                            var currentCount = Int(label.text!)

                            if currentCount! < 8 {
                                currentCount! += 1
                                label.text = String(currentCount!)
                            }else{
                                currentCount! = 1
                                label.text = "1"
                            }
                            if currentCount! > Int((self.childNode(withName: "//enemyCountCycle")?.children[0] as! SKLabelNode).text!)! {
                                (self.childNode(withName: "//enemyCountCycle")?.children[0] as! SKLabelNode).text! = String(currentCount!)
                            }
                            GameState.sharedInstance().numHumanPlayers = currentCount!
                        }
                        return
                    case "enemyCountCycle":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        dismissTextFields()
                        (button as! SpriteButton).buttonTouchedUpInside(){
                            let label = ((button as! SpriteButton).children[0] as! SKLabelNode)
                            var currentCount = Int(label.text!)
                            
                            if currentCount! < 8 {
                                currentCount! += 1
                                label.text = String(currentCount!)
                            }else{
                                currentCount! = 2
                                label.text = "2"
                            }
                            let numHumans = Int((self.childNode(withName: "numHumanPlayersCycle")?.children[0] as! SKLabelNode).text!)
                            if numHumans! > currentCount! {
                                (self.childNode(withName: "numHumanPlayersCycle")?.children[0] as! SKLabelNode).text! = String(currentCount!)
                            }
                            GameState.sharedInstance().currentGameMap!.numPlayers = currentCount!
                        }
                        return
                    case "widthField":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        if self.childNode(withName: "widthField")?.isHidden == false{
                            for view in (self.view?.subviews)! {
                                if view is UITextField {
                                    if view.tag == 1 {
                                        (view as! UITextField).becomeFirstResponder()
                                    }
                                }
                            }
                        }
                        return
                    case "heightField":
                        if self.tapSoundMaker != nil {
                            self.tapSoundMaker!.run(SKAction.play())
                        }
                        if self.childNode(withName: "widthField")?.isHidden == false{
                            for view in (self.view?.subviews)! {
                                if view is UITextField {
                                    if view.tag == 2 {
                                        (view as! UITextField).becomeFirstResponder()
                                    }
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

        if self.childNode(withName: "difficultyCycle") != nil && self.childNode(withName: "enemyCountCycle") != nil {
            if self.nodes(at: locationInScene).contains(self.childNode(withName: "difficultyCycle")!) == false {
                if self.nodes(at: locationInScene).contains(self.childNode(withName: "enemyCountCycle")!) == false {
                    if self.nodes(at: locationInScene).contains(self.childNode(withName: "mapTypeCycle")!) == false {
                        resetCycleButtons()
                    }
                }
            }
        }
    }
}
