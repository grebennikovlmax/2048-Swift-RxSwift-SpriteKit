//
//  MainViewController.swift
//  testGame
//
//  Created by Максим Гребенников on 25.03.2020.
//  Copyright © 2020 Maksim Grebennikov. All rights reserved.
//

import UIKit
import SpriteKit

class MainViewController: UIViewController {
    
    var scene = GameScene()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = SKView(frame: view.frame)
        if let skView = self.view as? SKView {
            skView.presentScene(scene)
            skView.showsPhysics = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
