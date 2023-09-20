// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBIterator.h"
#import "DVECLevelDB+Internal.h"
#import "DVECLevelDBReadOptions+Internal.h"

@implementation DVECLevelDBIterator {
    leveldb::Iterator *_iterator;
}

- (instancetype)initWithLevelDB:(DVECLevelDB *)levelDB readOptions:(DVECLevelDBReadOptions *)readOptions {
    if (self = [super init]) {
        _iterator = levelDB.db->NewIterator(*(readOptions.options));
    }
    return self;
}

- (void)dealloc {
    delete _iterator;
    _iterator = nil;
}

- (BOOL)isValid {
    return _iterator->Valid();
}

- (void)seekToFirstEntry {
    _iterator->SeekToFirst();
}

- (void)seekToLastEntry {
    _iterator->SeekToLast();
}

- (void)seekToNextEntry {
    _iterator->Next();
}

- (void)seekToPreviousEntry {
    _iterator->Prev();
}

- (void)seekToKey:(NSData *)key {
    leveldb::Slice target = sliceForData(key);
    _iterator->Seek(target);
}

- (NSData *)currentKey {
    leveldb::Slice key = _iterator->key();
    return [NSData dataWithData:dataForSlice(key)];
}

- (NSData *)currentValue {
    leveldb::Slice value = _iterator->value();
    return [NSData dataWithData:dataForSlice(value)];
}

@end
