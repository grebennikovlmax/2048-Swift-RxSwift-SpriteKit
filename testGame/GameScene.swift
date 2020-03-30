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
    func setScore(_ score: Int)
    func gameOver()
    func createTile(_ tile: SKSpriteNode, with title: SKLabelNode)
    func moveTo(tile: SKSpriteNode, to position: CGFloat, direction: GameLogic.directions)
    func deleteChild(_ tile: SKSpriteNode)
}

class GameScene: SKScene {
    
    private var gameLogic = GameLogic()
    private var scoreBoard = SKLabelNode()
    private var mainBoard = SKSpriteNode()
    private var gameOverNode = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = .white
        self.size = view.frame.size
        self.scaleMode = .resizeFill
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        gameLogic.delegate = self
        setupSwipeControls()
        createMainBoard()
        createScoreBoard()
    }

    
    private func createScoreBoard() {
        scoreBoard = SKLabelNode(text: "Score: 0")
        scoreBoard.fontSize = 30
        scoreBoard.fontColor = .black
        scoreBoard.position = CGPoint(x: 0, y: mainBoard.frame.height / 1.5)
        self.addChild(scoreBoard)
    }
    
    private func createMainBoard() {
        let size = gameLogic.mainBoardSize
        mainBoard = SKSpriteNode(color: .lightGray, size: size)
        mainBoard.anchorPoint = CGPoint(x: 0.5,y: 0.5)
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
    
    func setScore(_ score: Int) {
        self.scoreBoard.text = "Score: \(score)"
    }

    func moveTo(tile: SKSpriteNode, to position: CGFloat, direction: GameLogic.directions) {
        var action: SKAction
        if direction == .up || direction == .down {
            action = SKAction.moveTo(y: position, duration: 0.1)
        } else {
            action = SKAction.moveTo(x: position, duration: 0.1)
        }
        tile.run(action)
    }
    
    func createTile(_ tile: SKSpriteNode, with title: SKLabelNode) {
        title.fontSize = 30
        title.fontColor = .black
        title.position = CGPoint(x: 0, y: -(title.frame.height)/2)
        tile.addChild(title)
        run(.wait(forDuration: 0.2)) { [weak self] in
            self?.mainBoard.addChild(tile)
        }
    }
    
    func deleteChild(_ tile: SKSpriteNode) {
        tile.removeFromParent()
    }
    
    func gameOver() {
        gameOverNode = SKSpriteNode(color: .brown, size: mainBoard.size)
        gameOverNode.alpha = 0.7
        gameOverNode.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        let label = SKLabelNode(text: "Game Over")
        label.position = CGPoint(x: 0, y: label.frame.height)
        label.fontSize = 50
        label.fontColor = .black
        let button = SKLabelNode(text: "Try again")
        button.position = CGPoint(x: 0, y: -label.frame.height)
        button.fontSize = 30
        button.fontColor = .black
        gameOverNode.addChild(button)
        gameOverNode.addChild(label)
        self.addChild(gameOverNode)
    }
}

