//
//  CreateMemberModel.h
//  LTSample-iOS
//
//  Created by shanezhang on 2021/3/25.
//

#import <Foundation/Foundation.h>
#import <LTIMSDK/LTMemberModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateMemberModel : LTMemberModel
@property (nonatomic, strong, nonnull) NSString *accountID;
@end

NS_ASSUME_NONNULL_END
