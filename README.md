# ios_objectiveC_Utils
To convert data Dictionary to Model Class or Model Class to Dictionary

It is also supported nested ditionary conversion.

Below is the sample Model class in swift, where you need to compulsary set the ```@objcMembers``` before the class keyword. and inherit it as ```NSObject```

```
@objcMembers class SampleHRQModel: NSObject {
    
    var user_id : NSString!
    var messageId : NSString!
    var name : NSString!
    var message : NSString!
    
    override init() {
        super.init()
    }
}
```

In case of Objective C, please refer below :-

```
#import <Foundation/Foundation.h>

@interface SampleHRQModel : NSObject

@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *message;

@end

#import "SampleHRQModel.h"

@implementation Contact

- (instancetype) init{

    self = [super init];

    if (self) {
        //Set Default value for properties
    }
    return self
}

@end
```

Below is the sample Dictionary not the JSON type, you can convert JSON to Model and then you can use :-
```
{
  "user_id" : 1010
  "messageId" : 5001
  "name" : John
  "message" : Hello!!! Eric
}

```

Please use the below code when you need to convet as

Convert Dictionary to Model class :-
Swift :-
```
SampleHRQModel hrqModel = SampleHRQModel();
hrqModel = Utils.setModelClass(hrqModel, with: userDict as! [AnyHashable : Any]) as! SampleHRQModel
```
Objective C :-
```
SampleHRQModel *hrqModel = [[SampleHRQModel alloc] init];
hrqModel = [Utils setModelClass:hrqModel withDictionary: userDict];
```

Convert Model class to Dictionary :-
Swift :-
```
let dict = Utils.convertModel(toDictionary: hRqModel) as! [NSString : Any]
```
Objective C :-
```
NSDictionary *dict = [Utils convertModelToDictionary: hRqModel];
```

Limitation :-
1. You need to always use the same property name as in dictionary key value, becuase it internally mapped to class or dictionary
2. This library support only for ```NSString``` Property.
3. This library written in C, then you have to declare class as ```@objcMembers``` and uses property type as ```NSString```.

