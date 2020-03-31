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
    func createBlankTile(in point: CGPoint, with size: CGSize)
    func gameOver()
    func createTile(_ tile: SKShapeNode, with title: SKLabelNode)
    func moveTo(tile: SKShapeNode, to position: CGFloat, direction: GameLogic.directions)
    func deleteChild(_ tile: SKShapeNode)
    func setSize() -> CGSize
}

class GameScene: SKScene {
    
    private var gameLogic = GameLogic()
    private var scoreBoard = SKLabelNode()
    private var mainBoard = SKSpriteNode()
    private var gameOverNode = SKSpriteNode()
    private var cropMainBoard = SKCropNode()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = .white
        self.size = view.frame.size
        self.scaleMode = .resizeFill
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setupSwipeControls()
        createMainBoard()
        createScoreBoard()
        newGame()
    }

    
    private func createScoreBoard() {
        scoreBoard = SKLabelNode(text: "Score: 0")
        scoreBoard.fontSize = 30
        scoreBoard.fontColor = .black
        scoreBoard.position = CGPoint(x: 0, y: mainBoard.frame.height / 1.5)
        self.addChild(scoreBoard)
    }
    
    private func createMainBoard() {
        let size = CGSize(width: 300, height: 300)
        let mask = SKShapeNode(rectOf: size, cornerRadius: 15)
        mask.fillColor = .white
        cropMainBoard.maskNode = mask
        mainBoard = SKSpriteNode(color: .gray, size: size)
        mainBoard.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        cropMainBoard.addChild(mainBoard)
        self.addChild(cropMainBoard)
    }
    
    func newGame() {
        gameLogic.delegate = self
    }
    
}

    //MARK: - GameSceneDelegate

extension GameScene: GameSceneDelegate {
    
    func setSize() -> CGSize {
        return mainBoard.size
    }
    
    func createBlankTile(in point: CGPoint, with size: CGSize) {
        let blankTile = SKShapeNode(rectOf: size, cornerRadius: 10)
        blankTile.position = point
        blankTile.fillColor = .lightGray
        blankTile.lineWidth = 0
        cropMainBoard.addChild(blankTile)
    }
    
    
    func setScore(_ score: Int) {
        self.scoreBoard.text = "Score: \(score)"
    }

    func moveTo(tile: SKShapeNode, to position: CGFloat, direction: GameLogic.directions) {
        var action: SKAction
        if direction == .up || direction == .down {
            action = SKAction.moveTo(y: position, duration: 0.1)
        } else {
            action = SKAction.moveTo(x: position, duration: 0.1)
        }
        tile.run(action)
    }
    
    func createTile(_ tile: SKShapeNode, with title: SKLabelNode) {
        title.fontSize = 30
        title.fontColor = .darkGray
        title.fontName = "Helvetica"
        title.position = CGPoint(x: 0, y: -(title.frame.height)/2)
        tile.addChild(title)
        tile.alpha = 0
        cropMainBoard.addChild(tile)
        tile.run(SKAction.fadeAlpha(to: 1, duration: 0.15))
        
    }
    
    func deleteChild(_ tile: SKShapeNode) {
        tile.removeFromParent()
    }
    
    func gameOver() {
        gameOverNode = SKSpriteNode(color: .brown, size: mainBoard.size)
        gameOverNode.alpha = 0
        gameOverNode.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        let label = SKLabelNode(text: "Game Over")
        label.position = CGPoint(x: 0, y: label.frame.height)
        label.fontName = "Helvetica"
        label.fontSize = 50
        label.fontColor = .black
        let button = SKLabelNode(text: "Try again")
        button.position = CGPoint(x: 0, y: -label.frame.height)
        button.fontSize = 30
        button.fontName = "Helvetica"
        button.fontColor = .black
        gameOverNode.addChild(button)
        gameOverNode.addChild(label)
        cropMainBoard.addChild(gameOverNode)
        gameOverNode.run(SKAction.fadeAlpha(to: 0.7, duration: 0.3))
    }
}

    //MARK:- GestureRecognition

extension GameScene {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if gameOverNode.contains(touch.location(in: gameOverNode)) {
            self.gameOverNode.removeFromParent()
            newGame()
        }
    }
}

