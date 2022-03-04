#import "CdeDownloadItem.h"

@interface ysdq_CdeDownloadItem ()
@end

@implementation ysdq_CdeDownloadItem

@synthesize apptag_,
	taskid_,
	state_,
	stateName_,
	priority_,
	errorCode_,
	url_,
	filename_,
	filepathTmp_,
	filepath_,
	createTime_,
	progress_,
	finishedSize_,
	size_,
	fileext_,
	downloadRate_,
	removedState_,
	fileErrorCode_,
	expireTime_;
@synthesize base64Url_,other_;

//@synthesize apptag=_apptag;
//@synthesize taskid=_taskid;
//@synthesize state_name=_state_name;
////@synthesize state = _state;
//@synthesize priority=_priority;
//@synthesize error_code=_error_code;
//@synthesize url=_url;
//@synthesize filename=_filename;
//@synthesize filepath_tmp=_filepath_tmp;
//@synthesize filepath=_filepath;
//@synthesize create_time=_create_time;
//@synthesize progress=_progress;
//@synthesize finished_size=_finished_size;
//@synthesize size=_size;
//@synthesize fileext=_fileext;
//@synthesize download_rate=_download_rate;
//@synthesize base64url = _base64url;
//@synthesize other=_other;

- (id)init {
    if (self = [super init]) {
    }
    
    return self;
}

//- (void)dealloc {
//   [apptag release];
//   [state release];
//
//   [super dealloc];
// 
//}
//- (void) dealloc {
//    self.apptag_ = nil;
//    [super dealloc];
//}

@end
