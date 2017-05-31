//
//  MHGLRender.h
//  OpenGL_Demo
//
//  Created by CoolKernel on 11/05/2017.
//  Copyright © 2017 CoolKernel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES3/gl.h>

typedef NS_ENUM(NSInteger, DrawGraphicType) {
    Graphic1 = 0,
    Graphic2,
    Graphic3,
    Graphic4,
};

@interface MHGLRender : NSObject
@property (nonatomic, assign) DrawGraphicType graphicType;

- (MHGLRender *)initWithGLLayer:(CAEAGLLayer *)glLayer frame:(CGRect)frame;
- (void)startRender;

@end
