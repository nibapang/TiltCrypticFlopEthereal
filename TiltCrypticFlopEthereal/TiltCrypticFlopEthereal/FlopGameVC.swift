//
//  FlopGameVC.swift
//  TiltCrypticFlopEthereal
//
//  Created by SunTory on 2025/3/12.
//

import UIKit
import SpriteKit
import GameplayKit

class FlopGameVC: UIViewController {

    @IBOutlet weak var viewGame: SKView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.frame.size)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        let skView = view as! SKView
        skView.presentScene(scene)
        skView.backgroundColor = .clear
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
