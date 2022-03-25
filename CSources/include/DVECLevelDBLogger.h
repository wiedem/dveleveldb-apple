// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DVECLevelDBLogBlock)();

NS_SWIFT_NAME(CLevelDB.FormatLogger)
@protocol DVECLevelDBFormatLogger <NSObject>
- (void)logWithFormat:(NSString *)format arguments:(va_list)arguments;
@end

NS_SWIFT_NAME(CLevelDB.Logger)
@protocol DVECLevelDBSimpleLogger <NSObject>
- (void)logMessage:(NSString *)message;
@end

NS_SWIFT_NAME(CLevelDB.SystemLogger)
@interface DVECLevelDBSystemLogger: NSObject<DVECLevelDBFormatLogger>
@end

NS_SWIFT_NAME(CLevelDB.VoidLogger)
__attribute__((objc_subclassing_restricted))
@interface DVECLevelDBVoidLogger: NSObject<DVECLevelDBFormatLogger, DVECLevelDBSimpleLogger>
@end

NS_ASSUME_NONNULL_END
