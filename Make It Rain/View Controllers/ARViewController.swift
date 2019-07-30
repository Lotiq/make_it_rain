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
import SceneKitVideoRecorder

class ARViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var sessionInfoView: UIVisualEffectView!
    @IBOutlet weak var recordBarButtonItem: UIBarButtonItem!
    
    var money: Int!
    // Width of the currency in meters
    let restrictedWidth: CGFloat = 0.156
    
    // Selected currency local variable
    var selectedCurrency: Currency!
    
    // Dictionary of banknote nominals
    var banknoteBank: [Int : Int]! // [Banknote Bill: Number In Use]
    
    // Dictionary of banknote nominal value and SCNNodes
    var modelAssets = [Int : SCNNode]()
    
    // Array for ar anchor planes added to scene.
    var anchorPlanesInScene = [SCNNode]()
    
    // Bool variable to track whether the action has been performed
    var rained = false
    
    // Button that enables and disables recording
    var recButton: RecordButton!
    
    // AR Recorder
    var recorder: SceneKitVideoRecorder?
    
    // Video URL
    var videoURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        self.view.backgroundColor = UIColor.theme.secondary
        
        recButton = RecordButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        recButton.delegate = self
        let navigationFont = UIFont(name: "Montserrat Medium", size: 24)
        recordBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: navigationFont!], for: .normal)
        recordBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: navigationFont!], for: .focused)
        recordBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: navigationFont!], for: .highlighted)
        recordBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: navigationFont!], for: .disabled)
        
        recordBarButtonItem.customView = recButton

        self.navigationItem.backBarButtonItem = .createBackButtonWith(title: "Back")
        
        interaction(isHidden: true)
        
        initiateBanknoteBank()
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
        
        // Rotates back to Portrait if needed
        
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if recorder == nil {
            var options = SceneKitVideoRecorder.Options.default
            
            let scale = UIScreen.main.nativeScale
            let sceneSize = sceneView.bounds.size
            options.videoSize = CGSize(width: sceneSize.width * scale, height: sceneSize.height * scale)
            recorder = try! SceneKitVideoRecorder(withARSCNView: sceneView, options: options)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // let navBar = self.navigationController!.navigationBar
        // recButton.frame = CGRect(x: 0, y: 0, width: navBar.frame.height - 10, height: navBar.frame.height - 10 )
        // self.navigationController?.navigationBar.frame.width -4
    }
    
    @IBAction func makeItRain(_ sender: UIButton) {
        rained = true
        sender.isHidden = true
        // Get SNNode which is serves as an anchor
        guard let anchor = sceneView.scene.rootNode.childNode(withName: "anchor", recursively: true) else {
            print("No plane anchor detected")
            return
        }
        
        // Convert anchors center position to
        let anchorWorldPosition = anchor.convertPosition(anchor.position, to: sceneView.scene.rootNode)
        
        guard let plane = anchor.geometry as? SCNPlane else {
            return
        }
        // Get plane's width and height
        let width = Float(plane.width)
        let height = Float(plane.height)
        
        /*
        // Test Corners
        var corners: [(x: Float,z: Float)] = []
        corners.append((x: anchorWorldPosition.x - width/2, z: anchorWorldPosition.z - height/2))
        corners.append((x: anchorWorldPosition.x - width/2, z: anchorWorldPosition.z + height/2))
        corners.append((x: anchorWorldPosition.x + width/2, z: anchorWorldPosition.z - height/2))
        corners.append((x: anchorWorldPosition.x + width/2, z: anchorWorldPosition.z + height/2)
        
        let (min, max) = anchor.boundingBox
        let minWorld = anchor.convertPosition(min, to: sceneView.scene.rootNode)
        let maxWorld = anchor.convertPosition(max, to: sceneView.scene.rootNode)
        let xMinActual = Float.minimum(minWorld.x, maxWorld.x)
        let xMaxActual = Float.maximum(minWorld.x, maxWorld.x)
        let zMinActual = Float.minimum(minWorld.z, maxWorld.z)
        let zMaxActual = Float.maximum(minWorld.z, maxWorld.z)
        
        // Test Corner boxes
        let box1 = SCNNode(geometry: SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0))
        box1.position = SCNVector3(corners[0].x, anchorWorldPosition.y, corners[0].z)
        sceneView.scene.rootNode.addChildNode(box1)
        
        let box2 = SCNNode(geometry: SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0))
        box2.position = SCNVector3(corners[1].x, anchorWorldPosition.y, corners[1].z)
        sceneView.scene.rootNode.addChildNode(box2)
        
        let box3 = SCNNode(geometry: SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0))
        box3.position = SCNVector3(corners[2].x, anchorWorldPosition.y, corners[2].z)
        sceneView.scene.rootNode.addChildNode(box3)
        
        let box4 = SCNNode(geometry: SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0))
        box4.position = SCNVector3(corners[3].x, anchorWorldPosition.y, corners[3].z)
        sceneView.scene.rootNode.addChildNode(box4)
        */
        
        for anchorPlane in anchorPlanesInScene {
            anchorPlane.isHidden = true
        }
        
        let count = banknoteBank.reduce(0) { (total, entry) -> Int in
            total + entry.value
        }
        
        // Adjust maximum duration
        var timing = (2+Double(count)/10)
        if timing > 30 {
            timing = 30
        }
        
        recButton.playState = .playing
        
        for banknote in banknoteBank {
            for _ in (0..<banknote.value){
                
                // Choose a random location certain distance away from the center
                let endX = Float.random(in: anchorWorldPosition.x - width/2 ... anchorWorldPosition.x + width/2)
                let endZ = Float.random(in: anchorWorldPosition.z - height/2 ... anchorWorldPosition.z + height/2)
                
                // Adjusting z position to avoid flickering
                let zFightingAdjustment = Float.random(in: 0.00001...0.01)
                let endY = anchorWorldPosition.y + zFightingAdjustment
                
                // Random height from which they fall
                let offsetY: Float = 0.5 + Float.random(in: 0.3...1.0)
                
                // Combine to create start and end locations
                let startLocation = SCNVector3(endX, endY + offsetY, endZ)
                let endLocation = SCNVector3(endX, endY, endZ)
                
                // Get the SCNNode with the required image
                guard let newNode = modelAssets[banknote.key]?.clone() else {
                    print("Unable to create a new node")
                    return
                }
                
                newNode.position = startLocation
                
                // Random rotation
                newNode.eulerAngles.y = Float.random(in: 0..<2 * Float.pi)
                
                // Adjust for SCNNode to be positioned lying, but not standing
                newNode.eulerAngles.x = -Float.pi/2
                
                sceneView.scene.rootNode.addChildNode(newNode)
                
                // Add random duration
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
    
    func initiateBanknoteBank(){
        selectedCurrency = Currency.selectedCurrency
        money = Int(Double(Currency.dollarValue)/selectedCurrency.ratio)
        banknoteBank = Currency.distributeCurrencyDescending()
        
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
    }
    
    @IBAction func showPressed(_ sender: UIBarButtonItem) {
        guard sender.customView == nil else {return}
        let main = UIStoryboard(name: "Main", bundle: nil)
        let shareVC = main.instantiateViewController(withIdentifier: "ShareVideoViewController") as! ShareVideoViewController
        shareVC.videoURL = self.videoURL
        navigationController?.pushViewController(shareVC, animated: true)
    }
}



extension ARViewController: RecordButtonDelegate {
    func RecordButtonStartedRecording() {
        self.recorder?.startWriting().onSuccess {
            print("Recording Started")
        }
    }
    
    func RecordButtonFinished() {
 
        recButton.isEnabled = false
        recordBarButtonItem.customView = nil
        recordBarButtonItem.isEnabled = false
        self.recorder?.finishWriting().onSuccess { [weak self] url in
            DispatchQueue.main.async {
                self?.recordBarButtonItem.isEnabled = true
            }
            self?.videoURL = url
        }

    }
}



extension ARViewController: ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - ARSCNViewDelegate
    
    /// - Tag: PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor, rained == false else { return }
        
        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
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
            let plane = planeNode.geometry as? SCNPlane,
            rained == false
            else {return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z)
        /*
         Plane estimation may extend the size of the plane, or combine previously detected
         planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
         corresponding node for one plane, then calls this method to update the size of
         the remaining plane.
         */
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
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
        // Disable raining again, once finished
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




