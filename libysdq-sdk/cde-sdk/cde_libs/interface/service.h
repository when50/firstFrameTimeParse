#ifndef __PLATFORM_IOS_LIBCDE_SERVICE_H_INCLUDE__
#define __PLATFORM_IOS_LIBCDE_SERVICE_H_INCLUDE__

#ifdef __cplusplus
class ysdq_cde_proxy;
extern "C" {
long ysdq_cdeSetHandler(ysdq_cde_proxy* handler);
#endif // __cplusplus

// ysdq_cde new api
long ysdq_cdeStartService( const char *params, const char *identify );
long ysdq_cdeStopService(void);
long ysdq_cdeActivateService(void); // return 0 if service is active, 1 if service need restart, < 0 if service not started
long ysdq_cdeSetNetworkType( int type );
long ysdq_cdeSetChannelSeekPosition( const char *url, double pos );
long ysdq_cdeSetGlobalProxyUrl( const char *url );
long ysdq_cdeSetKeyDataCache( const char *key, const char *data );
long ysdq_cdeGetServicePort(void);
long ysdq_cdeGetVersionNumber(void);
const char *ysdq_cdeGetVersionString(void);
char *ysdq_cdeTrimLinkShellUrlParams( const char *url ); // return value with free
int  ysdq_cdeGetSegmentData( const char *url, const char *path, bool trunMp4, double requireTime, int *width, int *height, int *errorCode, double *offsetTime, double *duration, int *size );
int  ysdq_cdeWriteLogLine( int level, const char *text );

// ysdq_cde state api
int ysdq_cdeGetStateTotalDuration( long handle, const char *url );
int ysdq_cdeGetStateDownloadedDuration( long handle, const char *url );
double ysdq_cdeGetStateDownloadedPercent( long handle, const char *url );
int ysdq_cdeGetStateUrgentReceiveSpeed( long handle, const char *url );
int ysdq_cdeGetStateLastReceiveSpeed( long handle, const char *url );

// compatible for old versions
long ysdq_utpStartService( int port, const char *identify );
long ysdq_utpStartServiceWithParams( const char *params, const char *identify );
long ysdq_utpStopService( long handle );
long ysdq_utpGetServicePort( long handle );
long ysdq_utpStartDefaultService( const char *identify );
long ysdq_utpStopDefaultService(void);
long ysdq_utpSetNetType( long handle, int type );
long ysdq_utpGetVersionNumber(void);
const char *ysdq_utpGetVersionString(void);
char* ysdq_acceleratePlay(const char* url, int offset);


// linkshell wrapper api
//int initLinkShell();
//char * getURLFromLinkShell( const char *input );

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // __PLATFORM_IOS_LIBCDE_SERVICE_H_INCLUDE__
