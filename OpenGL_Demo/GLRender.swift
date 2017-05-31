//
//  GLRender.swift
//  OpenGL_Demo
//
//  Created by CoolKernel on 26/05/2017.
//  Copyright © 2017 CoolKernel. All rights reserved.
//

import Foundation
import OpenGLES.ES2
import UIKit

let vertexShaderSources_1 =
"attribute vec3 position;" +
"void main() {" +
"  gl_Position = vec4(position, 1.0);" +
"}"


let fragmentShaderSouces_1 =
"precision mediump float;" +
"void main() {" +
"  gl_FragColor = vec4(0.5, 0.0, 0.0, 1.0);" +
"}"

let vertexShaderSources_2 =
"attribute vec3 position;" +
"varying vec3 colorCoord;" +
"attribute vec3 color;" +
"void main() {" +
"   colorCoord = color;" +
"   gl_Position = vec4(position, 1);" +
"}"

let fragmentShaderSources_2 =
"precision mediump float;" +
"varying vec3 colorCoord;" +
"void main() {" +
"   gl_FragColor = vec4(colorCoord, 1);" +
"}"

let vertexShaderSources_3 =
"attribute vec3 position;" +
"attribute vec3 color;" +
"attribute vec2 texcoord;" +
"varying vec2 texcoordOut;" +
"varying vec3 colorOut;" +
"void main() {" +
"   texcoordOut = texcoord;" +
"   colorOut = color;" +
"  gl_Position = vec4(position, 1.0);" +
"}"

let fragmentShaderSources_3 =
"precision mediump float;" +
"varying vec3 colorOut;" +
"varying vec2 texcoordOut;" +
"uniform sampler2D ourTexture;" +
"void main() {" +
//"   vec4 mask = texture2D(ourTexture, texcoordOut);" +
//"   gl_FragColor = vec4(mask.rgb, 1.0);" +
"   vec4 m = texture2D(ourTexture, texcoordOut);" +
"   vec4 c = mix(m, vec4(colorOut, 1), 0.4);" +
"   gl_FragColor = c;" +
"}"


struct GLRender {
    enum GLRenderGraphicType: Int {
        case graphic1, graphic2, graphic3, graphic4
    }

    private var program: GLuint = 0
    private let glLayer: CAEAGLLayer
    private let context: EAGLContext
    private var renderBuffer: GLuint = 0
    private var frameBuffer: GLuint = 0
    private let width: Float
    private let height: Float
    
    var drawType: GLRenderGraphicType = .graphic1
    
    init(_ glLayer: CAEAGLLayer, _ frame: CGRect) {
        self.glLayer = glLayer
        self.context = EAGLContext(api: .openGLES2)
        self.width = Float(frame.width)
        self.height = Float(frame.height)
        genBuffer()
    }
    
    mutating func startRender() {
        loadShader()
        drawFrame()
    }
    
    mutating func genBuffer() {
        EAGLContext.setCurrent(self.context)
        
        glGenFramebuffers(1, &self.frameBuffer)
        glGenRenderbuffers(1, &self.renderBuffer)
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.frameBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.renderBuffer)
        
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.glLayer)
        
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.renderBuffer)
    }
    
    mutating func loadShader() {
        if self.program > 0 {
            glDeleteProgram(self.program)
        }
        
        var vertexSources = ""
        var fragmentSources = ""
        
        switch self.drawType {
        case .graphic1, .graphic2:
            vertexSources = vertexShaderSources_1
            fragmentSources = fragmentShaderSouces_1
        case .graphic3:
            vertexSources = vertexShaderSources_2
            fragmentSources = fragmentShaderSources_2
        case .graphic4:
            vertexSources = vertexShaderSources_3
            fragmentSources = fragmentShaderSources_3
        }
        
        let vertexShader = compilerShader(GLenum(GL_VERTEX_SHADER), vertexSources)
        let fragmentShader = compilerShader(GLenum(GL_FRAGMENT_SHADER), fragmentSources)
        
        self.program = glCreateProgram()
        
        glAttachShader(self.program, vertexShader)
        glAttachShader(self.program, fragmentShader)
        
        glBindAttribLocation(self.program, 3, ("position" as NSString).utf8String)
        switch self.drawType {
        case .graphic1, .graphic2:
            break
        case .graphic3:
            glBindAttribLocation(self.program, 4, ("color" as NSString).utf8String)
        case .graphic4:
            glBindAttribLocation(self.program, 4, ("color" as NSString).utf8String)
            glBindAttribLocation(self.program, 5, ("texcoord" as NSString).utf8String)
        }
        
        glLinkProgram(self.program)
        
        var linkSuccess: GLint = 1
        glGetProgramiv(self.program, GLenum(GL_LINK_STATUS), &linkSuccess)
        
        if linkSuccess == GL_FALSE {
            var message = [GLchar](repeating: GLchar(0), count: 256)
            var len = GLsizei(0)
            glGetProgramInfoLog(self.program, 256, &len, &message)
            let log = String.init(utf8String: message)
            print("program link error is \(String(describing: log))")
        }
        
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
    }
    
    mutating func drawFrame() {
        EAGLContext.setCurrent(self.context)
        
        glUseProgram(self.program)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.frameBuffer)
        
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glViewport(0, 0, GLsizei(self.width), GLsizei(self.height))
        
        let positionLocaltion: GLuint = 3
        let colorLocation: GLuint = 4
        let textCoorLocation: GLuint = 5
        
        switch drawType {
        case .graphic1:
            let vertices:[GLfloat] =
                [-0.5, -0.5, 0.0,
                 0.5, -0.5, 0.0,
                 0.0, 0.5, 0.0]
            glVertexAttribPointer(positionLocaltion, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices)
            glEnableVertexAttribArray(positionLocaltion)
            
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        case .graphic2:
            let vertices:[GLfloat] = [
                -0.5, -0.5, 0,   //左下
                0.5,  -0.5, 0,   //右下
                -0.5, 0.5,  0,   //左上
                0.5,  0.5,  0]
            
            glVertexAttribPointer(positionLocaltion, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices)
            glEnableVertexAttribArray(positionLocaltion)

            let indices:[GLbyte] =
                [0,1,2,
                1,2,3]
            glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), indices)
        case .graphic3:
            let colorData:[GLfloat] = [
                //RGB格式
                1,  0,  0,
                0,  1,  0,
                0,  0,  1]
            glVertexAttribPointer(colorLocation, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, colorData)
            glEnableVertexAttribArray(colorLocation)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
            
            let vertices:[GLfloat] =
                [0, 0, 0,
                 0.5, 0, 0.5,
                 1, 0, 0,
                 0.5, 1, 0]
            glVertexAttribPointer(positionLocaltion, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices)
            glEnableVertexAttribArray(positionLocaltion)
            
            let indices:[GLbyte] =
                [0, 1, 2,
                 0, 3, 2,
                 0, 1, 3,
                 1, 2, 3]
            glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), indices)
            
        case .graphic4:
            var texture: GLuint = 0
            glGenTextures(1, &texture)
            
            glBindTexture(GLenum(GL_TEXTURE_2D), texture)
            
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
            
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
            
            glActiveTexture(GLenum(GL_TEXTURE0))
            glUniform1i(GLint(textCoorLocation), 0)
            
            setupTexture("testSources")
            
            let vertices:[GLfloat] =
                [-1, -1, 0,
                1,  -1, 0,
                1,  1,  0,
                -1, 1,  0]
            
            let colors:[GLfloat] = [
                //---- 颜色 ----
                1.0, 0.0, 0.0,
                0.0, 1.0, 0.0,
                0.0, 0.0, 1.0,
                1.0, 1.0, 0.0]
            
            let texCoords:[GLfloat] = [
                0, 0,//左下
                1, 0,//右下
                1, 1,//右上
                0, 1]//左上
            
            glVertexAttribPointer(positionLocaltion, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices)
            glEnableVertexAttribArray(positionLocaltion)

            glVertexAttribPointer(colorLocation, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, colors)
            glEnableVertexAttribArray(colorLocation)
            
            glVertexAttribPointer(textCoorLocation, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, texCoords)
            glEnableVertexAttribArray(textCoorLocation)
            
            let indices:[GLubyte] =
                [0, 1, 2,
                0, 3, 2,
                0, 1, 3,
                1, 2, 3]
            glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), indices)
        }
        
        let finished = self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        print("finished is: \(finished)")
    }
}

extension GLRender {
    func compilerShader(_ shaderType: GLenum, _ sources: String) -> GLuint {
        let shader = glCreateShader(shaderType)
        var sourcePointer = (sources as NSString).utf8String
        var len = GLint((sources as NSString).length)
        glShaderSource(shader, 1, &sourcePointer, &len)
        
        glCompileShader(shader)
        
        var success: GLint = 1
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &success)
        
        if success == GL_FALSE {
            var message = [GLchar](repeating: GLchar(0), count: 256)
            var len = GLsizei(0)
            glGetShaderInfoLog(shader, 256, &len, &message)
            let log = String.init(utf8String: message)
            print("shader:\(shaderType) compile error is \(String(describing: log))")
        }
        
        return shader
    }
    
    func setupTexture(_ imageName: String) {
        guard let image = UIImage.init(named: imageName) else { return }
        guard let ref = image.cgImage else { return }
        
        let width = image.size.width
        let height = image.size.height
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(width * height) * 4)

        let context = CGContext.init(data: data, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: Int(width) * 4, space: colorSpace, bitmapInfo: ref.bitmapInfo.rawValue)
        context?.translateBy(x: 0, y: height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.clear(rect)
        context?.draw(ref, in: rect)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), data)
        free(data)
    }
}
