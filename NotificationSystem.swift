//
// Created by Aleksandr Grin on 1/8/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class NotificationSystem:NSObject {
    private var actionToPlay:SKAction? = nil
    private var nodeToRun:SKLabelNode? = nil
    private var notificationQueue:Array<(text: String, color:SKColor?, font:String?)> = []

    func setExecution(action: SKAction, node: SKLabelNode){
        self.actionToPlay = action
        self.nodeToRun = node
    }

    func addNew(notification: String, fontColor:SKColor?, fontName:String?){
        if self.nodeToRun != nil {
            if self.notificationQueue.count == 0{
                self.notificationQueue.append((text: notification, color: fontColor, font: fontName))
                self.runNextAction()
            }else{
                self.notificationQueue.append((text: notification, color: fontColor, font: fontName))
            }
        }else{
            print("FATAL ERROR \(#function)")
            return
        }
    }

    private func runNextAction(){
        if self.notificationQueue.count == 0 {
            return
        }else{
            let notification = self.notificationQueue[0]

            let gameNotificationIndicator = SKLabelNode(text: notification.text)
            gameNotificationIndicator.fontSize = 36
            gameNotificationIndicator.fontColor = notification.color ?? .black
            gameNotificationIndicator.horizontalAlignmentMode = .center
            gameNotificationIndicator.verticalAlignmentMode = .center
            gameNotificationIndicator.fontName = notification.font ?? "Arial-BoldMT"

            gameNotificationIndicator.alpha = 1
            gameNotificationIndicator.isHidden = true
            gameNotificationIndicator.position = CGPoint(x: 0 , y: 0)
            gameNotificationIndicator.zPosition = 20
            gameNotificationIndicator.name = "gameNotification"
            gameNotificationIndicator.isUserInteractionEnabled = false
            let message = gameNotificationIndicator.multilined()
            let parentNode = self.nodeToRun!.parent!
            self.nodeToRun = message
            parentNode.addChild(message)

            self.nodeToRun!.run(self.actionToPlay!){
                self.notificationQueue.remove(at: 0)
                self.runNextAction()
            }
        }
    }
}