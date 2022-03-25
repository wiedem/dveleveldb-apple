// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "DVECLevelDBOptions.h"
#import "DVECLevelDBKeyComparator.h"
#import "DVECLevelDBFilterPolicy.h"

#define KVC_SWIFT_UNAVAILABLE NS_SWIFT_UNAVAILABLE("Key value coding method not available for Swift.")

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CLevelDB)
__attribute__((objc_subclassing_restricted))
@interface DVECLevelDB: NSObject
@property (class, nonatomic, assign, readonly) int majorVersion;
@property (class, nonatomic, assign, readonly) int minorVersion;
@property (nonatomic, strong, readonly) NSURL *directoryURL;
@property (nonatomic, strong, readonly) DVECLevelDBOptions *options;

+ (BOOL)destroyDbAtDirectoryURL:(NSURL *)url options:(DVECLevelDBOptions *)options error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;
+ (BOOL)repairDbAtDirectoryURL:(NSURL *)url options:(DVECLevelDBOptions *)options error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;

- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithDirectoryURL:(NSURL *)url
                                      options:(DVECLevelDBOptions *)options
                                 formatLogger:(nullable id<DVECLevelDBFormatLogger>)formatLogger
                                keyComparator:(nullable id<DVECLevelDBKeyComparator>)keyComparator
                                 filterPolicy:(nullable id<DVECLevelDBFilterPolicy>)filterPolicy
                            lruBlockCacheSize:(size_t)lruBlockCacheSize
                                        error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;
- (nullable instancetype)initWithDirectoryURL:(NSURL *)url
                                      options:(DVECLevelDBOptions *)options
                                 simpleLogger:(nullable id<DVECLevelDBSimpleLogger>)simpleLogger
                                keyComparator:(nullable id<DVECLevelDBKeyComparator>)keyComparator
                                 filterPolicy:(nullable id<DVECLevelDBFilterPolicy>)filterPolicy
                            lruBlockCacheSize:(size_t)lruBlockCacheSize
                                        error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;

- (nullable instancetype)initWithDirectoryURL:(NSURL *)url
                                      options:(DVECLevelDBOptions *)options
                                        error:(NSError *_Nullable *_Nullable)error NS_SWIFT_UNAVAILABLE("Use init(directoryURL:options:logger:keyComparator:filterPolicy:lruBlockCacheSize:) instead.");

- (nullable NSString *)valueForKey:(NSString *)key options:(DVECLevelDBReadOptions *)options error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;
- (nullable NSString *)valueForKey:(NSString *)key error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;
- (BOOL)setValue:(nullable NSString *)value forKey:(NSString *)key options:(DVECLevelDBWriteOptions *)options error:(NSError *_Nullable *_Nullable)error;
- (BOOL)setValue:(nullable NSString *)value forKey:(NSString *)key error:(NSError *_Nullable *_Nullable)error;
- (BOOL)syncSetValue:(nullable NSString *)value forKey:(NSString *)key error:(NSError *_Nullable *_Nullable)error;
- (BOOL)removeValueForKey:(NSString *)key options:(DVECLevelDBWriteOptions *)options error:(NSError *_Nullable *_Nullable)error;
- (BOOL)removeValueForKey:(NSString *)key error:(NSError *_Nullable *_Nullable)error;
- (BOOL)syncRemoveValueForKey:(NSString *)key error:(NSError *_Nullable *_Nullable)error;

- (nullable NSString *)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(NSString *)obj forKeyedSubscript:(NSString *)key;

- (NSEnumerator<NSString *>*)keyEnumerator;

- (id)valueForKey:(NSString *)key KVC_SWIFT_UNAVAILABLE;
- (void)setValue:(nullable id)value forKey:(NSString *)key KVC_SWIFT_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
