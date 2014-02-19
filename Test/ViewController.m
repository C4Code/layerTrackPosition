//
//  ViewController.m
//  Test
//
//  Created by moi on 2/16/2014.
//  Copyright (c) 2014 moi. All rights reserved.
//

#import "ViewController.h"
//#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CALayer *trackingLayer;
@property (nonatomic, strong) CAShapeLayer *pathLayer;
@property (nonatomic, strong) UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createDisplayLink];
    [self createPathLayer];
    [self createTrackingLayer];
    [self createAddLabel];
    [self startAnimating];
}

-(void)createAddLabel {
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    self.label.font = [UIFont fontWithName:@"Monaco" size:10];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.text = @"{x,y}";
    [self.view addSubview:self.label];
}

-(void)startAnimating {
    //begin the animation transaction
    [CATransaction begin];
    //create the stroke animation
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    //from 0
    strokeEndAnimation.fromValue = @(0);
    //to 1
    strokeEndAnimation.toValue = @(1);
    //1s animation
    strokeEndAnimation.duration = 10.0f;
    //repeat forever
    strokeEndAnimation.repeatCount = HUGE_VAL;
    //ease in / out
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //apply to the pathLayer
    [_pathLayer addAnimation:strokeEndAnimation forKey:@"strokeEndAnimation"];

    //NOTE: we don't actually TRACK above animation, its there only for visual effect
    
    //begin the follow path animation
    CAKeyframeAnimation *followPathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //set the path for the keyframe animation
    followPathAnimation.path = _pathLayer.path;
    //add an array of times that match the NUMBER of points in the path
    //for custom paths, you'll need to know the number of points and calc this yourself
    //for an ellipse there are 5 points exactly
    followPathAnimation.keyTimes = @[@(0),@(0.25),@(0.5),@(0.75),@(1)];
    //copy the timing function
    followPathAnimation.timingFunction = strokeEndAnimation.timingFunction;
    //copy the duration
    followPathAnimation.duration = strokeEndAnimation.duration;
    //copy the repeat count
    followPathAnimation.repeatCount = strokeEndAnimation.repeatCount;
    //add the animation to the layer
    [_trackingLayer addAnimation:followPathAnimation forKey:@"postionAnimation"];
    [CATransaction commit];
}

-(void)createDisplayLink {
    _displayLink = [CADisplayLink
                    displayLinkWithTarget:self
                    selector:
                    @selector(displayLinkDidUpdate:)];
    
    [_displayLink
     addToRunLoop:[NSRunLoop mainRunLoop]
     forMode:NSDefaultRunLoopMode];
}

-(void)createPathLayer {
    _pathLayer = [CAShapeLayer layer];
    _pathLayer.bounds = CGRectMake(0,0,100,100);
    _pathLayer.path = CGPathCreateWithEllipseInRect(_pathLayer.bounds, nil);
    _pathLayer.fillColor = [UIColor clearColor].CGColor;
    _pathLayer.lineWidth = 5;
    _pathLayer.strokeColor = [UIColor blackColor].CGColor;
    _pathLayer.position = self.view.center;
    [self.view.layer addSublayer:_pathLayer];
}

-(void)createTrackingLayer {
    _trackingLayer = [CALayer layer];
    
    //set the frame (NOT bounds) so that we can see the layer
    _trackingLayer.frame = CGRectMake(0,0,5,5);
    _trackingLayer.backgroundColor = [UIColor redColor].CGColor;
    
    //we add the blank layer to the PATH LAYER
    //so that its coordinates are always in the path layer's coordinate system
    [_pathLayer addSublayer:_trackingLayer];
}

- (void)displayLinkDidUpdate:(CADisplayLink *)sender {
    //grab the presentation layer of the blank layer
    CALayer *presentationLayer = [_trackingLayer presentationLayer];
    //grab the position of the blank layer
    //convert it to the main view's layer coordinate system
    CGPoint position = [self.view.layer convertPoint:presentationLayer.position
                                           fromLayer:_trackingLayer];
    //print it out
//    NSLog(@"%4.2f,%4.2f",position.x,position.y);
    self.label.text = [NSString stringWithFormat:@"{%3.f,%3.f}",position.x,position.y];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
