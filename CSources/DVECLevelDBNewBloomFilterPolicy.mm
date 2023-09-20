// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBFilterPolicy.h"
#import "DVECLevelDB+Internal.h"
#import "leveldb/leveldb/slice.h"
#import "leveldb/leveldb/filter_policy.h"
#import <vector>

@interface DVECLevelDBNewBloomFilterPolicy()
@property (nonatomic, assign) leveldb::FilterPolicy const *filterPolicy;
@end

@implementation DVECLevelDBNewBloomFilterPolicy

- (instancetype)initWithBitsPerKey:(int)bitsPerKey {
    if (self = [super init]) {
        _filterPolicy = leveldb::NewBloomFilterPolicy(bitsPerKey);
    }
    return self;
}

- (void)dealloc {
    delete _filterPolicy;
    _filterPolicy = nil;
}

- (NSString *)name {
    return [NSString stringWithUTF8String:_filterPolicy->Name()];
}

- (NSData *)createFilterForKeys:(NSArray<NSData *> *)keys currentFilter:(NSData *)currentFilter {
    std::vector<leveldb::Slice> keysSlices;
    for (NSData *key in keys) {
        leveldb::Slice keySlice((const char *)key.bytes, key.length);
        keysSlices.push_back(keySlice);
    }
    
    std::string dst((const char *)currentFilter.bytes, currentFilter.length);
    NSInteger oldLength = dst.length();
    _filterPolicy->CreateFilter(keysSlices.data(), (int)keys.count, &dst);

    if (dst.length() > oldLength) {
        std::string addedStr = dst.substr(oldLength, dst.length() - oldLength);
        return [NSData dataWithBytes:addedStr.data() length:addedStr.size()];
    } else {
        return currentFilter;
    }
}

- (BOOL)keyMayMatch:(NSData *)key filter:(NSData *)filter {
    leveldb::Slice keySlice = sliceForData(key);
    leveldb::Slice filterSlice = sliceForData(filter);
    return _filterPolicy->KeyMayMatch(keySlice, filterSlice);
}

@end
