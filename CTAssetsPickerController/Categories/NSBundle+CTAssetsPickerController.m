/*
 
 MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "NSBundle+CTAssetsPickerController.h"
#import "CTAssetsPickerController.h"

@interface UIApplication (Extension)

+ (BOOL)isAppExtension;
+ (UIApplication *)safeSharedApplication;

@end

@interface NSObject (NSInvocation)

- (BOOL)performBoolSelector:(SEL)selector withParameters:(NSArray *)parameters;

@end

@implementation NSBundle (CTAssetsPickerController)

+ (NSBundle *)ctassetsPickerBundle
{
  static NSBundle *bundle;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    bundle = [NSBundle bundleWithPath:[NSBundle ctassetsPickerBundlePath]];
  });
  
  return bundle;
}

+ (NSString *)ctassetsPickerBundlePath
{
  static NSString *bundlePath;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSString *dir = [UIApplication isAppExtension] ? @"../../Frameworks/" : @"Frameworks/";
    bundlePath = [[NSBundle mainBundle] pathForResource:[dir stringByAppendingString:@"CTAssetsPicker"] ofType:@"framework"];
  });
  
  return bundlePath;
}

@end

@implementation UIApplication (Extension)

+ (BOOL)isAppExtension
{
  return [[self class] safeSharedApplication] == nil;
}

+ (UIApplication *)safeSharedApplication
{
  UIApplication *safeSharedApplication = nil;
  
  if ([UIApplication respondsToSelector:@selector(sharedApplication)]) {
    safeSharedApplication = [UIApplication performSelector:@selector(sharedApplication)];
  }
  if (!safeSharedApplication.delegate) {
    safeSharedApplication = nil;
  }
  
  return safeSharedApplication;
}

@end

@implementation NSObject (NSInvocation)

- (BOOL)performBoolSelector:(SEL)selector withParameters:(NSArray *)parameters
{
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[UIApplication class] instanceMethodSignatureForSelector:selector]];
  [invocation setTarget:self];
  [invocation setSelector:selector];
  for (NSUInteger idx = 0; idx < parameters.count; idx++) {
    id parameter = parameters[idx];
    [invocation setArgument:&parameter atIndex:(NSInteger)idx + 2]; // Plus 2 is needed because idx 0 = self and idx 1 = _cmd
  }
  [invocation invoke];
  BOOL returnValue;
  [invocation getReturnValue:&returnValue];
  return returnValue;
}

@end
