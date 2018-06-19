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
    /// - Parameter planeAnchor: ARPlaneAnchor to get the size properties from
    /// - Returns: SCNNode with the plane
    func createWall(planeAnchor: ARPlaneAnchor) -> SCNNode {
        // Create a new node
        let node = SCNNode()
        
        // Get estimated width (x) and height (z) of discovered plane
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        
        // Attach a plane to the node with given width and height
        node.geometry = SCNPlane(width: width, height: height)
        
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
        let wall = createWall(planeAnchor: planeAnchor)
        
        // Add the wall to the node of discovered plane
        node.addChildNode(wall)
    }
    
    
    // Triggered when ARKit changes the properties of earlier discovered anchor
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Check that the node is being updated is a plane
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Check that the node has a child node
        guard let planeNode = node.childNodes.first else { return }
        
        // Check that this child node has a geometry of SCNPlane type
        guard let plane = planeNode.geometry as? SCNPlane else { return }
        
        // Adjust the (x, z) position of the plane node
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // Adjust the plane width and height
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
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
