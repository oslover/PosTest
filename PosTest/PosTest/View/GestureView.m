//
//  GestureView.m
//  PosTest
//
//  Created by Macmini on 1/2/18.
//  Copyright © 2018 Santo. All rights reserved.
//

#import "GestureView.h"

@interface Line: NSObject
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint secondPoint;

+ (Line*) lineWith: (CGPoint) first :(CGPoint) second;
- (CGFloat) length;
@end

@implementation Line
+ (Line*) lineWith: (CGPoint) first :(CGPoint) second {
    Line* line = [Line new];
    line.firstPoint = first;
    line.secondPoint = second;
    return line;
}

- (CGFloat) length {
    CGFloat xDist = (_secondPoint.x - _firstPoint.x);
    CGFloat yDist = (_secondPoint.y - _firstPoint.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}
@end

@interface Coordinate: NSObject
@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double scale;
@property (nonatomic, strong) UIColor* color;

- (CGPoint) point;
@end

@implementation Coordinate
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.x = 0;
        self.y = 0;
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        self.color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
//        self.color = [UIColor whiteColor];
        self.scale = 1.0;
    }
    return self;
}

- (CGPoint) point {
    return CGPointMake(_x, _y);
}

- (void) setScale:(double)scale {
    _scale = scale;
    self.color = [self.color colorWithAlphaComponent: _scale / 1.5f];
}
@end

@interface SegmentLayer: CAShapeLayer
@property (nonatomic, strong) CAGradientLayer* gradientLayer;
@property (nullable) UIBezierPath* startPath;
@property (nullable) UIBezierPath* completedPath;

+ (SegmentLayer*) segmentLayerWith: (UIBezierPath*) startPath
                                  :(UIBezierPath*) completedPath
                                  :(UIColor*) startColor
                                  :(UIColor*) endColor
                                  :(CGPoint) startPoint //Gradient Start Point
                                  :(CGPoint) endPoint; //Gradient End Point

- (void) showOn: (CALayer*)layer animated: (BOOL) animated;
@end

@implementation SegmentLayer
+ (SegmentLayer*) segmentLayerWith: (UIBezierPath*) startPath
                                  :(UIBezierPath*) completedPath
                                  :(UIColor*) startColor
                                  :(UIColor*) endColor
                                  :(CGPoint) startPoint
                                  :(CGPoint) endPoint
{
    SegmentLayer* layer = [SegmentLayer new];
    layer.shadowOpacity = 1.0f;
    layer.shadowColor = startColor.CGColor;
    layer.shadowRadius = 10.0f;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.startPath = startPath;
    layer.completedPath = completedPath;
    layer.path = layer.startPath.CGPath;
    
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    layer.gradientLayer = gradientLayer;
    gradientLayer.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];

    double xDiff = endPoint.x - startPoint.x;
    double yDiff = endPoint.y - startPoint.y;
    
    if (xDiff == 0) {
        if (yDiff > 0) {
            gradientLayer.startPoint = CGPointMake(0.5, 1);
            gradientLayer.endPoint = CGPointMake(0.5, 0);
        }
        else {
            gradientLayer.startPoint = CGPointMake(0.5, 0);
            gradientLayer.endPoint = CGPointMake(0.5, 1);
        }
    }
    else if (xDiff > 0) {
        if (yDiff == 0) {
            gradientLayer.startPoint = CGPointMake(0, 0);
            gradientLayer.endPoint = CGPointMake(1, 0);
        }
        else if (yDiff > 0) {
            gradientLayer.startPoint = CGPointMake(0, 1);
            gradientLayer.endPoint = CGPointMake(1, 0);
        }
        else {
            gradientLayer.startPoint = CGPointMake(0, 0);
            gradientLayer.endPoint = CGPointMake(1, 1);
        }
    }
    else {
        if (yDiff == 0) {
            gradientLayer.startPoint = CGPointMake(1, 0);
            gradientLayer.endPoint = CGPointMake(0, 0);
        }
        else if (yDiff > 0) {
            gradientLayer.startPoint = CGPointMake(1, 1);
            gradientLayer.endPoint = CGPointMake(0, 0);
        }
        else {
            gradientLayer.startPoint = CGPointMake(1, 0);
            gradientLayer.endPoint = CGPointMake(0, 1);
        }
    }
    return layer;
}

- (void) showOn: (CALayer*)layer animated: (BOOL) animated {
    self.frame = layer.bounds;
    self.gradientLayer.frame = layer.bounds;
    self.path = _startPath.CGPath;
    self.lineWidth = 3;
    self.strokeColor = [UIColor whiteColor].CGColor;
    self.gradientLayer.mask = self;
    
    [layer addSublayer: self.gradientLayer];
    self.path = _startPath.CGPath;
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath: @"path"];
    animation.toValue = (id)_completedPath.CGPath;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    if (animated) {
        animation.duration = 0.3f;
    }
    else {
        animation.duration = 0.0f;
    }
    [self addAnimation: animation forKey: animation.keyPath];
}
@end


@interface GestureView () {
    UIBezierPath *path;
}

@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) NSUInteger   currentSegmentIndex;
@property (nonatomic, strong) NSMutableArray<Coordinate*>* coordinates;
@property (nonatomic, strong) NSMutableArray* segmentLayers;

@end

@implementation GestureView

#pragma mark Internal Method

- (void) initialize {
    if (self.values == nil || self.values.count == 0) {
        NSLog(@"No data to play");
        return;
    }
    
    [self clear];
    [self initCoordinates];
    [self initSegments];
    [self updateToCurrentPosition];
    [self drawToCurrent];
}

- (void) clear {
    [self.segmentLayers removeAllObjects];
    [self.coordinates removeAllObjects];
    self.layer.sublayers = nil;
    [self.layer setNeedsDisplay];
}

- (void) initCoordinates {
    double maxWidth = self.bounds.size.width * 0.4f;
//    NSLog(@"MaxWidth - %.2f", maxWidth);
    double maxX=0, maxY=0, maxZ=0;
    for (PMVValue* value in self.values) {
        double x = [value numberAt: 0];
        double y = [value numberAt: 1];
        double z = [value numberAt: 2];
        
        if (fabs(x) > maxX) {
            maxX = fabs(x);
        }
        
        if (fabs(y) > maxY) {
            maxY = fabs(z);
        }
        
        if (fabs(z) > maxZ) {
            maxZ = fabs(z);
        }
    }
    
    if (maxX == 0) {
        NSLog(@"MaxX Initialization Failure...");
        return;
    }
    
    self.zoomScale = maxWidth / maxX;
    if (self.zoomScale == 0) {
        NSLog(@"View Width is 0");
        return;
    }
    
    self.coordinates = [NSMutableArray array];
    
    for (PMVValue* value in self.values) {
        double x = [value numberAt: 0];
        double y = [value numberAt: 1];
        double z = [value numberAt: 2];
        
        Coordinate* coordinate = [Coordinate new];
        coordinate.x = x * self.zoomScale + self.center.x;
        coordinate.y = y * self.zoomScale + self.center.y;
        if (maxZ == 0) {
            coordinate.scale = 1.0;
        }
        else {
            coordinate.scale = 1 + z/maxZ*0.8;
        }
        NSLog(@"Coordinate - (%.2f,%.2f) x %.2f", coordinate.x, coordinate.y, coordinate.scale);
        [self.coordinates addObject: coordinate];
    }
}

#pragma mark MainDrawing
#define DEFAULT_LINE_WIDTH      30.0f

- (Line*) linePerpendicularTo: (Line*)pp ofRelativeLength: (float) fraction
{
    CGFloat x1 = pp.firstPoint.x, y1 = pp.firstPoint.y, x2 = pp.secondPoint.x, y2 = pp.secondPoint.y;
    
    CGFloat dx, dy, m;
    dx = x2 - x1;
    dy = y2 - y1;
    m = -dx/dy;
    CGFloat b = cos(atan(fabs(m)))*fraction/2;
    
    CGFloat xa, ya, xb, yb;
    xa = x2 + b/2;
    ya = m*(xa-x2) + y2;
    xb = x2 - b/2;
    yb = m*(xb-x2) + y2;
    return [Line lineWith: CGPointMake(xa, ya) :CGPointMake(xb, yb)];
}

- (Line*) lineAt: (NSInteger) index {
    if (index == 0) {
        //change the y position for line's first and second point.
        Line* origline = [self linePerpendicularTo: [Line lineWith: [_coordinates[1] point] : [_coordinates[0] point]]
                                                    ofRelativeLength: _coordinates[0].scale * DEFAULT_LINE_WIDTH];
        Line* line = [Line lineWith:origline.secondPoint :origline.firstPoint];
        return line;
    }
    else if (index == [_coordinates count]-1) {
        Line* line = [self linePerpendicularTo: [Line lineWith: [_coordinates[index-1] point] : [_coordinates[index] point]]
                              ofRelativeLength: _coordinates[index].scale * DEFAULT_LINE_WIDTH];
        return line;
    }
    else {
        Line* line = [self linePerpendicularTo: [Line lineWith: [_coordinates[index-1] point] : [_coordinates[index] point]]
                               ofRelativeLength: _coordinates[index].scale * DEFAULT_LINE_WIDTH];
//        Line* line2 = [self linePerpendicularTo: [Line lineWith: [_coordinates[index+1] point] : [_coordinates[index] point]]
//                               ofRelativeLength: _coordinates[index].scale * DEFAULT_LINE_WIDTH];
//        CGPoint start = CGPointMake((line1.firstPoint.x + line2.secondPoint.x)/2,
//                                    (line1.firstPoint.y + line2.secondPoint.y)/2);
//        CGPoint end = CGPointMake((line2.firstPoint.x + line1.secondPoint.x)/2,
//                                    (line2.firstPoint.y + line1.secondPoint.y)/2);
        return line;//[Line lineWith: start :end];
    }
}

- (void) initSegments {
    if ([_coordinates count] <= 2)
        return;
    
    self.segmentLayers = [NSMutableArray array];
    
    NSMutableArray<Line*>* lines = [NSMutableArray array];
    for (NSInteger i=0; i < self.coordinates.count; ++i) {
        [lines addObject: [self lineAt: i]];
    }
    
    NSInteger nCurves = [lines count]-1;
    for (NSInteger i=0; i < nCurves; ++i) {
        Line* line = lines[i];
//Top lines
        UIBezierPath *startPath = [UIBezierPath bezierPath];
        [startPath moveToPoint: line.firstPoint];
        [startPath addLineToPoint: line.secondPoint];
        NSLog(@"Origin (%.2f, %.2f)", [_coordinates[i] point].x, [_coordinates[i] point].y);
        NSLog(@"Line - %.2f: (%.2f, %.2f)->(%.2f, %.2f)", [line length], line.firstPoint.x, line.firstPoint.y, line.secondPoint.x, line.secondPoint.y);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint curPt = line.firstPoint, prevPt, nextPt, endPt;
        [path moveToPoint: curPt];
        
        NSInteger nextii = (i+1)%[lines count];
        NSInteger previi = (i-1 < 0 ? [lines count]-1 : i-1);
        
        prevPt = lines[previi].firstPoint;
        nextPt = lines[nextii].firstPoint;
        endPt = nextPt;
        
        CGFloat mx, my;
        if (i > 0) {
            mx = (nextPt.x - curPt.x)*0.5 + (curPt.x - prevPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5 + (curPt.y - prevPt.y)*0.5;
        }
        else {
            mx = (nextPt.x - curPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5;
        }
        
        CGPoint ctrlPt1;
        ctrlPt1.x = curPt.x + mx / 3.0;
        ctrlPt1.y = curPt.y + my / 3.0;
        
        curPt = lines[nextii].firstPoint;
        nextii = (nextii+1)%[lines count];
        previi = i;
        
        prevPt = lines[previi].firstPoint;
        nextPt = lines[nextii].firstPoint;
        
        if (i < nCurves-1) {
            mx = (nextPt.x - curPt.x)*0.5 + (curPt.x - prevPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5 + (curPt.y - prevPt.y)*0.5;
        }
        else {
            mx = (curPt.x - prevPt.x)*0.5;
            my = (curPt.y - prevPt.y)*0.5;
        }
        
        CGPoint ctrlPt2;
        ctrlPt2.x = curPt.x - mx / 3.0;
        ctrlPt2.y = curPt.y - my / 3.0;
        [path addCurveToPoint:endPt controlPoint1:ctrlPt1 controlPoint2:ctrlPt2];
        [path addLineToPoint: lines[i+1].secondPoint];
//Bottom Lines
        curPt = line.secondPoint;
        
        nextii = (i+1)%[lines count];
        previi = (i-1 < 0 ? [lines count]-1 : i-1);
        
        prevPt = lines[previi].secondPoint;
        nextPt = lines[nextii].secondPoint;
        endPt = lines[i].secondPoint;
        
        if (i > 0) {
            mx = (nextPt.x - curPt.x)*0.5 + (curPt.x - prevPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5 + (curPt.y - prevPt.y)*0.5;
        }
        else {
            mx = (nextPt.x - curPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5;
        }
        
        ctrlPt1.x = curPt.x + mx / 3.0;
        ctrlPt1.y = curPt.y + my / 3.0;
        
        curPt = lines[nextii].secondPoint;
        nextii = (nextii+1)%[lines count];
        previi = i;
        
        prevPt = lines[previi].secondPoint;
        nextPt = lines[nextii].secondPoint;
        
        if (i < nCurves-1) {
            mx = (nextPt.x - curPt.x)*0.5 + (curPt.x - prevPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5 + (curPt.y - prevPt.y)*0.5;
        }
        else {
            mx = (curPt.x - prevPt.x)*0.5;
            my = (curPt.y - prevPt.y)*0.5;
        }
        
        ctrlPt2.x = curPt.x - mx / 3.0;
        ctrlPt2.y = curPt.y - my / 3.0;
        [path addCurveToPoint: endPt controlPoint1:ctrlPt2 controlPoint2:ctrlPt1];
        [path closePath];
        
        SegmentLayer* layer = [SegmentLayer segmentLayerWith: startPath : path : _coordinates[i].color : _coordinates[i+1].color : lines[i].firstPoint : lines[i+1].firstPoint];
        [self.segmentLayers addObject: layer];
    }
}

- (void) updateToCurrentPosition {
    PMVValue* startValue = self.values[0];
    if (_currentTime != 0) {
        for (int i=0; i<self.values.count; i++) {
            PMVValue* value = self.values[i];
            if (value.timestamp - startValue.timestamp >= _currentTime) {
                _currentSegmentIndex = i;
                break;
            }
        }
    }
}

- (void) drawToCurrent {
    path = [UIBezierPath bezierPath];
    for (int i=0; i<_currentSegmentIndex; i++) {
        [self drawSegment:i animated: NO];
    }
}

- (void) onUpdate: (NSTimer*) timer {
    if (_currentSegmentIndex >= self.values.count) {
        [self stop];
        return;
    }
    
    [self drawSegment: _currentSegmentIndex animated: YES];
    _currentSegmentIndex ++;
}

#pragma mark Main Drawing
- (void) drawSegment: (NSUInteger) index animated: (BOOL) animated {
    if ( self.segmentLayers == nil || self.segmentLayers.count == 0
        || index >= self.segmentLayers.count - 1 || index <= 0) {
        return;
    }
    
    [self.segmentLayers[index-1] showOn: self.layer animated: animated];
}

#pragma mark External Method

- (void) draw {
    _currentSegmentIndex = self.values.count;
    [self drawToCurrent];
}

- (void) start {
    if (_timer != nil) {
        [_timer invalidate];
    }
    
    _currentSegmentIndex = 0;
    if (self.values == nil || self.values.count == 0) {
        return;
    }
    
    [self initialize];
    self.playing = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 0.2f
                                                  target: self
                                                selector: @selector(onUpdate:)
                                                userInfo: nil
                                                 repeats: YES];
}

- (void) stop {
    if (_timer != nil) {
        [_timer invalidate];
    }
    self.playing = NO;
}

@end
