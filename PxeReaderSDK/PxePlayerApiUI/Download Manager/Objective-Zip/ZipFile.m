//
//  ZipFile.m
//  Objective-Zip v. 0.8.3
//
//  Created by Gianluca Bertani on 25/12/09.
//  Copyright 2009-10 Flying Dolphin Studio. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions 
//  are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the name of Gianluca Bertani nor the names of its contributors 
//    may be used to endorse or promote products derived from this software 
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "ZipFile.h"
#import "ZipException.h"
#import "ZipReadStream.h"
#import "ZipWriteStream.h"
#import "FIleInZipInfo.h"

#define FILE_IN_ZIP_MAX_NAME_LENGTH (256)


@implementation ZipFile


+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(NSString *)password error:(NSError **)error {
    // Begin opening
    zipFile zip = unzOpen((const char*)[path UTF8String]);
    if (zip == NULL) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"failed to open zip file" forKey:NSLocalizedDescriptionKey];
        if (error) {
            *error = [NSError errorWithDomain:@"Objective-ZipErrorDomain" code:-1 userInfo:userInfo];
        }
        return NO;
    }
    
    NSDictionary * fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    ZPOS64_T fileSize = fileAttributes.fileSize;
    ZPOS64_T currentPosition = 0;
    
    unz_global_info  globalInfo = {0ul, 0ul};
    unzGetGlobalInfo(zip, &globalInfo);
    
    // Begin unzipping
    if (unzGoToFirstFile(zip) != UNZ_OK) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"failed to open first file in zip file" forKey:NSLocalizedDescriptionKey];
        if (error) {
            *error = [NSError errorWithDomain:@"Objective-ZipErrorDomain" code:-2 userInfo:userInfo];
        }
        return NO;
    }
    
    BOOL success = YES;
    int ret = 0;
    unsigned char buffer[4096] = {0};
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableSet *directoriesModificationDates = [[NSMutableSet alloc] init];
    
   
    NSInteger currentFileNumber = 0;
    do {
        @autoreleasepool {
            if ([password length] == 0) {
                ret = unzOpenCurrentFile(zip);
            } else {
                ret = unzOpenCurrentFilePassword(zip, [password cStringUsingEncoding:NSASCIIStringEncoding]);
            }
            
            if (ret != UNZ_OK) {
                success = NO;
                break;
            }
            
            // Reading data and write to file
            unz_file_info fileInfo;
            memset(&fileInfo, 0, sizeof(unz_file_info));
            
            ret = unzGetCurrentFileInfo(zip, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
            if (ret != UNZ_OK) {
                success = NO;
                unzCloseCurrentFile(zip);
                break;
            }
            
            currentPosition += fileInfo.compressed_size;

            
            char *filename = (char *)malloc(fileInfo.size_filename + 1);
            unzGetCurrentFileInfo(zip, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
            filename[fileInfo.size_filename] = '\0';
            
            //
            // Determine whether this is a symbolic link:
            // - File is stored with 'version made by' value of UNIX (3),
            //   as per http://www.pkware.com/documents/casestudies/APPNOTE.TXT
            //   in the upper byte of the version field.
            // - BSD4.4 st_mode constants are stored in the high 16 bits of the
            //   external file attributes (defacto standard, verified against libarchive)
            //
            // The original constants can be found here:
            //    http://minnie.tuhs.org/cgi-bin/utree.pl?file=4.4BSD/usr/include/sys/stat.h
            //
            const uLong ZipUNIXVersion = 3;
            const uLong BSD_SFMT = 0170000;
            const uLong BSD_IFLNK = 0120000;
            
            BOOL fileIsSymbolicLink = NO;
            if (((fileInfo.version >> 8) == ZipUNIXVersion) && BSD_IFLNK == (BSD_SFMT & (fileInfo.external_fa >> 16))) {
                fileIsSymbolicLink = YES;
            }
            
            // Check if it contains directory
            NSString *strPath = [NSString stringWithCString:filename encoding:NSUTF8StringEncoding];
            BOOL isDirectory = NO;
            if (filename[fileInfo.size_filename-1] == '/' || filename[fileInfo.size_filename-1] == '\\') {
                isDirectory = YES;
            }
            free(filename);
            
            // Contains a path
            if ([strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location != NSNotFound) {
                strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            }
            
            NSString *fullPath = [destination stringByAppendingPathComponent:strPath];
            NSError *err = nil;
            NSDate *modDate = [[self class] _dateWithMSDOSFormat:(UInt32)fileInfo.dosDate];
            NSDictionary *directoryAttr = [NSDictionary dictionaryWithObjectsAndKeys:modDate, NSFileCreationDate, modDate, NSFileModificationDate, nil];
            
            if (isDirectory) {
                [fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:directoryAttr  error:&err];
            } else {
                [fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:directoryAttr error:&err];
            }
            if (nil != err) {
                NSLog(@"[Objective-Zip] Error: %@", err.localizedDescription);
            }
            
            if(!fileIsSymbolicLink)
                [directoriesModificationDates addObject: [NSDictionary dictionaryWithObjectsAndKeys:fullPath, @"path", modDate, @"modDate", nil]];
            
            if ([fileManager fileExistsAtPath:fullPath] && !isDirectory && !overwrite) {
                unzCloseCurrentFile(zip);
                ret = unzGoToNextFile(zip);
                continue;
            }
            
            if(!fileIsSymbolicLink)
            {
                FILE *fp = fopen((const char*)[fullPath UTF8String], "wb");
                while (fp) {
                    int readBytes = unzReadCurrentFile(zip, buffer, 4096);
                    
                    if (readBytes > 0) {
                        fwrite(buffer, readBytes, 1, fp );
                    } else {
                        break;
                    }
                }
                
                if (fp) {
                    fclose(fp);
                    
                    // Set the original datetime property
                    if (fileInfo.dosDate != 0) {
                        NSDate *orgDate = [[self class] _dateWithMSDOSFormat:(UInt32)fileInfo.dosDate];
                        NSDictionary *attr = [NSDictionary dictionaryWithObject:orgDate forKey:NSFileModificationDate];
                        
                        if (attr) {
                            if ([fileManager setAttributes:attr ofItemAtPath:fullPath error:nil] == NO) {
                                // Can't set attributes
                                NSLog(@"[Objective-Zip] Failed to set attributes - whilst setting modification date");
                            }
                        }
                    }
                    
                    // Set the original permissions on the file
                    uLong permissions = fileInfo.external_fa >> 16;
                    if (permissions != 0) {
                        // Store it into a NSNumber
                        NSNumber *permissionsValue = @(permissions);
                        
                        // Retrieve any existing attributes
                        NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[fileManager attributesOfItemAtPath:fullPath error:nil]];
                        
                        // Set the value in the attributes dict
                        attrs[NSFilePosixPermissions] = permissionsValue;
                        
                        // Update attributes
                        if ([fileManager setAttributes:attrs ofItemAtPath:fullPath error:nil] == NO) {
                            // Unable to set the permissions attribute
                            NSLog(@"[Objective-Zip] Failed to set attributes - whilst setting permissions");
                        }
                        
#if !__has_feature(objc_arc)
                        [attrs release];
#endif
                    }
                }
            }
            else
            {
                // Assemble the path for the symbolic link
                NSMutableString* destinationPath = [NSMutableString string];
                int bytesRead = 0;
                while((bytesRead = unzReadCurrentFile(zip, buffer, 4096)) > 0)
                {
                    buffer[bytesRead] = 0;
                    [destinationPath appendString:[NSString stringWithUTF8String:(const char*)buffer]];
                }
                
                // Create the symbolic link (making sure it stays relative if it was relative before)
                int symlinkError = symlink([destinationPath cStringUsingEncoding:NSUTF8StringEncoding],
                                           [fullPath cStringUsingEncoding:NSUTF8StringEncoding]);
                
                if(symlinkError != 0)
                {
                    NSLog(@"Failed to create symbolic link at \"%@\" to \"%@\". symlink() error code: %d", fullPath, destinationPath, errno);
                }
            }
            
            unzCloseCurrentFile( zip );
            ret = unzGoToNextFile( zip );
            
          
            
            currentFileNumber++;
        }
    } while(ret == UNZ_OK && ret != UNZ_END_OF_LIST_OF_FILE);
    
    // Close
    unzClose(zip);
    
    // The process of decompressing the .zip archive causes the modification times on the folders
    // to be set to the present time. So, when we are done, they need to be explicitly set.
    // set the modification date on all of the directories.
    NSError * err = nil;
    for (NSDictionary * d in directoriesModificationDates) {
        if (![[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[d objectForKey:@"modDate"], NSFileModificationDate, nil] ofItemAtPath:[d objectForKey:@"path"] error:&err]) {
            NSLog(@"[Objective-Zip] Set attributes failed for directory: %@.", [d objectForKey:@"path"]);
        }
        if (err) {
            NSLog(@"[Objective-Zip] Error setting directory file modification date attribute: %@",err.localizedDescription);
        }
    }
    
#if !__has_feature(objc_arc)
    [directoriesModificationDates release];
#endif
    
  
    return success;
}

- (id) initWithFileName:(NSString *)fileName mode:(ZipFileMode)mode {
	if (self= [super init]) {
		_fileName= [fileName ah_retain];
		_mode= mode;
		
		switch (mode) {
			case ZipFileModeUnzip:
				_unzFile= unzOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding]);
				if (_unzFile == NULL) {
					NSString *reason= [NSString stringWithFormat:@"Can't open '%@'", _fileName];
					@throw [[[ZipException alloc] initWithReason:reason] autorelease];
				}
				break;
				
			case ZipFileModeCreate:
				_zipFile= zipOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding], APPEND_STATUS_CREATE);
				if (_zipFile == NULL) {
					NSString *reason= [NSString stringWithFormat:@"Can't open '%@'", _fileName];
					@throw [[[ZipException alloc] initWithReason:reason] autorelease];
				}
				break;
				
			case ZipFileModeAppend:
				_zipFile= zipOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding], APPEND_STATUS_ADDINZIP);
				if (_zipFile == NULL) {
					NSString *reason= [NSString stringWithFormat:@"Can't open '%@'", _fileName];
					@throw [[[ZipException alloc] initWithReason:reason] autorelease];
				}
				break;
				
			default: {
				NSString *reason= [NSString stringWithFormat:@"Unknown mode %d", _mode];
				@throw [[[ZipException alloc] initWithReason:reason] autorelease];
			}
		}
	}
	
	return self;
}

- (void) dealloc {
	[_fileName release];
	
	[super ah_dealloc];
}

- (ZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip compressionLevel:(ZipCompressionLevel)compressionLevel {
	if (_mode == ZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted with Unzip mode"];
		@throw [[[ZipException alloc] initWithReason:reason] autorelease];
	}
	
	NSDate *now= [NSDate date];
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:now];	
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= [date second];
	zi.tmz_date.tm_min= [date minute];
	zi.tmz_date.tm_hour= [date hour];
	zi.tmz_date.tm_mday= [date day];
	zi.tmz_date.tm_mon= [date month] -1;
	zi.tmz_date.tm_year= [date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
	int err= zipOpenNewFileInZip3_64(
									 _zipFile,
									 [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
									 &zi,
									 NULL, 0, NULL, 0, NULL,
									 (compressionLevel != ZipCompressionLevelNone) ? Z_DEFLATED : 0,
									 compressionLevel, 0,
									 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
									 NULL, 0, 1);
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	return [[[ZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip] autorelease];
}

- (ZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(ZipCompressionLevel)compressionLevel {
	if (_mode == ZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted with Unzip mode"];
		@throw [[[ZipException alloc] initWithReason:reason] autorelease];
	}
	
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:fileDate];	
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= [date second];
	zi.tmz_date.tm_min= [date minute];
	zi.tmz_date.tm_hour= [date hour];
	zi.tmz_date.tm_mday= [date day];
	zi.tmz_date.tm_mon= [date month] -1;
	zi.tmz_date.tm_year= [date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
	int err= zipOpenNewFileInZip3_64(
									 _zipFile,
									 [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
									 &zi,
									 NULL, 0, NULL, 0, NULL,
									 (compressionLevel != ZipCompressionLevelNone) ? Z_DEFLATED : 0,
									 compressionLevel, 0,
									 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
									 NULL, 0, 1);
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	return [[[ZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip] autorelease];
}

- (ZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(ZipCompressionLevel)compressionLevel password:(NSString *)password crc32:(NSUInteger)crc32 {
	if (_mode == ZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted with Unzip mode"];
		@throw [[[ZipException alloc] initWithReason:reason] autorelease];
	}
	
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:fileDate];	
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= [date second];
	zi.tmz_date.tm_min= [date minute];
	zi.tmz_date.tm_hour= [date hour];
	zi.tmz_date.tm_mday= [date day];
	zi.tmz_date.tm_mon= [date month] -1;
	zi.tmz_date.tm_year= [date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
	int err= zipOpenNewFileInZip3_64(
									 _zipFile,
									 [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
									 &zi,
									 NULL, 0, NULL, 0, NULL,
									 (compressionLevel != ZipCompressionLevelNone) ? Z_DEFLATED : 0,
									 compressionLevel, 0,
									 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
									 [password cStringUsingEncoding:NSUTF8StringEncoding], crc32, 1);
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	return [[[ZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip] autorelease];
}

- (NSString*) fileName {
	return _fileName;
}

- (NSUInteger) numFilesInZip {
	if (_mode != ZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[[ZipException alloc] initWithReason:reason] autorelease];
	}
	
	unz_global_info64 gi;
	int err= unzGetGlobalInfo64(_unzFile, &gi);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error getting global info in '%@'", _fileName];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	return gi.number_entry;
}

- (NSArray *) listFileInZipInfos {
	int num= [self numFilesInZip];
	if (num < 1)
		return [[[NSArray alloc] init] autorelease];
	
	NSMutableArray *files= [[[NSMutableArray alloc] initWithCapacity:num] autorelease];

	[self goToFirstFileInZip];
	for (int i= 0; i < num; i++) {
		FileInZipInfo *info= [self getCurrentFileInZipInfo];
		[files addObject:info];

		if ((i +1) < num)
			[self goToNextFileInZip];
	}

	return files;
}

- (void) goToFirstFileInZip {
	if (_mode != ZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[[ZipException alloc] initWithReason:reason] autorelease];
	}
	
	int err= unzGoToFirstFile(_unzFile);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error going to first file in zip in '%@'", _fileName];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
}

- (BOOL) goToNextFileInZip {
	if (_mode != ZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[[ZipException alloc] initWithReason:reason] autorelease];
	}
	
	int err= unzGoToNextFile(_unzFile);
	if (err == UNZ_END_OF_LIST_OF_FILE)
		return NO;

	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error going to next file in zip in '%@'", _fileName];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	return YES;
}

- (BOOL) locateFileInZip:(NSString *)fileNameInZip {
	if (_mode != ZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[[ZipException alloc] initWithReason:reason] autorelease];
	}
	
	int err= unzLocateFile(_unzFile, [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding], NULL);
	if (err == UNZ_END_OF_LIST_OF_FILE)
		return NO;

	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error locating file in zip in '%@'", _fileName];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	return YES;
}

- (FileInZipInfo *) getCurrentFileInZipInfo {
	if (_mode != ZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[[ZipException alloc] initWithReason:reason] autorelease];
	}

	char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
	unz_file_info64 file_info;
	
	int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	NSString *name= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
	
	ZipCompressionLevel level= ZipCompressionLevelNone;
	if (file_info.compression_method != 0) {
		switch ((file_info.flag & 0x6) / 2) {
			case 0:
				level= ZipCompressionLevelDefault;
				break;
				
			case 1:
				level= ZipCompressionLevelBest;
				break;
				
			default:
				level= ZipCompressionLevelFastest;
				break;
		}
	}
	
	BOOL crypted= ((file_info.flag & 1) != 0);
	
	NSDateComponents *components= [[[NSDateComponents alloc] init] autorelease];
	[components setDay:file_info.tmu_date.tm_mday];
	[components setMonth:file_info.tmu_date.tm_mon +1];
	[components setYear:file_info.tmu_date.tm_year];
	[components setHour:file_info.tmu_date.tm_hour];
	[components setMinute:file_info.tmu_date.tm_min];
	[components setSecond:file_info.tmu_date.tm_sec];
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDate *date= [calendar dateFromComponents:components];
	
	FileInZipInfo *info= [[FileInZipInfo alloc] initWithName:name length:file_info.uncompressed_size level:level crypted:crypted size:file_info.compressed_size date:date crc32:file_info.crc];
	return [info autorelease];
}

- (ZipReadStream *) readCurrentFileInZip {
	if (_mode != ZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[[ZipException alloc] initWithReason:reason] autorelease];
	}

	char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
	unz_file_info64 file_info;
	
	int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	NSString *fileNameInZip= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
	
	err= unzOpenCurrentFilePassword(_unzFile, NULL);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening current file in '%@'", _fileName];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	return [[[ZipReadStream alloc] initWithUnzFileStruct:_unzFile fileNameInZip:fileNameInZip] autorelease];
}

- (ZipReadStream *) readCurrentFileInZipWithPassword:(NSString *)password {
	if (_mode != ZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[[ZipException alloc] initWithReason:reason] autorelease];
	}
	
	char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
	unz_file_info64 file_info;
	
	int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	NSString *fileNameInZip= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];

	err= unzOpenCurrentFilePassword(_unzFile, [password cStringUsingEncoding:NSUTF8StringEncoding]);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening current file in '%@'", _fileName];
		@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
	}
	
	return [[[ZipReadStream alloc] initWithUnzFileStruct:_unzFile fileNameInZip:fileNameInZip] autorelease];
}

- (void) close {
	switch (_mode) {
		case ZipFileModeUnzip: {
			int err= unzClose(_unzFile);
			if (err != UNZ_OK) {
				NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", _fileName];
				@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
			}
			break;
		}
			
		case ZipFileModeCreate: {
			int err= zipClose(_zipFile, NULL);
			if (err != ZIP_OK) {
				NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", _fileName];
				@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
			}
			break;
		}
			
		case ZipFileModeAppend: {
			int err= zipClose(_zipFile, NULL);
			if (err != ZIP_OK) {
				NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", _fileName];
				@throw [[[ZipException alloc] initWithError:err reason:reason] autorelease];
			}
			break;
		}

		default: {
			NSString *reason= [NSString stringWithFormat:@"Unknown mode %d", _mode];
			@throw [[[ZipException alloc] initWithReason:reason] autorelease];
		}
	}
}


// Format from http://newsgroups.derkeiler.com/Archive/Comp/comp.os.msdos.programmer/2009-04/msg00060.html
// Two consecutive words, or a longword, YYYYYYYMMMMDDDDD hhhhhmmmmmmsssss
// YYYYYYY is years from 1980 = 0
// sssss is (seconds/2).
//
// 3658 = 0011 0110 0101 1000 = 0011011 0010 11000 = 27 2 24 = 2007-02-24
// 7423 = 0111 0100 0010 0011 - 01110 100001 00011 = 14 33 2 = 14:33:06
+ (NSDate *)_dateWithMSDOSFormat:(UInt32)msdosDateTime {
    static const UInt32 kYearMask = 0xFE000000;
    static const UInt32 kMonthMask = 0x1E00000;
    static const UInt32 kDayMask = 0x1F0000;
    static const UInt32 kHourMask = 0xF800;
    static const UInt32 kMinuteMask = 0x7E0;
    static const UInt32 kSecondMask = 0x1F;
    
    static NSCalendar *gregorian;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef __IPHONE_8_0
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#else
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
#endif
    });
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSAssert(0xFFFFFFFF == (kYearMask | kMonthMask | kDayMask | kHourMask | kMinuteMask | kSecondMask), @"[Objective-Zip] MSDOS date masks don't add up");
    
    [components setYear:1980 + ((msdosDateTime & kYearMask) >> 25)];
    [components setMonth:(msdosDateTime & kMonthMask) >> 21];
    [components setDay:(msdosDateTime & kDayMask) >> 16];
    [components setHour:(msdosDateTime & kHourMask) >> 11];
    [components setMinute:(msdosDateTime & kMinuteMask) >> 5];
    [components setSecond:(msdosDateTime & kSecondMask) * 2];
    
    NSDate *date = [NSDate dateWithTimeInterval:0 sinceDate:[gregorian dateFromComponents:components]];
    
#if !__has_feature(objc_arc)
    [components release];
#endif
    
    return date;
}


@end
