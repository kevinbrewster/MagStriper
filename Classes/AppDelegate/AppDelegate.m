//
//  AppDelegate.m
//  MagTool
//
//  Created by Kevin Brewster on 12/28/12.
//  Copyright (c) 2012 Kevin Brewster. All rights reserved.
//

#import "AppDelegate.h"
#import "ORSSerialPortManager.h"
#import "MSR206Device.h"
#import "ReadViewController.h"
#import "WriteViewController.h"
#import "EraseViewController.h"
#import "DuplicateViewController.h"
#import "SetupViewController.h"
#import "NSData+MagStripeEncode.h"

@interface AppDelegate ()
@property (strong,nonatomic) NSViewController *currentViewController;
@property (strong,nonatomic) NSView *viewControllerParentView;
@property (strong,nonatomic) NSMutableDictionary *viewControllers;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSDictionary *defaults = @{@"coercivity":@1, @"dataFormat":@"ISO", @"textFormat":@"ASCII"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
    self.viewControllers = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ORSSerialPortWasConnectedNotification:) name:@"ORSSerialPortWasConnected" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ORSSerialPortWasDisconnectedNotification:) name:@"ORSSerialPortWasDisconnected" object:nil];
    
    
    if (self.serialPortManager.availablePorts.count) {
        [self ORSSerialPortWasConnected:nil];
    } else{
        [self ORSSerialPortWasDisconnected:nil];
    }
    
}
- (void)setView:(NSString*)name
{
    if ([self.currentViewController view]) {
        if([self.currentViewController respondsToSelector:@selector(cancelAction:)]){
            [self.currentViewController performSelector:@selector(cancelAction:) withObject:nil];
        }
        [self.currentViewController.view removeFromSuperview];
    }
    
    NSString *viewControllerName = [NSString stringWithFormat:@"%@ViewController", name];
    if(!self.viewControllers[viewControllerName]){
        self.viewControllers[viewControllerName] = [[NSClassFromString(viewControllerName) alloc] init];
    }
    self.currentViewController = self.viewControllers[viewControllerName];
    
    
    [self.currentViewController.view setAutoresizingMask:NSViewMaxYMargin];
    [self.window.contentView addSubview:self.currentViewController.view];
    //[self.currentViewController.view setFrameOrigin:NSMakePoint(0, 0)];
    [self resizeWindowForContentSize: self.currentViewController.view.frame.size];
    
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"lastView"];
}
- (void)resizeWindowForContentSize:(NSSize) size {
    NSRect windowFrame = [self.window contentRectForFrameRect:self.window.frame];
    NSRect newWindowFrame = [self.window frameRectForContentRect:
                             NSMakeRect( NSMinX( windowFrame ), NSMaxY( windowFrame ) - size.height, size.width, size.height )];
    [self.window setFrame:newWindowFrame display:YES animate:self.window.isVisible];
}
- (void) ORSSerialPortWasConnected:(NSNotification *) notification
{
    if(!self.MSRDevice){
        ORSSerialPort *port = [self.serialPortManager.availablePorts lastObject];
        self.MSRDevice = [[MSR206Device alloc] initWithPort:port];
        
        // Enable all access to read/write/erase 
        for(NSToolbarItem *item in self.toolbar.items){
            if(![item.itemIdentifier isEqualToString:@"Setup"]){
                [item setEnabled:YES];
                [item setAutovalidates:YES];
            }
        }
        [[self.fileMenu itemWithTitle:@"File"] setEnabled:YES];
        
        NSString *defaultView = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastView"];
        if(!defaultView) defaultView = @"Read";
        
        [self.toolbar setSelectedItemIdentifier:defaultView];
        [self setView:defaultView];
    }
}
- (void) ORSSerialPortWasDisconnected:(NSNotification *) notification
{
    if(!self.MSRDevice || ![self.serialPortManager.availablePorts containsObject:self.MSRDevice.port]){
        self.MSRDevice = nil;
        
        // Disable all access to read/write/erase
        for(NSToolbarItem *item in self.toolbar.items){
            if(![item.itemIdentifier isEqualToString:@"Setup"]){
                [item setEnabled:NO];
                [item setAutovalidates:NO];
            }
        }
        [[self.fileMenu itemWithTitle:@"File"] setEnabled:NO];
        
        [self.toolbar setSelectedItemIdentifier:@"Setup"];
        [self setView:@"Setup"];
    }
}

#pragma mark IBActions

- (IBAction)toolbarItemPressed:(NSToolbarItem *)sender
{
    [self setView:sender.itemIdentifier];
}
- (IBAction)batchWriteFromFile:(id)sender
{
    //if(!self.MSRDevice) return;
    
    // Create and configure the panel.
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setMessage:@"Choose a text file with card data to write."];
    [panel setAllowedFileTypes:@[@"public.plain-text",@"public.comma-separated-values-text"]];
    [panel setAccessoryView:self.fileOptionsSelect];
    
    //[panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSNumber *track = [NSNumber numberWithInteger:self.fileOptionsSelect.selectedTag];
            if(track.intValue < 1 || track.intValue > 3) track = nil;
            
            [self setView:@"Write"];
            if([self.currentViewController respondsToSelector:@selector(writeFromURL:withTrack:)]){
                [self.currentViewController performSelector:@selector(writeFromURL:withTrack:) withObject:panel.URL withObject:track];
            }
        }
    }];
}
- (IBAction)batchReadToFile:(id)sender
{
    if(!self.MSRDevice) return;
    
    // Create and configure the panel.
    NSSavePanel* panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"Mag Stripe Data"];
    [panel setMessage:@"Choose a text file to store the read card data."];
    [panel setAccessoryView:self.fileOptionsSelect];
    
    //[panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSNumber *track = [NSNumber numberWithInteger:self.fileOptionsSelect.selectedTag];
            if(track.intValue < 1 || track.intValue > 3) track = nil;
            
            [self setView:@"Read"];
            if([self.currentViewController respondsToSelector:@selector(readToURL:withTrack:)]){
                [self.currentViewController performSelector:@selector(readToURL:withTrack:) withObject:panel.URL withObject:track];
            }
        }
    }];
}

- (IBAction)batchErase:(id)sender
{
    if(!self.MSRDevice) return;
    
    [self setView:@"Erase"];
    if([self.currentViewController respondsToSelector:@selector(batchErase)]){
        [self.currentViewController performSelector:@selector(batchErase)];
    }
}

@end
