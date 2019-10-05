//
//  Utils.h
//  samplecoding
//
//  Copyright © 2018 sumit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSDictionary *)convertModelToDictionary:(id)classSelf;

+ (id)setModelClass:(id)classSelf withDictionary:(NSDictionary *)reqDict;

@end
