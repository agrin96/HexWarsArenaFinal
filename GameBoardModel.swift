//
//  GameBoard.swift
//  HexWars
//
//  Created by Aleksandr Grin on 8/5/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation


enum MapSizeTypes:Int {
    case tiny = 0
    case small
    case medium
    case large
    case huge
    
    //Used to return a classification for the board size
    static func size(columns: Int,rows: Int) throws -> MapSizeTypes{
        switch (columns * rows) {
        case 1..<(8*8):
            return MapSizeTypes.tiny
        case (8*8)..<(16*16):
            return MapSizeTypes.small
        case (16*16)..<(24*24):
            return MapSizeTypes.medium
        case (24*24)..<(32*32):
            return MapSizeTypes.large
        case (32*32)..<100000:
            return MapSizeTypes.huge
        default:
            throw boardConstructionError.mapSizeNotWithinBounds("Map size of: \(columns) by \(rows)")
        }
    }
}

//Conveniance structure to hold the board in one.
class BoardBounds: NSObject, NSCoding{
    var columns:Int = 0 //Length
    var rows:Int = 0    //Width

    init(columns:Int, rows:Int){
        self.columns = columns
        self.rows = rows
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.columns, forKey: "BoardBounds_columns")
        aCoder.encode(self.rows, forKey: "BoardBounds_rows")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.columns = aDecoder.decodeInteger(forKey: "BoardBounds_columns")
        self.rows = aDecoder.decodeInteger(forKey: "BoardBounds_rows")
    }
}

//Container for all map related properties so they can easily be passed around and encapsulated.
class MapModelDescriptor: NSObject, NSCoding {
    var bounds:BoardBounds?
    var landDistribution:MapFillType?
    var landMassGrowthRadius:Int?
    var seedToUse:UInt64?
    var numPlayers:Int?

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.bounds!, forKey: "MapModelDescriptor_bounds")
        aCoder.encode(self.landDistribution!.rawValue, forKey: "MapModelDescriptor_landDistribution")
        aCoder.encode(self.landMassGrowthRadius!, forKey: "MapModelDescriptor_landMassGrowthRadius")
        aCoder.encode(self.seedToUse!, forKey: "MapModelDescriptor_seedToUse")
        aCoder.encode(self.numPlayers!, forKey: "MapModelDescriptor_numPlayers")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        if let data = aDecoder.decodeObject(forKey: "MapModelDescriptor_bounds") as? BoardBounds {
            self.bounds = data
        }
        if let data = aDecoder.decodeObject(forKey: "MapModelDescriptor_landDistribution") as? Int{
            self.landDistribution = MapFillType(rawValue: data)
        }

        self.landMassGrowthRadius = aDecoder.decodeInteger(forKey: "MapModelDescriptor_landMassGrowthRadius")

        if let data = aDecoder.decodeObject(forKey: "MapModelDescriptor_seedToUse") as? UInt64 {
            self.seedToUse = data
        }

        self.numPlayers = aDecoder.decodeInteger(forKey: "MapModelDescriptor_numPlayers")
    }
}

class GameBoardModel:NSObject {
    var boardModel:Array<Array<TileTypes>>?         //Stores the board model to build the Tilemap
    
    //Called to create a tile map model randomly with the paramaters passed in using the descriptor
    func createRandomTileMapModel(mapDescription: GameMap) {
        if mapDescription.mapBounds != nil {
            boardModel = Array.init(repeating: Array<TileTypes>.init(repeating: .empty, count: mapDescription.mapBounds!.columns), count: mapDescription.mapBounds!.rows)
            
            let boardSize = try! MapSizeTypes.size(columns: mapDescription.mapBounds!.columns, rows: mapDescription.mapBounds!.rows)
            createLandMassForBoard(size: boardSize, mapDescriptor: mapDescription)
        }
        //visualization for debug
        if boardModel != nil {
            placeCrowns(for: mapDescription.numPlayers!)
            //printCurrentBoardModel()
        }


    }
    
    //Handles creating the landmasses based on the mapsize.
    private func createLandMassForBoard(size: MapSizeTypes, mapDescriptor: GameMap) {
        
        //Default mapfilltype should be continents. It is a good balance.
        let fill = mapDescriptor.mapFillType ?? .continents
        switch size {
        case .tiny:
            let growthRadius = mapDescriptor.landGrowthRadius ?? 1
            createSetOfContinentsFor(mapFill: fill, mapDescriptor: mapDescriptor, radius: growthRadius)
            return
        case .small:
            let growthRadius = mapDescriptor.landGrowthRadius ?? 1
            createSetOfContinentsFor(mapFill: fill, mapDescriptor: mapDescriptor, radius: growthRadius)
            return
        case .medium:
            let growthRadius = mapDescriptor.landGrowthRadius ?? 1
            createSetOfContinentsFor(mapFill: fill, mapDescriptor: mapDescriptor, radius: growthRadius)
            return
        case .large:
            let growthRadius = mapDescriptor.landGrowthRadius ?? 1
            createSetOfContinentsFor(mapFill: fill, mapDescriptor: mapDescriptor, radius: growthRadius)
            return
        case .huge:
            let growthRadius = mapDescriptor.landGrowthRadius ?? 1
            createSetOfContinentsFor(mapFill: fill, mapDescriptor: mapDescriptor, radius: growthRadius)
            return
        }
    }
    
    //Helper function to createLandmass by handling the looping
    private func createSetOfContinentsFor(mapFill: MapFillType, mapDescriptor: GameMap, radius: Int){
        var landMassLocations = Array<CGPoint>()
        var percentOfMapToFill = 0.0
        
        switch mapFill {
        case .fractured:
            percentOfMapToFill = 0.05
        case .islands:
            percentOfMapToFill = 0.15
        case .continents:
            percentOfMapToFill = 0.30
        case .pangea:
            percentOfMapToFill = 0.70
        }
        
        let seedToUse = mapDescriptor.seedForMap ?? generateRandomSeed()
        let source = GKLinearCongruentialRandomSource(seed: seedToUse)

        while try! percentOfMapToFill > percentOfMapFilled() || landMassLocations.count < 2{
            let growthLocation = try! getRandomCentralizedBoardLocationFor(bounds: mapDescriptor.mapBounds!, source: source)

            landMassLocations.append(CGPoint(x: growthLocation.0, y: growthLocation.1))
            createContinentInRegionAround(column: growthLocation.0, row: growthLocation.1, with: radius, bounds: mapDescriptor.mapBounds!)
        }
        
        connectDisparateLandMass(locations: landMassLocations, bounds: mapDescriptor.mapBounds!)
    }
    
    // Generate a random seed to use for GKGameplaykit random generator.
    private func generateRandomSeed() -> UInt64 {
        let range = UInt64.max - UInt64.max % UInt64.max
        var rand:UInt64 = 0
        
        repeat {
            arc4random_buf(&rand, MemoryLayout.size(ofValue: rand))
        } while rand >= range
        
        return rand % UInt64.max
    }
    
    //Finds the ratio of .empty tiles to not empty tiles and returns the percentage
    private func percentOfMapFilled() throws -> Double {
        if boardModel?.count != 0 {
            var tilesFilled:Double = 0
            for row in 0..<boardModel!.count {
                for column in 0..<boardModel![row].count {
                    if boardModel![row][column].rawValue != 0 {
                        tilesFilled += 1
                    }
                }
            }
            return (tilesFilled / Double(boardModel!.count * boardModel![0].count))
        }else{
            throw boardConstructionError.boardModelNotInitialized
        }
    }
    
    //Creates a solid large connected land mass around the tile specified.
    //@param radius: specifies how large to make the land mass in a tile radius.
    private func createContinentInRegionAround(column: Int, row: Int, with radius: Int, bounds: BoardBounds){
        if boardModel != nil {
            let colMin = (column - radius) < 0 ? 0 : (column - radius)
            let rowMin = (row - radius) < 0 ? 0 : (row - radius)
            
            let colMax = (column + radius) > bounds.columns ? bounds.columns : (column + radius)
            let rowMax = (row + radius) > bounds.rows ? bounds.rows : (row + radius)

            for row in rowMin..<rowMax {
                for col in colMin..<colMax {
                    boardModel![row][col] = .neutral
                }
            }
        }
    }
    
    //Returns a random location on the board array with an inset of 1.
    private func getRandomCentralizedBoardLocationFor(bounds: BoardBounds, source: GKLinearCongruentialRandomSource) throws -> (Int, Int){

        let colRandomizer = GKRandomDistribution(randomSource: source, lowestValue: 1, highestValue: (bounds.columns - 1))
        let rowRandomizer = GKRandomDistribution(randomSource: source, lowestValue: 1, highestValue: (bounds.rows - 1))
        
        let centralCol = colRandomizer.nextInt()
        let centralRow = rowRandomizer.nextInt()
        
        if centralCol < 0 || centralRow < 0 {
            throw boardConstructionError.valuesNotProperlySet("Function: \(#function), Line \(#line), column: \(centralCol), row:\(centralRow)")
        }
        
        return (centralCol, centralRow)
    }
    
    //To be playable, all the landmasses have to be connected up. This function takes the coordinates of the centers of
    // generated land masses and makes sure they are connected to eachother.
    private func connectDisparateLandMass(locations: Array<CGPoint>, bounds: BoardBounds){
        let pairedLandMasses = try! createCoordinatePointPairs(locations: locations)
        
        let sortedPairs = pairedLandMasses.sorted(by: {
            return (taxiCabDistanceFor(locA: $0.A, locB: $0.B) > taxiCabDistanceFor(locA: $1.A, locB: $1.B))
        })
        connectCoordinatePairsWithTiles(pairs: sortedPairs, bounds: bounds)
    }
    
    //Handles creating the path of tiles between two coordinate pairs. Makes sure that all land masses are connected up in
    // a semi random fashion giving a more organic appearance.
    private func connectCoordinatePairsWithTiles(pairs: Array<(A: CGPoint, B: CGPoint)>, bounds: BoardBounds){
        for pair in pairs{
            let target = pair.A
            var current = pair.B
            
            while current != target {
                if current.x < target.x {
                    current.x += 1
                    boardModel![Int(current.y)][Int(current.x)] = .neutral
                    
                    if current.y < target.y {
                        current.y += 1
                        boardModel![Int(current.y)][Int(current.x)] = .neutral
                        
                    }else if current.y > target.y{
                        current.y -= 1
                        boardModel![Int(current.y)][Int(current.x)] = .neutral
                    }
                }else if current.x > target.x {
                    current.x -= 1
                    boardModel![Int(current.y)][Int(current.x)] = .neutral

                    if current.y < target.y {
                        current.y += 1
                        boardModel![Int(current.y)][Int(current.x)] = .neutral
                        
                    }else if current.y > target.y{
                        current.y -= 1
                        boardModel![Int(current.y)][Int(current.x)] = .neutral
                    }
                }else{
                    if current.y < target.y {
                        current.y += 1
                        boardModel![Int(current.y)][Int(current.x)] = .neutral
                        
                    }else if current.y > target.y{
                        current.y -= 1
                        boardModel![Int(current.y)][Int(current.x)] = .neutral
                    }
                }
            }
        }
    }
    
    //To be able to calculate distances between points, we must first transform our array of coordinates into an array
    // of coordinate pairs so that we can directly run a distance function on them and sort.
    // NOTE: This function assumes you must have at least 2 locations!
    private func createCoordinatePointPairs(locations: Array<CGPoint>) throws -> Array<(A: CGPoint, B: CGPoint)>{
        if locations.count < 2 {
            throw boardConstructionError.coordinatePairingFailed("\(#function), \(#line) NOT ENOUGH ELEMENTS")
        }
        var coordinatePairs = Array<(A: CGPoint, B: CGPoint)>()
        
        for location in locations {
            //If we mix an example array of (AB CD EF GH) we will end up with redundancies hence this way we avoid them
            if location != locations[0] {
                coordinatePairs.append((A: locations[0], B: location))
                //print("DEBUG: pair: [\(locations[0]), \(location)]")
            }
        }
        //If there are no pairs then something is wrong.
        if coordinatePairs.count == 0 {
            throw boardConstructionError.coordinatePairingFailed("\(#function) \(#line)")
        }else{
            return coordinatePairs
        }
    }
    
    //Returns the taxi cab distance between two points A and B.
    private func taxiCabDistanceFor(locA: CGPoint, locB: CGPoint) -> Int{
        return Int(abs(locA.x - locB.x) + abs(locA.y - locB.y))
    }

    private func placeCrowns(for players: Int){
        var numberOfTiles = 0
        for row in 0..<boardModel!.count {
            for col in 0..<boardModel![row].count{
                if boardModel![row][col] == .neutral{
                    numberOfTiles += 1
                }
            }
        }

        //Here we reduce the number of tiles and make sure that the number of crowns is divisible by the number of players
        // Since every player must have an equal number of crowns.
        let numberOfCrowns:Int = players

        //placeNeutralTiles(of: .crown, amount: numberOfCrowns)
        radialPlaceCrownTiles(amount: numberOfCrowns)
        placeNeutralTiles(of: .level1, amount: numberOfTiles / 10)
        placeNeutralTiles(of: .level2, amount: numberOfTiles / 15)
        placeNeutralTiles(of: .level3, amount: numberOfTiles / 20)
    }

    private func placeNeutralTiles(of type:TileTypes, amount: Int){
        let seedToUse = generateRandomSeed()
        let source = GKMersenneTwisterRandomSource(seed: seedToUse)
        let colRandomizer = GKRandomDistribution(randomSource: source, lowestValue: 1, highestValue: boardModel![0].count - 1)
        let rowRandomizer = GKRandomDistribution(randomSource: source, lowestValue: 1, highestValue: boardModel!.count - 1)

        var numTilesActive:Int = 0
        while numTilesActive < amount {
            let col = colRandomizer.nextInt()
            let row = rowRandomizer.nextInt()

            if boardModel![row][col] == .neutral {
                boardModel![row][col] = type
                numTilesActive += 1
            }
        }
    }

    private func radialPlaceCrownTiles(amount:Int){
        var numTilesActive:Int = 0
        var placementRadius:Int = (min(boardModel!.count, boardModel![0].count) / 2) - 1  //Radius of inscribed circle with a slight inset.
        let referenceRadius:Int = placementRadius

        //let degreeValueOfPositions:[Double] = [0, 45, 90, 135, 180, 225, 270, 315]  //These represent the circle positions to calculate
        //let degreeValueOfPositions:[Double] = [22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5]  //These represent the secondary circle positions to calculate
        let positionAngles_X:[Double] = [0.0, 0.71, 1.0, 0.71, 0.0, -0.71, -1, -0.71]     //Using sin(angles above)
        let positionAngles_Y:[Double] = [1.0, 0.71, 0.0, -0.71, -1.0, -0.71, 0.0, 0.71]   //Using cos(angles above)

        let secondPositionAngles_X:[Double] = [0.38, 0.92, 0.92, 0.38, -0.38, -0.92, -0.92, -0.38]
        let secondPositionAngles_Y:[Double] = [0.92, 0.38, -0.38, -0.92, -0.92, -0.38, 0.38, 0.92]

        var positionValues_X:[Double] = positionAngles_X.map({ return (Double(placementRadius) * $0) })  //x = r * sin(theta)
        var positionValues_Y:[Double] = positionAngles_Y.map({ return (Double(placementRadius) * $0) })  //y = r * cos(theta)

        //Rounds to integers and converts to board coordinates.
        var boardNormalized_X:[Int] = positionValues_X.map({ return (Int($0) + placementRadius)})
        var boardNormalized_Y:[Int] = positionValues_Y.map({ return (Int($0) + placementRadius)})

        while numTilesActive < amount {
            for i in 0..<boardNormalized_X.count {
                let row:Int = boardNormalized_X[i]
                let col:Int = boardNormalized_Y[i]


                if numTilesActive != amount {
                    if boardModel![row][col] == .neutral {
                        boardModel![row][col] = .crown
                        numTilesActive += 1
                    }
                }else{
                    break
                }
            }
            //If we didnt get it on the first go, tighten the radius and try again.
            if numTilesActive != amount {

                let randomizer = GKMersenneTwisterRandomSource(seed: NSDate().timeIntervalSinceNow.bitPattern)
                placementRadius = randomizer.nextInt(upperBound: referenceRadius)

                //Recompute positions. //Alternate the position rotation to diversify starting location.
                if placementRadius % 2 == 0{
                    positionValues_X = positionAngles_X.map({ return (Double(placementRadius) * $0) })
                    positionValues_Y = positionAngles_Y.map({ return (Double(placementRadius) * $0) })
                }else{
                    positionValues_X = secondPositionAngles_X.map({ return (Double(placementRadius) * $0) })
                    positionValues_Y = secondPositionAngles_Y.map({ return (Double(placementRadius) * $0) })
                }

                boardNormalized_X = positionValues_X.map({ return (Int($0) + placementRadius)})
                boardNormalized_Y = positionValues_Y.map({ return (Int($0) + placementRadius)})
            }
        }
    }
    
    // Prints a debug representation of the Array as a 2D Matrix into the console
    func printCurrentBoardModel() {
        var outputString = ""
        if boardModel != nil {
            for row in 0..<boardModel!.count {
                for column in 0..<boardModel![row].count {
                    if column % boardModel![row].count == 0 {
                        outputString += "\n"
                    }
                    outputString += "[\(boardModel![row][column].rawValue)]"
                }
            }
            print("Current Board Model: \n \(outputString)")
        }
    }
}



