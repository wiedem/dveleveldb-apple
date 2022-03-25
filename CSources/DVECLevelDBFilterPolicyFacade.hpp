// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#ifndef DVECLevelDBFilterPolicyFacade_hpp
#define DVECLevelDBFilterPolicyFacade_hpp

#import "leveldb/leveldb/filter_policy.h"

class DVECLevelDBFilterPolicyFacade final : public leveldb::FilterPolicy {
public:
    explicit DVECLevelDBFilterPolicyFacade(id<DVECLevelDBFilterPolicy> filterPolicy) : _filterPolicy(filterPolicy) {
    }

    ~DVECLevelDBFilterPolicyFacade() override {
        _filterPolicy = nil;
    }

    void CreateFilter(const leveldb::Slice *keys, int n, std::string *dst) const override {
        NSMutableArray<NSString *> *objcKeys = [[NSMutableArray alloc] initWithCapacity:n];
        for (int i=0; i<n; i++) {
            NSString *key = [[NSString alloc] initWithBytesNoCopy:(void *)keys[i].data()
                                                           length:keys[i].size()
                                                         encoding:NSUTF8StringEncoding
                                                     freeWhenDone:NO];
            [objcKeys addObject:key];
        }

        NSData *currentFilter;
        if (dst->size() > 0) {
            currentFilter = [NSData dataWithBytesNoCopy:(void *)dst->data() length:dst->size()];
        } else {
            currentFilter = [NSData data];
        }
        NSData *newFilter = [_filterPolicy createFilterForKeys:objcKeys currentFilter:currentFilter];
        dst->append((const char *)newFilter.bytes, newFilter.length);
    }

    bool KeyMayMatch(const leveldb::Slice &key, const leveldb::Slice &filter) const override {
        NSString *keyString = [[NSString alloc] initWithBytesNoCopy:(void *)key.data() length:key.size() encoding:NSUTF8StringEncoding freeWhenDone:NO];
        NSString *filterString = [[NSString alloc] initWithBytesNoCopy:(void *)filter.data() length:filter.size() encoding:NSUTF8StringEncoding freeWhenDone:NO];
        return [_filterPolicy keyMayMatch:keyString filter:filterString];
    }

    const char* Name() const override { return [_filterPolicy.name UTF8String]; }

private:
    __strong id<DVECLevelDBFilterPolicy> _filterPolicy;
};

#endif /* DVECLevelDBFilterPolicyFacade_hpp */
