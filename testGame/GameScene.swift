//
//  GameScene.swift
//  testGame
//
//  Created by Максим Гребенников on 26.03.2020.
//  Copyright © 2020 Maksim Grebennikov. All rights reserved.
//

import UIKit
import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameOver()
    func createTile()
    func moveTo(tile: SKSpriteNode, to position: CGFloat, direction: GameLogic.directions)
    func deleteChild(_ tile: SKSpriteNode)
}

class GameScene: SKScene {
    
    private var gameLogic = GameLogic()
    private var mainBoard = SKSpriteNode()
    private var tile = SKSpriteNode()
    private var tileLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = .white
        self.size = view.frame.size
        self.scaleMode = .resizeFill
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        gameLogic.delegate = self
        setupSwipeControls()
        createMainBoard()
        createTile()
    }
    
    private func createMainBoard() {
        gameLogic.configureMainBoard(&mainBoard)
        self.addChild(mainBoard)
    }
    
    func setupSwipeControls() {
        let up = UISwipeGestureRecognizer(target: gameLogic, action: #selector(gameLogic.swipeUp))
        up.direction = .up
        view?.addGestureRecognizer(up)
        
        let down = UISwipeGestureRecognizer(target: gameLogic, action: #selector(gameLogic.swipeDown))
        down.direction = .down
        view?.addGestureRecognizer(down)
        
        let left = UISwipeGestureRecognizer(target: gameLogic, action: #selector(gameLogic.swipeLeft))
        left.direction = .left
        view?.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: gameLogic, action: #selector(gameLogic.swipeRight))
        right.direction = .right
        view?.addGestureRecognizer(right)
    }
    
}

extension GameScene: GameSceneDelegate {

    func moveTo(tile: SKSpriteNode, to position: CGFloat, direction: GameLogic.directions) {
        var action: SKAction
        if direction == .up || direction == .down {
            action = SKAction.moveTo(y: position, duration: 0.1)
        } else {
            action = SKAction.moveTo(x: position, duration: 0.1)
        }
        tile.run(action)
    }
    
    func createTile() {
        run(.wait(forDuration: 0.15)) { [weak self] in
            self?.gameLogic.configureTile(&self!.tile, withLabel: &self!.tileLabel)
            self?.mainBoard.addChild(self!.tile)
        }
        
    }
    
    func deleteChild(_ tile: SKSpriteNode) {
        tile.removeFromParent()
    }
    
    func gameOver() {
        print("GameOver")
    }
}

