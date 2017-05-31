//
//  MHTest.m
//  OpenGL_Demo
//
//  Created by CoolKernel on 19/05/2017.
//  Copyright © 2017 CoolKernel. All rights reserved.
//

#import "MHTest.h"
#import <UIKit/UIKit.h>
#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES3/gl.h>


@implementation MHTest

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)test
{
    GLuint sampler;
    glGenSamplers(1, &sampler);
    
    glDeleteSamplers(1, &sampler);
    
//    glEndQueryEXT(<#GLenum target#>)
//    glPixelStorei(<#GLenum pname#>, <#GLint param#>)
}

@end
