//
//  MHGLRender.m
//  OpenGL_Demo
//
//  Created by CoolKernel on 11/05/2017.
//  Copyright © 2017 CoolKernel. All rights reserved.
//

#import "MHGLRender.h"

#define vertex_shader @"attribute vec3 position;\
void main() {\
 gl_Position = vec4(position, 1.0);\
}"

#define fragment_shader @"precision mediump float;\
void main() {\
  gl_FragColor = vec4(0.5, 0.0, 0.0, 1.0);\
}"

#define vertex_shader1 @"attribute vec3 position;\
varying vec3 color;\
attribute vec3 colorCoord_color1;\
void main() {\
   color = colorCoord_color1;\
  gl_Position = vec4(position, 1.0);\
}"

#define fragment_shader1 @"precision mediump float;\
varying vec3 color;\
void main() {\
  gl_FragColor = vec4(color, 1.0);\
}"

#define vertex_shader2 @"attribute vec3 position;\
attribute vec3 color;\
attribute vec2 texcoord;\
varying vec2 texcoordOut;\
varying vec3 colorOut;\
void main() {\
   texcoordOut = texcoord;\
   colorOut = color;\
  gl_Position = vec4(position, 1.0);\
}"

#define fragment_shader2 @"precision mediump float;\
varying vec3 colorOut;\
varying vec2 texcoordOut;\
uniform sampler2D ourTexture;\
void main() {\
   vec4 mask = texture2D(ourTexture, texcoordOut);\
   gl_FragColor = vec4(mask.rgb, 1.0);\
   vec4 m = texture2D(ourTexture, texcoordOut);\
   vec4 c = mix(m, vec4(colorOut, 1), 0.4);\
   gl_FragColor = c;\
}"


@implementation MHGLRender
{
    GLuint _program;
    CAEAGLLayer *_glLayer;
    EAGLContext *_context;
    GLuint _renderBuffer;
    GLuint _frameBuffer;

    float _width;
    float _height;
}

- (MHGLRender *)initWithGLLayer:(CAEAGLLayer *)glLayer frame:(CGRect)frame
{
    if (self = [super init]) {
        _glLayer = glLayer;
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_context];
        [self genBuffer];
        
        _width = frame.size.width;
        _height = frame.size.height;
    }
    
    return self;
}

- (void)startRender
{
    [self loadShader];
    if (self.graphicType == Graphic3) {
        [self drawFrameWithTexture];
    } else {
        [self drawFrame];
    }
}

- (void)genBuffer
{
    glGenFramebuffers(1, &_frameBuffer);
    glGenRenderbuffers(1, &_renderBuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);

    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_glLayer];
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void)loadShader
{
    if (_program) {
        glDeleteProgram(_program);
    }
    
    NSString *vertex = NULL;
    NSString *fragment = NULL;
    switch (self.graphicType) {
        case Graphic1:
            vertex = vertex_shader;
            fragment = fragment_shader;
            break;
        case Graphic2:
            vertex = vertex_shader1;
            fragment = fragment_shader1;
            break;
        case Graphic3:
            vertex = vertex_shader2;
            fragment = fragment_shader2;
            break;
        default:
            vertex = vertex_shader;
            fragment = fragment_shader;
            break;
    }
    
    GLuint vertexShader = [self compileShader:GL_VERTEX_SHADER source:[vertex UTF8String]];
    GLuint fragmentShader = [self compileShader:GL_FRAGMENT_SHADER source:[fragment UTF8String]];
    
    _program = glCreateProgram();
    
    glAttachShader(_program, vertexShader);
    glAttachShader(_program, fragmentShader);
    
    glLinkProgram(_program);
    
    GLint linkSuccess;
    glGetProgramiv(_program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(_program, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"program link eror:%@", messageString);
    }
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
}

- (GLuint)compileShader:(GLenum)shaderType source:(const char *)source
{
    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &source, NULL);
    
    glCompileShader(shader);
    
    GLint complieSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &complieSuccess);
    if (complieSuccess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shader, sizeof(message), 0, &message[0]);
        NSString *m = [NSString stringWithUTF8String:message];
        NSLog(@"shader compile error: %@", m);
    }
    
    return shader;
}

- (void)setGraphicType:(DrawGraphicType)graphicType
{
    _graphicType = graphicType;
}

- (void)drawFrame
{
    [EAGLContext setCurrentContext:_context];

    glUseProgram(_program);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, _width, _height);
    
    int index = glGetAttribLocation(_program, "position");
    if (index < 0) {
        NSLog(@"position index not found");
    }
        
    switch (_graphicType) {
        case Graphic1:
        {
            const GLfloat vertices[] = {
                -0.5, -0.5, 0,   //左下
                0.5,  -0.5, 0,   //右下
                -0.5, 0.5,  0,   //左上
                0.5,  0.5,  0    //右上
            };
            
            glVertexAttribPointer(index, 3, GL_FLOAT, GL_FALSE, 0, vertices);
            glEnableVertexAttribArray(index);
            
            //    glDrawArrays(GL_TRIANGLES, 0, 4);
            const GLubyte indices[] = {
                0,1,2,
                1,2,3
            };
            glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, indices);
        }
            break;
        case Graphic2:
        {
            GLfloat colorData[] = {
                //RGB格式
                1,  0,  0,
                0,  1,  0,
                0,  0,  1
            };
            
            int colorIndex = glGetAttribLocation(_program, "colorCoord_color1");
            if (colorIndex < 0) {
                NSLog(@"color index not found");
            }
            glVertexAttribPointer(colorIndex, 3, GL_FLOAT, GL_FALSE, 0, colorData);
            glEnableVertexAttribArray(colorIndex);
            glDrawArrays(GL_TRIANGLES, 0, 3);

            const GLfloat vertices[] = {
                0, 0, 0,
                0.5, 0, 0.5,
                1, 0, 0,
                0.5, 1, 0
            };
            
            glVertexAttribPointer(index, 3, GL_FLOAT, GL_FALSE, 0, vertices);
            glEnableVertexAttribArray(index);
            
            //    glDrawArrays(GL_TRIANGLES, 0, 4);
            const GLubyte indices[] = {
                0, 1, 2,
                0, 3, 2,
                0, 1, 3,
                1, 2, 3
            };
            glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, indices);
        }
            break;
        default:
            break;
    }
    

    BOOL finished = [_context presentRenderbuffer:GL_RENDERBUFFER];
    NSLog(@"draw finished:%d", finished);
}

- (void)drawFrameWithTexture
{
    [self loadShader];
    
    [EAGLContext setCurrentContext:_context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    glUseProgram(_program);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, _width, _height);
    
    GLuint texture;
    glGenTextures(1, &texture);
    
    glBindTexture(GL_TEXTURE_2D, texture);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
//    glFramebufferTexture2D(<#GLenum target#>, <#GLenum attachment#>, <#GLenum textarget#>, <#GLuint texture#>, <#GLint level#>)
//    glGetUniformBlockIndex(GLuint program, <#const GLchar *uniformBlockName#>)
    
    glActiveTexture(GL_TEXTURE0);
    int index = glGetUniformLocation(_program, "ourTexture");
    if (index < 0) {
        NSLog(@"ourTexture index not found");
    }
    glUniform1i(index, 0);
    [self setupTextureWithImageName:@"testSources"];
    
    const GLfloat vertices[] = {
        -1, -1, 0,
        1,  -1, 0,
        1,  1,  0,
        -1, 1,  0
    };
    
    const GLfloat colors[] = {
        //---- 颜色 ----
        1.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 0.0f,
    };
    
    const GLfloat texCoords[] = {
        0, 0,//左下
        1, 0,//右下
        1, 1,//右上
        0, 1,//左上
    };
    
    int position_index = glGetAttribLocation(_program, "position");
    glVertexAttribPointer(position_index, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(position_index);
    
    int color_index = glGetAttribLocation(_program, "color");
    glVertexAttribPointer(color_index, 3, GL_FLOAT, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(color_index);
    
    int textcoord_index = glGetAttribLocation(_program, "texcoord");
    glVertexAttribPointer(textcoord_index, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
    glEnableVertexAttribArray(textcoord_index);

    
    const GLubyte indices[] = {
        0, 1, 2,
        0, 2, 3
    };

    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, indices);
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    BOOL finished = [_context presentRenderbuffer:GL_RENDERBUFFER];
    NSLog(@"draw finished:%d", finished);
}

- (void)setupTextureWithImageName:(NSString *)imageName
{
    CGImageRef cgImageRef = [[UIImage imageNamed:imageName] CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef ctx = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(ctx, 0, height);
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(ctx, rect);
    CGContextDrawImage(ctx, rect, cgImageRef);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    CGContextRelease(ctx);
    free(imageData);
}

@end
