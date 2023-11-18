//
//  ViewController.swift
//  skibidi
//
//  Created by Sumedh Garimella on 11/17/23.
//

import SwiftUI
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let options = ["Language", "Support", "Freeform"]
    
    let textField = UITextField()
    
    let shapes = ["Language":"a circle.", "Support":"a heart.", "Freeform": "anything you want!"]
    
    var drawView: UIView!
    var lastPoint: CGPoint?
    
    /*
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(location, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                let position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                          hitResult.worldTransform.columns.3.y,
                                          hitResult.worldTransform.columns.3.z)
                
                // Create a node (e.g., a sphere) at the touched position
                let sphere = SCNSphere(radius: 0.01)
                let node = SCNNode(geometry: sphere)
                node.position = position
                
                sceneView.scene.rootNode.addChildNode(node)
            }
        }
     
     */
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let currentPoint = gesture.location(in: drawView)

        switch gesture.state {
        case .began:
            lastPoint = currentPoint
            drawLineFrom(lastPoint: currentPoint, toPoint: currentPoint)
        case .changed:
            guard let last = lastPoint else { return }
                        drawLineFrom(lastPoint: last, toPoint: currentPoint)
                        lastPoint = currentPoint
        default:
            lastPoint = nil
        }
    }
    
    func drawLineFrom(lastPoint: CGPoint, toPoint: CGPoint) {
            let path = UIBezierPath()
            path.move(to: lastPoint)
            path.addLine(to: toPoint)

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.black.cgColor
            shapeLayer.lineWidth = 2.0

            drawView.layer.addSublayer(shapeLayer)
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        
        drawView = UIView(frame: view.bounds)
        view.addSubview(drawView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        //drawView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.1
        drawView.addGestureRecognizer(longPressGesture)
        
        // Create a new scene
        let scene = SCNScene()
        
        let button = UIButton(primaryAction: nil)

        let actionClosure = { (action: UIAction) in
            print(self.shapes[action.title] ?? "question mark")
        }

        let submit = { (action: UIAction) in
            print("Submitting")
        }
        
        var menuChildren: [UIMenuElement] = []
        for option in options {
            menuChildren.append(UIAction(title: option, handler: actionClosure))
        }
            
        button.menu = UIMenu(options: .displayInline, children: menuChildren)
        
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
            
        button.frame = CGRect(x: 150, y: 200, width: 100, height: 40)
        self.view.addSubview(button)
        
        textField.placeholder = "Enter text"
        textField.borderStyle = .roundedRect
        textField.delegate = self // Set the delegate if you want to handle text field events
         
        self.view.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
                    textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    textField.heightAnchor.constraint(equalToConstant: 40)
                ])
        
        // let submitButton = UIButton(primaryAction: submit())
        
        // self.view.addSubview(submitButton)
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let trackConfig = ARWorldTrackingConfiguration()
        
        trackConfig.planeDetection = .horizontal
        sceneView.session.run(trackConfig)

        sceneView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
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
    
    /*
     
     override func viewDidLoad() {
             super.viewDidLoad()
             
             sceneView = ARSCNView(frame: view.bounds)
             view.addSubview(sceneView)
             
             let scene = SCNScene()
             sceneView.scene = scene
             sceneView.delegate = self
             
             let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
             sceneView.addGestureRecognizer(tapGesture)
         }
     
     @objc func handleTap(_ gesture: UITapGestureRecognizer) {
             let location = gesture.location(in: sceneView)
             let hitTestResults = sceneView.hitTest(location, types: .featurePoint)
             
             if let hitResult = hitTestResults.first {
                 let position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                           hitResult.worldTransform.columns.3.y,
                                           hitResult.worldTransform.columns.3.z)
                 
                 // Create a node (e.g., a sphere) at the touched position
                 let sphere = SCNSphere(radius: 0.01)
                 let node = SCNNode(geometry: sphere)
                 node.position = position
                 
                 sceneView.scene.rootNode.addChildNode(node)
             }
         }
     */

}
