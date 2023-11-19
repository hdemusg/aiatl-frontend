//
//  ViewController.swift
//  kunstenAR
//
//  Created by Sumedh Garimella on 11/18/23.
//

import SwiftUI
import UIKit
import SceneKit
import ARKit
import Foundation
import AVFoundation
import Speech

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @State private var name: String = ""
    @State private var recognizedText: String = "" // Added for STT
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    func convertImageToByteArray(image: UIImage) -> Data? {
        return image.pngData()
    }

    
    @objc func submitButtonTapped(_ sender: UIButton) {
        guard let drawingImage = captureDrawing() else {
            print("Could not capture drawing")
            return
        }
        
        guard let imageBytes = convertImageToByteArray(image: drawingImage) else {
            print("Could not convert image to bytes")
            return
        }
        
        let prompt = textField.text ?? ""
        sendImageToBackend(imageBytes: imageBytes, prompt: prompt)
    }

    
    // MARK: - Drawing Capture and Storage
    func captureDrawing() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(drawView.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        drawView.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func saveImageToLocalDirectory(_ image: UIImage) -> URL? {
            guard let data = image.pngData() else { return nil }
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = UUID().uuidString + ".png"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("Saved image to \(fileURL)")
                return fileURL
            } catch {
                print("Error saving image: \(error)")
                return nil
            }
        }
        
    func sendImageToBackend(imageBytes: Data, prompt: String) {
        let url = URL(string: "https://b5c7-128-61-50-201.ngrok-free.app/backend")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(prompt)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageBytes)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        print(body)

        let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("Error sending image: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
                      let responseData = data {
                       do {
                           // Parse JSON data
                           if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                               // Access parsed JSON values here
                               print("Parsed JSON: \(json)")
                               var model: String
                               var personality: String
                               if let modelValue = json["model"] as? String, let personalityValue = json["personality"] as? String {
                                   // Both values were successfully cast to String
                                   model = modelValue
                                   personality = personalityValue
                                   self.setUpChat(model: model, personality: personality)
                               } else {
                                   // Handle the case where either 'model' or 'personality' values are not Strings or are nil
                                   print("Failed to extract 'model' or 'personality' as String")
                               }
                               // Example: Accessing specific keys in the JSON response
                               if let contentLength = json["Content-Length"] as? Int {
                                   print("Content-Length: \(contentLength)")
                               }
                               // Access other keys similarly...
                           } else {
                               print("Unable to parse JSON data")
                           }
                       } catch {
                           print("Error parsing JSON: \(error)")
                       }            } else {
                           print("Server error")
                       }

        }
        
        task.resume()
    }
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let textView = UITextView()
    let voiceInputButton = UIButton()
    
    var longPressGesture: UILongPressGestureRecognizer?
    
    func setUpChat(model: String, personality: String) {
        print(model)
        print(personality)
        DispatchQueue.main.async {
            self.clear()
            self.removeLongPressGesture()

            switch model {
            case "woman":
                let sphere = SCNSphere(radius: 0.1)
                let node = SCNNode(geometry: sphere)
                self.sceneView.scene.rootNode.addChildNode(node)
            case "airplane":
                let sphere = SCNSphere(radius: 0.1)
                let node = SCNNode(geometry: sphere)
                self.sceneView.scene.rootNode.addChildNode(node)
            case "bird":
                let sphere = SCNSphere(radius: 0.1)
                let node = SCNNode(geometry: sphere)
                self.sceneView.scene.rootNode.addChildNode(node)
            case "cat":
                let sphere = SCNSphere(radius: 0.1)
                let node = SCNNode(geometry: sphere)
                self.sceneView.scene.rootNode.addChildNode(node)
            case "guitar":
                let sphere = SCNSphere(radius: 0.1)
                let node = SCNNode(geometry: sphere)
                self.sceneView.scene.rootNode.addChildNode(node)
            default:
                let sphere = SCNSphere(radius: 0.1)
                let node = SCNNode(geometry: sphere)
                self.sceneView.scene.rootNode.addChildNode(node)
            }
            // ScrollView setup
            self.scrollView.frame = self.view.bounds
            self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            // Content View setup
            self.contentView.frame = CGRect(x: 0, y: self.view.bounds.width - 190, width: self.view.bounds.width, height: self.view.bounds.height)
            self.contentView.backgroundColor = .white

            // Text View setup
            self.textView.frame = CGRect(x: 20, y: self.view.bounds.width - 170, width: self.view.bounds.width - 40, height: 100)
            self.textView.text = "Your scrollable text goes here..."
            self.textView.isEditable = false

            // Voice Input Button setup
            self.voiceInputButton.frame = CGRect(x: 20, y: self.view.bounds.height-70, width: self.view.bounds.width - 40, height: 50)
            self.voiceInputButton.setTitle("Tap to input voice", for: .normal)
            self.voiceInputButton.setTitleColor(.white, for: .normal)
            self.voiceInputButton.backgroundColor = .blue
            self.voiceInputButton.addTarget(self, action: #selector(self.voiceInputButtonTapped), for: .touchUpInside)

            // Adding views to content view
            self.contentView.addSubview(self.textView)
            self.contentView.addSubview(self.voiceInputButton)

            // Set content size for scrolling
            let contentHeight = self.textView.frame.maxY + 20 // Adjust this value as needed
            self.contentView.frame.size = CGSize(width: self.view.bounds.width, height: contentHeight)
            self.scrollView.contentSize = self.contentView.frame.size

            // Add content view to scroll view
            self.scrollView.addSubview(self.contentView)
            self.view.addSubview(self.scrollView)
        }
    }
    
    func clear() {
        drawView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    
    
    func addLongPressGesture() {
        // Add the long press gesture to the scrollView
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        drawView.addGestureRecognizer(longPressGesture!)
    }

    func removeLongPressGesture() {
        DispatchQueue.main.async {
            if let gesture = self.longPressGesture {
                // Remove the long press gesture from the scrollView
                self.drawView.removeGestureRecognizer(gesture)
                self.longPressGesture = nil
            }
        }
    }
    
    func removeDraw() {
        DispatchQueue.main.async {
            // Remove drawView from its superview on the main thread
            self.drawView.removeFromSuperview()
        }
    }
    func chatbotPOST(name: String) {
            // URL for your endpoint
            guard let url = URL(string: "https://b5c7-128-61-50-201.ngrok-free.app/backend") else {
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
    
    
    let options = ["Language", "Support", "Freeform"]
       
    let textField = UITextField()
       
    let clearButton = UIButton()
    let actionMenuButton = UIButton(type: .system)
    let submitButton = UIButton()
       
    let shapes = ["Language":"a circle.", "Support":"a heart.", "Freeform": "anything you want!"]
       
    var currentColor = UIColor.black.cgColor
    var drawView: UIView!
    var lastPoint: CGPoint?
    var model: String?
    
    /*
     @objc func handleTap(_ gesture: UITapGestureRecognizer) {
         if tappable {
             print("tap")
             let location = gesture.location(in: sceneView)
             let hitTestResults = sceneView.hitTest(location, types: .featurePoint)
             
             if let hitResult = hitTestResults.first {
                 let position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                           hitResult.worldTransform.columns.3.y,
                                           hitResult.worldTransform.columns.3.z)
                 
                 // Create a node (e.g., a sphere) at the touched position
                 switch model {
                 case "woman":
                     let sphere = SCNSphere(radius: 0.1)
                     let node = SCNNode(geometry: sphere)
                     node.position = position
                     sceneView.scene.rootNode.addChildNode(node)
                     tappable = false
                 case "airplane":
                     let sphere = SCNSphere(radius: 0.1)
                     let node = SCNNode(geometry: sphere)
                     node.position = position
                     sceneView.scene.rootNode.addChildNode(node)
                     tappable = false
                 case "bird":
                     let sphere = SCNSphere(radius: 0.1)
                     let node = SCNNode(geometry: sphere)
                     node.position = position
                     sceneView.scene.rootNode.addChildNode(node)
                     tappable = false
                 case "cat":
                     let sphere = SCNSphere(radius: 0.1)
                     let node = SCNNode(geometry: sphere)
                     node.position = position
                     sceneView.scene.rootNode.addChildNode(node)
                     tappable = false
                 case "guitar":
                     let sphere = SCNSphere(radius: 0.1)
                     let node = SCNNode(geometry: sphere)
                     node.position = position
                     sceneView.scene.rootNode.addChildNode(node)
                     tappable = false
                 default:
                     let sphere = SCNSphere(radius: 0.1)
                     let node = SCNNode(geometry: sphere)
                     node.position = position
                     sceneView.scene.rootNode.addChildNode(node)
                     tappable = false
                 }
                 // ScrollView setup
                 scrollView.frame = view.bounds
                 scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                 // Content View setup
                 contentView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
                 contentView.backgroundColor = .white

                 // Text View setup
                 textView.frame = CGRect(x: 20, y: 20, width: view.bounds.width - 40, height: 200)
                 textView.text = "Your scrollable text goes here..."
                 textView.isEditable = false

                 // Voice Input Button setup
                 voiceInputButton.frame = CGRect(x: 20, y: 230, width: view.bounds.width - 40, height: 50)
                 voiceInputButton.setTitle("Tap to input voice", for: .normal)
                 voiceInputButton.setTitleColor(.white, for: .normal)
                 voiceInputButton.backgroundColor = .blue
                 voiceInputButton.addTarget(self, action: #selector(voiceInputButtonTapped), for: .touchUpInside)

                 // Adding views to content view
                 contentView.addSubview(textView)
                 contentView.addSubview(voiceInputButton)

                 // Set content size for scrolling
                 let contentHeight = textView.frame.maxY + 20 // Adjust this value as needed
                 contentView.frame.size = CGSize(width: view.bounds.width, height: contentHeight)
                 scrollView.contentSize = contentView.frame.size

                 // Add content view to scroll view
                 scrollView.addSubview(contentView)
                 view.addSubview(scrollView)
             }
         }
      }
     */
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
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

        /*
        @objc func submitButtonTapped(_ sender: UIButton) {
                // Action for the red button tap
            var text = textField.text!
            print(text)
            chatbotPOST(name: text)
        }
         */
        
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
    @objc func voiceInputButtonTapped() {
        // Implement voice input functionality here
        // This method will be triggered when the button is tapped
        print("Voice input button tapped!")
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
                addLongPressGesture()
                
                
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
                textField.placeholder = "What do you want to talk about"
                textField.borderStyle = .roundedRect
                //textField.delegate = self // Set the delegate if you want to handle text field events
                 
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

/*
 let scrollView = UIScrollView()
     let contentView = UIView()
     let textView = UITextView()
     let voiceInputButton = UIButton()

     override func viewDidLoad() {
         super.viewDidLoad()

         // ScrollView setup
         scrollView.frame = view.bounds
         scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

         // Content View setup
         contentView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
         contentView.backgroundColor = .white

         // Text View setup
         textView.frame = CGRect(x: 20, y: 20, width: view.bounds.width - 40, height: 200)
         textView.text = "Your scrollable text goes here..."
         textView.isEditable = false

         // Voice Input Button setup
         voiceInputButton.frame = CGRect(x: 20, y: 230, width: view.bounds.width - 40, height: 50)
         voiceInputButton.setTitle("Tap to input voice", for: .normal)
         voiceInputButton.setTitleColor(.white, for: .normal)
         voiceInputButton.backgroundColor = .blue
         voiceInputButton.addTarget(self, action: #selector(voiceInputButtonTapped), for: .touchUpInside)

         // Adding views to content view
         contentView.addSubview(textView)
         contentView.addSubview(voiceInputButton)

         // Set content size for scrolling
         let contentHeight = textView.frame.maxY + 20 // Adjust this value as needed
         contentView.frame.size = CGSize(width: view.bounds.width, height: contentHeight)
         scrollView.contentSize = contentView.frame.size

         // Add content view to scroll view
         scrollView.addSubview(contentView)
         view.addSubview(scrollView)
     }

     @objc func voiceInputButtonTapped() {
         // Implement voice input functionality here
         // This method will be triggered when the button is tapped
         print("Voice input button tapped!")
     }
 */
