//
//  TilesModel.swift
//  testGame
//
//  Created by Максим Гребенников on 26.03.2020.
//  Copyright © 2020 Maksim Grebennikov. All rights reserved.
//

import Foundation
import SpriteKit

class Tile: Equatable {
  
  static func == (lhs: Tile, rhs: Tile) -> Bool {
    return lhs.title == rhs.title
  }
  
  
  var title: Int
  var row: Int
  var column: Int
  var sprite: SKShapeNode?
  
  init(row: Int, column: Int) {
    self.row = row
    self.column = column
    self.title = [2,4].randomElement()!
  }
}
