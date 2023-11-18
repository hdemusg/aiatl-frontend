//
//  ViewController.swift
//  skibidi
//
//  Created by Sumedh Garimella on 11/17/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let options = ["Language", "Support", "Freeform"]
    
    let shapes = ["Language":"a circle.", "Support":"a heart.", "Freeform": "anything you want!"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
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
        
        // let submitButton = UIButton(primaryAction: submit())
        
        // self.view.addSubview(submitButton)
        
        // Set the scene to the view
        sceneView.scene = scene
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

    // MARK: - ARSCNViewDelegate
    
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
