//
//  ESCodeSection.m
//  ESCodeSection
//
//  Created by Elf Sundae on 2016/05/27.
//  Copyright © 2016年 Elf Sundae. All rights reserved.
//

#import "ESCodeSection.h"

static ESCodeSection *sharedPlugin;

@implementation ESCodeSection

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidFinishLaunching:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
        } else {
            [self initializeAndLog];
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [self initializeAndLog];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
}

#pragma mark - Helper

/**
 * Returns the current actived Xcode source editor.
 */
- (NSTextView *)currentSourceEditor
{
    NSTextView *editor = nil;
    NSResponder *firstResponder = [NSApp keyWindow].firstResponder;
    if ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")]) {
        editor = (NSTextView *)firstResponder;
    }
    if (!editor) {
        NSBeep();
    }

    return editor;
}

#pragma mark - Implementation

- (BOOL)initialize
{
    // Create menu items, initialize UI, etc.
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];

        NSMenuItem *codeSeparatorMenuItem = [[NSMenuItem alloc] initWithTitle:@"Insert Code Separator..."
                                                                       action:@selector(codeSeparatorAction:)
                                                                keyEquivalent:@"m"];
        [codeSeparatorMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
        [codeSeparatorMenuItem setTarget:self];
        [[editMenuItem submenu] addItem:codeSeparatorMenuItem];

        NSMenuItem *nameItem = [[NSMenuItem alloc] initWithTitle:@"Insert @name section..."
                                                          action:@selector(insertNameSectionAction:)
                                                   keyEquivalent:@"m"];
        [nameItem setKeyEquivalentModifierMask:NSControlKeyMask | NSShiftKeyMask];
        [nameItem setTarget:self];
        [[editMenuItem submenu] addItem:nameItem];

        return YES;
    } else {
        return NO;
    }
}

- (void)codeSeparatorAction:(id)sender
{
    NSTextView *sourceEditor = [self currentSourceEditor];
    if (!sourceEditor)
        return;

    [sourceEditor.undoManager beginUndoGrouping];
    [sourceEditor insertText:
     @"////////////////////////////////////////////////////////////////////////////////////////////////////\n"
     @"////////////////////////////////////////////////////////////////////////////////////////////////////\n"
     @"#pragma mark - "
            replacementRange:sourceEditor.selectedRange];
    [sourceEditor.undoManager endUndoGrouping];
}

- (void)insertNameSectionAction:(id)sender
{
    NSTextView *sourceEditor = [self currentSourceEditor];
    if (!sourceEditor)
        return;

    [sourceEditor.undoManager beginUndoGrouping];
    [sourceEditor insertText:
     @"///=============================================\n"
     @"/// @name "
            replacementRange:sourceEditor.selectedRange];
    NSUInteger location = sourceEditor.selectedRange.location;
    [sourceEditor insertText:@"\n"
     @"///=============================================\n"
            replacementRange:sourceEditor.selectedRange];
    sourceEditor.selectedRange = NSMakeRange(location, 0);
    [sourceEditor.undoManager endUndoGrouping];
}

@end
