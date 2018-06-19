//
//  printNodes.swift
//  ARKit Animation
//
//  Created by Denis Bystruev on 11/06/2018.
//  Copyright © 2018 Denis Bystruev. All rights reserved.
//

import SceneKit

/// level of hierarchy when printing nodes
var level = 0

/// node counter
var nodeCount = 0

/// Print node information recoursevely
///
/// - Parameter node: an SCNNode to start with
func printNodeInfo(starting node: SCNNode) {
    // update node counter
    nodeCount += 1
    
    if level < 1 {
        // we can have only one node on top level
        nodeCount = 1
        print("\(nodeCount). \(nodeInfo(node))")
    } else {
        if 1 < level {
            for _ in 2...level {
                print("│", terminator: "")
            }
        }
        print("├\(nodeCount). \(nodeInfo(node))")
    }
    
    // recoursively check child nodes
    level += 1
    for childNode in node.childNodes {
        printNodeInfo(starting: childNode)
    }
    level -= 1
}


/// Formats a string to print information about the SCNNode
///
/// - Parameter node: SCNNode to print information about
/// - Returns: formatted string with node information
func nodeInfo(_ node: SCNNode) -> String {
    // level of hierarchy and node's name
    var result = "level \(level): \(node.name ?? "nil")"
    
    // node's coordinates
//    result += " pos: \(node.position.x):\(node.position.y):\(node.position.z)"
    
    // node's scale
//    result += " scale: \(node.scale.x):\(node.scale.y):\(node.scale.z)"
    
    // node's materials
    if let geometry = node.geometry {
        result += " materials: \(geometry.materials.count)"
    }
    
//    // node's animations
//    result += " animations: \(node.animationKeys.count)"
//    
//    // clear animation list
//    var animationList = ""
//
//    // compose animation list
//    for key in node.animationKeys {
//        animationList += " \(key)"
//        
//        if let animation = ViewController.animations[key] {
//            // get the animation offset time
//            let start = animation.timeOffset
//
//            // get the animation duration
//            let duration = animation.duration
//
//            animationList += " \(start):\(duration)"
//        }
//    }
//
//    // if there are animations in the list add it to the result
//    if animationList != "" {
//        result += "(\(animationList))"
//    }
    
    return result
}
