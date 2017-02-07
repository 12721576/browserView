//
//  Person+CoreDataProperties.h
//  test
//
//  Created by huangkai on 16/8/9.
//  Copyright © 2016年 huangkai. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *age;
@property (nullable, nonatomic, retain) NSManagedObject *card;

@end

NS_ASSUME_NONNULL_END
