//
//  MHGLView.m
//  OpenGL_Demo
//
//  Created by CoolKernel on 11/05/2017.
//  Copyright © 2017 CoolKernel. All rights reserved.
//

#import "MHGLView.h"

@implementation MHGLView
{
    MHGLRender *_renderer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE],
                                        kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8,
                                        kEAGLDrawablePropertyColorFormat,
                                        nil];
        _renderer = [[MHGLRender alloc] initWithGLLayer:(CAEAGLLayer *)self.layer frame:frame];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE],
                                        kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8,
                                        kEAGLDrawablePropertyColorFormat,
                                        nil];
        _renderer = [[MHGLRender alloc] initWithGLLayer:(CAEAGLLayer *)self.layer frame:self.frame];
    }
    
    return self;
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)startRender
{
    [_renderer startRender];
}

- (void)drawType:(DrawGraphicType)type
{
    _renderer.graphicType = type;
}

@end
