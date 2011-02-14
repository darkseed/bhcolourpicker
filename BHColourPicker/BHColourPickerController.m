//
//  BHColourPickerViewController.m
//  ColourPickerHarness
//
//  Created by bunnyhero on 10/05/09.
/*
 Copyright (c) 2009, BUNNYHERO LABS
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
 * Neither the name of BUNNYHERO LABS nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
*/

#import "BHColourPickerController.h"
#import "BHColourPickerControllerDelegate.h"
#import "BHColourPickerUtil.h"
#import "BHBlackCircleView.h"

#define WIDTH 280
#define HEIGHT 280

//  private category
@interface BHColourPickerController ()

- (void)makeColourWheel;
- (BOOL)getRgbAlphaAtPoint:(CGPoint)point value:(float)value rgb:(RedGreenBlue *)rgb alpha:(float *)alpha;
- (BOOL)isInColourWheel:(CGPoint)globalPoint;
- (BOOL)updateWithTouch:(UITouch *)touch;
- (void)updateColourFromControls;

@end

@implementation BHColourPickerController

@synthesize colourWheel;
@synthesize blackCircleView;
@synthesize valueSlider;
@synthesize colourView;
@synthesize cursorView;
@synthesize doneButton;
@synthesize cancelButton;
@synthesize delegate;
@synthesize colour;
@synthesize menuAndTitle;
@dynamic title;




//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [colourWheel release];
    [blackCircleView release];
    [valueSlider release];
    [colourView release];
    [doneButton release];
    [cancelButton release];
    [cursorView release];
    [colour release];
    [delegate release];
    [titleText release];
    if (data)
        free(data);
    [super dealloc];
}


+ (BHColourPickerController *)newColourPickerController    //  using default nib name
{
    return [[BHColourPickerController alloc] initWithNibName:@"BHColourPickerViewController"
                                                      bundle:nil];
}


/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if (titleText)
        menuAndTitle.title = titleText;
    [self makeColourWheel];
    //  set the initial colour and position of the cursor
    if (colour) {
        colourView.backgroundColor = colour;
        CGColorRef cgColour = colour.CGColor;
        //  we only handle rgb
        CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(cgColour));
        if (model != kCGColorSpaceModelRGB) {
            NSLog(@"not rgb colourspace, %d", model);
            return;
        }
        
        const CGFloat *components = CGColorGetComponents(cgColour);
        RedGreenBlue rgb = { components[0], components[1], components[2] };
        HueSaturationValue hsv = [BHColourPickerUtil hueSaturationValueFromRedGreenBlue:rgb];
        valueSlider.value = hsv.value;
        colourWheel.alpha = hsv.value;
        float radius = WIDTH/2;
        CGFloat x = colourWheel.center.x + cos(hsv.hue * M_PI/180.0) * hsv.saturation * radius;
        CGFloat y = colourWheel.center.y + sin(hsv.hue * M_PI/180.0) * hsv.saturation * radius;
        cursorView.center = CGPointMake(x, y);
    }
}



/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (NSString *)titleText
{
    return titleText;
}

- (void)setTitleText:(NSString *)aTitle
{
    menuAndTitle.title = aTitle;
    if (aTitle != titleText) {
        [titleText release];
        titleText = [aTitle retain];
    }
}

- (BOOL)getRgbAlphaAtPoint:(CGPoint)point value:(float)value rgb:(RedGreenBlue *)rgb alpha:(float *)alpha
{
    float radius = WIDTH / 2;
    float centreX = WIDTH / 2;
    float centreY = HEIGHT / 2;

    float deltaX = point.x - centreX;
    float deltaY = point.y - centreY;
    float distSquared = deltaX * deltaX + deltaY * deltaY;
    
    if (distSquared > radius * radius) {
        return NO;
    }
    else {
        //  the distance is the saturation.
        float dist = sqrtf(distSquared);
        HueSaturationValue hsv;
        hsv.saturation = dist/radius;
        hsv.value = value;
        hsv.hue = atan2f(deltaY, deltaX) * 180.0f / M_PI;
        if (rgb)
            *rgb = [BHColourPickerUtil redGreenBlueFromHueSaturationValue:hsv];
        //  calc alpha if it's less than a pixel from the edge!
        if (alpha)
            *alpha = fabs(dist - radius) < 1.0f ? fabs(dist - radius) : 1.0f;
        return YES;
    }
}



- (void)makeColourWheel {
    if (data == NULL) {
        //  the pixels!
        data = (unsigned int *)malloc(WIDTH * HEIGHT * 4);
        //  fill it! this is where we do the good stuff
                
        unsigned int *p = data;
        for (int y=0; y < WIDTH; y++) {
            float yy = (float)y;
            for (int x=0; x < HEIGHT; x++, p++) {
                float xx = (float)x;
                RedGreenBlue rgb;
                float alpha;
                if ([self getRgbAlphaAtPoint:CGPointMake(xx, yy) value:1.0f rgb:&rgb alpha:&alpha]) {
                    *p = ((int)(alpha * 255.f) << 24) | ((int)(rgb.blue * 255.f) << 16)
                            | ((int)(rgb.green * 255.f) << 8) | ((int)(rgb.red * 255.f));
                }
                else {
                    *p = 0;
                }
            }
        }
        //  the data provider
        CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, data, WIDTH * HEIGHT * 4, NULL);
        //  colourspace
        CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGImageAlphaLast;
        CGImageRef image = CGImageCreate(WIDTH, HEIGHT, 8, 32, WIDTH * 4, colourSpace, bitmapInfo, dataProvider,
                                         NULL, FALSE, kCGRenderingIntentDefault);
        CGColorSpaceRelease(colourSpace);
        CGDataProviderRelease(dataProvider);
        //  HA, don't free the data, we'll need it to draw.
        //    free(data);
        UIImage *uiImage = [[UIImage alloc] initWithCGImage:image];
        colourWheel.image = uiImage;
        [uiImage release];
        CGImageRelease(image);
    }
}

- (void)updateColourFromControls
{
    CGPoint pos = [self.view convertPoint:cursorView.center toView:colourWheel];
    RedGreenBlue rgb;
    if ([self getRgbAlphaAtPoint:pos value:valueSlider.value rgb:&rgb alpha:NULL]) {
        UIColor *newColour = [[UIColor alloc] initWithRed:rgb.red green:rgb.green blue:rgb.blue alpha:1.0f];
        colourView.backgroundColor = newColour;
        self.colour = newColour;
        [newColour release];
    }
}

- (IBAction)sliderChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    colourWheel.alpha = slider.value;
    [self updateColourFromControls];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ( ! [self updateWithTouch:touch]) {
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ( ! [self updateWithTouch:touch]) {
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ( ! [self updateWithTouch:touch]) {
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
}


- (BOOL)updateWithTouch:(UITouch *)touch
{
    if (touch.view == colourWheel) {
        CGPoint pos = [touch locationInView:self.view];
        if ([self isInColourWheel:pos]) {
            cursorView.center = pos;
            [self updateColourFromControls];
            return YES;
        }
    }
    return NO;
}


- (BOOL)isInColourWheel:(CGPoint)globalPoint
{
    //  just checks to see if it's circle radius
    CGFloat dx = globalPoint.x - colourWheel.center.x;
    CGFloat dy = globalPoint.y - colourWheel.center.y;
    CGFloat deltaSquared = dx*dx + dy*dy;
    float radius = WIDTH / 2;
    return deltaSquared <= radius * radius;
}


- (IBAction)buttonClicked:(id)sender
{
    if (sender == cancelButton
            && delegate && [delegate respondsToSelector:@selector(colourPickerControllerDidCancel:)]) {
        [delegate colourPickerControllerDidCancel:self];
    }
    else if (sender == doneButton && delegate
            && [delegate respondsToSelector:@selector(colourPickerController:didFinishPickingColour:)]) {
        [delegate colourPickerController:self didFinishPickingColour:colour];
    }
}

@end
