//
//  GameViewController.swift
//  burtblaster
//
//  Created by Alex Burt on 10/4/17.
//  Copyright (c) 2017 Bloc. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, BurtBlasterDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var burtBlaster:BurtBlaster!
    
    // #1
    var panPointReference:CGPoint?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        
        let skView = view as! SKView
        
        skView.multipleTouchEnabled = false
        
        
        // Create and configure the scene.
        
        scene = GameScene(size: skView.bounds.size)
        
        scene.scaleMode = .AspectFill
        
        
        // #13
        
        scene.tick = didTick
        
        burtBlaster = BurtBlaster()
        burtBlaster.delegate = self
        burtBlaster.beginGame()
        
        // Present the scene.
        
        skView.presentScene(scene)
        
        // #14
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // #15
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        burtBlaster.rotateShape()
        
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        
        // #2
        
        let currentPoint =
        sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            
            // #3 
            
            if abs(currentPoint.x - originalPoint.x) >
                (BlockSize * 0.9) {
                
                // #4
                if sender.velocityInView(self.view).x >
                    CGFloat (0) {
                    burtBlaster.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    burtBlaster.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        
        burtBlaster.dropShape()
    }
    
    // #5 
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecignizer
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // #6 
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailByGestureRecognizer
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UITapGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer{
                return true
            }
        }
        return false
    }
    
    
    func didTick() {
        
        burtBlaster.letShapeFall()
    }
    func nextShape() {
        let newShapes = burtBlaster.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(newShapes.nextShape!){}
        self.scene.movePreviewShape(fallingShape) {
            
            // #16
            self.view.userInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(burtBlaster: BurtBlaster) {
        
        levelLabel.text = "\(burtBlaster.level)"
        scoreLabel.text = "\(burtBlaster.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        
        // The following is false when restarting a new game
        
        if burtBlaster.nextShape != nil && burtBlaster.nextShape?.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(burtBlaster.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    func gameDidEnd(burtBlaster: BurtBlaster) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        scene.playSound("Sounds/gameover.mp3")
        scene.animateCollapsingLines(burtBlaster.removeAllBlocks(), fallenBlocks: burtBlaster.removeAllBlocks()) {
            burtBlaster.beginGame()
        }
    }
    
    func gameDidLevelUp(burtblaster: BurtBlaster) {
        levelLabel.text = "\(burtBlaster.level)"
        if scene.tickLengthMillis >= 100{
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("Sounds/levelup.mp3")
        
    }
    func gameShapeDidDrop(burtBlaster: BurtBlaster) {
        
        // #7
        
        scene.stopTicking()
        scene.redrawShape(burtBlaster.fallingShape!) {
            burtBlaster.letShapeFall()
        }
        scene.playSound("Sounds/drop.mp3")
    }
    
    func gameShapeDidLand(burtBlaster: BurtBlaster) {
       scene.stopTicking()
       self.view.userInteractionEnabled = false
        
        // #10 
        
        let removedLines = burtBlaster.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(burtBlaster.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                
                // #11
            
                self.gameShapeDidLand(burtBlaster)
            }
            scene.playSound("Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // #17
    
    func gameShapeDidMove(burtBlaster: BurtBlaster) {
        scene.redrawShape(burtBlaster.fallingShape!) {}
    }
}

