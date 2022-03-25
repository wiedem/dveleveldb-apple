// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(CLevelDB.ErrorDomain)
FOUNDATION_EXPORT NSErrorDomain const DVECLevelDBErrorDomain;

NS_SWIFT_NAME(CLevelDB.Exception)
FOUNDATION_EXPORT NSExceptionName const DVECLevelDBException;

typedef NS_ERROR_ENUM(DVECLevelDBErrorDomain, DVECLevelDBError) {
    DVECLevelDBErrorUnknownError = 0,
    DVECLevelDBErrorNotFound = 1,
    DVECLevelDBErrorCorruptedData = 2,
    DVECLevelDBErrorIOError = 3,
    DVECLevelDBErrorNotSupported = 4,
    DVECLevelDBErrorInvalidArgument = 5,
    DVECLevelDBErrorInvalidType = 6
} NS_SWIFT_NAME(CLevelDB.Error);
