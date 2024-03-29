// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import "DVECLevelDB.h"
#import "leveldb/leveldb/db.h"

NS_ASSUME_NONNULL_BEGIN

leveldb::Slice sliceForData(NSData *data);
NSData *dataForString(const std::string &string);
NSData *dataForSlice(const leveldb::Slice &slice);
NSData *createDataForString(std::string &string);
void copyDataToString(NSData *data, std::string &string);

@interface DVECLevelDB(Internal)
@property (nonatomic, assign, readonly) leveldb::DB *db;
@end

NS_ASSUME_NONNULL_END
