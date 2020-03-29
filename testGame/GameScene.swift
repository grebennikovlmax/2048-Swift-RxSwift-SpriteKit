//
//  GameScene.swift
//  testGame
//
//  Created by Максим Гребенников on 26.03.2020.
//  Copyright © 2020 Maksim Grebennikov. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {
    
    private var mainBoard = SKSpriteNode()
    private var tile = SKSpriteNode()
    private var tileTitle = SKLabelNode()
    private var tiles: [Tile] = []
    private var coordinates: [CGPoint] = [
        CGPoint(x: -135, y: 135), CGPoint(x: -45, y: 135), CGPoint(x: 45, y: 135), CGPoint(x: 135, y: 135),
        CGPoint(x: -135, y: 45), CGPoint(x: -45, y: 45), CGPoint(x: 45, y: 45), CGPoint(x: 135, y: 45),
        CGPoint(x: -135, y: -45), CGPoint(x: -45, y: -45), CGPoint(x: 45, y: -45), CGPoint(x: 135, y: -45),
        CGPoint(x: -135, y: -135), CGPoint(x: -45, y: -135), CGPoint(x: 45, y: -135), CGPoint(x: 135, y: -135)
        ]

    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = .white
        self.size = view.frame.size
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setupSwipeControls()
        createMainBoard()
        createTile()
    }
    
    private func createMainBoard() {
        let size = CGSize(width: 370, height: 370)
        mainBoard = SKSpriteNode(color: .lightGray, size: size)
        mainBoard.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        self.addChild(mainBoard)
    }

    private func createTile() {
        let size = CGSize(width: 80, height: 80)
        let usingCoordinates = tiles.map { $0.node.position }
        let openCoordinates = coordinates.filter { !usingCoordinates.contains($0) }
        tile = SKSpriteNode(color: .darkGray, size: size)
        tile.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tile.position = openCoordinates.randomElement()!
        tileTitle = SKLabelNode(text: "2")
        tileTitle.fontSize = 30
        tileTitle.position = CGPoint(x: 0, y: -(tileTitle.frame.height)/2)
        tileTitle.text = ["2","4"].randomElement()
        tile.addChild(tileTitle)
        mainBoard.addChild(tile)
        tiles.append(Tile(title: tileTitle, color: .darkGray, node: tile))
    }
    
    func setupSwipeControls() {
        let up = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        up.direction = .up
        view?.addGestureRecognizer(up)
        
        let down = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        down.direction = .down
        view?.addGestureRecognizer(down)
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        left.direction = .left
        view?.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        right.direction = .right
        view?.addGestureRecognizer(right)
    }
    
    func matchingTiles(this tile: Tile, with nextTile: Tile) {
        tile.title.text = String(Int(tile.title.text!)! * 2)
        tile.node.color = .red
        tiles.removeAll { $0 == nextTile }
        nextTile.node.removeFromParent()
    }
    
    @objc func swipeUp() {
        let check = tiles.map({ $0.node.position })
        for tile in tiles.sorted(by: { $0.node.position.y > $1.node.position.y }) {
            guard tile.node.position.y != CGFloat(135) else { continue }
            let rowTiles = tiles.filter { $0.node.position.x == tile.node.position.x }.sorted(by: {$0.node.position.y > $1.node.position.y})
            let target: CGFloat = 135 - tile.node.position.y
            if let index = rowTiles.firstIndex(of: tile) {
                if rowTiles.indices.contains(index - 1){
                    let nextTile = rowTiles[index - 1]
                    if tile.title.text == nextTile.title.text {
                        tile.node.run(SKAction.moveTo(y: tile.node.position.y + target - CGFloat((index - 1) * 90), duration: 0.1))
                        matchingTiles(this: tile, with: nextTile)
                    } else {
                        tile.node.run(SKAction.moveTo(y: tile.node.position.y + target - CGFloat(index * 90), duration: 0.1))
                    }
                } else {
                    tile.node.run(SKAction.moveTo(y: tile.node.position.y + target - CGFloat(index * 90), duration: 0.1))
                }
            }
        }
        run(.wait(forDuration: 0.2)) { [weak self] in
            if check != self?.tiles.map({ $0.node.position }) {
                self?.createTile()
            }
        }
    }
    
    @objc func swipeDown() {
        let check = tiles.map({ $0.node.position })
        for tile in tiles.sorted(by: { $0.node.position.y < $1.node.position.y }) {
            guard tile.node.position.y != CGFloat(-135) else { continue }
            let rowTiles = tiles.filter { $0.node.position.x == tile.node.position.x }.sorted(by: {$0.node.position.y < $1.node.position.y})
            let target: CGFloat = -135 - tile.node.position.y
            if let index = rowTiles.firstIndex(of: tile) {
                if rowTiles.indices.contains(index - 1){
                    let nextTile = rowTiles[index - 1]
                    if tile.title.text == nextTile.title.text {
                        tile.node.run(SKAction.moveTo(y: tile.node.position.y + target + CGFloat((index - 1) * 90), duration: 0.1))
                        matchingTiles(this: tile, with: nextTile)
                    } else {
                        tile.node.run(SKAction.moveTo(y: tile.node.position.y + target + CGFloat(index * 90), duration: 0.1))
                    }
                } else {
                    tile.node.run(SKAction.moveTo(y: tile.node.position.y + target + CGFloat(index * 90), duration: 0.1))
                }
            }
        }
        run(.wait(forDuration: 0.2)) { [weak self] in
            if check != self?.tiles.map({ $0.node.position }) {
                self?.createTile()
            }
        }
    }
    
    @objc func swipeLeft() {
        let check = tiles.map({ $0.node.position })
        for tile in tiles.sorted(by: { $0.node.position.x < $1.node.position.x }) {
            guard tile.node.position.x != CGFloat(-135) else { continue }
            let rowTiles = tiles.filter { $0.node.position.y == tile.node.position.y }.sorted(by: {$0.node.position.x < $1.node.position.x})
            let target: CGFloat = -135 - tile.node.position.x
            if let index = rowTiles.firstIndex(of: tile) {
                if rowTiles.indices.contains(index - 1){
                    let nextTile = rowTiles[index - 1]
                    if tile.title.text == nextTile.title.text {
                        tile.node.run(SKAction.moveTo(x: tile.node.position.x + target + CGFloat((index - 1) * 90), duration: 0.1))
                        matchingTiles(this: tile, with: nextTile)
                    } else {
                        tile.node.run(SKAction.moveTo(x: tile.node.position.x + target + CGFloat(index * 90), duration: 0.1))
                    }
                } else {
                    tile.node.run(SKAction.moveTo(x: tile.node.position.x + target + CGFloat(index * 90), duration: 0.1))
                }
            }
        }
        run(.wait(forDuration: 0.2)) { [weak self] in
            if check != self?.tiles.map({ $0.node.position }) {
                self?.createTile()
            }
        }
    }
    
    @objc func swipeRight() {
        let check = tiles.map({ $0.node.position })
        for tile in tiles.sorted(by: { $0.node.position.x > $1.node.position.x }) {
            guard tile.node.position.x != CGFloat(135) else { continue }
            let rowTiles = tiles.filter { $0.node.position.y == tile.node.position.y }.sorted(by: {$0.node.position.x > $1.node.position.x})
            let target: CGFloat = 135 - tile.node.position.x
            if let index = rowTiles.firstIndex(of: tile) {
                if rowTiles.indices.contains(index - 1){
                    let nextTile = rowTiles[index - 1]
                    if tile.title.text == nextTile.title.text {
                        tile.node.run(SKAction.moveTo(x: tile.node.position.x + target - CGFloat((index - 1) * 90), duration: 0.1))
                        matchingTiles(this: tile, with: nextTile)
                    } else {
                        tile.node.run(SKAction.moveTo(x: tile.node.position.x + target - CGFloat(index * 90), duration: 0.1))
                    }
                } else {
                    tile.node.run(SKAction.moveTo(x: tile.node.position.x + target - CGFloat(index * 90), duration: 0.1))
                }
            }
        }
        run(.wait(forDuration: 0.2)) { [weak self] in
            if check != self?.tiles.map({ $0.node.position }) {
                self?.createTile()
            }
        }
    }
}
