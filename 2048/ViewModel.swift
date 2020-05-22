//
//  ViewModel.swift
//  2048
//
//  Created by Максим Гребенников on 12.04.2020.
//  Copyright © 2020 Maksim Grebennikov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class ViewModel {
  
  private let gameSize: Int
  private var mainBoard: [[Tile?]] = []
  private var isMoved = true
  
    //MARK: - Input
  var swipe = PublishSubject<UISwipeGestureRecognizer>()
  
    //MARK: - Output
  
  var gesture: Observable<Void>!
  var newTile = PublishRelay<Tile>()
  var moveTile = PublishRelay<Tile>()
  var points = BehaviorRelay<Int>(value: 0)
  var gameOver = PublishRelay<Void>()
  
  init(gameSize: Int) {
    self.gameSize = gameSize
    
    gesture = swipe.asObservable().map { [unowned self] geture -> Void in
      self.moveTile(direction: geture.direction)
    }
  }
  
  func startGame() {
    if !mainBoard.isEmpty {
      for row in mainBoard {
        for tile in row {
          tile?.sprite?.removeFromParent()
        }
      }
    }
    points.accept(0)
    let temp = Array<Tile?>(repeating: nil, count: gameSize)
    mainBoard = Array(repeating: temp, count: gameSize)
    isMoved = true
    createTile()
  }
  
  private func checkCoordinates() -> [(Int, Int)] {
    var freeCoordinates: [(Int, Int)] = []
    for i in 0..<gameSize {
      for j in 0..<gameSize {
        guard mainBoard[i][j] == nil else { continue }
        freeCoordinates.append((i,j))
      }
    }
    return freeCoordinates
  }
  
  private func createTile() {
    let freeCoordinates = checkCoordinates()
    guard !freeCoordinates.isEmpty else {
         gameOver.accept(())
         return
    }
    guard isMoved else { return }
    isMoved = false
    let randomPoint = freeCoordinates.randomElement()!
    let tile = Tile(row: randomPoint.0, column: randomPoint.1)
    mainBoard[tile.row][tile.column] = tile
    newTile.accept(tile)
  }
  
  private func moveTile(direction: UISwipeGestureRecognizer.Direction) {
    switch direction {
    case .up:
      for i in 1..<gameSize {
        for j in 0..<gameSize {
          guard let tile = mainBoard[i][j] else { continue }
          var newInd = i
          while  newInd > 0  {
            guard let matchTile = mainBoard[newInd - 1][j] else {
              newInd -= 1
              continue
            }
            if tile == matchTile {
              tile.title *= 2
              points.accept(points.value + tile.title)
              matchTile.sprite?.removeFromParent()
              mainBoard[newInd - 1][j] = nil
              newInd -= 1
            }
            break
          }
          if tile.row != newInd {
            isMoved = true
          }
          mainBoard[i][j] = nil
          tile.row = newInd
          mainBoard[newInd][j] = tile
          moveTile.accept(tile)
        }
      }
    case .down:
      for i in stride(from: gameSize - 2, through: 0, by: -1) {
        for j in 0..<gameSize {
          guard let tile = mainBoard[i][j] else { continue }
          var newInd = i
          while newInd < gameSize - 1 {
            guard let matchTile = mainBoard[newInd + 1][j] else {
              newInd += 1
              continue
            }
            if tile == matchTile {
              tile.title *= 2
              points.accept(points.value + tile.title)
              matchTile.sprite?.removeFromParent()
              mainBoard[newInd + 1][j] = nil
              newInd += 1
            }
            break
          }
          if tile.row != newInd {
            isMoved = true
          }
          mainBoard[i][j] = nil
          tile.row = newInd
          mainBoard[newInd][j] = tile
          moveTile.accept(mainBoard[newInd][j]!)
        }
      }
    case .left:
      for i in 1..<gameSize {
        for j in 0..<gameSize {
          guard let tile = mainBoard[j][i] else { continue }
          var newInd = i
          while  newInd > 0  {
            guard let matchTile = mainBoard[j][newInd - 1] else {
              newInd -= 1
              continue
            }
            if tile == matchTile {
              tile.title *= 2
              points.accept(points.value + tile.title)
              matchTile.sprite?.removeFromParent()
              mainBoard[j][newInd - 1] = nil
              newInd -= 1
            }
            break
          }
          if tile.column != newInd {
            isMoved = true
          }
          mainBoard[j][i] = nil
          tile.column = newInd
          mainBoard[j][newInd] = tile
          moveTile.accept(mainBoard[j][newInd]!)
        }
      }
    case .right:
      for i in stride(from: gameSize - 2, through: 0, by: -1) {
        for j in 0..<gameSize {
          guard let tile = mainBoard[j][i] else { continue }
          var newInd = i
          while newInd < gameSize - 1 {
            guard let matchTile = mainBoard[j][newInd + 1] else {
              newInd += 1
              continue
            }
            if tile == matchTile {
              tile.title *= 2
              points.accept(points.value + tile.title)
              matchTile.sprite?.removeFromParent()
              mainBoard[j][newInd + 1] = nil
              newInd += 1
            }
              break
          }
          if tile.column != newInd {
            isMoved = true
          }
          mainBoard[j][i] = nil
          tile.column = newInd
          mainBoard[j][newInd] = tile
          moveTile.accept(mainBoard[j][newInd]!)
        }
      }
    default:
      break
    }
    createTile()
  }
  
  
}
