# iOS PXE 3.0.2 SDK

## What's New
The new iOS PXE 3.0 SDK release contains some new features and some major refactoring. 

 1. Download By Chapter
 2. New Notes and Highlights User Interface
 3. New PXE_NotebookEvent Notification
 4. Support for Custom Basket API

***

### The PxePlayer Sample App
The PxePlayer Sample App implements the new iOS PXE 3.0 SDK and provides examples of how to use it. Just open the `PxeReaderSampleWorkspace.xcworkspace` in the PxePlayerSampleApp directory to get started.

***

### Moved Properties
As part of the refactoring involved in the PXE 3.0 release, certain properties directly related to the PxePlayer user interface that had been placed in `PxePlayerDataInterface` have been moved to the more appropriate `PxePlayerPageViewOptions` . This includes the following:

 1. `bookTheme` - NSString variable to hold the book page theme (day, night, sepia)
 2. `bookFont` - NSInteger variable to hold the book page font size
 3. `labelProvider` - An optional object to provide custom labels for annotations and bookmarks
 4. `printPageSupport` - BOOL that indicates whether Print Page display is supported
 5. `hostWhiteList` - Array of known hosts whos served content must appear inline (embedded)
 6. `hostExternalList` - Array of known hosts whos content must appear externally in Safari
 
### New Properties
We now use a property `assetId` in `PxePlayerDataInterface` to specify an ePub file rather than `contextId` as in the 2.X versions of PXE. For all chapter and book downloads, the ePub file will be named using the assetId. If an assetId is not provided, the `contextId` will be used and it will be assumed that the `PxePlayerDataInterface` is referencing the entire book.

***
 
### Download By Chapter
This new feature gives our client applications the ability to offer their users the choice to download smaller ePub files for individual chapters or the very large ePub file for an entire text book (when that functionality is available for a particular title).

The iOS PXE SDK will automatically check the new Manifest API for any data regarding the availablilty of ePubs by chapter as part of the download process. You can retrieve that data by calling the following method in PxePlayer:

```
[pxePlayer retrieveManifestItemsForDataInterface:dataInterface 
                           withCompletionHandler:^(PxePlayerManifest *manifest, NSError *error) {
    ...
    }];
```

If available, the completion handler will receive a `PxePlayerManifest` object that should contain an `items` array  of `PxePlayerManifestItem` objects. Here are the properties:

```
PxePlayerManifest
@property (nonatomic, assign) NSNumber *totalSize;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *epubFileName;
@property (nonatomic, strong) NSString *bookTitle;
@property (nonatomic, strong) NSString *contextId;
@property (nonatomic, strong) NSString *fullUrl;
@property (nonatomic, strong) NSArray *items;

PxePlayerManifestItem
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) NSString *assetId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *epubFileName;
@property (nonatomic, assign) BOOL isDownloaded;
```

The iOS PXE SDK refers to the ePub files as assets and uses an `assetId` to identify them. For individual chapter ePub files, the `assetId` found in the `PxePlayerManifestItem` object is used. The ePub file for the entire book uses the `contextId` as it's `assetId`. 

Most methods which previously referred specifically to the `contextId` have been deprecated in the `PxePlayerDownloadManager` in favor of `assetId`.  For example,

```
- (PxePlayerDownloadContext *) getDownloadContextWithContextId:(NSString*)contextId
```
 
has been deprecated in favor of

```
- (PxePlayerDownloadContext *) getDownloadContextWithAssetId:(NSString*)assetId;
```

(Please see the `PxePlayerDownloadManager.h` header for more detailed information.)

#### Offline Page Navigation
In order to get a clear idea of expected behavior, let's look at a hypothetical situation in which a user has downloaded chapters 3 and 5 of a book and is reading their content offline. 

##### Next and Previous Page
As the user navigates to the next page beyond the last page of chapter 3, they will automatically be forwarded to the first page of chapter 5. Going back from the first page of Chapter 5 will take them to the last page of Chapter 3. 

##### Page Jumps
If the user attempt to jump to a page that has not been downloaded (for instance, a page in Chapter 7), PXE will broadcast a `PXEPLAYER_PAGE_FAILED` notification containing a `PxePlayerNavigationError` with a localized description "Cannot jump to invalid page number".

##### FirstPage
While offline, PXE will consider the first page of the book to be the first page of Chapter 3 and will notify accordingly with a PXE_Navigation notification.

##### Last Page
While offline, PXE will consider the last page of the book to be the last page of Chapter 5 and will notify accordingly with a PXE_Navigation notification.

*** 

### Notes and Highlights

Although nothing in regard to the new Notes and Highlights interface requires any code changes to PXE client applications, it should be noted that the UIMenuController had to be swizzled in order to match with the latest UX design. `UIMenuItem+CXAImageSUpport` was used (https://github.com/cxa/UIMenuItem-CXAImageSupport) so reference this should you encounter any conflicts.

***

## Getting Started With PXE
The following example is a typical way to start using the PXE 3.0 SDK. (This code was taken from the Login screen of the PxePlayer Sample App.)

```
PxePlayerEnvironmentContext *environmentContext = [[PxePlayerEnvironmentContext alloc] initWithWebAPIEndpoint:@"http://paperapi-qa.stg-openclass.com/"
                                                                                         searchServerEndpoint:@"http://dragonfly-qa.stg-openclass.com/"
                                                                                          pxeServicesEndpoint:@"http://pxe-sdk-qa.stg-openclass.com/"
                                                                                               pxeSDKEndpoint:@"http://pxe-sdk-qa.stg-openclass.com/"];
NSError* error;
BOOL success = [[PxePlayer sharedInstance] updatePxeEnvironment:environmentContext error:&error];
if (success)
{
    PxePlayerUser *ppu = [PxePlayerUser new];
    ppu.identityId = self.username.text;
    ppu.authToken = @"ST-4317-TF0dxzcSq7LLdVOLrbpd-b3-rumba-int-01-02";

    [[PxePlayer sharedInstance] setCurrentUser:ppu];
} else {
    NSLog(@"Error Updating PxePlayerEnvironemnt: %@", error);
}
```

Note that the `PxePlayer` is still a Singleton so there is no allocation of an instance. The `updatePxeEnvironment` method receives the PxePlayerEnvironmentContext object and an NSError object. It will return a boolean based on the success of the update. If it was a success, the current `PxePlayerUser` is set. If not, the error that was passed in is displayed. A more detailed explanation of the various parts of this initialization follows.

*** 

## PxePlayerEnvironmentContext
The Service URLs for PXE are now configurable by using the `PxePlayerEnvironmentContext`. This has to be done at the beginning of a PXE session before anything else is attempted.

```
PxePlayerEnvironmentContext *environmentContext = [[PxePlayerEnvironmentContext alloc] initWithWebAPIEndpoint:@"http://paperapi-qa.stg-openclass.com/"
                                                                                         searchServerEndpoint:@"http://dragonfly-qa.stg-openclass.com/"
                                                                                          pxeServicesEndpoint:@"http://pxe-sdk-qa.stg-openclass.com/"
                                                                                               pxeSDKEndpoint:@"http://pxe-sdk-qa.stg-openclass.com/"];
```

or

```
PxePlayerEnvironmentContext *environmentContext = [PxePlayerEnvironmentContext new]; 
[environmentContext setWebAPIURL:@"http://paperapi-qa.stg-openclass.com/"];
[environmentContext setSearchServerURL:@"http://dragonfly-qa.stg-openclass.com/"];
[environmentContext setPxeServicesURL:@"http://pxe-sdk-qa.stg-openclass.com/"];
[environmentContext setPxeSDKURL:@"http://pxe-sdk-qa.stg-openclass.com/"];
```
### Migrating from 2.X versions of PXE

#### PXE SDK URL
Check with the eRPS (formerly PXE) team to see if this needs to be changed. There were quite a few modifications made to the previous javascript SDK in order to handle the new Notes and Highlights user experience. A new javascript bundle will have to downloaded.

*** 

## Identity ID
You must set the current user as soon as possible to assure that data is stored and retrieved properly.

```
PxePlayerUser *pxePlayerUser = [PxePlayerUser new];
pxePlayerUser.identityId = self.userId;
pxePlayerUser.authToken = self.authToken;

[[PxePlayer sharedInstance] setCurrentUser:pxePlayerUser];
```

*** 

## PxePlayerDataInterface
The purpose of the `PxePlayerDataInterface` object is to provide the properties required for retrieving and storing data associated with a title (table of contents, manifest, annotations, bookmarks, glossary, search) and is required for viewing and/or downloading a title. Previous versions of the PXE SDK had included properties associated with page navigation and display to the data interface. Those properties have been appropriately reassigned to the `PxePlayerPageViewOptions` object. 
<p></p>
The newest property added to the data interface is `assetId`. This is used to reference downloaded ePub files and comes from the manifest data. If an `assetId` is not provided in the data interface, the `contextId` is passed through the getter and the download manager knows that the the data interface is referencing the entire book.
<p></p>
Refer to the `PxePlayerDataInterface.h` header file for all its properties as well as a brief description of each.

### baseURLs?
When a user downloads an ePub package to their device, it's _offline_ path is where PXE looks no matter whether the device is online or offline. Still, some functionality, like Search and Glossary, require an _online_ path to be submitted for indexing. This is why PXE needs both the `offlineBaseURL` and the `onlineBaseURL` provided. The idea of the base URL is that any relative path can be appended to it to create an accurate absolute URI.

```
dataInterface.onlineBaseURL  = @"https://content.openclass.com/eps/pearson-reader/api/item/9d156801-1289-4b74-902e-ea82e2eeb502/1/file/A_Changing_Planet";
dataInterface.offlineBaseURL = [[PATH_OF_DOCUMENT stringByAppendingPathComponent:bookInfo[@"contextId"]] stringByAppendingPathExtension:@"epub"];
```

#### Online Base URL
The onlineBaseURL path should lead right up to but not include the content (toc, html folders, images, etc.). This is all usually contained within the OPS folder. The following example shows how to determine the base URL from an absolute uri.

```
tocAbsoluteURI = "http://content.openclass.com/eps/sanvan/api/item/04e13dd6-c3af-4e5a-ac79-bffd25c82fa0/1/file/Dye_1_14_15/OPS/xhtml/introduction.xhtml"

basePath = "http://content.openclass.com/eps/sanvan/api/item/04e13dd6-c3af-4e5a-ac79-bffd25c82fa0/1/file/Dye_1_14_15/"
```

It's not necessary to worry about whether the path should end with a "/" or not.

PxePlayer offers a helper method, `getOnlineBaseURLFromTOCAbsoluteURL`, to pull the base URL out of the absolute path to the TOC but it only works if there is an "OPS/" in the url to start.

```
if ([dataInterface.tocPath rangeOfString:@"toc.ncx"].location != NSNotFound)
{
    dataInterface.onlineBaseURL = [self.pxePlayer getOnlineBaseURLFromTOCAbsoluteURL:self.currentCourse.courseBook.ncxUrl];
}
```

#### Offline Base URL
The offlineBaseURL should be the local file path to the downloaded (or soon-to-be-downloaded) ePub file.

The following is a basic method of dynamically building the offline base URL.

```
NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
NSString *offlineBaseURL = [NSString stringWithFormat: @"%@/%@.epub", documentDir, contextId];
```

Note that downloaded content should be stored in the Library directory as opposed to the Documents directory.

### tocPath
The toc path __should__ be a relative one and must be something that can be appended to the base URL to complete the absolute URI.

```
tocPath = @"xhtml/toc.xhtml"
```

### indexId
Previous versions of PXE would resubmit the tocPath to the indexing service to retrieve the indexId used for search and for glossary services. Problems arise when the original book is indexed using one TOC URL and the current TOC is different (perhaps the book was indexed with http and the current TOC path uses the https schema). To help avoid confusion, you can now submit the indexId returned from the bookshelf services and PXE will skip the "submitting of the TOC path for indexing" step in the loading process.

***

## AppDelegate
If you want your application to receive local notifications when background downloads are complete, you need to add/update the following to your app delegate:

```
-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.backgroundTransferCompletionHandler = completionHandler;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    // Override point for customization after application launch.
    // NEEDED TO DISPLAY BACKGROUND DOWNLOAD MESSAGES FOR OFFLINE
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0; //for online
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
```

***

## PxePlayerPageViewOptions
`PxePlayerPageViewOptions` are a collection of properties used to configure the `PxePlayerPageViewController` and are passed through the render method in `PxePlayer`.

```
[[PxePlayer sharedInstance] renderWithOptions:pageViewOptions];
```

The following are configurable options for initializing the `PxePlayerPageViewController`. 

1. `BOOL shouldAllowPageSwipe` - allows page swiping, Defaults to YES
2. `NSUInteger transitionStyle` - Defaults to UIPageViewControllerTransitionStylePageCurl (not currently configurable at this time)
3. `BOOL scalePage` - Defaults to NO (not currently an option due to CSS limitations on content)
4. `PxePlayerPageViewBacklinkMapping *backlinkMapping` - Options for backlinking (linking back to an app or web app that launched you)
5. `BOOL printPageSupport` - If your app requires print page jump support (when users need to jump to a corresponding printed book page number in the ePub book), set this parameter to `YES`. This will result in the print page numbers being displayed on the far left of the page. The default value for this is `NO`.<p></p>
6. `NSArray *hostWhiteList` - To help assure that audio and video that is supposed to be embedded in a page does not open in PXE's internal browser or lightbox, we've added a host whitelist to hold urls for content servers that are internal and whose content is assured to always stay embedded. You can either add urls to the data interface one at a time:
<p></p>`[dataInterface addHostToWhiteList:@"mediaplayer.pearsoncmg.com"];`<p></p>You can also add an entire array of hosts at one time: <p></p>`[dataInterface addHostArrayToWhiteList: hostArray];` <p></p>By default, `mediaplayer.pearson.cmg` is added to the whitelist.<p></p>
7. `NSArray *hostExternalList` - Just as the `hostWhiteList` is for specifying known hosts for media that is supposed to playback embedded in a page, the `hostExternalList` is for specifying hosts that must be linked to externally from the app (e.g. jump to Safari). You would populate it the same way as the `hostWhiteList`, for example:<p></p>`[dataInterface addHostToExternalList:@"etext.pearsonxl.com"];`<p></p>
8. `BOOL useDefaultFontAndTheme` - Tells PXE to use default font and theme settings at start (in case no settings are provided). Default is YES. If set to NO, PXE will not pass any values to Javascript. 
9. `NSString bookTheme` - Variable to hold the book page theme (day, night, sepia)
10. `NSInteger fontSize` - Variable to hold the book page font size
11. `PxePlayerLabelProvider *labelProvider` - An optional object through which a client applications can provide custom labels for annotations and bookmarks. See below for more info about the labelProvider.

### Label Provider
Annotations (and Bookmarks) have an array property called labels. By default, PXE populates this property with the `pageTitle`. Some applications would like to customize this property with additional data. This can be done through the `PxePlayerLabelProvider`.

You must initialize the `PxePlayerLabelProvider` with a `PxePlayerLabelProviderDelegate`. The protocol for this delegate can be seen in the `PxePlayerLabelProvider` header. There is only one method required:

```
- (NSString *) provideLabelForPageWithPath:(NSString*)relativePath;
```

Once you have specified an object as the delegate, you can initialize a `PxePlayerLabelProvider`:

```
PxePlayerLabelProvider *labelProvider = [[PxePlayerLabelProvider alloc] initWithDelegate:self];
```

If the delegate you've specified is a Singleton, you can set the label provider in PXE through the `PxePlayerDataInterface`. If you prefer to use an object more closely associated with the container you use for the `PxePlayerPageViewController` (recommended), then you can initialize the label provider later and set it in PXE through the `PxePlayer` shared instance.

```
[[PxePlayer sharedInstance] setLabelProvider: labelProvider];
```

The following is an example of one way to set up the required protocol method:

```
// PxePlayerLabelProviderDelegate
- (NSString *) provideLabelForPageWithPath:(NSString *)relativePath
{
    NSDictionary *pageDetails = [[PxePlayer sharedInstance] getPageDetails:@"pageURL" withValue:relativePath];

    NSString *pageTitle = [pageDetails objectForKey:@"pageTitle"];

    NSMutableString *customLabel = [NSMutableString new];
    [customLabel appendFormat:@"{"];
    [customLabel appendFormat:@"\"pageTitle\":\"%@\",", pageTitle];
    [customLabel appendFormat:@"\"pageURL\":\"%@\"", relativePath];
    [customLabel appendFormat:@"}"];

    return customLabel;
}
```

Remember that this NSString will be injected into a javascript method within the `<head>` of each xhtml page. Here is an example of a JSON string generated from the above method:

```
{
    "pageTitle":"Video: Population Growth in Zambia",
    "pageURL":"s9ml/chapter03/video_population_growth_in_zambia.xhtml#data-uuid-498e293e642447c0b79d42d9cba61cb7"
}
```

And here is how that string would be used:

```
addAnnotationSupport("nextext_qauser1", 
                     "4PM49REXEKT", 
                     "introduction-data-uuid-76a6df4a820a4c39bb26c0620819ae2f", 
                     "s9ml/chapter03/video_population_growth_in_zambia.xhtml#data-uuid-498e293e642447c0b79d42d9cba61cb7", 
                     true, 
                     "https://pxe-sdk-qa.stg-openclass.com/services-api/api", 
                     {"pageTitle":"Video: Population Growth in Zambia","pageURL":"s9ml/chapter03/video_population_growth_in_zambia.xhtml#data-uuid-498e293e642447c0b79d42d9cba61cb7"},
                     "https://content.openclass.com/eps/pearson-reader/api/item/9d156801-1289-4b74-902e-ea82e2eeb502/1/file/A_Changing_Planet");
```

Note that a value for the label property of an annotation will be inserted when the annotation is created. After that, it is never changed. Annotations that were created prior to implementing the `PxePlayerLabelProvider` will contain the default `pageTitle` value.

For a working example, please refer to the PxePlayer Sample Application.

All current and future PageView options will be set through the `PxePlayerPageViewOptions` properties when you call `PxePlayer` to `renderWithOptions:`.

```
//Default Option settings
PxePlayerPageViewOptions *pageViewOptions = [PxePlayerPageViewOptions new];
pageViewOptions.shouldAllowPageSwipe = YES;
pageViewOptions.transitionStyle = UIPageViewControllerTransitionStylePageCurl;
pageViewOptions.scalePage = NO;

PxePlayerLabelProvider *labelProvider = [[PxePlayerLabelProvider alloc] initWithDelegate:self];
pageViewOptions.labelProvider = labelProvider;

self.pageViewController = [[PxePlayer sharedInstance] renderWithOptions:pageViewOptions];
```

### Backlink Mapping
Backlink Mapping is a way for PXE content to link back to a learning application that launched it. Links in the content are to be wrapped with user and  course information and appropriate query parameters. Here's an example of a link:

```
<a href="https://etext.pearsonxl.com/etextlink.aspx?
            custom_targetId=assignedhomework&
            custom_chapterId=1&
            userparamName=etextuser1&
            courseParamName=course1" 
        class="lms-link" 
        id="12345" 
        data-lms="xl-he" 
        data-lms-linksdesc="something_to_help_Editorial_identify">Math XL.</a>
```

To enable backlink mapping, a `PxePlayerPageViewBacklinkMapping` object needs to be supplied with the `PxePlayerPageViewOptions` object. This object has 4 NSString properties that hold JSON strings. They are required to initialize the PXE Javascript SDK. 

```
@property (nonatomic, retain) NSString *backlinkCSVMappings;
@property (nonatomic, retain) NSString *backlinkLaunchParams;
@property (nonatomic, retain) NSString *backlinkEndpointMapping;
@property (nonatomic, retain) NSString *backlinkSignatureEndpoint;
```

Refer to this document (https://docs.google.com/document/d/1Y4kti-JtHwQndygUJXLBatMSow6SNKsUkHatjMEl64Y/edit#) for detailed information about these properties.

Note that `backlinkSignatureEndpoint` refers to the Url of the client application (e.g. eText) launchParams API (e.g. url for QA https://paperapi-qa.stg-openclass.com/nextext-api/api/nextext/backlink/launchparams/book/4PM49REXEKT).

***

## PxePlayerDownloadManager
The new `PxePlayerDownloadManager` is used to download ePub assets (books, chapters, packages, etc) to a device. It is a Singleton so you access it through a call to a shared Instance.

```
[PxePlayerDownloadManager sharedInstance]
```

### Update The Download Manager
Just as you update the `PxePlayer` shared instance with the `PxePlayerDataInterface`, you do the same to the Download Manager (`PxePlayerDownloadManager` operates independant of `PxePlayer`).

```
[[PxePlayerDownloadManager sharedInstance] updateWithDataInterface:self.dataInterface]; 
```

### The Download Context
Updating the download manager returns a `PxePlayerDownloadContext` object, a value-object that contains the data associated with the download file.

### Downloading Book Assets (i.e. chapters)
PXE iOS SDK provides a way for the client apps to see what book assets (chapters) are available for download. This information is contained in `PxePlayerManifest` object. To obtain this object client app needs to call method `retrieveManifestItemsForDataInterface: withCompletionHandler:` from PxePlayer class. An example of possible implementation in client app:

```
PxePlayer *pxePlayer = [PxePlayer sharedInstance];
self.assets = [[NSMutableArray alloc] init];
        
[pxePlayer retrieveManifestItemsForDataInterface:dataInterface
                           withCompletionHandler:^(PxePlayerManifest *manifest, NSError *error) {

    if (manifest) {
        if (error.code == PxePlayerNoManifestFoundInStore) { //the Paper API had no manifest available
            //more code
        }
        [self.assets addObjectsFromArray:manifest.items];
    }
}];
```

The array `self.assets` will have the objects in it of type `PxePlayerManifestItem`. Some of the properties of this object are assetId, fullUrl for asset downlod, size, title and isDownloaded. For conveniance PXE iOS SDK inputs the information about the entire book download as the first item of the `manifest.items` array. So if a book has 12 chapters then `manifest.items` arrays will contain 13 items: the first one about the entire book, the second about the first chapter, the third about the second chapter, so on and so forth. The title for the entire book download will be "Download book". The client app may change it to the actual title if desired. PXE iOS SDK keeps track of which of the assets have been downloaded or deleted using the isDownloaded property of type BOOL. 

The client app may display the information about assets in a UI element of choice such as UITableView holding custom UITableViewCell elements. To enable concurrent download of chapters the view controller containing the UITableView needs to be the delegate of PxePlayerDownloadManager (see `PxePlayerDownloadManagerDelegate` below for more information).

There may be cases where manifest is not available for a given book title. In this case PXE iOS SDK will still return `manifest.items` array which will contain one item - the information of the entire book download. Along with it an error is returned with the code of `PxePlayerNoManifestFoundInStore` so the client app may know the manifest is not stored in the local database. Consequently isDownloaded property value is not tracked in the local database. However, client apps may at any time verify the existance of the asset file by using `checkForDownloadedFileByAssetId:` method. For more information see Managing Your Downloads section below. This method can also be used as an alternative to the isDownloaded property for the assets for which book manifest does exist in the local database.

For more information on asset (book/chapter) download please refer to iOS Sample App and review `PxeReaderSampleDownloadManagerViewController` and `PxeReaderSampleDownloadTableViewCell`.

### PxePlayerDownloadManagerDelegate
As a `PxePlayerDownloadManagerDelegate`, your registered class instance can receive data in regard to downloads, i.e. success/failure or total bytes written/total bytes expected. This is an optional yet recommended step.

[[PxePlayerDownloadManager sharedInstance] setDelegate: self];

### Starting, Pausing, Stopping, or Deleting a Download
The following example shows how to start (or pause) downloading a context using the `assetId`.

PxePlayerDownloadContext *downloadContext = [[PxePlayerDownloadManager sharedInstance] getDownloadContextWithAssetId: self.assetId];
[[PxePlayerDownloadManager sharedInstance] startOrPauseDownloadingSingleFile:downloadContext];

### Update UI
There are a couple of ways the UI can be updated. 

1. Notifications<br>
`[[NSNotificationCenter defaultCenter] postNotificationName:BOOK_DOWNLOAD_COMPLETE_NOTIFICATION object:self];`

2. Delegates

```
- (void) updateDownloadRequest:(PxePlayerDownloadContext*)downloadContext
             totalBytesWritten:(int64_t)totalBytesWritten
     totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
                  
-(void)updateUIElementsFinished:(PxePlayerDownloadContext *)ppdc 
                        atIndex:(int)index;

```

Stopping or deleting a download is very similiar. Please refer to the the PxePlayer Sample App for detailed examples.

### Available disk space
You can use the `PxePlayerDownloadManager` to find the available disk space on a device.

```
[[PxePlayerDownloadManager sharedInstance] getFreeDiskspace];
```

### Managing Your Downloads
Although you use PXE to download your ePub files, PXE does not manage them for you. It's up to your app to manage what's to be saved or deleted from the device. To help in detecting if a context exists locally, `PxePlayerDownloadManager` offers a method to search for a downloaded context on the device based on the asset id.

```
[[PxePlayerDownloadManager sharedInstance] checkForDownloadedFileByAssetId: self.dataInterface.assetId];
```

***

## Annotations (Notes and Highlights)
To retrieve a complete list of Annotations for the current context, you call the following method in the PxePlayer instance.

```
[[PxePlayer sharedInstance] getAnnotationsWithCompletionHandler:^(PxePlayerAnnotationsTypes *pxePlayerAnnotationsTypes, NSError *error) {
    ...
}];
```

The `PxePlayerAnnotationsTypes` object contains two `PxePlayerAnnotations` objects; one named `myAnnotations` (contains those annotations created by the user) and the other named `sharedAnnotations` (annotations shared with the user by others, e.g., an instructor).

Each `PxePlayerAnnotations` object contains a `contentsAnnotations` mutable dictionary with entries keyed by relative page URIs. Each entry value is an array of `PxePlayerAnnotation` objects associated with that URI.

A visual representation of the `PxePlayerAnnotationsTypes` object can be seen in the following example. Note that in addition to the properties that describe the annotation, `PxePlayerAnnotation` also contains an `appData` NSDictionary property that can be used for attaching application specific data. 

```
{
    myAnnotations (PxePlayerAnnotations) :
    { 
        myContentsAnnotations: 
        {
            "s9ml/imported_files01/14_3_america_enters_world_war_ii.xhtml" =     (
                "PxePlayerAnnotation:    annotationDttm: 1426549426691    colorCode: #FFD231    isMathML: NO    labels: (    Introduction)   noteText: A day that will live in  infamy \n   selectedText: A surprise attack on Pearl Harbor,    range: 2:26,2:31   contentId:     shareable: NO   uri:   appData: "
                );
            "s9ml/imported_files01/reader_9.xhtml" =     (
                "PxePlayerAnnotation:    annotationDttm: 1426549681036    colorCode: #FFD231    isMathML: NO    labels: (    "Message Asking for War Against Japan")    noteText: Who was the one?    selectedText: 388 to 1    range: 1:8,1:10    contentId:     shareable: NO   uri:   appData: ",
                "PxePlayerAnnotation:    annotationDttm: 1426550912966    colorCode: #FB91CF    isMathML: NO   labels: (    "Message Asking for War Against Japan")    noteText: The axis of evil    selectedText: Axis Powers.   range: 1:61,1:62    contentId:     shareable: NO   uri:   appData: "
            );
        }
    }
    sharedAnnotations (PxePlayerAnnotations) :
    ( 
        sharedContentsAnnotations1: 
        {
            "s9ml/imported_files01/14_3_america_enters_world_war_ii.xhtml" =     (
                "PxePlayerAnnotation:   annotationDttm: 1426549125681    colorCode: #FFD231    isMathML: NO    labels: (    "Introduction" )    noteText: A day that will live in  infamy    selectedText: A surprise attack on Pearl Harbor,    range: 2:26,2:31    contentId:    shareable: YES  uri:    appData: "
            );
            "s9ml/imported_files01/reader_9.xhtml" =     (
                "PxePlayerAnnotation:    annotationDttm: 1426549029951    colorCode: #FFD231   isMathML: NO    labels: (    "Message Asking for War Against Japan")    noteText: Who was the one?    selectedText: 388 to 1    range: 1:8,1:10    contentId:     shareable: YES   uri:    appData: "
            );
        }
        sharedContentsAnnotations2: 
        {
            "s9ml/imported_files02/14_4_america_enters_world_war_ii.xhtml" =     (
                "PxePlayerAnnotation:   annotationDttm: 1426549125681    colorCode: #FFD231    isMathML: NO    labels: (    "Introduction" )    noteText: A day that will live in  infamy    selectedText: A surprise attack on Pearl Harbor,    range: 2:26,2:31    contentId:    shareable: YES  uri:    appData: "
            );
            "s9ml/imported_files02/reader_12.xhtml" =     (
                "PxePlayerAnnotation:    annotationDttm: 1426549029951    colorCode: #FFD231   isMathML: NO    labels: (    "Message Asking for War Against Japan")    noteText: Who was the one?    selectedText: 388 to 1    range: 1:8,1:10    contentId:     shareable: YES   uri:    appData: "
            );
        }
    )
}
```

#### Scrolling to a Highlight on Page
Client app may allow user to scroll to a previously saved highlight. To do this the cient needs to simply send the annotation to eRPS iOS SDK as the `PxePlayerAnnotation` object. Here is an example code implementation:

```
@property (nonatomic, strong) PxePlayerPageViewController *pageViewController;

- (void) annotationSelectEventWithAnnotation:(PxePlayerAnnotation*)annotation
{
    [self.pageViewController jumpToAnnotation:annotation];
}
```

eRPS iOS SDK will navigate to the page containing the note and then scroll to the highlight in the web view.

##### Error Handling
The SDK validates the sent annotation object and reports error accordingly. The receive those the client app needs to listen to `PXEPLAYER_PAGE_FAILED` notification to review and parse error(s)

```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoadFailure:) name:PXEPLAYER_PAGE_FAILED object:nil];
```

In the notification's `userInfo` dictionary object the error indicating the problem is under `NSUnderlyingError` key.

```
-(void)receiveLoadFailure:(NSNotification*)notification
{
   NSError *specificError = [notification.userInfo objectForKey:NSUnderlyingErrorKey]; 
}
```

Possible error codes are:

30 - PxePlayerMissingAnnotationError - nill annotation object passed  
31 - PxePlayerMissingAnnotationIdError - annotation id is missing in annotation object passed (annotationDttm)  
1  - PxePlayerInvalidURL - if url for page is missing in the passed annotation object  

### Limitations of 3.0 Release
The iOS PXE 3.0 release does not support inserting, updating, or deleting Annotations offline because synching policies are not yet agreed upon.

Your application might require some additional programming to warn users about this limitation. The Notes and Highlights pop up does currently warn the user about this.

#### Group by Color
By default, the `contentsAnnotations` dictionary in the `PxePlayerAnnotations` object contains entries keyed on the URI. You can also acquire the contentsAnnotations keyed by color code:

```
NSDictionary *contentsAnnotationsByColor = pxePlayerAnnotations.contentsAnnotationsByColor;
```

Of course, if you want all of the annotations combined into one object with the annotations grouped by color, you can do the following:

```
PxePlayerAnnotations *allAnnotationsGroupedByColor = pxePlayerAnnotationsTypes.combinedAnnotationsByColor;
```

* * *

## Bookmarks


### Limitations of 3.0 Release
The iOS PXE 3.0 release does not support inserting, updating, or deleting Bookmarks offline because synching policies are not yet agreed upon.

Your application might require some additional programming to warn users about this limitation.

* * *

## Glossary

Here is the key/value structure of a glossary object dictionary:

```
NSDictionary *glossaryObj = @{
        @"term" : glossary.term  /*formerly "dfn"*/, 
         @"key" : glossary.key /*formerly "h4"*/,
  @"definition" : glossary.definition /*formerly "p"*/
 }; 
```                           

* * * 

## Additional Features

### Scrolling to the top or bottom of a page
PXE already sends out notifications when pages start and stop scrolling. We've added some `userInfo` to the `PXE_ContentStoppedScrolling` notification so you can tell if the content is at the top or bottom of the page.
Here's an example of what to do...

```
#import "PxePlayerUIEvents.h"
#import "PxePlayerUIConstants.h"
    ...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentStartedScrolling:) name:PXE_ContentStartedScrolling object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentStoppedScrolling:) name:PXE_ContentStoppedScrolling object:nil];
    ...
    - (void) contentStoppedScrolling:(NSNotification*)notification
    {
        NSDictionary *scrollPositionDict = notification.userInfo;
        NSString *scrollPosition = [scrollPositionDict objectForKey:@"position"];
        if (scrollPosition)
        {
            if ([scrollPosition isEqualToString:PXEPLAYER_TOP])
            {
                ...
            }
            else if ([scrollPosition isEqualToString:PXEPLAYER_BOTTOM])
            {
                ...
            }
        }
    }
```

### Scrolling Up and Down
You might need to take an action depending on whether the content is scrolling up or down. To do this, add an observer for the PXE_ContentScrolling event.

```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentScrolling:) name:PXE_ContentScrolling object:nil];
...
- (void) contentScrolling:(NSNotification*)notification
{
	NSDictionary *scrollDict = notification.userInfo;
    NSString *scrollDirection = [scrollDict objectForKey:PXEPLAYER_DIRECTION];
	if	(scrollDirection)
	{
		if (scrollDirection isEqualToString:PXEPLAYER_DIRECTION_UP)
		{
			[self showThatThingYouNeedToShow];
		}
		else if (scrollDirection isEqualToString:PXEPLAYER_DIRECTION_DOWN)
		{
			[self hideThatThingThatYouWereShowing];
		}
	}
}
```

### Notifications for First and Last Page
PXE now sends out `PXE_Navigation` notifications (one of the `PxePlayerUIEvents`) when it has navigated to the first or last page of a context. You just have to add a PXE_Navigation observer.

```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationNotifications:) name:PXE_Navigation object:nil];
```

To determine if you have reached the first page or last page, you would look for the `navigation` key in the notification's userInfo and check the value.

```
- (void) navigationNotifications:(NSNotification *)notification
{
    NSDictionary *navDict = notification.userInfo;

    NSString *navPage = [navDict objectForKey:@"navigation"];

    if ([navPage isEqualToString: PXEPLAYER_FIRSTPAGE])
    {
        // Hide the back button in the navigation control
    } 
    else if ([navPage isEqualToString: PXEPLAYER_LASTPAGE])
    {
        // Hide the forward button in the navigation control
    }
    else if ([navPage isEqualToString: PXEPLAYER_MIDDLEPAGE])
    {
        // Show both nav buttons
    } 
}
```

### Notifications for Widget Events
When PXE receives javascript onWidgetEvents, it parses and decodes them and then forwards them as  as `PXE_WidgetEvent` notifications.

```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(widgetNotifications:) name:PXE_WidgetEvent object:nil];
```

The userInfo dictionary will contain the message received plus the relative URL of the page from which the event originated. For example:

```
{
    clientId = 1436474638483;
    method = "queue-3167101122918928900";
    msgOrigin = pxelifecycle;
    page = "OPS/s9ml/front_matter/filep7000496628000000000000000021b4f.xhtml#b3e5c88163ff401bb821dd8c3a99b1d9";
    type = "__internal";
}
```

### Notifications for Page Click Events
When PXE receives javascript onPageClickEvent, it parses and decodes them and then forwards them as  as `PXE_PageClickEvent` notifications.

```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageClickNotifications:) name:PXE_PageClickEvent object:nil];
```

The userInfo dictionary will contain the message received plus the relative URL of the page from which the event originated. For example:

```
{
    method = domClick;
    msgOrigin = widget;
    page = "OPS/s9ml/front_matter/cover.xhtml";
    payload =     {
        clickType = "Left click";
    };
    type = data;
}
```

### Notifications for Notebook Events
When PXE receives javascript onNotebookPrompt pxe-frame event, it parses and decodes them and then forwards them as  as `PXE_NotebookEvent` notifications.

```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notebookNotifications:) name:PXE_NotebookEvent object:nil];
```

The userInfo dictionary will contain the message received plus the relative URL of the page from which the event originated. For example:

```
{
    msgOrigin = pxe;
    page = "OPS/s9ml/chapter02/filep7000495165000000000000000000005.xhtml";
    prompts =     (
                {
            id = "discussit_gp_q001";
            question = "\n         What do you think draws people to dangerous activities, such as diving with sharks?\n        ";
            tag = Activity;
        },
                {
            id = "discussit_gp_q002";
            question = "\n         Question 2: What do you think draws people to dangerous activities, such as diving with sharks?\n        ";
            tag = activity2;
        },
                {
            id = "discussit_gp_q003";
            question = "\n         Question 3: What do you think draws people to dangerous activities, such as diving with sharks?\n        ";
            tag = activity3;
        }
    );
    triggeredPromptIndex = 0;
    type = onNotebookPrompt;
}
```

### Jumping to a Digital Page using a Print Page number
Imagine a classroom scenario where the instructor tells the class to turn to page 128 in their text books. The students using digital text books would be at a loss since page 128 in their digital text book would have different content from page 128 in a printed text book.

Now, if the content supports it, you can jump to the digital equivalent of a print page by calling one of the following methods:

```
- (void) jumpToPrintPage:(NSString*)printPageNumber;
```

or

```
- (void) jumpToPrintPage:(NSString*)printPageNumber onComplete:(void (^)(BOOL success, NSNumber *digitalPage, NSString *pageURL))handler;
```

See the PXE Reader Sample app for an example on how to use this feature. 

Also, don't forget to set the `printPageJumpSupport` property to `YES` (true) in the `PxePlayerDataInterface` if you want the print page numbers to be visible in the left margin of the page. By default, it is set to `NO` (false).

### Resetting User's Auth Token and Learning Context in PXE
If client app attempts to navigate to a quiz page and the learning context contains an expired token the quiz page will not show.
PXE SDK exposes these two methods to reset the token and learning context:

```
self.pxePlayer = [PxePlayer sharedInstance];
[self.pxePlayer resetAuthToken:myRefreshedToken];

[self.pxePlayer resetLearningContext:myNewLearningContext];
```

Please note that there may be other properties at play which may have to be reset, such as content auth token, content auth token name and cookie domain. PXE already allows you to do that and you can find the setters for all three properties in `PxePlayer.h`.

