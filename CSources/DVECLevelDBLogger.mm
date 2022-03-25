// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBLogger.h"

@implementation DVECLevelDBSystemLogger

- (void)logWithFormat:(NSString *)format arguments:(va_list)arguments {
    NSLogv(format, arguments);
}

@end

#pragma mark -
@implementation DVECLevelDBVoidLogger

- (void)logWithFormat:(NSString *)format arguments:(va_list)arguments {}
- (void)logMessage:(nonnull NSString *)message {}

@end
