//
//  SFDocument.h
//  KRImport
//
//  Created by Michael Ilich on 12-03-15.
//  Copyright (c) 2012 Sarofax. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PVRTexture;

@interface SFDocument : NSDocument {
    
    IBOutlet NSPathCell *sourcePath;            // The FBX Source path selection widget
    IBOutlet NSPathCell *resultPath;            // The output folder destination path selection widget
    IBOutlet NSScrollView *fileListing;         // The scroll view displaying the output of the conversion operation
    IBOutlet NSTextView *filenameListing;       // The text view inside the above scroll view
    NSAttributedString *theContent;             // The string block to display in the text view
    
    IBOutlet NSTextField *tfPosX;               // export value for camera start X position in cm
    IBOutlet NSTextField *tfPosY;               // export value for camera start Y position in cm
    IBOutlet NSTextField *tfPosZ;               // export value for camera start Z position in cm
    IBOutlet NSTextField *tfTouchScale;         // export value for Touch scale in cm/s full screen width
    IBOutlet NSTextField *tfNearZ;              // export value for camera near Z extent
    IBOutlet NSTextField *tfFarZ;               // export value for camera far Z extent
    IBOutlet NSTextField *tfMinX;               // export value for camera minimum X boundary
    IBOutlet NSTextField *tfMaxX;               // export value for camera maximum X boundary
    IBOutlet NSTextField *tfMinZ;               // export value for camera minimum Z boundary
    IBOutlet NSTextField *tfMaxZ;               // export value for camera maximum Z boundary
    IBOutlet NSTextField *tfMap;                // export value for map filename
    IBOutlet NSTextField *tfMap2x;              // export value for retina map filename
    IBOutlet NSTextField *tfMapIpad;            // export value for iPad map filename

    PVRTexture *textureToConvert;               // TBD: converted texture asset in PVR format
}

@property (nonatomic, retain) IBOutlet NSScrollView *fileListing;
@property (nonatomic, retain) IBOutlet NSTextView *filenameListing;

- (IBAction)selectSource :(id)sender;
- (IBAction)selectResult :(id)sender;
- (IBAction)convertPushed:(id)sender;

@end