//
//  PxePlayerNotesHighlights.m
//  PxeReader
//
//  Created by Mason, Darren J on 9/17/14.
//  Copyright (c) 2014 Pearson. All rights reserved.
//

//TODO:Redo this in a more user friendly fashion

#import "PxePlayerNotesHighlights.h"
#import "PxePlayer.h"
#import "PxePlayerAnnotation.h"
#import "PXEPlayerMacro.h"
#import "Reachability.h"
#import "NSString+Extension.h"
#import "PxePlayerError.h"
#import "PXEPlayerUIConstants.h"

#define _PXE_PLACE_HOLDER_TEXT @"Add a Note (optional)"
#define _PXE_SAVE_TEXT @"Saving..."
#define _PXE_SHARE_TEXT @"Share with Students"
#define _PXE_DELETE_TEXT @"Delete"
#define _PXE_PLACEHOLDER_TEXT @"Untitled Expression"

#define PXE_ANNOTATION_NOTES_HEIGHT 106
#define PXE_ANNOTATION_WARNING_HEIGHT 44
#define PXE_ANNOTATION_WARNING_TEXT NSLocalizedString(@"Offline. Cannot make changes.", nil)
#define PXE_HIGHLIGHT_FRAME_HEIGHT 280
#define PXE_SMALL_PHONE_MAX_HEIGHT 600
#define PXE_SMALL_PHONE_MAX_WIDTH 400
#define PXE_HIGHLIGHT_FRAME_MARGIN 200
#define PXE_PHONE_LANDSCAPE_WIDTH_MARGIN 50
#define PXE_PHONE_LANDSCAPE_HEIGHT_MARGIN 150
#define PXE_KEYBOARD_Y_COORDINATE_ADJUSTER 75.0
#define PXE_KEYBOARD_Y_COORDINATE_ADJUSTER_iOS7 40.0
#define PXE_ANNOTATION_CHARACTER_LIMIT 3000

@interface PxePlayerNotesHighlights ()

@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) NSUInteger editNote;
@property (nonatomic, strong) NSString *bundlePath;
@property (nonatomic, assign) NSInteger currentColor;

@property (nonatomic, strong) NSMutableDictionary *annotationObj;

@end

Reachability* internetReachable;

CGRect notesTextOrigFrame;
CGRect keyboardFrame;

@implementation PxePlayerNotesHighlights

- (void) moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up
{
    CGRect keyboardEndFrame;
    NSDictionary* userInfo = [aNotification userInfo];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    keyboardFrame = [self convertRect:keyboardEndFrame toView:nil];
    
    CGRect movement;
    
    if(up)
    {
        movement = CGRectMake(self.highLightPopUp.frame.origin.x,
                              [self calculatePopUpYCoordinateBasedOnCurrentCoordinate:self.highLightPopUp.frame.origin.y
                                                                        keyboardHeight:keyboardFrame.size.height],
                              self.highLightPopUp.frame.size.width,
                              [self calculatePopUpHeightForCurrentHeight:self.highLightPopUp.frame.size.height
                                                     keyboardYCoordinate:[self calculateYCoordinateForKeyboard:keyboardFrame]]); //keyboardFrame.origin.y]);
    }
    else
    {
        movement = CGRectMake(self.highLightPopUp.frame.origin.x,
                              (self.highLightPopUp.frame.origin.y + keyboardFrame.size.height*0.5),
                              self.highLightPopUp.frame.size.width,
                              self.highLightPopUp.frame.size.height);
    
    }
    self.highLightPopUp.frame = movement;
}

-(float) calculatePopUpYCoordinateBasedOnCurrentCoordinate:(float)current
                                             keyboardHeight:(float)keyboardHeight {
    if (current - keyboardHeight*0.5 < 0) {
        return 0;
    }
    else {
        return current - keyboardHeight*0.5;
    }
}

-(float) calculatePopUpHeightForCurrentHeight:(float)currentHeight
                          keyboardYCoordinate:(float)keyboardYCoordinate {
    float yCoordinateAdjusted = (keyboardYCoordinate > 0) ? keyboardYCoordinate - [self adjustKeyboardHeight]
                                                          : [self provideCorrectSizeForScreenHeight:[UIScreen mainScreen].bounds.size.height]; //Fix for keyboard Y coord. = 0 if keyboard is not up
    if (currentHeight > yCoordinateAdjusted) {
        return yCoordinateAdjusted;
    }
    return currentHeight;
}

-(float) adjustKeyboardHeight {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0") && UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return PXE_KEYBOARD_Y_COORDINATE_ADJUSTER_iOS7;
    }
    
    return PXE_KEYBOARD_Y_COORDINATE_ADJUSTER;
}

-(float) calculateYCoordinateForKeyboard:(CGRect)keyboard {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        return [self provideCorrectSizeForScreenHeight:[UIScreen mainScreen].bounds.size.height] - keyboard.size.height;
    }

    return keyboard.origin.y;
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:YES];
    self.isEditing = YES;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:NO];
    self.isEditing = YES;
}

- (id)initWithSuperView:(PxePlayerPagesWebView*)view withMessage:(NSString*)jsonString andEvent:(NSString*)event
{
    DLog(@"Message: %@::::Event: %@", jsonString, event);
    self.parentView = view;
    CGRect frame  = view.frame;
    self = [super initWithFrame:view.frame];
    
    notesTextOrigFrame = CGRectMake(4, 50, self.highLightPopUp.frame.size.width-4, self.highLightPopUp.frame.size.height);
    
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.bundlePath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] bundlePath],@"PxeReaderResources.bundle"] ;
        
        self.webView = view;
        self.autoresizesSubviews = YES;
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight |
                                 UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleBottomMargin);
        
        UIScreen *mainScreen = [UIScreen mainScreen];
        
        //ipad all
        CGRect highlightFrame = CGRectMake(view.frame.size.width*0.5 - ((view.frame.size.width-PXE_HIGHLIGHT_FRAME_MARGIN)*0.5),
                                           (frame.size.height * 0.5)-PXE_PHONE_LANDSCAPE_HEIGHT_MARGIN,
                                           view.frame.size.width-PXE_HIGHLIGHT_FRAME_MARGIN, PXE_HIGHLIGHT_FRAME_HEIGHT);
        
        UIViewAutoresizing resizeMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
        
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        { //iphone only
            if(UIDeviceOrientationIsLandscape(deviceOrientation))
            {
                //iphone landscape
                if([self provideCorrectSizeForScreenWidth:mainScreen.bounds.size.width] < PXE_SMALL_PHONE_MAX_HEIGHT &&
                   [self provideCorrectSizeForScreenHeight:mainScreen.bounds.size.height] < PXE_SMALL_PHONE_MAX_WIDTH)
                {
                    //small screen like ipods and iphone 4
                    highlightFrame = CGRectMake(25, 0, frame.size.width-PXE_PHONE_LANDSCAPE_WIDTH_MARGIN,
                                                [self provideCorrectSizeForScreenHeight:mainScreen.bounds.size.height]-PXE_PHONE_LANDSCAPE_HEIGHT_MARGIN);
                }
                else
                {
                    highlightFrame = CGRectMake(25, 0, [self provideCorrectSizeForScreenWidth:mainScreen.bounds.size.width]-PXE_PHONE_LANDSCAPE_WIDTH_MARGIN,
                                                [self provideCorrectSizeForScreenHeight:mainScreen.bounds.size.height]-PXE_PHONE_LANDSCAPE_HEIGHT_MARGIN);
                }
            }
            else
            {
                //iphone portrait
                highlightFrame = CGRectMake(0, frame.size.height / 2-PXE_HIGHLIGHT_FRAME_MARGIN,
                                            mainScreen.bounds.size.width, PXE_HIGHLIGHT_FRAME_HEIGHT);
            }
            resizeMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        }
        
        self.highLightPopUp = [[UIView alloc] initWithFrame:highlightFrame];
        self.highLightPopUp.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        [self.highLightPopUp setHidden:NO];
        self.highLightPopUp.userInteractionEnabled = YES;
        self.highLightPopUp.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1].CGColor;
        self.highLightPopUp.layer.borderWidth = 1;
        self.highLightPopUp.layer.cornerRadius = 5.0;
        self.highLightPopUp.layer.shadowColor = [UIColor blackColor].CGColor;
        self.highLightPopUp.layer.shadowOffset = CGSizeMake(2,2);
        self.highLightPopUp.layer.shadowOpacity = 0.3;
        self.highLightPopUp.autoresizesSubviews = YES;
        self.highLightPopUp.autoresizingMask = resizeMask;
        self.highLightPopUp.contentMode = UIViewContentModeScaleToFill;
        
        [self initColorSelector];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitle:@"x" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        closeButton.frame = CGRectMake(self.highLightPopUp.frame.size.width - 30, 10.0, 28.0, 28.0);
        closeButton.userInteractionEnabled = YES;
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.highLightPopUp addSubview:closeButton];
        
        notesTextOrigFrame = CGRectMake(4, 50, self.highLightPopUp.frame.size.width-4, self.highLightPopUp.frame.size.height-PXE_ANNOTATION_NOTES_HEIGHT);
        
        [self addWarningObjectsWithFrame:notesTextOrigFrame];
        
        self.notesView =[[UITextView alloc] initWithFrame:notesTextOrigFrame];
        self.notesView.layer.borderColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
        self.notesView.layer.borderWidth = 1;
        [self.notesView setText:_PXE_PLACE_HOLDER_TEXT];
        self.notesView.textColor =  [UIColor lightGrayColor];
        self.notesView.delegate = self;
        self.notesView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.notesView.editable = YES;
        self.notesView.backgroundColor = [UIColor whiteColor];
        self.notesView.autocorrectionType = UITextAutocorrectionTypeNo; //remove auto correction on keyboard - takes too much space.
        
        [self.highLightPopUp addSubview:self.notesView];
        
        self.saving = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
        self.saving.frame = CGRectMake([[PxePlayer sharedInstance] getAnnotationsSharable] ? 200 :10, (self.highLightPopUp.frame.size.height-self.saving.frame.size.height-17),150,20);
        [self.saving setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [self.saving setText:_PXE_SAVE_TEXT];
        [self.saving setHidden:YES];
        [self.highLightPopUp addSubview:self.saving];
        
        //only add if shareable
        if([[PxePlayer sharedInstance] getAnnotationsSharable])
        {
            self.shareable = [UIButton buttonWithType:UIButtonTypeCustom];
            self.shareable.layer.cornerRadius = 4;
            self.shareable.frame = CGRectMake(10, (self.highLightPopUp.frame.size.height-self.saving.frame.size.height-15), 15, 15);
            self.shareable.layer.borderWidth = 1;
            self.shareable.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1].CGColor;
            [self.shareable addTarget:self action:@selector(checkShared:) forControlEvents:UIControlEventTouchUpInside];
            self.shareable.tag =0;//off
            
            
            self.share = [UIButton buttonWithType:UIButtonTypeCustom];
            self.share.frame = CGRectMake(10, (self.highLightPopUp.frame.size.height-self.saving.frame.size.height-17),150,20);
            [self.share setTitle:_PXE_SHARE_TEXT forState:UIControlStateNormal];
            [self.share addTarget:self action:@selector(checkShared:) forControlEvents:UIControlEventTouchUpInside];
            self.share.titleLabel.font = [UIFont systemFontOfSize: 12];
            [self.share setTitleColor:[UIColor colorWithRed:26/255.0 green:109/255.0 blue:169/255.0 alpha:1] forState:UIControlStateNormal];
        
            [self.highLightPopUp addSubview:self.shareable];
            [self.highLightPopUp addSubview:self.share];
        }
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteButton addTarget:self action:@selector(deleteAndClose:) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteButton setTitle:_PXE_DELETE_TEXT forState:UIControlStateNormal];
        self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:14];
        self.deleteButton.frame = CGRectMake(0, 0, 68, 31);
        self.deleteButton.frame = CGRectMake((_highLightPopUp.frame.size.width - self.deleteButton.frame.size.width-10), (self.highLightPopUp.frame.size.height-self.deleteButton.frame.size.height-10), 68,31);
        self.deleteButton.userInteractionEnabled = YES;
        self.deleteButton.tag = 1;
        [self addGradient:self.deleteButton];
        [self.deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.deleteButton.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1].CGColor;
        self.deleteButton.layer.borderWidth = 1;
        self.deleteButton.layer.cornerRadius = 5.0;
        self.deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.highLightPopUp addSubview:self.deleteButton];
        
        self.modalWindow = [[UIView alloc]initWithFrame:CGRectMake(0,0,frame.size.width, frame.size.height)];
        self.modalWindow.backgroundColor = [UIColor blackColor];
        self.modalWindow.alpha = 0.5;
        [self.modalWindow setHidden:NO];
        self.modalWindow.contentMode = UIViewContentModeScaleToFill;
        
        self.modalWindow.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        
        //add to view
        [self addSubview:self.modalWindow];
        [self addSubview:self.highLightPopUp];
    }
    // New Annotations don't have an isNew property
    self.isNew = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    [self showViewWhenReachable:[Reachability isReachable]];
    
    [self setUpViewWithMessage:jsonString];
    
    return self;
}

//Fix for iOS 7.1
-(float) provideCorrectSizeForScreenWidth:(float)width {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0") && UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return [UIScreen mainScreen].bounds.size.height; //main screen bounds size doesn't reflect rotation prior to 8.x
    }
    else {
        return width;
    }
}

//Fix for iOS 7.1
-(float) provideCorrectSizeForScreenHeight:(float)height {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0") && UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return [UIScreen mainScreen].bounds.size.width; //main screen bounds size doesn't reflect rotation prior to 8.x
    }
    else {
        return height;
    }
}

- (void) initColorSelector
{
    self.colorPanel = [[UIView alloc]initWithFrame:CGRectMake(0,0,300,32)];
    self.colorPanel.userInteractionEnabled = YES;
    
    UIButton *colorYellow = [UIButton buttonWithType:UIButtonTypeCustom];
    colorYellow.tag = 0;
    colorYellow.layer.cornerRadius = 6;
    [colorYellow addTarget:self action:@selector(colorClicked:) forControlEvents:UIControlEventTouchUpInside];
    [colorYellow setTitle:@"" forState:UIControlStateNormal];
    colorYellow.frame = CGRectMake(15.0, 10.0, 28.0, 28.0);
    colorYellow.userInteractionEnabled = YES;
    colorYellow.layer.borderWidth = 1;
    colorYellow.backgroundColor = [UIColor colorWithRed:255/255.0 green:210/255.0 blue:49/255.0 alpha:1];
    [self.colorPanel addSubview:colorYellow];
    [self selectColor: 0];
    
    UIButton *colorPink = [UIButton buttonWithType:UIButtonTypeCustom];
    colorPink.layer.cornerRadius = 6;
    [colorPink addTarget:self action:@selector(colorClicked:) forControlEvents:UIControlEventTouchUpInside];
    [colorPink setTitle:@"" forState:UIControlStateNormal];
    colorPink.frame = CGRectMake(48.0, 10.0, 28.0, 28.0);
    colorPink.userInteractionEnabled = YES;
    colorPink.tag = 1;
    colorPink.backgroundColor = [UIColor colorWithRed:251/255.0 green:145/255.0 blue:205/255.0 alpha:1];
    colorPink.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1].CGColor;
    colorPink.layer.borderWidth = 1;
    [self.colorPanel addSubview:colorPink];
    
    UIButton *colorGreen = [UIButton buttonWithType:UIButtonTypeCustom];
    colorGreen.layer.cornerRadius = 6;
    [colorGreen addTarget:self action:@selector(colorClicked:) forControlEvents:UIControlEventTouchUpInside];
    [colorGreen setTitle:@"" forState:UIControlStateNormal];
    colorGreen.frame = CGRectMake(81.0, 10.0, 28.0, 28.0);
    colorGreen.userInteractionEnabled = YES;
    colorGreen.tag = 2;
    colorGreen.backgroundColor = [UIColor colorWithRed:84/255.0 green:223/255.0 blue:72/255.0 alpha:1];
    colorGreen.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1].CGColor;
    colorGreen.layer.borderWidth = 1;
    [self.colorPanel addSubview:colorGreen];
    
    [self.highLightPopUp addSubview:self.colorPanel];
}

- (void) addWarningObjectsWithFrame:(CGRect)notesFrame
{
    // Warning Objects
    self.warningView = [[UIView alloc] initWithFrame:notesFrame];
    self.warningView.backgroundColor = [UIColor colorWithRed:238/255.0 green:128/255.0 blue:43/255.0 alpha:1];
    self.warningView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    //TODO: Maybe place these 2 elements in a container view so that their spacial realtionship doesn't change as the pop up resizes
    float warningIconX = self.warningView.frame.origin.x + 15;
    UIImage *warningIcon = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"warning.tiff"]];
    self.warningIconView = [[UIImageView alloc] initWithFrame:CGRectMake(warningIconX, 11, 20, 22)];
    [self.warningIconView setImage: warningIcon];
    self.warningIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.warningIconView.backgroundColor = [UIColor clearColor];
    self.warningIconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    float warningX = warningIconX + self.warningIconView.frame.size.width + 15;
    self.warningTitle = [[UILabel alloc] initWithFrame:CGRectMake(warningX, 10, (self.warningView.frame.size.width-warningX), 25)];
    self.warningTitle.backgroundColor = [UIColor clearColor];
    self.warningTitle.textColor = [UIColor whiteColor];
    [self.warningTitle setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [self.warningTitle setText:PXE_ANNOTATION_WARNING_TEXT];
    self.warningTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    self.warningIconView.alpha = 0.0;
    self.warningTitle.alpha = 0.0;
    
    [self.warningView addSubview:self.warningTitle];
    [self.warningView addSubview:self.warningIconView];
    
    [self.highLightPopUp addSubview:self.warningView];
}

-(void)setUIOnAnnotateAdd:(NSString*)jsonString
{
    [self setUpViewWithMessage:jsonString];
}

-(void)setUpViewWithMessage:(NSString*) jsonString
{
    DLog(@"jsonString1: %@", jsonString);
    if(jsonString)
    {
//        NSString *decodedString = [jsonString urlDecodeUsingEncoding];
//        DLog(@"decodedString: %@", decodedString);
//        if(decodedString)
//        {
//            jsonString = decodedString;
//        }
//        jsonString = [jsonString unEscapeCharactersInString];
        DLog(@"jsonString2: %@", jsonString);
        // Sometimes the text contans hard returns
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br />"];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@"<br />"];
        
        DLog(@"jsonString3: %@", jsonString);
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        self.annotationObj = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:kNilOptions
                                                               error:&jsonError];
        DLog(@"self.annotationObj: %@", self.annotationObj);
        DLog(@"ERROR: %@", jsonError);
        
        DLog(@"isNew: %@", [self.annotationObj objectForKey:@"isNew"] );
        // Added boolValue to condition because was always true without it
        if([[self.annotationObj objectForKey:@"isNew"] boolValue] == 0 )
        {
            self.isNew = NO;
        }
        
        if([self.annotationObj objectForKey:@"data"])
        {
            NSString *noteText = [self.annotationObj objectForKey:@"data"][@"noteText"];
            DLog(@"NOTE TEXT: %@", [self.annotationObj objectForKey:@"data"][@"noteText"]);
            DLog(@"Reachable: %@", [Reachability isReachable]?@"YES":@"NO");
            if(!noteText && ![Reachability isReachable])
            {
                DLog(@"No Notetext and offline");
                PxePlayerAnnotation *pxePlayerAnnotation = [[PxePlayer sharedInstance] getAnnotationOnDeviceForAnnotationData:self.annotationObj onPage:[self getRelativeURI]];
                if (pxePlayerAnnotation)
                {
                    noteText = pxePlayerAnnotation.noteText;
                }
            }
            noteText = [noteText stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
            noteText = [noteText stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            
            [self.notesView setText:noteText];
            self.notesView.textColor =  [UIColor blackColor];
            //mathML
            if([[self.annotationObj objectForKey:@"data"][@"isMathMl"]boolValue])
            {
                [self doMathML:self.annotationObj];
            }
        }
        
        //was this shareable?
        if([[self.annotationObj objectForKey:@"shareable" ]boolValue ])
        {
            [self.shareable setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"checkmark.png"]] forState:UIControlStateNormal];
            [self.colorPanel setHidden:YES]; //its shared so hide colors.
            self.shareable.tag = 1;
            [self.highLightPopUp addSubview:self.shareable];
            [self.highLightPopUp addSubview:self.share];
            self.saving.frame = CGRectMake(200, (self.highLightPopUp.frame.size.height-self.saving.frame.size.height-17),150,20);
        }
        
        if ([self.annotationObj objectForKey:@"isEditable"])
        {
            self.editNote = [[self.annotationObj objectForKey:@"isEditable"] integerValue];
            
            if (self.editNote > 0)
            {
                self.deleteButton.hidden = NO;
                self.notesView.editable = YES;
            } else {
                self.deleteButton.hidden = YES;
                self.notesView.editable = NO;
            }
        }
        
        if([self.annotationObj objectForKey:@"annotations"])
        {
            if([[self.annotationObj objectForKey:@"annotations"][0][@"data"][@"isMathMl"]boolValue])
            {
                [self doMathML:self.annotationObj];
            }
        }
        
        //only show color if there is one to show
        if([self.annotationObj objectForKey:@"data" ])
        {
            NSString *hexCode = (NSString*)[self.annotationObj objectForKey:@"data"][@"colorCode"];
            
            [self selectColor:[hexCode intValue]];
        }
    }
    else
    {
        [self saveAnnotation];
    }
}

-(void)doMathML:(id)jsonObj
{
    //this might be called multiple times so return if thats the case
    if(self.mathML)
        return;
    //move everything down 35px
    float offsetForElements=35;
    
    self.mathML = [[UITextField alloc] initWithFrame:CGRectMake(4, 44, self.highLightPopUp.frame.size.width-4, offsetForElements)];
    //some padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.mathML.leftView = paddingView;
    self.mathML.leftViewMode = UITextFieldViewModeAlways;
    self.mathML.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    
    self.mathML.placeholder = _PXE_PLACEHOLDER_TEXT;
    self.mathML.text =  [jsonObj objectForKey:@"data"][@"selectedText"];
    [self.mathML setBackgroundColor:[UIColor whiteColor]];
    [self.mathML setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    //offset the size of the windoow
    self.highLightPopUp.frame = CGRectMake(self.highLightPopUp.frame.origin.x, self.highLightPopUp.frame.origin.y, self.highLightPopUp.frame.size.width, self.highLightPopUp.frame.size.height+ offsetForElements);
    //offset the notes window
    self.notesView.frame = CGRectMake(self.notesView.frame.origin.x, self.notesView.frame.origin.y+offsetForElements, self.notesView.frame.size.width, self.notesView.frame.size.height- offsetForElements);
    self.share.frame = CGRectMake(self.share.frame.origin.x, self.share.frame.origin.y+offsetForElements, self.share.frame.size.width, self.share.frame.size.height);
    self.shareable.frame = CGRectMake(self.shareable.frame.origin.x, self.shareable.frame.origin.y+offsetForElements, self.shareable.frame.size.width, self.shareable.frame.size.height);
    self.deleteButton.frame = CGRectMake(self.deleteButton.frame.origin.x, self.deleteButton.frame.origin.y, self.deleteButton.frame.size.width, self.deleteButton.frame.size.height);
    [self.highLightPopUp addSubview:self.mathML];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.textColor =  [UIColor blackColor];
    if([textView.text isEqualToString:_PXE_PLACE_HOLDER_TEXT])
    {
        textView.text = @"";
    }
    return  YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self textViewShouldBeginEditing:_notesView];
    
    // Not syncing offline so don't call javascript to save when not Reachable
    
    if ([Reachability isReachable])
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self.saving setHidden:NO];
            [self saveAnnotation];
            
        });
        
        dispatch_time_t popTimeOFF = dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC);
        dispatch_after(popTimeOFF, dispatch_get_main_queue(), ^(void){
            [self.saving setHidden:YES];
        });
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    DLog(@"replacementText: %@", text);
    if (textView.text.length + (text.length - range.length) > PXE_ANNOTATION_CHARACTER_LIMIT)
    {
        NSError *error = [PxePlayerError errorForCode:PxePlayerAnnotationsError
                                      localizedString:NSLocalizedString(@"Annotation max characters reached.", @"Annotation max characters reached.")];
        
        NSDictionary *errorInfo = @{PXEPLAYER_ERROR:error};
        [[NSNotificationCenter defaultCenter] postNotificationName:PXEPLAYER_ANNOTATION_MAX_CHAR
                                                            object:nil
                                                          userInfo:errorInfo];
        
        return NO;
    }
    
    return YES;
}

-(void)saveAnnotation
{
    if([Reachability isReachable])
    {
        NSString *noteText = self.notesView.text;
        
        if([noteText isEqualToString:_PXE_PLACE_HOLDER_TEXT])
        {
            noteText = @"";
        }
        if(!noteText)
        {
            noteText = @"";
        }
//        DLog(@"currentColor: %ld", (long)self.currentColor);
//        DLog(@"noteText: %@", noteText);
//        DLog(@"baseURL: %@", [[PxePlayer sharedInstance] getOnlineBaseURL]);
//        DLog(@"uri: %@", [self getRelativeURI]);
//        DLog(@"identityID: %@", [[PxePlayer sharedInstance] getIdentityID]);
//        DLog(@"noteText: %@", noteText);
//        NSDictionary *dataDict = @{
//                                   @"colorCode":(long)self.shareable.tag>0? @"3" : [NSString stringWithFormat:@"%ld",(long)self.currentColor],
//                                   @"noteText":[noteText stringEscapedForJavasacript],
//                                   @"expLabel":self.mathML ? self.mathML.text : @"",
//                                   @"shareable":(long)self.shareable.tag>0?@"true":@"false",
//                                   @"baseURL":[[PxePlayer sharedInstance] getOnlineBaseURL],
//                                   @"uri": [self getRelativeURI],
//                                   @"identityId":[[PxePlayer sharedInstance] getIdentityID]
//                                   };
//        DLog(@"self.isNew: %@", self.isNew?@"YES":@"NO");
//        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil];
//        NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];

        NSMutableString *jsonString = [NSMutableString new];
        
        [jsonString appendFormat:@"{"];
        [jsonString appendFormat:@"\"colorCode\":\"%@\",",(long)self.shareable.tag>0? @"3" : [NSString stringWithFormat:@"%ld",(long)self.currentColor]];
        [jsonString appendFormat:@"\"noteText\":\"%@\",",[noteText stringEscapedForJavasacript]];
        [jsonString appendFormat:@"\"expLabel\":\"%@\",",self.mathML ? self.mathML.text : @""];
        [jsonString appendFormat:@"\"shareable\":\"%@\",",(long)self.shareable.tag>0?@"true":@"false"];
        [jsonString appendFormat:@"\"baseURL\":\"%@/\",",[[[PxePlayer sharedInstance] getOnlineBaseURL] stringEscapedForJavasacript]];
        [jsonString appendFormat:@"\"uri\":\"%@\",",[[self getRelativeURI] stringEscapedForJavasacript]];
        [jsonString appendFormat:@"\"identityId\":\"%@\"",[[PxePlayer sharedInstance] getIdentityID]];
        [jsonString appendFormat:@"}"];
        
        DLog(@"jsonString: %@", jsonString);
        
        NSString *functionName = self.isNew ? @"saveMobileAnnotation" : @"updateMobileAnnotation";
        NSString *jsCall = [NSString stringWithFormat:@"Annotate.instance.%@(%@)",functionName, jsonString];
        DLog(@"jsCall: %@", jsCall);
        [self.webView stringByEvaluatingJavaScriptFromString:jsCall];
    }
}

/**
 button gradient
 */
-(void) addGradient:(UIButton *) button
{
    // Add Border
    CALayer *layer = button.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
    
    // Add Shine
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    [layer addSublayer:shineLayer];
}

#pragma mark - Events
-(void)checkShared:(id)sender
{
    //toggle me
    if((long)self.shareable.tag > 0)
    {
        [self.shareable setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"uncheckmark.png"]] forState:UIControlStateNormal];
        self.shareable.tag = 0;
        [self.colorPanel setHidden:NO];
        [self selectColor:0];
    }
    else
    {
        [self.shareable setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.bundlePath,@"checkmark.png"]] forState:UIControlStateNormal];
        self.shareable.tag = 1;
        [self.colorPanel setHidden:YES];
    }
    
    [self saveAnnotation];
}

-(void)resizeWindow:(BOOL)isPortrait{
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    
    CGRect highlightFrame;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    { //only for iphone
        if(isPortrait)
        { //going to be portrait
            //iphone portrait
            highlightFrame = CGRectMake(0, 0, self.parentView.frame.size.width, [self calculatePopUpHeightForCurrentHeight:PXE_HIGHLIGHT_FRAME_HEIGHT
                                                                                                       keyboardYCoordinate:keyboardFrame.origin.y]);
        }
        else
        {
            //iphone landscape
            CGFloat mainScreenWidth = [self provideCorrectSizeForScreenWidth:mainScreen.bounds.size.width];
            CGFloat mainScreenHeight = [self provideCorrectSizeForScreenHeight:mainScreen.bounds.size.height];
            
            if(mainScreenWidth < PXE_SMALL_PHONE_MAX_HEIGHT && mainScreenHeight < PXE_SMALL_PHONE_MAX_WIDTH)
            {
                //small screen like ipods and iphone 4
                highlightFrame = CGRectMake(25, 0, self.parentView.frame.size.width-PXE_PHONE_LANDSCAPE_WIDTH_MARGIN,
                                            [self calculatePopUpHeightForCurrentHeight:mainScreenHeight-PXE_PHONE_LANDSCAPE_HEIGHT_MARGIN
                                                                   keyboardYCoordinate:[self calculateYCoordinateForKeyboard:keyboardFrame]]);
            }
            else
            {
                highlightFrame = CGRectMake(25, 0, mainScreenWidth-PXE_PHONE_LANDSCAPE_WIDTH_MARGIN,
                                            [self calculatePopUpHeightForCurrentHeight:mainScreenHeight-PXE_PHONE_LANDSCAPE_HEIGHT_MARGIN
                                                                   keyboardYCoordinate:[self calculateYCoordinateForKeyboard:keyboardFrame]]);
            }
        }
        self.highLightPopUp.frame =  highlightFrame;
    }
    else
    {
        if (self.isEditing && (!isPortrait))
        {
            self.highLightPopUp.frame = CGRectMake(self.highLightPopUp.frame.origin.x,
                                                  (self.parentView.frame.size.height*0.5 - self.highLightPopUp.frame.size.height)/2,
                                                  self.highLightPopUp.frame.size.width,
                                                  self.highLightPopUp.frame.size.height);
        } else {
            self.highLightPopUp.center = self.parentView.center;
        }
    }
    [self repositionElements];
}

- (void) repositionElements
{
    // Warning Icon
    float warningIconX = (self.warningView.frame.origin.x + ((self.warningView.frame.size.width-4)*.28)) - 36;
    self.warningIconView.frame = CGRectMake(warningIconX, 11, 20, 22);
}

- (void) deleteAndClose:(id)sender
{
    [self.modalWindow setHidden:YES];
    [self.highLightPopUp setHidden:YES];
    [self setHidden:YES];
    [self.webView stringByEvaluatingJavaScriptFromString:@"Annotate.instance.removeMobileAnnotation()"];
    
    // bit of overkill
    self.notesView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [self.delegate noteDidClose];
    //close keyboard
    [self.notesView resignFirstResponder];
}

- (void) closeButton:(id)sender
{
    [self.modalWindow setHidden:YES];
    [self.highLightPopUp setHidden:YES];
    [self setHidden:YES];
    [self.delegate noteDidClose];
    [self saveAnnotation];
    
    // bit of overkill
    self.notesView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    //close keyboard
    [self.notesView resignFirstResponder];
}

-(void)selectColor:(NSInteger)index
{
    self.currentColor = index;
    DLog(@"self.currentColor: %ld", (long)self.currentColor);
    //other buttons go gray
    NSArray *subviews = [self.colorPanel subviews];
    
    for (UIView *subview in subviews)
    {
        if([subview isKindOfClass:[UIButton class]] && ((UIButton*)subview).tag != index)
        {
            subview.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1].CGColor;
            subview.layer.borderWidth = 1;
        }
        else
        {
            subview.layer.borderColor =  [UIColor blackColor].CGColor;
            subview.layer.borderWidth = 2;
        }
    }
}

-(void)colorClicked:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [self selectColor:(NSInteger)button.tag];
    [self saveAnnotation];
}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case NotReachable:
        {
            [self showViewWhenReachable:NO];
            break;
        }
        case ReachableViaWiFi:
        {
            [self showViewWhenReachable:YES];
            break;
        }
        case ReachableViaWWAN:
        {
            [self showViewWhenReachable:YES];
            break;
        }
    }
}

- (void) showViewWhenReachable:(BOOL)reachable
{
    if (reachable)
    {
        [self hideSaveWarning];
        [self enableButtons];
    } else {
        [self showSaveWarning];
        [self disableButtons];
    }
}

- (void) showSaveWarning
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect newFrame = CGRectMake(self.notesView.frame.origin.x, self.notesView.frame.origin.y + PXE_ANNOTATION_WARNING_HEIGHT, self.notesView.frame.size.width, self.notesView.frame.size.height - PXE_ANNOTATION_WARNING_HEIGHT);
                         self.notesView.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         if (finished)
                         {
                             [UIView animateWithDuration:0.25
                                              animations:^{
                                                  self.warningIconView.alpha = 1.0;
                                                  self.warningTitle.alpha = 1.0;
                                              }
                                              completion:NULL];
                         }
                     }];
}

- (void) hideSaveWarning
{
    if (self.notesView.frame.size.height == notesTextOrigFrame.size.height - PXE_ANNOTATION_WARNING_HEIGHT)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.warningIconView.alpha = 0.0;
                             self.warningTitle.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             if (finished)
                             {
                                 [UIView animateWithDuration:0.5
                                                  animations:^{
                                                      self.notesView.frame = notesTextOrigFrame;
                                                  }
                                                  completion:NULL];
                             }
                         }];
    }
}

- (void) dismissWarning:(UISwipeGestureRecognizer *)swipeUp
{
    [self hideSaveWarning];
}

- (void) disableButtons
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.colorPanel.alpha = 0.0;
                         self.deleteButton.alpha = 0.0;
                         self.saving.alpha = 0.0;
                         self.share.alpha = 0.0;
                         self.shareable.alpha = 0.0;
                     }
                     completion:NULL];
}

- (void) enableButtons
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.colorPanel.alpha = 1.0;
                         self.deleteButton.alpha = 1.0;
                         self.saving.alpha = 1.0;
                         self.share.alpha = 1.0;
                         self.shareable.alpha = 1.0;
                     }
                     completion:NULL];
}

- (NSString *) getRelativeURI
{
    NSString *uri = self.webView.request.URL.absoluteString;
    
    uri = [[PxePlayer sharedInstance] removeBaseUrlFromUrl:uri];
    uri = [[PxePlayer sharedInstance] formatRelativePathForJavascript:uri];
    DLog(@"relativeURI: %@", uri);
    return uri;
}

- (void) dealloc
{
    // Just in case
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    // bit of overkill
    self.notesView.delegate = nil;
}

@end