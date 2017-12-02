//
//  Scene.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/2/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import SpriteKit
import ARKit
import CoreML
import Vision

protocol SceneDelegate {
    func didFailToFindObject()
    func didDetectObject(identifier: String)
}

class Scene: SKScene {
    
    private var currentAnchor: ARAnchor?
    var sceneDelegate: SceneDelegate?
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.x = -0.5  // top
            translation.columns.3.y = 0.5   // right
            translation.columns.3.z = -2    // distance in front of cam, negative mas malayo
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // remove current anchor
            self.removeAnchor()
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            self.currentAnchor = anchor
            
            sceneView.session.add(anchor: anchor)
        }
    }
    
    func findObject() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            DispatchQueue.global(qos: .background).async {
                do {
                    // create model
                    let model = try VNCoreMLModel(for: Food101().model)
                    
                    // create request
                    let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                        // Jump onto the main thread
                        DispatchQueue.main.async {
                            // Access the first result in the array after casting the array as a VNClassificationObservation array
                            guard let results = request.results as? [VNClassificationObservation],
                                let result = results.first else {
                                    print ("No results?")
                                    return
                            }
                            
                            // Create a transform with a translation of 0.2 meters in front of the camera
                            var translation = matrix_identity_float4x4
                            translation.columns.3.x = -0.5  // top
                            translation.columns.3.y = 0.5   // right
                            translation.columns.3.z = -2    // distance in front of cam, negative mas malayo
                            let transform = simd_mul(currentFrame.camera.transform, translation)
                            
                            // remove current anchor
                            self.removeAnchor()
                            
                            // Add a new anchor to the session
                            let anchor = ARAnchor(transform: transform)
                            self.currentAnchor = anchor
                            
                            sceneView.session.add(anchor: anchor)
                            self.sceneDelegate?.didDetectObject(identifier: result.identifier)
                        }
                    })
                    
                    // create a handler
                    let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, options: [:])
                    try handler.perform([request])
                } catch {}
            }
        }
    }
    
    func removeAnchor() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        if let a = self.currentAnchor {
            sceneView.session.remove(anchor: a)
        }
    }
    
    func redraw() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        if let a = self.currentAnchor {
            sceneView.session.remove(anchor: a)
            // lol
            sceneView.session.add(anchor: a)
        }
    }
    
}
