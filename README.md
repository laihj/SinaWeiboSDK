# 新浪微博SDK #

基于新浪微博官方SDK，官方版OAuth2.0 SDK基本上是个DEMO，没什么功能，且不易扩展。

### 调用示例

    WBEngine *engine = [app sharedWBEngineWithDelegate:selfrootView:self];
    [engine getCommentWithStatusId:@"11111111111"
                     completeBlock:^{  
                     	//返回的数据
                         NSData *re = engine.request.responseData;
                     }
                       failedBlock:^{
                           //返回的出错信息 NSError
                           NSError *error = engine.request.requestError
                       }];

### 已完成接口 ###

	//发微博
	- (void)sendWeiBoWithText:(NSString *)text
	                    image:(UIImage *)image
	            completeBlock:(requestBlock) completeBlock
	              failedBlock:(requestBlock) faildBlock;

	//评论微博
	- (void) commentWeiboWithText:(NSString *) text
	                     statusId:(NSString *) sid
	                completeBlock:(requestBlock)completeBlock
	                  failedBlock:(requestBlock) faildBlock;


	- (void) commentWeiboWithText:(NSString *) text
	                     statusId:(NSString *) sid
	                   alsoRepost:(BOOL) repost
	                completeBlock:(requestBlock) completeBlock
	                  failedBlock:(requestBlock) faildBlock;
	//转发微博
	- (void) repostWeiboWithText:(NSString *) text
	                    statusId:(NSString *) sid
	               completeBlock:(requestBlock) completeBlock
	                 failedBlock:(requestBlock) faildBlock;

	//获取微博的评论列表
	- (void) getCommentWithStatusId:(NSString *) StatusId
	                  completeBlock:(requestBlock) completeBlock
	                    failedBlock:(requestBlock) faildBlock;

	//添加收藏
	- (void) addStatusToFavoritesWithStatusId:(NSString *) StatusId
	                                   andTag:(NSString *) tag
	                            completeBlock:(requestBlock) completeBlock
	                              failedBlock:(requestBlock) faildBlock;

	//更新收藏tag
	- (void) updateStatusFavoritesTag:(NSString *) StatusId
	                           andTag:(NSString *) tag
	                    completeBlock:(requestBlock) completeBlock
	                      failedBlock:(requestBlock) faildBlock;

	//获取用户收藏的微博
	- (void) getFavoriteStatusPage:(NSInteger) page
	                         Count:(NSInteger) count
	                 completeBlock:(requestBlock) completeBlock
	                   failedBlock:(requestBlock) faildBlock;

	//获取某个收藏tag下面的微博列表
	- (void) getFavoriteStatusWithTag:(NSString *) tag
	                             Page:(NSInteger) page
	                            Count:(NSInteger) count
	                    completeBlock:(requestBlock) completeBlock
	                      failedBlock:(requestBlock) faildBlock;

	//获取当前用户的tag列表
	- (void) getTag:(NSString *) tag
	           Page:(NSInteger) page
	          Count:(NSInteger) count
	  completeBlock:(requestBlock) completeBlock
	    failedBlock:(requestBlock) faildBlock;
