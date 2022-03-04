//
//  NSString+NTYExtension.m
//  SARRS
//
//  Created by wangchao on 2017/7/8.
//  Copyright © 2017年 Beijing Ninety Culture Co.ltd. All rights reserved.
//

#import "NSString+NTYExtension.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSObject+Cast.h"

@implementation NSString (NTYExtension)

- (NSString*)nty_trimed {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSString*)nty_trimed:(NSString*)characters {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:characters];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSString*)nty_reportDecode {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
}

- (NSString*)nty_replaced:(NSString*)source with:(NSString*)target {
    return [self stringByReplacingOccurrencesOfString:source withString:target];
}

- (BOOL)nty_contains:(NSString*)string {
    if (!string) {return NO;}
    return [self containsString:string];
}

- (BOOL)nty_hasURLEncoded {
    NSString *original = self;
    NSString *decoded = [original nty_urlDecoded];
    if (![original isEqualToString:decoded]) {
        // The URL was not encoded yet
        return YES;
    } else {
        // The URL was already encoded
        return NO;
    }
}

- (NSString*)nty_urlEncoded {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString*)nty_urlDecoded {
    return [self stringByRemovingPercentEncoding];
}

// 保留查看，如果验证没有调用2.8.5以后可以移除
//- (NSString*)nty_cfURLEncoded {
//    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//            (CFStringRef)self,
//            NULL,
//            CFSTR("!*'();:@&=+$,/?%#[]"),
//            kCFStringEncodingUTF8));
//    return result;
//}
//
//- (NSString*)nty_cfURLDecoded {
//    NSString *result = CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
//            (CFStringRef)self,
//            CFSTR(""),
//            kCFStringEncodingUTF8));
//    return result;
//}

#if 0 /// 备份一下代码
    - (NSString*)sarrs_URLEncoded {
        // Encode all the reserved characters, per RFC 3986
        // (<http://www.ietf.org/rfc/rfc3986.txt>)
        CFStringRef escaped =
            CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                (CFStringRef)self,
                NULL,
                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                kCFStringEncodingUTF8);
        NSString*result = CFBridgingRelease(escaped);

        return result;
    }

    - (NSString*)sarrs_URLDecoded {
        NSMutableString *resultString = [NSMutableString stringWithString:self];
        [resultString replaceOccurrencesOfString:@"+"
                                      withString:@" "
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [resultString length])];

        return [resultString nty_urlDecoded];
    }

#endif // if 0

- (NSString*)nty_base64Encoded {
    if (self.length == 0) {
        return nil;
    }
    NSData   *data    = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encoded = [data base64EncodedStringWithOptions:0];

    return encoded;
}

- (NSString*)nty_base64Decoded {
    if (self.length == 0) {
        return nil;
    }

    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    // Decoded NSString from the NSData
    if (data.length == 0) {
        NSLog(@"base64 decode failed");
        return nil;
    }
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return string;
}

- (NSData*)nty_utf8Encoded {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*)nty_joinString:(NSString*)string {
    return [self stringByAppendingString:string];
}

- (NSString*)nty_joinPath:(NSString*)path {
    return [self stringByAppendingPathComponent:path];
}

- (NSString*)nty_joinExtension:(NSString*)pathExtension {
    return [self stringByAppendingPathExtension:pathExtension];
}

- (NSString*)nty_joindAction:(NSString*)action {
    if ([action isEmpty]) {
        return self;
    }
    NSAssert([self containsString:@"://"],@"host不合法",self);
    NSString *host = self;
    if (![host hasSuffix:@"/"] && action) {
        host = [host stringByAppendingString:@"/"];
    }
    if ([action hasPrefix:@"/"]) {
        action = [action substringFromIndex:1];
    }
    NSString *URL = [host stringByAppendingString:action];
    return URL;
}

- (NSString*)nty_dirname {
    return [self stringByDeletingLastPathComponent];
}

- (NSString*)nty_basename {
    return [self lastPathComponent];
}

- (NSString*)nty_extension {
    return [self pathExtension];
}

- (NSString*)nty_filename {
    return [[self lastPathComponent] stringByDeletingPathExtension];
}



#pragma mark - encrypt
- (NSString*)nty_md5 {
    const char   *string = self.UTF8String;
    int           length = (int)strlen(string);
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, length, bytes);
    
    return [self nty_stringFromBytes:bytes length:CC_MD5_DIGEST_LENGTH];
}


#pragma mark - Helpers

- (NSString*)nty_stringFromBytes:(unsigned char*)bytes length:(NSInteger)length {
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < length; i++) {
        [mutableString appendFormat:@"%02x", bytes[i]];
    }
    
    return [NSString stringWithString:mutableString];
}

- (int)nty_javaHashCode {
    int h = 0;
    for (int i = 0; i < (int)self.length; i++) {
        h = (31 * h) + [self characterAtIndex:i];
    }
    return h;
}

@end
