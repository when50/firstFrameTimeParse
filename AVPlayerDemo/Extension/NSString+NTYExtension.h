//
//  NSString+NTYExtension.h
//  SARRS
//
//  Created by wangchao on 2017/7/8.
//  Copyright © 2017年 Beijing Ninety Culture Co.ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSString (NTYExtension)
+ (NSString*)nty_userAgent;      /// UA
+ (NSString*)nty_mobileIMSI;//运营商编码460...

- (NSString*)nty_trimed;
- (NSString*)nty_trimed:(NSString*)characters;
/**
 *  上报时候对字符串特殊字符的处理
 *
 *  @return 处理后的字符串
 */
- (NSString*)nty_reportDecode;
- (NSString*)nty_replaced:(NSString*)source with:(NSString*)target;
/**
 *  是否包含子字符串判断，对nil字符串做了容错
 *
 *  @param string 查找的字符
 *
 *  @return 是否包含字符
 */
- (BOOL)nty_contains:(NSString*)str;

- (nullable NSString*)nty_base64Encoded;
- (nullable NSString*)nty_base64Decoded;
- (NSData*)nty_utf8Encoded;
- (NSString*)nty_aes:(NSString*)password;
- (NSString *)nty_daes:(NSString*)password;

/**
 * 判断URL是否已经编码
 *  @return YES/NO
 */

- (BOOL)nty_hasURLEncoded;
/**
 *  添加URL编码
 *  @note stringByAddingPercentEscapesUsingEncoding
 *  @return 编码后的URL
 */
- (NSString*)nty_urlEncoded;
/**
 *  移除URL编码
 *  @note stringByRemovingPercentEncoding
 *  @return 移除编码后的URL
 */
- (NSString*)nty_urlDecoded;

///**
// *  添加URL编码
// *  @note CFURLCreateStringByAddingPercentEscapes
// *  @return 编码后的URL
// */
//- (NSString*)nty_cfURLEncoded;
///**
// *  移除URL编码
// *  @note CFURLCreateStringByReplacingPercentEscapesUsingEncoding
// *  @return 移除编码后的URL
// */
//- (NSString*)nty_cfURLDecoded;

#pragma mark - 简化 stringByAppendingXXX
- (NSString*)nty_joinString:(NSString*)string;
- (NSString*)nty_joinPath:(NSString*)path;
- (NSString*)nty_joinExtension:(NSString*)pathExtension;
- (NSString*)nty_joindAction:(NSString*)action;

- (NSString*)nty_dirname;   /// 所在目录
- (NSString*)nty_basename;  /// 带扩展名的文件名
- (NSString*)nty_filename;  /// 不带扩展名的文件名
- (NSString*)nty_extension; /// 扩展名

- (int)nty_javaHashCode;


#pragma mark - encrypt(hash)
@property (readonly) NSString *nty_md5;

@end
NS_ASSUME_NONNULL_END
