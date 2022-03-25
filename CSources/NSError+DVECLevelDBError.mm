// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBError.h"
#import "leveldb/leveldb/status.h"

NSString *const DVECLevelDBErrorDomain = @"com.diva-e.LevelDB.ErrorDomain";
NSString *const DVECLevelDBException = @"com.diva-e.LevelDB.Exception";

@implementation NSError(DVECLevelDBError)

+ (instancetype)createFromLevelDBStatus:(leveldb::Status)status {
    if (status.ok()) {
        return nil;
    }

    NSInteger errorCode = DVECLevelDBErrorUnknownError;

    if (status.IsNotFound()) {
        errorCode = DVECLevelDBErrorNotFound;
    } else if (status.IsCorruption()) {
        errorCode = DVECLevelDBErrorCorruptedData;
    } else if (status.IsIOError()) {
        errorCode = DVECLevelDBErrorIOError;
    } else if (status.IsNotSupportedError()) {
        errorCode = DVECLevelDBErrorNotSupported;
    } else if (status.IsInvalidArgument()) {
        errorCode = DVECLevelDBErrorInvalidArgument;
    }

    NSDictionary<NSErrorUserInfoKey, id> *userInfo = @{
        NSDebugDescriptionErrorKey: [NSString stringWithUTF8String:status.ToString().c_str()]
    };

    return [NSError errorWithDomain:DVECLevelDBErrorDomain
                               code:errorCode
                           userInfo:userInfo];
}

@end

