//
//  ARSceneViewController.swift
//  FitsmindSample
//
//  Created by Seevan Ranka on 07/01/18.
//  Copyright © 2018 Seevan Ranka. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ARSceneViewController: UIViewController,ARSCNViewDelegate  {

    @IBOutlet weak var sceneView: ARSCNView!
    
    var position = CGPoint()
    var nodeModel:SCNNode!
    let nodeName = "_material_1"

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action:#selector(BackAction(sender:)) )
        sceneView.showsStatistics = true
        sceneView.antialiasingMode = .multisampling4X
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let modelScene = SCNScene(named:
        "dummy_obj/dummy_obj.obj")!
        nodeModel =  modelScene.rootNode.childNode(
            withName: nodeName, recursively: true)
        nodeModel.position = get3dPosition()
        sceneView.session.add(anchor: ARAnchor(transform: nodeModel.simdTransform))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: .resetTracking)
    }

    override func viewWillDisappear(_ animated: Bool) {
        sceneView.session.pause()
    }
    
    @objc func BackAction(sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
   
    // converts CGPoint of a plane to SCNVector3(3d coordinates)
    func get3dPosition() -> SCNVector3{
        let ProjectedPlaneCenter = self.sceneView.projectPoint(self.nodeModel.position)
        let projectedDepth = ProjectedPlaneCenter.z
        let vpWithDepth = SCNVector3(Float(self.position.x), Float(self.position.y), projectedDepth)
        let scenePoint = self.sceneView.unprojectPoint(vpWithDepth)
        return scenePoint
    }
    
    // MARK: ARSCNViewDelegate Method
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            DispatchQueue.main.async {
                let modelClone = self.nodeModel.clone()
                modelClone.position = self.get3dPosition()
                node.addChildNode(modelClone)
            }
        }
    }
   
}
