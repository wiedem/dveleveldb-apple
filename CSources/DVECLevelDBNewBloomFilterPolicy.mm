// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDBFilterPolicy.h"
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

- (NSData *)createFilterForKeys:(NSArray<NSString *> *)keys currentFilter:(NSData *)currentFilter {
    std::vector<leveldb::Slice> keysSlices;
    for (NSString *key in keys) {
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        leveldb::Slice keySlice((const char *)keyData.bytes, keyData.length);
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

- (BOOL)keyMayMatch:(NSString *)key filter:(NSString *)filter {
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    leveldb::Slice keySlice((const char *)keyData.bytes, keyData.length);

    NSData *filterData = [filter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    leveldb::Slice filterSlice((const char *)filterData.bytes, filterData.length);

    return _filterPolicy->KeyMayMatch(keySlice, filterSlice);
}

@end
