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

class ViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate{
    
    func chatbotPOST(name: String) {
        // URL for your endpoint
        guard let url = URL(string: "https://84ad-128-61-50-201.ngrok-free.app/backend") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue(name, forHTTPHeaderField: "name")
        
        // Create URLSession
        let session = URLSession.shared
        
        // Send the request
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                
                print("Error: \(error)")
                return
            }
            
            // Check if there is data returned
            if let data = data {
                // Process the response data
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            }
        }
        
        task.resume()
    }

    @IBOutlet var sceneView: ARSCNView!
    
    let options = ["Language", "Support", "Freeform"]
    
    let textField = UITextField()
    
    let clearButton = UIButton()
    let actionMenuButton = UIButton(type: .system)
    let submitButton = UIButton()
    
    let shapes = ["Language":"a circle.", "Support":"a heart.", "Freeform": "anything you want!"]
    
    var currentColor = UIColor.red.cgColor
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
    
    @objc func clearButtonTapped(_ sender: UIButton) {
            // Action for the red button tap
            drawView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        }

    @objc func submitButtonTapped(_ sender: UIButton) {
            // Action for the red button tap
        var text = textField.text!
        print(text)
        // chatbotPOST(name: text)
    }
    
    func drawLineFrom(lastPoint: CGPoint, toPoint: CGPoint) {
            let path = UIBezierPath()
            path.move(to: lastPoint)
            path.addLine(to: toPoint)

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = currentColor
            shapeLayer.lineWidth = 2.0

            drawView.layer.addSublayer(shapeLayer)
        }
    
    /*

    @IBAction func colorPickerTapped(_ sender: UIButton) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true, completion: nil)
    }
    
    func colorPickerViewerControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        print("Selected color: \(selectedColor)")
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        currentColor = viewController.selectedColor.cgColor
    }
     */
    
    /*
     @IBAction func pickColorButtonTapped(_ sender: UIButton) {
             let colorPicker = UIColorPickerViewController()
             colorPicker.delegate = self
             present(colorPicker, animated: true, completion: nil)
         }
         
         // Delegate method called when color is picked
         func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
             let selectedColor = viewController.selectedColor
             // Use the selectedColor as needed (e.g., apply to a view, store it)
             print("Selected color: \(selectedColor)")
         }
         
         func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
             // This method is called when the color selection changes
             // Useful for real-time updates while the user selects the color
         }
     */
    
    
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
        longPressGesture.minimumPressDuration = 0.03
        drawView.addGestureRecognizer(longPressGesture)
        
        // Create a new scene
        let scene = SCNScene()
        
        // let button = UIButton(primaryAction: nil)
        
        /*
        let actionClosure = { (action: UIAction) in
            print(self.shapes[action.title] ?? "question mark")
        }

        let submit = { (action: UIAction) in
            print("Submitting")
        }
         */
        
        /*
         var menuChildren: [UIMenuElement] = []
         for option in options {
             menuChildren.append(UIAction(title: option, handler: actionClosure))
         }
             
         button.menu = UIMenu(options: .displayInline, children: menuChildren)
         
         button.showsMenuAsPrimaryAction = true
         button.changesSelectionAsPrimaryAction = true
             
         button.frame = CGRect(x: 150, y: 200, width: 100, height: 40)
         self.view.addSubview(button)
         */
        
        textField.text = ""
        textField.placeholder = "Name your creation!"
        textField.borderStyle = .roundedRect
        textField.delegate = self // Set the delegate if you want to handle text field events
         
        self.view.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
                    textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    textField.heightAnchor.constraint(equalToConstant: 40)
                ])
        
        clearButton.setTitle("clear", for: .normal)
        
        self.view.addSubview(clearButton)
        
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        
        let clearButton = UIButton(type: .system)
        clearButton.frame = CGRect(x: 20, y: 90, width: buttonWidth, height: buttonHeight)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.backgroundColor = .red
        clearButton.layer.cornerRadius = 5 // To make the button corners rounded
        
        let submitButton = UIButton(type: .system)
        submitButton.frame = CGRect(x: 130, y: 90, width: buttonWidth, height: buttonHeight)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = .systemGreen
        submitButton.layer.cornerRadius = 5 // To make the button corners rounded

        // Add an action to the button (you can define the action method below)
        clearButton.addTarget(self, action: #selector(clearButtonTapped(_:)), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitButtonTapped(_:)), for: .touchUpInside)
        
        self.view.addSubview(clearButton)
        self.view.addSubview(submitButton)
        
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
}

// MARK: - UIextention
extension UIColor {
    static let transparentLightBlue = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 0.5)
}
