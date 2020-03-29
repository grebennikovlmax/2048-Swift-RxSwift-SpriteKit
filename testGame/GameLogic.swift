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
        tiles.append(TileModel(title: tileTitle, node: tile))
    }
    
    func matchingTiles(this tile: TileModel, with nextTile: TileModel) {
        tile.title.text = String(Int(tile.title.text!)! * 2)
        tile.node.color = .red
        tiles.removeAll { $0 == nextTile }
        delegate?.deleteChild(nextTile.node)
     }
    
    @objc func swipeUp() {
        var position: CGFloat = 0
        for tile in tiles.sorted(by: { $0.node.position.y > $1.node.position.y }) {
            guard tile.node.position.y != CGFloat(135) else { continue }
            let rowTiles = tiles.filter { $0.node.position.x == tile.node.position.x }.sorted(by: {$0.node.position.y > $1.node.position.y})
            let target: CGFloat = 135 - tile.node.position.y
            if let index = rowTiles.firstIndex(of: tile) {
                if rowTiles.indices.contains(index - 1){
                    let nextTile = rowTiles[index - 1]
                    if tile.title.text == nextTile.title.text {
                        position = tile.node.position.y + target - CGFloat((index - 1) * 90)
                        matchingTiles(this: tile, with: nextTile)
                    } else {
                        position = tile.node.position.y + target - CGFloat(index * 90)
                    }
                } else {
                    position = tile.node.position.y + target - CGFloat(index * 90)
                }
            }
            delegate?.moveTo(tile: tile.node, to: position, direction: .up)
        }
        delegate?.createTile()
    }
    
    @objc func swipeDown() {
        var position: CGFloat = 0
        for tile in tiles.sorted(by: { $0.node.position.y < $1.node.position.y }) {
            guard tile.node.position.y != CGFloat(-135) else { continue }
            let rowTiles = tiles.filter { $0.node.position.x == tile.node.position.x }.sorted(by: {$0.node.position.y < $1.node.position.y})
            let target: CGFloat = -135 - tile.node.position.y
            if let index = rowTiles.firstIndex(of: tile) {
                if rowTiles.indices.contains(index - 1){
                    let nextTile = rowTiles[index - 1]
                    if tile.title.text == nextTile.title.text {
                        position = tile.node.position.y + target + CGFloat((index - 1) * 90)
                        matchingTiles(this: tile, with: nextTile)
                    } else {
                        position = tile.node.position.y + target + CGFloat(index * 90)
                    }
                } else {
                    position =  tile.node.position.y + target + CGFloat(index * 90)
                }
            }
            delegate?.moveTo(tile: tile.node, to: position, direction: .down)
        }
        delegate?.createTile()
    }
    
    @objc func swipeRight() {
        var position: CGFloat = 0
        for tile in tiles.sorted(by: { $0.node.position.x > $1.node.position.x }) {
            guard tile.node.position.x != CGFloat(135) else { continue }
            let rowTiles = tiles.filter { $0.node.position.y == tile.node.position.y }.sorted(by: {$0.node.position.x > $1.node.position.x})
            let target: CGFloat = 135 - tile.node.position.x
            if let index = rowTiles.firstIndex(of: tile) {
                if rowTiles.indices.contains(index - 1){
                    let nextTile = rowTiles[index - 1]
                    if tile.title.text == nextTile.title.text {
                        position = tile.node.position.x + target - CGFloat((index - 1) * 90)
                        matchingTiles(this: tile, with: nextTile)
                    } else {
                       position = tile.node.position.x + target - CGFloat(index * 90)
                    }
                } else {
                    position =  tile.node.position.x + target - CGFloat(index * 90)
                }
            }
            delegate?.moveTo(tile: tile.node, to: position, direction: .right)
        }
        delegate?.createTile()
    }
    
    @objc func swipeLeft() {
        var position: CGFloat = 0
        for tile in tiles.sorted(by: { $0.node.position.x < $1.node.position.x }) {
            guard tile.node.position.x != CGFloat(-135) else { continue }
            let rowTiles = tiles.filter { $0.node.position.y == tile.node.position.y }.sorted(by: {$0.node.position.x < $1.node.position.x})
            let target: CGFloat = -135 - tile.node.position.x
            if let index = rowTiles.firstIndex(of: tile) {
                if rowTiles.indices.contains(index - 1){
                    let nextTile = rowTiles[index - 1]
                    if tile.title.text == nextTile.title.text {
                        position = tile.node.position.x + target + CGFloat((index - 1) * 90)
                        matchingTiles(this: tile, with: nextTile)
                    } else {
                        position = tile.node.position.x + target + CGFloat(index * 90)
                    }
                } else {
                    position = tile.node.position.x + target + CGFloat(index * 90)
                }
            }
            delegate?.moveTo(tile: tile.node, to: position, direction: .left)
        }
        delegate?.createTile()
    }
}
