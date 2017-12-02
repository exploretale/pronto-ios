//
//  ViewController.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/2/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

enum ARViewType {
    case waitingForUserTap, waitingForResults, failedToGetResuls, resultDisplayed
}

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var buyCollectionView: UICollectionView!
    @IBOutlet weak var buyViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsViewBottomConstraint: NSLayoutConstraint!
    
    @IBAction func didTapRecognize(_ sender: Any) {
        arViewType = .resultDisplayed // temp
    }
    
    @IBAction func didTapReset(_ sender: Any) {
        arViewType = .waitingForUserTap
        if let scene = sceneView.scene as? Scene {
            scene.removeAnchor()
        }
    }
    
    var arViewType: ARViewType = ARViewType.waitingForUserTap {
        didSet {
            switch arViewType {
            case .waitingForUserTap:
                self.resetButton.isHidden = true
                self.markerView.isHidden = false
                self.boxView.isHidden = false
                self.activityIndicator.stopAnimating()
                self.instructionsLabel.text = "Place the object inside the box then tap it"
                self.showInstructions()
                self.hideBuy()
            case .waitingForResults:
                self.resetButton.isHidden = true
                self.markerView.isHidden = false
                self.boxView.isHidden = true
                self.activityIndicator.startAnimating()
                self.hideInstructions()
                self.hideBuy()
            case .failedToGetResuls:
                let alert = UIAlertController(title: "Error", message: "Failed to get results", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                self.resetButton.isHidden = true
                self.markerView.isHidden = false
                self.boxView.isHidden = false
                self.activityIndicator.stopAnimating()
                self.instructionsLabel.text = "Place the object inside the box then tap it"
                self.showInstructions()
                self.hideBuy()
            case .resultDisplayed:
                self.resetButton.isHidden = false
                self.markerView.isHidden = true
                self.boxView.isHidden = true
                self.activityIndicator.startAnimating()
                self.hideInstructions()
                self.showBuy()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        self.arViewType = .waitingForUserTap
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - Helper methods
    
    func showBuy() {
        self.buyViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
        }
    }
    
    func hideBuy() {
        self.buyViewBottomConstraint.constant = -self.buyViewHeightConstraint.constant
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
        }
    }
    
    func showInstructions() {
        self.instructionsViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
        }
    }
    
    func hideInstructions() {
        self.instructionsViewBottomConstraint.constant = -self.instructionsView.frame.height
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
        }
    }
    
    func getCaptionNode(title: String, description: String) -> SKNode {
        let labelBoxNode = SKSpriteNode(color: .darkGray, size: CGSize(width: 200, height: 200))
        labelBoxNode.position = CGPoint(x: 0, y: 0)
        
        let singleLineMessage = SKLabelNode()
        singleLineMessage.fontSize = min(labelBoxNode.size.width, labelBoxNode.size.height) /
            CGFloat(description.components(separatedBy: "\n").count)
        singleLineMessage.verticalAlignmentMode = .center
        singleLineMessage.text = description
        let message = singleLineMessage.multilined()
        message.position = CGPoint(x: 0, y: 0)
        message.zPosition = 1001
        
        labelBoxNode.addChild(message)
        
        return labelBoxNode
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        return getCaptionNode(title: "Hello", description: "hot dogs\ncold beer\nteam jerseys")
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
