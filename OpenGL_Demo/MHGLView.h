//
//  MHGLView.h
//  OpenGL_Demo
//
//  Created by CoolKernel on 11/05/2017.
//  Copyright © 2017 CoolKernel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGLRender.h"

@interface MHGLView : UIView

- (void)startRender;

- (void)drawType:(DrawGraphicType)type;


@end
