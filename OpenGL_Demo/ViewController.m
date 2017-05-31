//
//  ViewController.m
//  OpenGL_Demo
//
//  Created by CoolKernel on 11/05/2017.
//  Copyright © 2017 CoolKernel. All rights reserved.
//

#import "ViewController.h"
#import "MHGLView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MHGLView *glView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(UIButton *)sender {
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"Draw1"]) {
        [_glView drawType:Graphic1];
    } else if ([title isEqualToString:@"Draw2"]) {
        [_glView drawType:Graphic2];
    } else if ([title isEqualToString:@"Draw3"]) {
        [_glView drawType:Graphic3];
    } else if ([title isEqualToString:@"Draw4"]) {
        [_glView drawType:Graphic4];
    }
    [_glView startRender];
}


@end
