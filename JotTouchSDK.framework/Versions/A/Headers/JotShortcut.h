//
//  Shortcut.h
//  JotSDKLibrary
//
//  Created  on 11/19/12.
//  Copyright (c) 2012 Adonit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JotShortcut : NSObject

/*
 Defining the NSString `shortDescription` and `key` properties as `assign` is dangerous;
 they should be defined as `copy`, `strong`, or `retain` so that the string cannot be
 deallocated from underneath you.
 
 `assign` is for primitive types and for objects in the rare cases where you want to avoid
 retain cycles/strong reference cycles like you did here with the `target` property. When 
 an object-based property is defined as `assign`, assigning the property a value does not
 prolong the life of the object it points to. While that is the correct thing to do here
 with the `target`, it is entirely the wrong thing to do with an NSString property.
 
 The example code you've written in ViewController that creates the JotShortcuts works
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
 
 For that reason, these properties should be changed to `copy`.
 
 */

//@property (readwrite,assign) NSString *shortDescription;
//@property (readwrite,assign) NSString *key;

@property (readwrite,copy) NSString *shortDescription;
@property (readwrite,copy) NSString *key;

@property (readwrite) SEL selector;
@property (readwrite,assign) id target;
@property (readwrite) BOOL repeat;
@property (readwrite) NSTimeInterval repeatRate;
@property (readwrite) BOOL usableWhenStylusDepressed;
-(id)initWithShortDescription:(NSString *)shortDescription key:(NSString *)key target:(id)target selector:(SEL)selector;
-(id)initWithShortDescription:(NSString *)shortDescription key:(NSString *)key target:(id)target selector:(SEL)selector repeatRate:(NSTimeInterval)repeatRate;

-(id)initWithShortDescription:(NSString *)shortDescription key:(NSString *)key target:(id)target selector:(SEL)selector usableWithStylusDepressed:(BOOL)usableWhenStylusDepressed;
-(id)initWithShortDescription:(NSString *)shortDescription key:(NSString *)key target:(id)target selector:(SEL)selector repeatRate:(NSTimeInterval)repeatRate usableWithStylusDepressed:(BOOL)usableWhenStylusDepressed;;
-(void)start;
-(void)stop;
@end
