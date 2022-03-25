// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBKeyEnumerator.h"
#import "DVECLevelDB+Internal.h"
#import "DVECLevelDBReadOptions+Internal.h"
#import "leveldb/leveldb/db.h"

@implementation DVECLevelDBKeyEnumerator {
    BOOL _reverse;
    DVECLevelDB *_levelDB;
    leveldb::Iterator *_iterator;
}

- (instancetype)initWithDB:(DVECLevelDB *)levelDB reverse:(BOOL)reverse options:(DVECLevelDBReadOptions *)options {
    if (self = [super init]) {
        _levelDB = levelDB;
        _reverse = reverse;
        _iterator = _levelDB.db->NewIterator(*(options.options));

        if (reverse == NO) {
            _iterator->SeekToFirst();
        } else {
            _iterator->SeekToLast();
        }
    }
    return self;
}

- (void)dealloc {
    delete _iterator;
    _iterator = nil;
}

- (nullable NSString *)nextObject {
    if (_iterator->Valid() == false) {
        return nil;
    }
    leveldb::Slice keySlice = _iterator->key();

    if (_reverse == NO) {
        _iterator->Next();
    } else {
        _iterator->Prev();
    }

    return [[NSString alloc] initWithBytes:keySlice.data() length:keySlice.size() encoding:NSUTF8StringEncoding];
}

@end
