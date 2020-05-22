//
//  GameScene.swift
//  testGame
//
//  Created by Максим Гребенников on 26.03.2020.
//  Copyright © 2020 Maksim Grebennikov. All rights reserved.
//

import UIKit
import SpriteKit
import RxSwift
import RxCocoa

class GameScene: SKScene {
  
  private var scoreBoard: SKLabelNode!
  private var mainBoard: SKSpriteNode!
  private var gameOverNode: SKSpriteNode!
  private var cropMainBoard: SKCropNode!
  private var tileSize: CGFloat!
  private let offset: CGFloat = 10
  private let gameSize = 2
  private var viewModel: ViewModel!
  
  private let bag = DisposeBag()
    
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    self.backgroundColor = .white
    self.size = view.frame.size
    self.scaleMode = .resizeFill
    self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    createMainBoard(with: view.bounds.size)
    viewModel = ViewModel(gameSize: gameSize)
    setUpGestureRecognizer()
    bindViewModel()
    viewModel.startGame()
  }
    
  private func createMainBoard(with size: CGSize) {
    let size = CGSize(width: size.width / 1.25 , height: size.width / 1.25)
    tileSize = (size.width - offset * CGFloat(gameSize + 1)) / CGFloat(gameSize)
    let mask = SKShapeNode(rectOf: size, cornerRadius: 15)
    mask.fillColor = .white
    cropMainBoard = SKCropNode()
    cropMainBoard.maskNode = mask
    mainBoard = SKSpriteNode(color: .gray, size: size)
    mainBoard.position = CGPoint(x: -size.width / 2, y: size.width / 2)
    cropMainBoard.addChild(mainBoard)
    self.addChild(cropMainBoard)
      
    mainBoard.anchorPoint = CGPoint(x: 0,y: 1)
    
    for i in 0..<gameSize {
      for j in 0..<gameSize {
        let blank = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize),cornerRadius: 10)
        blank.position = calculatePoint(row: i, column: j)
        blank.lineWidth = 0
        blank.fillColor = .lightGray
        mainBoard.addChild(blank)
      }
    }
    
    scoreBoard = SKLabelNode(text: "Points: 0")
    scoreBoard.fontSize = 30
    scoreBoard.fontColor = .darkGray
    scoreBoard.fontName = "Helvetica"
    scoreBoard.position = CGPoint(x: 0, y: size.height / 2 + tileSize)
    addChild(scoreBoard)
  }
  
  private func bindViewModel() {
    viewModel.gesture
      .subscribe()
      .disposed(by: bag)
    
    viewModel.newTile
      .subscribe(onNext: { [unowned self] tile in
        self.createTile(tile: tile)
      })
      .disposed(by: bag)
    
    viewModel.moveTile
      .subscribe(onNext: { [unowned self] tile in
        self.move(tile: tile)
      })
      .disposed(by: bag)
    
    viewModel.points
      .subscribe(onNext: { [unowned self ] point in
        self.scoreBoard.text = "Points: \(point)"
      })
      .disposed(by: bag)
    
    viewModel.gameOver
      .subscribe(onNext: { [unowned self] in
        self.gameOver()
      })
      .disposed(by: bag)
  }
  
  private func deleteTile(tile: Tile) {
    tile.sprite?.removeFromParent()
  }
  
  private func createTile(tile: Tile) {
    if gameOverNode != nil {
      gameOverNode.removeFromParent()
      gameOverNode = nil
    }
    let tileNode = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize), cornerRadius: 10)
    tileNode.fillColor = setColor(for: tile.title)
    tileNode.position = calculatePoint(row: tile.row, column: tile.column)
    tileNode.lineWidth = 0
    
    let tileLable = SKLabelNode()
    tileLable.text = "\(tile.title)"
    tileLable.fontSize = 30
    tileLable.fontColor = .darkGray
    tileLable.fontName = "Helvetica"
    tileLable.position = CGPoint(x: 0, y: -(tileLable.frame.height) / 2)
    tileNode.addChild(tileLable)
    tileNode.alpha = 0
    
    tileNode.run(SKAction.fadeAlpha(to: 1, duration: 0.1))
    mainBoard.addChild(tileNode)
    tile.sprite = tileNode
  }
  
  private func setUpGestureRecognizer() {
    
    let directions: [UISwipeGestureRecognizer.Direction] = [.down, .left, .right, .up]
    for direction in directions {
      let swipe = UISwipeGestureRecognizer()
      swipe.direction = direction
      view!.addGestureRecognizer(swipe)
      swipe.rx.event
      .bind(to: viewModel.swipe)
      .disposed(by: bag)
    }
  }
  
  private func gameOver() {
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
  
  private func calculatePoint(row: Int, column: Int) -> CGPoint {
    return CGPoint(
      x: (tileSize / 2 + offset) + CGFloat(column) * (tileSize + offset),
      y: -(tileSize / 2 + offset) - CGFloat(row) * (tileSize + offset)
    )
  }
  
  private func move(tile: Tile) {
    let action = SKAction.move(to: calculatePoint(row: tile.row, column: tile.column), duration: 0.1)
    if let text = tile.sprite?.children.first as? SKLabelNode {
      text.text = "\(tile.title)"
    }
    tile.sprite?.fillColor = setColor(for: tile.title)
    tile.sprite!.run(action)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if gameOverNode != nil {
      viewModel.startGame()
    }
  }
    

}

        //MARK: - Color Picker

extension GameScene {
  
  func setColor(for title: Int) -> UIColor {
    switch title {
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
    default: return UIColor(red: 199/255, green: 8/255, blue: 100/255, alpha: 1)
    }
  }
  
}



