//
//  ESCodeSection.h
//  ESCodeSection
//
//  Created by Elf Sundae on 2016/05/27.
//  Copyright © 2016年 Elf Sundae. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface ESCodeSection : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end