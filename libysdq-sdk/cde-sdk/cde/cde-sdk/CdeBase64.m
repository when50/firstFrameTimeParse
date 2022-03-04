#import "CdeBase64.h"

NSString *ysdq_cdeUrlBase64EncodedString( NSString *input )
{
	if( input == nil ) return @"";
	if (![input length]) return @"";
	
	NSString *encoded = @"";
	NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
	
#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9 || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
	if (![NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)])
	{
		encoded = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
	}
	else
#endif
		
	{
		encoded = [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
	}
	
	return encoded != nil ? encoded : @"";
}


NSString *ysdq_cdeUrlEncodeUriComponent( NSString *input )
{
	if( input == nil ) return @"";

	// Encode all the reserved characters, per RFC 3986
	// (<http://www.ietf.org/rfc/rfc3986.txt>)
	NSString *outputStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
											(CFStringRef)input,
											NULL,
											(CFStringRef)@"!*'();:@&=+$,/?%#[]",
											kCFStringEncodingUTF8));
	return outputStr != nil ? outputStr : @"";
}
