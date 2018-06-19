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
    
    // MARK: - ViewController properties
    
    /// List of pictures and their sizes in real world in meters
    var pictures = TrackedArray<(name: String, width: CGFloat, height: CGFloat)>(
        ("American Gothic by Grant Wood", width: 0.653, height: 0.78),
        ("Stu-mick-o-súcks by George Catlin", width: 0.609, height: 0.736),
        ("The Gulf Stream by Winslow Homer", width: 1.25, height: 0.72)
    )

    /// Connection to the AR scene view in Main.Storyboard
    @IBOutlet var sceneView: ARSCNView!
    
    /// Action of tap gesture recognizer in Main.Storyboard
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        // Find a screen location of user tap
        let touchLocation = sender.location(in: sceneView)
        
        // Hit test to see if a ray from camera (user) through the tap instersects any planes
        let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
        
        // Check if any intersection with a plane was found
        guard let result = hitTestResult.first else { return }
        
        // Place a picture at the hit point
        placePicture(result: result)
        
        printNodeInfo(starting: sceneView.scene.rootNode)
    }
    
    
    // MARK: - UIViewController overrides
    
    /// View has been loaded
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
    
    
    /// View is about to be shown
    ///
    /// - Parameter animated: true if appearing process is animated
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start detecting planes
        detectPlanes(on: true)
    }

    
    /// View is about to be removed
    ///
    /// - Parameter animated: true if the removal process is animated
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // MARK: - ViewController methods
    
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
        
        // Set a name for the node
        node.name = "wall"
        
        // Rotate the node on x axis by -90º
        node.eulerAngles.x -= .pi / 2
        
        // Make the plane semitransparent
        node.opacity = 0.25
        
        // Return the node
        return node
    }
    
    
    /// Switch plane detection on or off
    ///
    /// - Parameter on: true if plane detections needs to be on
    func detectPlanes(on: Bool) {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Allow detection of vertical planes
        if on {
            configuration.planeDetection = .vertical
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    /// Places a picture at given ARHitTestResult
    ///
    /// - Parameter result: ARHitTestResult from intersecting user tap with a wall
    func placePicture(result: ARHitTestResult) {
        // Get the current picture to place
        let picture = pictures.current
        
        // Create an SCNPlane with the sizes from current picture
        let plane = SCNPlane(width: picture.width, height: picture.height)
        
        // Create UIImage with current picture
        guard let image = UIImage(named: "\(picture.name).jpg") else {
            print("\(#function) at \(#line): can't find an image with the name \"\(picture.name).jpg\"")
            return
        }
        
        // Create a material for the plance's surface
        let material = SCNMaterial()
        
        // Assign the picture to the material
        material.diffuse.contents = image
        
        // Assign material to the plane
        plane.materials = [material]
        
        // Create a node with the plane as geometry
        let planeNode = SCNNode(geometry: plane)
        
        // Set a name for the node
        planeNode.name = picture.name
        
        // Move plane node by 1 mm on z axis to avoid intererence with semitransparent planes
        planeNode.position.z += 0.001
        
        // Create a node which will be a parent for planeNode
        let node = SCNNode()
        
        // Set parent node's transform to the world transform of the result
        node.simdTransform = result.worldTransform
        
        // Rotate parent node on x axis by -90º
        node.eulerAngles.x -=  .pi / 2
        
        // Make plane node a child of this node
        node.addChildNode(planeNode)
        
        // Add the parent node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        
        // Advance the index to the next picture
        pictures.currentIndex += 1
        
        // Check if we placed all pictures and made the full round
        if pictures.currentIndex == 0 {
            // If so — remove all walls
            while let wallNode = sceneView.scene.rootNode.childNode(withName: "wall", recursively: true) {
                // Remove wall node's parent from parent node
                wallNode.parent?.removeFromParentNode()
                
                // Remove wall node from parent node
                wallNode.removeFromParentNode()
            }
            
            // Stop detecting planes
            detectPlanes(on: false)
        }
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
