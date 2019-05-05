//
//  ARViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/22/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var sessionInfoView: UIVisualEffectView!
    
    var money: Int!
    let restrictedWidth: CGFloat = 0.126 // in m
    // Selected currency
    var selectedCurrency: Currency!
    
    // Dictionary of banknote list and count
    var banknoteBank: [Int : Int]! // [Banknote Bill: Number In Use]
    
    // Dictionary of banknote nominal value and SCNNodes
    var modelAssets = [Int : SCNNode]()
    
    // Array for ar anchor planes added to scene.
    var anchorPlanesInScene = [SCNNode]()
    
    // Bool variable to track whether the action has been performed
    var rained = false
    
    // Currently selected model to place in scene.
    //var currentModelAsset: SCNNode!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interaction(isHidden: true)
        selectedCurrency = Currency.selectedCurrency
        money = Int(Double(Currency.dollarValue)/selectedCurrency.ratio)
        banknoteBank = distributeCurrencyDescending(availableBanknotes: selectedCurrency.availableBanknotes, money: money)
        sceneView.delegate = self
        
        for banknote in banknoteBank{
            let image = selectedCurrency.getImages()[banknote.key]!
            
            let width = image.size.width
            let ratio = restrictedWidth/width
            let plane = SCNPlane(width: restrictedWidth, height: image.size.height * ratio)
            
            let material = SCNMaterial()
            material.diffuse.contents = image
            material.isDoubleSided = true
            plane.materials = [material]
            
            let node = SCNNode(geometry: plane)
            
            
            modelAssets[banknote.key] = node
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableAllOrientations = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if ARKit is supported on device.
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        // Start the view's AR session with a configuration that uses the rear camera,
        // device position and orientation tracking, and plane detection.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableAllOrientations = false
        // Pause the view's session
        sceneView.session.pause()
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func makeItRain(_ sender: UIButton) {
        //rained = true
        //sender.isHidden = true
    
        // SB
        
        guard let anchor = sceneView.scene.rootNode.childNode(withName: "anchor", recursively: true) else {
            print("No plane anchor detected")
            return
        }

        //let anchor = anchorPlanesInScene[0]
        // Find bounds of our target
        // There is no reason to hit test anything because you already know where your target destination is.
        
        // Also --> your hitTest call will always return false
        // hitTest is for testing whether a user's touch on screen (in UIKit screen space) intersects with an object in the scene
        // You cannot use hitTest to test scene space coordinates.
        
        let (min, max) = anchor.boundingBox
        //let thisAnchor = anchor
        // Anchor here refers to the plane you added to the anchor
        // The coordinate space of the anchor is local
        // You need to convert this coordinate space to world space
        
        
        let minWorld = anchor.convertPosition(min, to: sceneView.scene.rootNode)
        let maxWorld = anchor.convertPosition(max, to: sceneView.scene.rootNode)
 
        
        let anchorWorldPosition = anchor.convertPosition(anchor.position, to: sceneView.scene.rootNode)
     
        // Always just use a test cube to check your math
        // let cube = SCNNode(geometry: SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0))
        // cube.position = anchor.convertPosition(anchor.position, to: sceneView.scene.rootNode)
        // sceneView.scene.rootNode.addChildNode(cube)
        
        // Get number of notes to drop
        // I'm not sure how the banknodeBank works, so I'm just taking the total number from all entries in the dictionary
        
        let xMinActual = Float.minimum(minWorld.x, maxWorld.x)
        let xMaxActual = Float.maximum(minWorld.x, maxWorld.x)
        let zMinActual = Float.minimum(minWorld.z, maxWorld.z)
        let zMaxActual = Float.maximum(minWorld.z, maxWorld.z)
        /*
        let box1 = SCNNode(geometry: SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0))
        box1.position = SCNVector3(xMinActual, anchorWorldPosition.y, zMinActual)
        sceneView.scene.rootNode.addChildNode(box1)
        
        let box2 = SCNNode(geometry: SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0))
        box2.position = SCNVector3(xMaxActual, anchorWorldPosition.y, zMaxActual)
        sceneView.scene.rootNode.addChildNode(box2)
        
        let box3 = SCNNode(geometry: SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0))
        box3.position = SCNVector3(xMinActual, anchorWorldPosition.y, zMaxActual)
        sceneView.scene.rootNode.addChildNode(box3)
        
        let box4 = SCNNode(geometry: SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0))
        box4.position = SCNVector3(xMaxActual, anchorWorldPosition.y, zMinActual)
        sceneView.scene.rootNode.addChildNode(box4)
        */

        
        for anchorPlane in anchorPlanesInScene {
            anchorPlane.isHidden = true
        }
        
        let count = banknoteBank.reduce(0) { (total, entry) -> Int in
            total + entry.value
        }
        var timing = (2+Double(count)/10)
        if timing > 15 {
            timing = 15
        }
        
        for banknote in banknoteBank {
            for _ in (0..<banknote.value){
                let endX = Float.random(in: xMinActual ... xMaxActual)
                let endZ = Float.random(in: zMinActual ... zMaxActual)
                
                let zFightingAdjustment = Float.random(in: 0.00001...0.01)
                let endY = anchorWorldPosition.y + zFightingAdjustment
                let offsetY: Float = 0.5 + Float.random(in: 0.3...1.0)
                
                let startLocation = SCNVector3(endX, endY + offsetY, endZ)
                let endLocation = SCNVector3(endX, endY, endZ)
                
                guard let newNode = modelAssets[banknote.key]?.clone() else {
                    print("Unable to create a new node")
                    return
                }
                
                newNode.position = startLocation
                
                newNode.eulerAngles.y = Float.random(in: 0..<2 * Float.pi)
                newNode.eulerAngles.x = -Float.pi/2
                
                sceneView.scene.rootNode.addChildNode(newNode)
                
                // Add random timing
                let duration = Double.random(in: 2...timing)
                let action = SCNAction.move(to: endLocation, duration: duration)
                newNode.runAction(action)
            }
        }
        
    }
    
    func interaction(isHidden: Bool) {
        actionButton.isHidden = isHidden
        sessionInfoView.isHidden = !isHidden
    }

    // TEMPORARY FUNCTION
    func distributeCurrencyDescending(availableBanknotes: Set<Int>, money: Int) -> [Int : Int]{
        var output = [Int : Int]()
        var r = money
        var mutableAvailableBanknotes = availableBanknotes
        while(r >= availableBanknotes.min()!){
            let newMax = mutableAvailableBanknotes.max()!
            let (quotient, remainder) = r.quotientAndRemainder(dividingBy: newMax)
            r = remainder
            output[newMax] = quotient
            mutableAvailableBanknotes.remove(newMax)
        }
        
        return output
    }
}



extension ARViewController: ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - ARSCNViewDelegate
    
    /// - Tag: PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        /*
         `SCNPlane` is vertically oriented in its local coordinate space, so
         rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
         */
        planeNode.eulerAngles.x = -.pi / 2
        
        // Make the plane visualization semitransparent to clearly show real-world placement.
        planeNode.opacity = 0.25
        
        planeNode.name = "anchor"
        
        /*
         Add the plane visualization to the ARKit-managed node so that it tracks
         changes in the plane anchor as plane estimation continues.
         */
        node.addChildNode(planeNode)
        
        // Save all plane nodes.
        anchorPlanesInScene.append(planeNode)
    }
    
    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else {
                return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        /*
         Plane estimation may extend the size of the plane, or combine previously detected
         planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
         corresponding node for one plane, then calls this method to update the size of
         the remaining plane.
         */
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    /*
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        <#code#>
    }*/
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    // MARK: - Private methods
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        var message: String!
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal surfaces."
            
        case .normal:
            // No feedback needed when tracking is normal and planes are visible.
            message = ""
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        case .limited(.relocalizing):
            message = "Relocalizing."
        case .limited(_):
            print("nothing happening")
        }
        if (!rained){
            if message != ""{
                interaction(isHidden: true)
            } else {
                interaction(isHidden: false)
            }
        }
        sessionInfoLabel.text = message
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}




