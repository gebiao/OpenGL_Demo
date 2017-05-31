//
//  GLViewController.swift
//  OpenGL_Demo
//
//  Created by CoolKernel on 26/05/2017.
//  Copyright © 2017 CoolKernel. All rights reserved.
//

import UIKit

class GLViewController: UIViewController {
    
    @IBOutlet weak var glView: GLView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func drawFrame(_ sender: UIButton) {
        let titleString = sender.title(for: .normal) ?? ""
        var type: GLRender.GLRenderGraphicType = .graphic1
        switch titleString {
        case "Draw1":
            type = .graphic1
        case "Draw2":
            type = .graphic2
        case "Draw3":
            type = .graphic3
        case "Draw4":
            type = .graphic4
        default: break
        }
        
        self.glView.drawType(type)
        self.glView.startRender()
    }

    @IBAction func switchOcRender(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
