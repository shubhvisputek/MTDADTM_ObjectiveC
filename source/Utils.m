//
//  Utils.m
//  samplecoding
//
//  Copyright © 2018 sumit. All rights reserved.
//

#import "Utils.h"
#import <objc/runtime.h>

#define KEY_EMPTY_STRING @""

@implementation Utils




+ (NSDictionary *) convertModelToDictionary:(id)classSelf{
    if ([classSelf class] == NULL) {
        return nil;
    }
    unsigned int numberOfProperties, i;
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    @try{
        
        objc_property_t *objcProperties = class_copyPropertyList([classSelf class], &numberOfProperties);
        
        for (i = 0; i < numberOfProperties; i++) {
            
            objc_property_t property = objcProperties[i];
            const char *propName = property_getName(property);
            if(propName) {
                const char *propType = getPropertyType(property);
                NSString *propertyType = [NSString stringWithUTF8String:propType];
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                if([propertyType isEqualToString:@"NSMutableString"] || [propertyType isEqualToString:@"NSString"] || [propertyType isEqualToString:@"B"] || [propertyType isEqualToString:@"c"] || [propertyType isEqualToString:@"bool"] || [propertyType isEqualToString:@"Boolean"]){
                    NSString *propertyValue = [classSelf valueForKey:propertyName] ? : KEY_EMPTY_STRING;
                    [properties setValue:propertyValue forKey:propertyName];
                    //NSLog(@"%@ : %@",propertyName, propertyValue);
                }
                else if([propertyType isEqualToString:@"NSMutableDictionary"] || [propertyType isEqualToString:@"NSDictionary"]){
                    NSDictionary *tmpDict = [classSelf valueForKey:propertyName];
                    //This is for Logger and testcode
                    //for (id key in tmpDict) {
                    //NSString *propertyValue = [tmpDict objectForKey:key];
                    //NSLog(@"%@ : %@",key, propertyValue);
                    //}
                    [properties setValue:tmpDict forKey:propertyName];
                }
                else if([propertyType isEqualToString:@"NSMutableArray"] || [propertyType isEqualToString:@"NSArray"]){
                    NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
                    for (int j=0; j<[[classSelf valueForKey:propertyName] count]; j++) {
                        
                        if([[[classSelf valueForKey:propertyName] objectAtIndex:j] isKindOfClass:[NSString class]]){
                            [tmpArr addObject:[[classSelf valueForKey:propertyName] objectAtIndex:j]];
                        }
                        else{
                            [tmpArr addObject:[Utils convertModelToDictionary:[[classSelf valueForKey:propertyName] objectAtIndex:j]]];
                        }
                    }
                    [properties setValue:tmpArr forKey:propertyName];
                }
                else{
                    [properties setValue:[Utils convertModelToDictionary:[classSelf valueForKey:propertyName]] forKey:propertyName];
                }
            }
        }
        free(objcProperties);
    }
    @catch(NSException *exception){
        NSLog(@"%s Exception Error - Conversion Model to Dict  => %@",__PRETTY_FUNCTION__,exception.description);
        return nil;
    }
    return properties;
}

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // A C primitive type:
            /*
             For example, int "i", long "l", unsigned "I", struct.
             Apple docs list plenty of examples of values returned. For a list
             of what will be returned for these primitives, search online for
             "Objective-c" "Property Attribute Description Examples"
             */
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // An Objective C id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // Another Objective C id type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

+ (id)setModelClass:(id)classSelf withDictionary:(NSDictionary *)reqDict{
    if ([classSelf class] == NULL) {
        return nil;
    }
    
    classSelf = [[[classSelf class] alloc] init];
    
    @try{
        unsigned int numberOfProperties, i;
        objc_property_t *objcProperties = class_copyPropertyList([classSelf class], &numberOfProperties);
        
        for (i = 0; i < numberOfProperties; i++) {
            
            objc_property_t property = objcProperties[i];
            const char *propName = property_getName(property);
            if(propName) {
                
                const char *propType = getPropertyType(property);
                NSString *propertyType = [NSString stringWithUTF8String:propType];
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                if([propertyType isEqualToString:@"NSMutableString"] || [propertyType isEqualToString:@"NSString"] || [propertyType isEqualToString:@"B"] || [propertyType isEqualToString:@"c"] || [propertyType isEqualToString:@"bool"] || [propertyType isEqualToString:@"Boolean"]){
                    if([[reqDict description] length]){
                        NSString *propertyValue = [reqDict objectForKey:propertyName] ? : @"";
                        [classSelf setValue:propertyValue forKey:propertyName];
                        //                        NSLog(@"%@ : %@-",propertyName, propertyValue);
                    }
                }
                else if([propertyType isEqualToString:@"NSMutableDictionary"] || [propertyType isEqualToString:@"NSDictionary"]){
                    NSString *propertyValue = [reqDict objectForKey:propertyName] ? : @"";
                    [classSelf setValue:propertyValue forKey:propertyName];
                }
                else if([propertyType isEqualToString:@"NSMutableArray"] || [propertyType isEqualToString:@"NSArray"]){
                    
                    NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
                    if([[reqDict description] length] && [[reqDict objectForKey:propertyName] isKindOfClass:NSArray.class]){
                        
                        for (int j=0; j<[[reqDict objectForKey:propertyName] count]; j++) {
                            id tmpClass = [[[[[classSelf valueForKey:propertyName] objectAtIndex:0] class] alloc] init];
                            
                            if([tmpClass isKindOfClass:[NSString class]]){
                                [tmpArr addObject:[[classSelf valueForKey:propertyName] objectAtIndex:j]];
                            }
                            else{
                                if([[reqDict objectForKey:propertyName] isKindOfClass:[NSArray class]] || [[reqDict objectForKey:propertyName] isKindOfClass:[NSMutableArray class]]){
                                    tmpClass = [Utils setModelClass:tmpClass withDictionary:[[reqDict objectForKey:propertyName] objectAtIndex:j]];
                                    [tmpArr addObject:tmpClass];
                                }
                                else{
                                    tmpClass = [Utils setModelClass:tmpClass withDictionary:[reqDict objectForKey:propertyName]];
                                    [tmpArr addObject:tmpClass];
                                    break;
                                }
                            }
                        }
                    }
                    else{
                        id tmpClass = [[[[[classSelf valueForKey:propertyName] objectAtIndex:0] class] alloc] init];
                        [tmpArr addObject:tmpClass];
                    }
                    [classSelf setValue:tmpArr forKey:propertyName];
                }
                else{
                    if([[reqDict description] length]){
                        [classSelf setValue:[Utils setModelClass:[[classSelf valueForKey:propertyName] self] withDictionary: [reqDict objectForKey:propertyName]]  forKey:propertyName];
                    }
                    else{
                        [classSelf setValue:[Utils setModelClass:[[classSelf valueForKey:propertyName] self] withDictionary:reqDict]  forKey:propertyName];
                    }
                }
            }
        }
        free(objcProperties);
    }
    @catch(NSException *exception){
        NSLog(@"%s Exception Error - Conversion Dict to Model  => %@",__PRETTY_FUNCTION__,exception.description);
        return nil;
    }
    
    return classSelf;
}

@end
