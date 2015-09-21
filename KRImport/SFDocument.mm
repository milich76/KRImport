//
//  SFDocument.m
//  KRImport
//
//  Created by Michael Ilich on 12-03-15.
//  Copyright (c) 2012 Sarofax. All rights reserved.
//

#import "SFDocument.h"
//#import "PVRTexture.h"

#import <stdint.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <vector.h>

#import <kraken/KRVector2.h>
#import <kraken/KRVector3.h>
#import <kraken/KRMesh.h>
#import <kraken/KRContext.h>
#import <kraken/KRBundle.h>

@implementation SFDocument

@synthesize fileListing, filenameListing;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
        
        [sourcePath setURL:[NSURL URLWithString:NSHomeDirectory()]];
        [resultPath setURL:[NSURL URLWithString:NSHomeDirectory()]];
                
        theContent = [[NSAttributedString alloc] initWithString:@""];
    }
    return self;
}


- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"SFDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    */
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    /*
    Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    */
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return TRUE;
}

- (IBAction)selectSource:(id)sender
{
    // Create a File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    	 
    // Set array of file types
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"fbx", nil];
    	 
    // Enable options in the dialog.
    [openDlg setDirectoryURL:sourcePath.URL];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowedFileTypes:fileTypesArray];
    [openDlg setAllowsMultipleSelection:NO];
     
    // Display the dialog box.  If the OK pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton ) {
        
        // Gets list of all files selected
        NSArray *files = [openDlg URLs];
        [sourcePath setURL:[NSURL URLWithString:[[files objectAtIndex:0] path]]];
        
    }
}

- (IBAction)selectResult:(id)sender
{
    // Create a File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable options in the dialog.
    [openDlg setDirectoryURL:resultPath.URL];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanCreateDirectories:YES];
    
    // Display the dialog box.  If the OK pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton ) {
        
        // Gets list of all files selected
        NSArray *files = [openDlg URLs];
        [resultPath setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/",[[files objectAtIndex:0] path]]]];
            
    } // end if
}

- (void) alertDidEnd:(NSAlert *) alert returnCode:(int) returnCode contextInfo:(int *) contextInfo
{
    switch (returnCode) {
        case 1001:
        {
            theContent = [[NSAttributedString alloc] initWithString:@""];
            [[filenameListing textStorage] setAttributedString:theContent];

            std::string path = [[[sourcePath URL] resourceSpecifier] UTF8String];
            std::string rzPath = [[[resultPath URL] resourceSpecifier] UTF8String];            
            
            std::string base_path = KRResource::GetFilePath(path);
            std::string out_path = KRResource::GetFilePath(rzPath);
            KRContext context = KRContext();
            context.loadResource(path);
            
            std::vector<KRResource *> resources = context.getResources();
            
            // Compress textures to PVR format
            context.getTextureManager()->compress(); // TODO, HACK, FINDME - This should be configurable and exposed through the World Builder GUI
            
            std::string base_name = KRResource::GetFileBase(path);
            std::vector<KRResource *> output_resources;
            
            //    KRBundle *main_bundle = new KRBundle(context, base_name);
            KRBundle *texture_bundle = new KRBundle(context, base_name + "_textures");
            KRBundle *animation_bundle = new KRBundle(context, base_name + "_animations");
            KRBundle *material_bundle = new KRBundle(context, base_name + "_materials");
            KRBundle *meshes_bundle = new KRBundle(context, base_name + "_meshes");
            
            for(std::vector<KRResource *>::iterator resource_itr=resources.begin(); resource_itr != resources.end(); resource_itr++) {
                KRResource *resource = *resource_itr;
                if(dynamic_cast<KRTexture *>(resource) != NULL) {
                    texture_bundle->append(*resource);
                } else if(dynamic_cast<KRAnimation *>(resource) != NULL) {
                    animation_bundle->append(*resource);
                } else if(dynamic_cast<KRAnimationCurve *>(resource) != NULL) {
                    animation_bundle->append(*resource);
                } else if(dynamic_cast<KRMaterial *>(resource) != NULL) {
                    material_bundle->append(*resource);
                } else if(dynamic_cast<KRMesh *>(resource) != NULL) {
                    meshes_bundle->append(*resource);
                } else {
                    output_resources.push_back(resource);
                    //            main_bundle->append(*resource);
                }
            }
            
            output_resources.push_back(texture_bundle);
            output_resources.push_back(animation_bundle);
            output_resources.push_back(material_bundle);
            output_resources.push_back(meshes_bundle);
            
            //    main_bundle->append(texture_bundle);
            //    main_bundle->append(animation_bundle);
            //    main_bundle->append(material_bundle);
            //    main_bundle->append(meshes_bundle);
            //    output_resources.push_back(main_bundle);            
            
            try {    
                for(vector<KRResource *>::iterator resource_itr = output_resources.begin(); resource_itr != output_resources.end(); resource_itr++) {
                    KRResource *pResource = (*resource_itr);
                    std::string out_file_name = out_path;
                    out_file_name.append("/");
                    out_file_name.append(pResource->getName());
                    out_file_name.append(".");
                    out_file_name.append(pResource->getExtension());                    
                    theContent = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nWriting %@ ...",[theContent string],[NSString stringWithUTF8String:out_file_name.c_str()]]];
                    [[filenameListing textStorage] setAttributedString:theContent];
                    
                    if(pResource->save(out_file_name)) {
                        theContent = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ SUCCESS!",[theContent string]]];
                        [[filenameListing textStorage] setAttributedString:theContent];
                        
                    } else {
                        theContent = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ FAIL",[theContent string]]];
                        [[filenameListing textStorage] setAttributedString:theContent];
                    }
                }
            } catch(...) {
                delete texture_bundle;
                delete animation_bundle;
                delete material_bundle;
                delete meshes_bundle;
                throw;
            }
            delete texture_bundle;
            delete animation_bundle;
            delete material_bundle;
            delete meshes_bundle;

//            NSString *uiContent = [NSString stringWithFormat:@"startPos %@ %@ %@\ntouchScale %@\nnearZ %@\nfarZ %@\nminX %@\nmaxX %@\nminZ %@\nmaxZ %@\nmap %@\nmap@2x %@\nmapiPad %@\n",tfPosX.stringValue,tfPosY.stringValue,tfPosZ.stringValue,tfTouchScale.stringValue,tfNearZ.stringValue,tfFarZ.stringValue,tfMinX.stringValue,tfMaxX.stringValue,tfMinZ.stringValue,tfMaxZ.stringValue,tfMap.stringValue,tfMap2x.stringValue,tfMapIpad.stringValue];
//            [uiContent writeToFile:[NSString stringWithFormat:@"%@KRMesh.ui",[resultPath stringValue]] atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
            
        }           
            break;
        case 1000:
        {
            NSLog(@"Not processing queue.");
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)convertPushed:(id)sender
{
    
    if ([[sourcePath stringValue] hasSuffix:@".fbx"] || [[sourcePath stringValue] hasSuffix:@".FBX"]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Yes"];
        [alert setMessageText:@"Process the queue?"];
        [alert setInformativeText:[NSString stringWithFormat:@"Do you want to process %@ and output to %@?",[sourcePath stringValue], [resultPath stringValue]]];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:[fileListing window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil]; 
        
    }    
    else {
        theContent = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Please Choose a valid FBX!"]];
        [[filenameListing textStorage] setAttributedString:theContent];
    }
}

+ (BOOL)autosavesInPlace
{
    return TRUE;
}

@end