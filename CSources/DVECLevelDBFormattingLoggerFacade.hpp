// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#ifndef DVECLevelDBLoggerFacade_hpp
#define DVECLevelDBLoggerFacade_hpp

#import "leveldb/leveldb/env.h"
#import "DVECLevelDBLogger.h"

class DVECLevelDBFormattingLoggerFacade final : public leveldb::Logger {
public:
    explicit DVECLevelDBFormattingLoggerFacade(id<DVECLevelDBFormatLogger> logger) : _logger(logger) {
    }

    ~DVECLevelDBFormattingLoggerFacade() override {
        _logger = nil;
    }

    void Logv(const char *format, std::va_list arguments) override {
        if (_logger == nil) {
            return;
        }

        NSString *stringFormat = [NSString stringWithCString:format encoding:NSUTF8StringEncoding];
        [_logger logWithFormat:stringFormat arguments:arguments];
    }

private:
    __strong id<DVECLevelDBFormatLogger> _logger;
};

#endif /* DVECLevelDBLoggerFacade_hpp */
