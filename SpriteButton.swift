//
//  SpriteButton.swift
//  HexWars
//
//  Created by Aleksandr Grin on 9/24/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit

class SpriteButton: SKSpriteNode {
    
    var buttonDefault:SKTexture?
    var buttonTouched:SKTexture?
    var buttonVariations:Array<SKLabelNode>?
    var text:SKLabelNode?
    
    var currentVariation:Int?
    var variationMax:Int?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(button: SKTexture, buttonTouched: SKTexture){
        let size = button.size()
        self.init(texture: button, color: .white, size: size)
        
        self.buttonDefault = button
        self.buttonTouched = buttonTouched
    }
    
    func setButtonText(text: String){
        let newLabel = SKLabelNode(text: text)
        newLabel.fontName = "Futura-CondensedExtraBold"
        newLabel.fontSize = 10
        newLabel.fontColor = .white
        newLabel.zPosition = 1000
        newLabel.horizontalAlignmentMode = .center
        newLabel.verticalAlignmentMode = .center
        let message = newLabel.multilined()
        self.text = message
        self.addChild(self.text!)
    }

    func setButtonTextFont(size: CGFloat){
        self.text!.fontSize = size
        if self.text != nil {
            if self.text!.children.count > 0 {
                for node in self.text!.children {
                    (node as! SKLabelNode).fontSize = size
                }
            }
        }
    }
    
    func addButtonVariation(text: String){
        let newLabel = SKLabelNode(text: text)
        newLabel.fontName = "Futura-CondensedExtraBold"
        newLabel.fontSize = 10
        newLabel.fontColor = .white
        newLabel.zPosition = 1000
        newLabel.horizontalAlignmentMode = .center
        newLabel.verticalAlignmentMode = .center
        let message = newLabel.multilined()
        message.position = self.text!.position
        for node in message.children{
            (node as! SKLabelNode).fontSize = self.text!.fontSize
        }
        if buttonVariations != nil{
            self.variationMax! += 1
            self.buttonVariations!.append(message)
        }else{
            self.variationMax = 1
            self.currentVariation = 0
            self.buttonVariations = [self.text!]
            self.buttonVariations!.append(message)
        }
    }
    
    func iterateButtonVariation(toPosition: Int?, completion: @escaping()->()){
        if toPosition != nil && buttonVariations?[toPosition!] != nil{
            self.text!.removeFromParent()
            self.text = buttonVariations![toPosition!]
            self.addChild(self.text!)
            currentVariation! = toPosition!
        }else{
            if currentVariation! < variationMax! {
                self.text!.removeFromParent()
                self.currentVariation! += 1
                self.text = self.buttonVariations![self.currentVariation!]
                self.addChild(self.text!)
                completion()
            }else{
                self.text!.removeFromParent()
                self.text = buttonVariations![0]
                self.currentVariation! = 0
                self.addChild(self.text!)
                completion()
            }
        }
    }
    
    func buttonTouchedUpInside(completion: @escaping () -> ()){
        if self.hasActions() == false{
            let currentTexture = self.texture
            let textureToDefault = SKAction.setTexture(currentTexture!)
            let textureToPress = SKAction.setTexture(buttonTouched!)
            let pressAnimation = SKAction.sequence([textureToPress, SKAction.wait(forDuration: 0.1), textureToDefault])
            
            self.run(pressAnimation)
            completion()
        }
    }

    override func encode(with coder: NSCoder){
        coder.encode(self.buttonDefault!, forKey: "SpriteButton_buttonDefault")
        coder.encode(self.buttonTouched!, forKey: "SpriteButton_buttonTouched")
        coder.encode(self.buttonVariations, forKey: "SpriteButton_buttonVariations")
        coder.encode(self.text, forKey: "SpriteButton_text")
        coder.encode(self.currentVariation, forKey: "SpriteButton_currentVariation")
        coder.encode(self.variationMax, forKey: "SpriteButton_variationMax")
        super.encode(with: coder)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let data = aDecoder.decodeObject(forKey: "SpriteButton_buttonDefault") as? SKTexture{
            self.buttonDefault = data
        }
        if let data = aDecoder.decodeObject(forKey: "SpriteButton_buttonTouched") as? SKTexture{
            self.buttonTouched = data
        }
        if let data = aDecoder.decodeObject(forKey: "SpriteButton_buttonVariations") as? [SKLabelNode]{
            self.buttonVariations = data
        }
        if let data = aDecoder.decodeObject(forKey: "SpriteButton_text") as? SKLabelNode {
            self.text = data
        }
        if let data = aDecoder.decodeObject(forKey: "SpriteButton_currentVariation") as? Int {
            self.currentVariation = data
        }
        if let data = aDecoder.decodeObject(forKey: "SpriteButton_variationMax") as? Int{
            self.variationMax = data
        }
    }
}
