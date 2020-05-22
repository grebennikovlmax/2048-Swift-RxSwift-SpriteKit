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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = SKView(frame: view.frame)
        let scene = GameScene()
        if let skView = self.view as? SKView {
            skView.presentScene(scene)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
