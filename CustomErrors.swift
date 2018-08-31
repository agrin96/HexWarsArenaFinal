//
//  CustomErrors.swift
//  HexWars
//
//  Created by Aleksandr Grin on 8/5/17.
//  Copyright © 2017 AleksandrGrin. All rights reserved.
//

import Foundation

enum boardConstructionError:Error {
    case insetGreaterThanRowOrColumn(String)
    case valuesNotProperlySet(String)
    case mapSizeNotWithinBounds(String)
    case arrayAccessorNotSet(String)
    case boardModelNotInitialized
    case coordinatePairingFailed(String)
}
