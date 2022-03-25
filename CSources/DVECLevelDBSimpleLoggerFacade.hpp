// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#ifndef DVECLevelDBSimpleLoggerFacade_hpp
#define DVECLevelDBSimpleLoggerFacade_hpp

#import "leveldb/leveldb/env.h"
#import "DVECLevelDBLogger.h"

class DVECLevelDBSimpleLoggerFacade final : public leveldb::Logger {
public:
    explicit DVECLevelDBSimpleLoggerFacade(id<DVECLevelDBSimpleLogger> logger) : _logger(logger) {
    }

    ~DVECLevelDBSimpleLoggerFacade() override {
        _logger = nil;
    }

    void Logv(const char *format, std::va_list arguments) override {
        if (_logger == nil) {
            return;
        }

        NSString *stringFormat = [[NSString alloc] initWithBytesNoCopy:(void *)format
                                                                length:strlen(format)
                                                              encoding:NSUTF8StringEncoding
                                                          freeWhenDone:NO];
        NSString *message = [[NSString alloc] initWithFormat:stringFormat arguments:arguments];
        [_logger logMessage:message];
    }

private:
    __strong id<DVECLevelDBSimpleLogger> _logger;
};

#endif /* DVECLevelDBSimpleLoggerFacade_hpp */
