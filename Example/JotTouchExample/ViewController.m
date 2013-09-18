//
//  ViewController.m
//  JotTouchExample
//
//  Created by Adam Wulf on 12/8/12.
//  Copyright (c) 2012 Adonit. All rights reserved.
//

#import "ViewController.h"


@interface ViewController(){
    JotStylusManager* jotManager;
    UIPinchGestureRecognizer* pinchGesture;
}

@end


@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    jotManager = [JotStylusManager sharedInstance];
    
    [jotManager addShortcutOptionButton1Default: [[JotShortcut alloc]
                                    initWithShortDescription:@"Undo"
                                    key:@"undo"
                                    target:canvasView selector:@selector(undo)
                                    repeatRate:100]];
    
    [jotManager addShortcutOptionButton2Default: [[JotShortcut alloc]
                                    initWithShortDescription:@"Redo"
                                    key:@"redo"
                                    target:canvasView selector:@selector(redo)
                                    repeatRate:100]];
    
    [jotManager addShortcutOption: [[JotShortcut alloc]
                                    initWithShortDescription:@"No Action"
                                    key:@"noaction"
                                    target:nil selector:@selector(decreaseStrokeWidth)
                                    repeatRate:100]];
    

	/* The following code demonstrates the problem with defining JotShortcut's
	 `shortDescription` and `key` properties as `assign`.
    
	 Defining the NSString `shortDescription` and `key` properties as `assign` is dangerous;
	 they should be defined as `copy`, `strong`, or `retain` so that the string cannot be
	 deallocated from underneath you.
	 
	 The example code you've written in ViewController above that creates the JotShortcuts works
	 just fine (out of pure luck) because of an implementation detail: when you use the @ sign
	 to create an NSString literal, it creates an instance of a special type of NSString,
	 __NSCFConstantString, that is allocated immediately at runtime and can never be
	 deallocated. Take the following code for example:
	 
		 [jotManager addShortcutOptionButton2Default: [[JotShortcut alloc]
										initWithShortDescription:@"Redo"
										key:@"redo"
										target:canvasView selector:@selector(redo)
										repeatRate:100]];

	 The strings @"Redo" and @"redo" are created at application launch and will persist
	 indefinitely until the program terminates: they can never and will never be deallocated. For that
	 reason, in this particular context, your implementation "works" fine. But imagine a developer
	 doing something like in the following code:
	 
	 
		for (NSUInteger i = 0; i < 10; i++) {
			JotShortcut *shortcut = [[JotShortcut alloc] initWithShortDescription:[NSString stringWithFormat:@"Set Color %lu", (unsigned long)i]
																			  key:[NSString stringWithFormat:@"setColor%lu", (unsigned long)i]
																		   target:nil
																		 selector:NSSelectorFromString([NSString stringWithFormat:@"setColor%lu", (unsigned long)i])
																	   repeatRate:100.0];
			if (shortcut) [jotManager addShortcutOption:shortcut];
			
		}

	 While perhaps a contrived example, this is perfectly legal code that your SDK ought to be able to handle.
	 
	 Under ARC, NSString's +stringWithFormat: will be creating "ordinary" NSStrings which differ from the
	 special __NSCFConstantString string literals created using the @ construct: they can and will be
	 released (and subsequently deallocated) unless you specify otherwise. By specifying that JotShortcut's
	 `shortDescription` and `key` properties be `assign` in nature, creating the JotShortcut object will not
	 cause the strings to be retained, and the strings will be released (and deallocated) at the end of each
	 time through the loop. You're left with 10 shortcut objects which have 2 invalid pointers each. Any attempt
	 to subsequently access the `shortDescription` or `key` properties elsewhere in your code will likely cause
	 a crash or unexpected behavior.
	 
	 Under MRC, NSString's +stringWithFormat: will be creating autoreleased strings, which, because you
	 defined the `shortDescription` and `key` properties as `assign`, will not be retained by the
	 JotShortcut object, and any attempt to access them at a later time (after the autorelease pool
	 has been popped) will equate to an attempt to access a dangling pointer, likely causing a crash.
	 
	 Thus, unless it is commented out, the following code will likely cause a crash due to trying to send a 
	 message to a deallocated object. */
	
	for (NSUInteger i = 0; i < 10; i++) {
		JotShortcut *shortcut = [[JotShortcut alloc] initWithShortDescription:[NSString stringWithFormat:@"Set Color %lu", (unsigned long)i]
																		  key:[NSString stringWithFormat:@"setColor%lu", (unsigned long)i]
																	   target:nil
																	 selector:NSSelectorFromString([NSString stringWithFormat:@"setColor%lu", (unsigned long)i])
																   repeatRate:100.0];
		if (shortcut) [jotManager addShortcutOption:shortcut];
	}

    
    jotManager.unconnectedPressure = 0;
    jotManager.palmRejectorDelegate = canvasView;
    
    jotManager.rejectMode = NO;
    jotManager.enabled = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector(connectionChange:)
                                                 name: JotStylusManagerDidChangeConnectionStatus
                                               object:nil];
    
    //
    // This gesture tests to see how the Jot SDK handles
    // gestures that are added to the drawing view
    //
    // We'll test a pinch gesture, which could be used for
    // pinch to zoom
    
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [canvasView addGestureRecognizer:pinchGesture];
    
}

-(void)connectionChange:(NSNotification *) note
{
    NSString *text;
    switch(jotManager.connectionStatus)
    {
        case JotConnectionStatusOff:
            text = @"Off";
            break;
        case JotConnectionStatusScanning:
            text = @"Scanning";
            break;
        case JotConnectionStatusPairing:
            text = @"Pairing";
            break;
        case JotConnectionStatusConnected:
            text = @"Connected";
            break;
        case JotConnectionStatusDisconnected:
            text = @"Disconnected";
            break;
        default:
            text = @"";
            break;
    }
    [settingsButton setTitle: text forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction

-(IBAction) showSettings:(id)sender{
    JotSettingsViewController* settings = [[JotSettingsViewController alloc] initWithOnOffSwitch: NO];
    if(popoverController){
        [popoverController dismissPopoverAnimated:NO];
    }
    popoverController = [[UIPopoverController alloc] initWithContentViewController:settings];
    [popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [popoverController setPopoverContentSize:CGSizeMake(300, 400) animated:NO];
}

#pragma mark - UIPopoverControllerDelegate

-(void) popoverControllerDidDismissPopover:(UIPopoverController *)_popoverController{
    popoverController = nil;
}


#pragma mark - Gesture Logs

-(IBAction) clear{
    logTextView.text = @"";
    [canvasView clear];
}

-(IBAction) toggleLogView{
    logView.hidden = !logView.hidden;
}

-(void) log:(NSString*) logLine{
    logTextView.text = [logTextView.text stringByAppendingFormat:@"%@\n", logLine];
    
    if(logTextView.contentSize.height > logTextView.bounds.size.height){
        logTextView.contentOffset = CGPointMake(0, logTextView.contentSize.height - logTextView.bounds.size.height);
    }
}

-(void)jotSuggestsToDisableGestures{
    // disable any other gestures, like a pinch to zoom
    [self log:@"Jot suggests to DISABLE gestures"];
    pinchGesture.enabled = NO;
}
-(void)jotSuggestsToEnableGestures{
    // enable any other gestures, like a pinch to zoom
    [self log:@"Jot suggests to ENABLE gestures"];
    pinchGesture.enabled = YES;
}
-(void) pinch:(UIPinchGestureRecognizer*)_pinchGesture{
    if(pinchGesture.state == UIGestureRecognizerStateBegan){
        [self log:@"Pinch Gesture Began"];
    }else if(pinchGesture.state == UIGestureRecognizerStateEnded){
        [self log:@"Pinch Gesture Ended"];
    }else if(pinchGesture.state == UIGestureRecognizerStateCancelled){
        [self log:@"Pinch Gesture Cancelled"];
    }
}

@end
