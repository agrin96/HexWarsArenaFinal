//
//  tileUIBuilder.swift
//  HexWars
//
//  Created by Aleksandr Grin on 9/27/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit

class tileUIBuilder {
    
    class func createTileBar(scene: SKScene, enterFromLeft: Bool, name: String?, yPosition: CGFloat?) -> SKSpriteNode {
        let trackBar = SKSpriteNode(texture: SKTexture(imageNamed: "TrackBar"))
        scene.addChild(trackBar)
        trackBar.zPosition = 0
        trackBar.name = name ?? "topBar"
        trackBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        trackBar.alpha = 0
        
        var newPosition:CGPoint?
        if yPosition != nil{
            if enterFromLeft == true{
                newPosition = CGPoint(x: -scene.view!.frame.width, y: yPosition!)
            }else{
                newPosition = CGPoint(x: scene.view!.frame.width, y: yPosition!)
            }
        }
        trackBar.position = newPosition ?? CGPoint(x: scene.view!.frame.width, y: scene.view!.frame.height - 100)
        
        return trackBar
    }
    
    //This function can generate the transparent tiles needed for the various menus using a 2D array of Ints representing tile positions
    //A 1 represents a transparent tile and a 0 represents an empty space. The function fills in with the appropriate spacing and positions.
    //@param configuration: a [[INT]] representing tiles
    //@param atTrack:       a track which will serve as the anchoring point of these tiles
    //@param firstIndented: determines whether the even or the odd tiles are indented
    //ExampleArray:     [[1, 0, 1],
    //                   [1, 1, 1],
    //                   [1, 1, 0]]
    class func generateTilesUsingArray(scene: SKScene, configuration: Array<Array<Int>>, atTrack: SKSpriteNode, evenIndented: Bool, enterFromLeft: Bool, offset: CGFloat?, completion: @escaping () -> ()) {
        let horizontalDelta = SKTexture(imageNamed: "TransparentHex").size().width * 1.55   //1.65
        let verticalDelta = SKTexture(imageNamed: "TransparentHex").size().height / 2.00    //1.95
        
        var newTilePositions:Array<Array<CGPoint?>> = Array.init(repeating: Array.init(repeating: nil, count: configuration[0].count), count: configuration.count)
        var transparentTiles:Array<Array<SKSpriteNode?>> = Array.init(repeating: Array.init(repeating: nil, count: configuration[0].count), count: configuration.count)
        
        //Sets the first tile position based on the indentation selected.
        let startingPosition = determineStartingPosition(scene: scene, horizontalDelta: horizontalDelta, track: atTrack, evenIndent: evenIndented, enterFromLeft: enterFromLeft, offset: offset)
        
        for row in 0..<configuration.count{
            for column in 0..<configuration[row].count{
                
                if configuration[row][column] == 1 {
                    let newHex = SKSpriteNode(texture: SKTexture(imageNamed: "TransparentHex"))
                    scene.addChild(newHex)
                    newHex.name = "transparent_c\(column)_r\(row)_\(atTrack.name!)"  //Naming convention to be able to find tiles later.
                    newHex.zPosition = 1
                    newHex.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    
                    transparentTiles[row][column] = newHex
                    if row % 2 == 0 {
                        //Even Tile rows
                        if enterFromLeft == true{
                            newHex.position = CGPoint(x: -100, y: atTrack.position.y - verticalDelta*CGFloat(row)) //Start tiles outside of the screen.
                            newTilePositions[row][column] = CGPoint(x: startingPosition.even.x - horizontalDelta*CGFloat(column),
                                                                    y: startingPosition.even.y - verticalDelta*CGFloat(row))

                        }else{
                            newHex.position = CGPoint(x: (scene.view?.frame.width)! + 100, y: atTrack.position.y - verticalDelta*CGFloat(row)) //Start tiles outside of the screen.
                            newTilePositions[row][column] = CGPoint(x: startingPosition.even.x + horizontalDelta*CGFloat(column),
                                                                    y: startingPosition.even.y - verticalDelta*CGFloat(row))
                        }
                    }else{
                        //Odd Tile rows
                        if enterFromLeft == true{
                            newHex.position = CGPoint(x: -100, y: atTrack.position.y - verticalDelta*CGFloat(row)) //Start tiles outside of the screen.
                            newTilePositions[row][column] = CGPoint(x: startingPosition.odd.x - horizontalDelta*CGFloat(column),
                                                                    y: startingPosition.odd.y - verticalDelta*CGFloat(row))
                        }else{
                            newHex.position = CGPoint(x: (scene.view?.frame.width)! + 100, y: atTrack.position.y - verticalDelta*CGFloat(row)) //Start tiles outside of the screen.
                            newTilePositions[row][column] = CGPoint(x: startingPosition.odd.x + horizontalDelta*CGFloat(column),
                                                                    y: startingPosition.odd.y - verticalDelta*CGFloat(row))
                        }
                    }
                }
            }
        }
        
        animateTileEntry(tiles: transparentTiles, toPositions: newTilePositions){
            completion()
        }
    }
    
    private class func determineStartingPosition(scene: SKScene, horizontalDelta: CGFloat, track: SKSpriteNode, evenIndent: Bool, enterFromLeft: Bool, offset: CGFloat?) -> (even: CGPoint,odd: CGPoint){
        
        var startingPosition:(even: CGPoint,odd: CGPoint)
        let offset:CGFloat = offset ?? 30
        if evenIndent == false {
            //The ODD tile rows are indented
            if enterFromLeft == false{
                startingPosition = (even: CGPoint(x: 0, y: track.position.y + offset),
                                    odd: CGPoint(x: horizontalDelta / 2, y: track.position.y + offset))
            }else{
                startingPosition = (even: CGPoint(x: scene.frame.width, y: track.position.y + offset),
                                    odd: CGPoint(x: scene.frame.width - horizontalDelta / 2, y: track.position.y + offset))
            }
            
        }else{
            //The EVEN tile rows are indented
            if enterFromLeft == false{
                startingPosition = (even: CGPoint(x: scene.frame.width - horizontalDelta / 2, y: track.position.y + offset),
                                    odd: CGPoint(x: scene.frame.width, y: track.position.y + offset))
            }else{
                startingPosition = (even: CGPoint(x: scene.frame.width - horizontalDelta / 2, y: track.position.y + offset),
                                    odd: CGPoint(x: scene.frame.width, y: track.position.y + offset))
            }
        }
        
        return startingPosition
    }
    
    private class func animateTileEntry(tiles: Array<Array<SKSpriteNode?>>, toPositions: Array<Array<CGPoint?>>, completion: @escaping ()->()){
        let maxNumberOfColumns = tiles.max(by: { $0.count < $1.count})!.count
        var animations:Array<Array<SKAction?>> = Array.init(repeating: Array.init(repeating: nil, count: maxNumberOfColumns), count: tiles.count)
        
        for column in 0..<maxNumberOfColumns {
            let selectedColumn = tiles[column: column]
            for row in 0..<selectedColumn.count {
                if toPositions[row][column] != nil {
                    var duration = 0.10
                    if column >= 4 {
                        duration = 0 //If the tiles are outside the screen then why bother animating?
                    }
                    let moveIn = SKAction.move(to: toPositions[row][column]!, duration: duration)
                    animations[row][column] = moveIn
                }
            }
        }
        
        animateTilesSequentially(tiles: tiles, animations: animations){
            completion()
        }
    }
    
    private class func animateTilesSequentially(tiles: Array<Array<SKSpriteNode?>>, animations: Array<Array<SKAction?>>, completion: @escaping()->()){
        if tiles.count != 0 && tiles[0].count != 0{
            let selectedTileColumn = tiles[column: 0]
            let selectedAnimationColumn = animations[column: 0]
            
            animateTileGroup(tiles: selectedTileColumn, animations: selectedAnimationColumn){
                var newTiles = tiles
                var newAnimations = animations
                for i in 0..<selectedTileColumn.count{
                    newTiles[i].remove(at: 0)
                    newAnimations[i].remove(at: 0)
                }
                self.animateTilesSequentially(tiles: newTiles, animations: newAnimations, completion: completion)
            }
        }else{
            completion()
            return
        }
    }
    

    private class func animateTileGroup(tiles: [SKSpriteNode?], animations: [SKAction?], completion: @escaping () -> ()){
        for i in 0..<tiles.count where i % 2 == 0{
            if tiles[i] != nil{
                tiles[i]!.run(animations[i]!){
                    for i in 0..<tiles.count where i % 2 != 0{
                        if tiles[i] != nil{
                            tiles[i]!.run(animations[i]!){
                                completion()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //This function can be used in conjunction with the generateTileFromArray function to print out the positions of tiles generated
    //Note this is the final positions of the tiles and corresponds to the array structure used to define desired positions.
    class func debugPrintTilePositions(positions: Array<Array<CGPoint?>>){
        var output:String = ""
        for row in 0..<positions.count {
            for column in 0..<positions[row].count{
                if positions[row][column] != nil {
                    output += " \(positions[row][column]!) ,"
                }else{
                    output += "         \(String(describing: positions[row][column]))         ,"
                }
            }
            output += "\n"
        }
        print(output)
    }
}
