//
//  GameLogic.swift
//  testGame
//
//  Created by Максим Гребенников on 30.03.2020.
//  Copyright © 2020 Maksim Grebennikov. All rights reserved.
//

import Foundation
import SpriteKit

class GameLogic {
    
    weak var delegate: GameSceneDelegate?
    private let mainBoardSize = CGSize(width: 370, height: 370)
    private let tileSize = CGSize(width: 80, height: 80)
    private let border: CGFloat = 10
    private let coordinates: [CGPoint] = [
    CGPoint(x: -135, y: 135), CGPoint(x: -45, y: 135), CGPoint(x: 45, y: 135), CGPoint(x: 135, y: 135),
    CGPoint(x: -135, y: 45), CGPoint(x: -45, y: 45), CGPoint(x: 45, y: 45), CGPoint(x: 135, y: 45),
    CGPoint(x: -135, y: -45), CGPoint(x: -45, y: -45), CGPoint(x: 45, y: -45), CGPoint(x: 135, y: -45),
    CGPoint(x: -135, y: -135), CGPoint(x: -45, y: -135), CGPoint(x: 45, y: -135), CGPoint(x: 135, y: -135)]
    private var maxValue: CGFloat {
        guard let max = self.coordinates.max(by: {$0.x < $1.x})?.x else { return 0}
        return max
    }
    private var minValue: CGFloat {
        guard let min = self.coordinates.max(by: {$0.x > $1.x})?.x else { return 0}
        return min
    }
    private var tiles: [TileModel] = []
    private var rectWidth: CGFloat {
        return border + tileSize.width
    }

    enum directions {
        case up
        case down
        case right
        case left
    }
    
    func setColor(for title: String?) -> UIColor {
        guard let title = title, let number = Int(title) else { return .white }
        switch number {
        case 2: return UIColor(red: 255/255, green: 217/255, blue: 184/255, alpha: 1)
        case 4: return UIColor(red: 255/255, green: 194/255, blue: 140/255, alpha: 1)
        case 8: return UIColor(red: 255/255, green: 164/255, blue: 84/255, alpha: 1)
        case 16: return UIColor(red: 255/255, green: 134/255, blue: 36/255, alpha: 1)
        case 32: return UIColor(red: 255/255, green: 117/255, blue: 0/255, alpha: 1)
        case 64: return UIColor(red: 255/255, green: 88/255, blue: 59/255, alpha: 1)
        case 128: return UIColor(red: 255/255, green: 64/255, blue: 31/255, alpha: 1)
        case 256: return UIColor(red: 255/255, green: 38/255, blue: 0/255, alpha: 1)
        case 512: return UIColor(red: 209/255, green: 0/255, blue: 0/255, alpha: 1)
        case 1024: return UIColor(red: 153/255, green: 2/255, blue: 2/255, alpha: 1)
        case 2048: return UIColor(red: 199/255, green: 8/255, blue: 100/255, alpha: 1)
        default: return .white
        }
    }
    
    func configureMainBoard(_ mainBoard: inout SKSpriteNode) {
        mainBoard = SKSpriteNode(color: .lightGray, size: mainBoardSize)
        mainBoard.anchorPoint = CGPoint(x: 0.5,y: 0.5)
    }
    
    func configureTile(_ tile: inout SKSpriteNode, withLabel tileTitle: inout SKLabelNode) {
        let usingCoordinates = tiles.map { $0.node.position }
        let openCoordinates = coordinates.filter { !usingCoordinates.contains($0) }
        tile = SKSpriteNode(color: .darkGray, size: tileSize)
        tile.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tile.position = openCoordinates.randomElement()!
        tileTitle = SKLabelNode(text: "2")
        tileTitle.fontSize = 30
        tileTitle.fontColor = .black
        tileTitle.position = CGPoint(x: 0, y: -(tileTitle.frame.height)/2)
        tileTitle.text = ["2","4"].randomElement()
        tile.color = setColor(for: tileTitle.text)
        tile.addChild(tileTitle)
        self.tiles.append(TileModel(title: tileTitle, node: tile))
    }
    
    func matchingTiles(this tile: TileModel, with nextTile: TileModel) {
        tile.title.text = String(Int(tile.title.text!)! * 2)
        tile.node.color = setColor(for: tile.title.text)
        tiles.removeAll { $0 == nextTile }
        delegate?.deleteChild(nextTile.node)
     }
    
    @objc func swipeUp() {
        swipe(direction: .up, sort: { $0.node.position.y > $1.node.position.y })
    }
    
    @objc func swipeDown() {
        swipe(direction: .down, sort: { $0.node.position.y < $1.node.position.y })
    }
    
    @objc func swipeRight() {
        swipe(direction: .right, sort: { $0.node.position.x > $1.node.position.x })
    }
    
    @objc func swipeLeft() {
        swipe(direction: .left, sort: { $0.node.position.x < $1.node.position.x })
    }
    
    private func swipe (direction: directions, sort: (TileModel, TileModel) -> Bool) {
        var position: CGFloat
        var target: CGFloat = 0
        var topPosition: CGFloat = 0
        var nodePosition: CGFloat = 0
        var operation: CGFloat = 0
        var isMoved = false
        var filter: (TileModel) -> Bool = { _ in return true }
        for tile in tiles.sorted(by: sort) {
            configureByDirection(direction, tile, &topPosition, &nodePosition, &operation, &filter)
            guard nodePosition != topPosition else { continue }
            target = topPosition - nodePosition
            let rowTiles = tiles.filter(filter).sorted(by: sort)
            guard let index = rowTiles.firstIndex(of: tile) else { continue }
            if rowTiles.indices.contains(index - 1), tile.title.text == rowTiles[index - 1].title.text {
                position = nodePosition + target + CGFloat(index - 1) * rectWidth * operation
                matchingTiles(this: tile, with: rowTiles[index - 1])
            } else {
                position = nodePosition + target + CGFloat(index) * rectWidth * operation
            }
            guard position != nodePosition else { continue }
            delegate?.moveTo(tile: tile.node, to: position, direction: direction)
            isMoved = true
        }
        if isMoved {
            delegate?.createTile()
        } else if !isMoved && tiles.count == coordinates.count {
            delegate?.gameOver()
        }
        
    }
    
    func configureByDirection(_ direction: directions, _ tile: TileModel, _ topPosition: inout CGFloat, _ nodePosition: inout CGFloat
        , _ operation: inout CGFloat, _ filter: inout (TileModel) -> Bool) {
        switch direction {
        case .up:
            topPosition = maxValue
            nodePosition = tile.node.position.y
            filter = { $0.node.position.x == tile.node.position.x }
            operation = -1
        case .down:
            topPosition = minValue
            nodePosition = tile.node.position.y
            filter = { $0.node.position.x == tile.node.position.x }
            operation = 1
        case .right:
            topPosition = maxValue;
            nodePosition = tile.node.position.x;
            filter = { $0.node.position.y == tile.node.position.y }
            operation = -1
        case .left:
            topPosition = minValue;
            nodePosition = tile.node.position.x;
            filter = { $0.node.position.y == tile.node.position.y }
            operation = 1
        }
    }
    
}
