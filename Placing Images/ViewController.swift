//
//  ViewController.swift
//  Placing Images
//
//  Created by Denis Bystruev on 19/06/2018.
//  Copyright © 2018 Denis Bystruev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Allow detection of vertical planes
        configuration.planeDetection = .vertical

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    /// Creates a vertical semitransparent plane for detected plane visualisation
    ///
    /// - Returns: SCNNode with the plane
    func createWall() -> SCNNode {
        // Create a new node
        let node = SCNNode()
        
        // Attach a 1x1 m plane to the node
        node.geometry = SCNPlane(width: 1, height: 1)
        
        // Rotate the node on X axis by -90º
        node.eulerAngles.x = -.pi / 2
        
        // Make the plane semitransparent
        node.opacity = 0.25
        
        // Return the node
        return node
    }

    
    // MARK: - ARSCNViewDelegate
    
    // Triggered whenever ARKit reports finding a new anchor
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Check that we discovered a plane
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Check that the plane is vertical
        guard planeAnchor.alignment == .vertical else { return }
        
        // Create a new wall
        let wall = createWall()
        
        // Add the wall to the node of discovered plane
        node.addChildNode(wall)
    }
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
