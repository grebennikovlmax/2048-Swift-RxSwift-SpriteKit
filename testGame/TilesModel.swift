//
//  TilesModel.swift
//  testGame
//
//  Created by Максим Гребенников on 26.03.2020.
//  Copyright © 2020 Maksim Grebennikov. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

struct Tile: Equatable {
    var title: SKLabelNode
    var color: UIColor
    var node: SKSpriteNode
}
