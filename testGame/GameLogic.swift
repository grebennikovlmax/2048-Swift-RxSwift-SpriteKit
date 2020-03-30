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
    private let coordinates: [CGPoint] = [
    CGPoint(x: -135, y: 135), CGPoint(x: -45, y: 135), CGPoint(x: 45, y: 135), CGPoint(x: 135, y: 135),
    CGPoint(x: -135, y: 45), CGPoint(x: -45, y: 45), CGPoint(x: 45, y: 45), CGPoint(x: 135, y: 45),
    CGPoint(x: -135, y: -45), CGPoint(x: -45, y: -45), CGPoint(x: 45, y: -45), CGPoint(x: 135, y: -45),
    CGPoint(x: -135, y: -135), CGPoint(x: -45, y: -135), CGPoint(x: 45, y: -135), CGPoint(x: 135, y: -135)]
    private var tiles: [TileModel] = []
    
    enum directions {
        case up
        case down
        case right
        case left
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
        tile.addChild(tileTitle)
        self.tiles.append(TileModel(title: tileTitle, node: tile))
    }
    
    func matchingTiles(this tile: TileModel, with nextTile: TileModel) {
        tile.title.text = String(Int(tile.title.text!)! * 2)
        tile.node.color = .red
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
                position = nodePosition + target + CGFloat((index - 1) * 90) * operation
                matchingTiles(this: tile, with: rowTiles[index - 1])
            } else {
                position = nodePosition + target + CGFloat(index * 90) * operation
            }
            guard position != nodePosition else { continue }
            delegate?.moveTo(tile: tile.node, to: position, direction: direction)
            isMoved = true
        }
        if isMoved  {
            delegate?.createTile()
        }
    }
    
    func configureByDirection(_ direction: directions, _ tile: TileModel, _ topPosition: inout CGFloat, _ nodePosition: inout CGFloat
        , _ operation: inout CGFloat, _ filter: inout (TileModel) -> Bool) {
        switch direction {
        case .up:
            topPosition = 135
            nodePosition = tile.node.position.y
            filter = { $0.node.position.x == tile.node.position.x }
            operation = -1
        case .down:
            topPosition = -135
            nodePosition = tile.node.position.y
            filter = { $0.node.position.x == tile.node.position.x }
            operation = 1
        case .right:
            topPosition = 135;
            nodePosition = tile.node.position.x;
            filter = { $0.node.position.y == tile.node.position.y }
            operation = -1
        case .left:
            topPosition = -135;
            nodePosition = tile.node.position.x;
            filter = { $0.node.position.y == tile.node.position.y }
            operation = 1
        }
    }
    
}
