# 新浪微博SDK #

基于新浪微博官方SDK，官方版OAuth2.0 SDK基本上是个DEMO，没什么功能，且不易扩展。

### 已完成接口 ###
	- (void) sendWeiBoWithText:(NSString *)text
	                     image:(UIImage *)image
	                       lat:(float) lat
	                       lon:(float) lon
	             completeBlock:(requestBlock) completeBlock
	               failedBlock:(requestBlock) faildBlock;

	//获取当前用户数据
	- (void) getUserDataWithCompleteBlock:(requestBlock) completeBlock
	                          failedBlock:(requestBlock) faildBlock;

	//评论
	- (void) commentWeiboWithText:(NSString *) text
	                     statusId:(NSString *) sid
	                completeBlock:(requestBlock) completeBlock
	                  failedBlock:(requestBlock) faildBlock;
	//转发
	- (void) repostWeiboWithText:(NSString *) text
	                    statusId:(NSString *) sid
	               completeBlock:(requestBlock) completeBlock
	                 failedBlock:(requestBlock) faildBlock;

	- (void) getCommentWithStatusId:(NSString *) StatusId
	                  completeBlock:(requestBlock) completeBlock
	                    failedBlock:(requestBlock) faildBlock;

	     