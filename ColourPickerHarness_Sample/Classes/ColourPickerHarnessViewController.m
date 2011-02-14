//
//  ColourPickerHarnessViewController.m
//  ColourPickerHarness
//
//  Created by bunnyhero on 27/04/09.
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

#import "ColourPickerHarnessViewController.h"
#import "BHColourPickerController.h"
#import "BHColourPickerControllerDelegate.h"

@implementation ColourPickerHarnessViewController

@synthesize showButton;

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [showButton release];
    [super dealloc];
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


- (IBAction)showColourPicker:(id)sender {
    //  since it has 'new' in the method name, you own it...
    BHColourPickerController *vc = [BHColourPickerController newColourPickerController];
    vc.delegate = self;
    vc.colour = self.view.backgroundColor;
    vc.titleText = @"Some kind of title";
    [self presentModalViewController:vc animated:YES];
    [vc release];   //  ...and must release it
}

- (void)colourPickerControllerDidCancel:(BHColourPickerController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)colourPickerController:(BHColourPickerController *)controller didFinishPickingColour:(UIColor *)colour
{
    self.view.backgroundColor = colour;
    [self dismissModalViewControllerAnimated:YES];
}
@end
