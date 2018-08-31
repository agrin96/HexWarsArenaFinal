//
// Created by Aleksandr Grin on 12/24/17.
// Copyright (c) 2017 AleksandrGrin. All rights reserved.
//

import Foundation
import SpriteKit

enum WallType:Int {
    case type1 = 0
    case type2
    case type3

}

struct TileWallTextures {
    var wallTextureSet:SKTextureAtlas

    var rightWall:SKTexture
    var upperRightWall:SKTexture
    var upperLeftWall:SKTexture
    var leftWall:SKTexture
    var lowerLeftWall:SKTexture
    var lowerRightWall:SKTexture
    var wallType:WallType

    init(type: WallType){
        let wallTypeRaw:String = String(type.rawValue + 1)
        self.wallTextureSet = SKTextureAtlas(named: "WallSections_\(wallTypeRaw)")

        self.rightWall = self.wallTextureSet.textureNamed("RightWall_\(wallTypeRaw)")
        self.upperRightWall = self.wallTextureSet.textureNamed("UpperRightWall_\(wallTypeRaw)")
        self.upperLeftWall = self.wallTextureSet.textureNamed("UpperLeftWall_\(wallTypeRaw)")
        self.leftWall = self.wallTextureSet.textureNamed("LeftWall_\(wallTypeRaw)")
        self.lowerLeftWall = self.wallTextureSet.textureNamed("LowerLeftWall_\(wallTypeRaw)")
        self.lowerRightWall = self.wallTextureSet.textureNamed("LowerRightWall_\(wallTypeRaw)")

        self.wallType = type
    }

}