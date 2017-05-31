//
//  GLView.swift
//  OpenGL_Demo
//
//  Created by CoolKernel on 26/05/2017.
//  Copyright © 2017 CoolKernel. All rights reserved.
//

import UIKit

class GLView: UIView {
    
    fileprivate(set) var render: GLRender!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let eaglLayer = self.layer as! CAEAGLLayer
        eaglLayer.isOpaque = true
        eaglLayer.drawableProperties = [false: kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8: kEAGLDrawablePropertyColorFormat]
        self.render = GLRender.init(eaglLayer, frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let eaglLayer = self.layer as! CAEAGLLayer
        eaglLayer.isOpaque = true
        eaglLayer.drawableProperties = [false: kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8: kEAGLDrawablePropertyColorFormat]
        self.render = GLRender.init(eaglLayer, frame)
    }

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    func startRender() {
        self.render.startRender()
    }
    
    func drawType(_ type: GLRender.GLRenderGraphicType) {
        self.render.drawType = type
    }
}
