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
import RxSwift

enum ARViewType {
    case waitingForUserTap, waitingForResults(identifier: String), failedToGetResults, resultDisplayed
}

class ViewController: UIViewController, ARSKViewDelegate, SceneDelegate {
    
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
    
    @IBOutlet weak var productDetailsView: UIView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var nutritionFactsLabel: UILabel!
    
    @IBAction func didTapRecognize(_ sender: Any) {
        if let scene = sceneView.scene as? Scene {
            scene.findObject()
        }
    }
    
    @IBAction func didTapReset(_ sender: Any) {
        self.food = nil
        arViewType = .waitingForUserTap
        if let scene = sceneView.scene as? Scene {
            scene.removeAnchor()
        }
    }
    
    var repository: Repository! = Repository.instance
    var food: Food?
    
    let disposeBag = DisposeBag()
    
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
            case .failedToGetResults:
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
        if let scene = sceneView.scene as? Scene {
            scene.sceneDelegate = self
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
    
    func getCaptionNode(food: Food) -> SKNode {
        foodLabel.text = food.name
        var nutrients = ""
        for nutrient in food.nutrients {
            if !nutrients.isEmpty {
                nutrients += "\n"
            }
            nutrients += "\(nutrient.label!) \(nutrient.quantity!)\(nutrient.unit!)"
        }
        nutritionFactsLabel.text = nutrients
        productDetailsView.layoutIfNeeded()
        let texture = SKTexture(image: getImage(view: productDetailsView))
        return SKSpriteNode(texture: texture)
    }
    
    func getImage(view: UIView) -> UIImage {
        let bounds = view.bounds
        let bg = view.backgroundColor
        
        view.backgroundColor = UIColor.white
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        view.bounds = bounds
        view.backgroundColor = bg
        return image!
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        guard let food = self.food else {
            return nil
        }
        
        // Create and configure a node for the anchor added to the view's session.
        return getCaptionNode(food: food)
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
    
    // MARK: SceneDelegate
    
    func didFailToFindObject() {
        arViewType = .failedToGetResults
    }
    
    func didDetectObject(identifier: String) {
        arViewType = .waitingForResults(identifier: identifier)
        let param = FoodParam(food: identifier)
        repository.search(param: param).subscribe(onNext: { food in
            self.food = food
            self.arViewType = .resultDisplayed
        }, onError: { error in
            self.arViewType = .failedToGetResults
        }).addDisposableTo(disposeBag)
    }
    
}
