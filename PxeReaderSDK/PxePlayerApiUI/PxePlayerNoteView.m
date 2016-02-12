//
//  PxePlayerAnnotation.m
//  PxeReader
//
//  Created by Richard Rosiak on 9/24/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import "PxePlayerNoteView.h"
#import "PxePlayerMacro.h"
#import "Reachability.h"
#import "NSString+Extension.h"
#import "PxePlayerMenuControllerManager.h"
#import "PxePlayer.h"
#import "PxePlayerNHUtility.h"
#import "PxePlayerError.h"
#import "PxePlayerUIConstants.h"

@interface PxePlayerNoteView()

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIScrollView *baseScrollView;
@property (nonatomic, strong) UITextView *selectionTextView;
@property (nonatomic, strong) UITextView *annotationTextView;
@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) NSString *contentSelection;
@property (nonatomic, strong) PxePlayerAnnotation *annotation;
@property (nonatomic, assign) BOOL isNewAnnotation;
@property (nonatomic, strong) NSString *webViewRequestUri;

@end

#define SELECTION_VIEW_MAX_HEIGHT 36.0f
#define SELECTION_VIEW_MARGIN 10.0f

#define PXE_ANNOTATION_CHARACTER_LIMIT 3000

@implementation PxePlayerNoteView

- (instancetype) initWithParentFrame:(CGRect)parentFrame
                     isAnnotationNew:(BOOL)isNew
                   annotationMessage:(NSString*)annotationMessage
                   webViewRequestUri:(NSString*)webViewUri
{
    self = [self initWithFrame:parentFrame];
    if (!self) {
        return nil;
    }
    
    [self setBackgroundColor: [UIColor whiteColor]];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.webViewRequestUri = webViewUri;
    self.annotation = [self parseAnnotationMessage:annotationMessage];
    self.contentSelection = self.annotation.selectedText;
    self.isNewAnnotation = NO; //isNew;
    self.currentAnnotationDttm = self.annotation.annotationDttm;
    DLog(@"Opening notes view with this annot Dttm: %@", self.currentAnnotationDttm);
    
    PxePlayerHighlightColor color = [PxePlayerNHUtility parseColorCodeFromAnnotationMessage:annotationMessage];
    
    self.topBar = [self createTopBar];
    
    [self createCancelButton];
    
    if (color != PxePlayerTurquoiseHighlight)
    {
        self.saveButton = [self createSaveButton];
    }
    
    self.baseScrollView = [self createScrollView];
    
    self.selectionTextView = [self createSelectionTextViewInParentFrame:parentFrame];
    
    self.annotationTextView = [self createAnnotationTextViewForHighlightColor:color];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) //not an iPad device
    {
        [self registerForKeyboardNotifications];
    }
    
    return self;
}

- (PxePlayerAnnotation*) parseAnnotationMessage:(NSString*)annotationMessage
{
    PxePlayerAnnotation *annotation = nil;
    if (!annotationMessage) {
        return annotation;
    }
    
    NSDictionary *annotationDict = [PxePlayerNHUtility parseAnnotationDictFromMessage:annotationMessage];
    
    annotation = [[PxePlayerAnnotation alloc] initWithDictionary:annotationDict];
    
    return annotation;
}

- (void) adjustSelectionInViewForSize:(CGSize)size
{
    self.selectionTextView.text = [self adjustLengthForSelection:self.contentSelection
                                                       frameSize:CGSizeMake(size.width - SELECTION_VIEW_MARGIN,
                                                                            size.height)];
}

#pragma keyboard methods
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void) deRegisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    DLog(@"Keybaord was shown with size: %f by %f and content insets are %f %f %f %f", kbSize.width, kbSize.height, self.annotationTextView.contentInset.top, self.annotationTextView.contentInset.left, self.annotationTextView.contentInset.bottom, self.annotationTextView.contentInset.right);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.annotationTextView.contentInset = contentInsets;
    self.annotationTextView.scrollIndicatorInsets = contentInsets;
    
    DLog(@"Moved the text view bottom to %f", contentInsets.bottom);
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    DLog(@"Keybaord is hiding...");
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.baseScrollView.contentInset = contentInsets;
    self.baseScrollView.scrollIndicatorInsets = contentInsets;
}

#pragma private selectors

- (UIView*) createTopBar
{
    UIView *topBar = [[UIView alloc] init];
    
    topBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [topBar setBackgroundColor:[UIColor blackColor]];
    
    [self addSubview:topBar];
    
    NSLayoutConstraint *topBarTopContstraint = [NSLayoutConstraint constraintWithItem:topBar
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0
                                                                             constant:0];
    
    NSLayoutConstraint *topBarLeftContstraint = [NSLayoutConstraint constraintWithItem:topBar
                                                                             attribute:NSLayoutAttributeLeading
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeLeading
                                                                            multiplier:1.0
                                                                              constant:0];
    
    NSLayoutConstraint *topBarRightContstraint = [NSLayoutConstraint constraintWithItem:topBar
                                                                              attribute:NSLayoutAttributeTrailing
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1.0
                                                                               constant:0];
    
    NSLayoutConstraint *topBarHeightContstraint = [NSLayoutConstraint constraintWithItem:topBar
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0
                                                                                constant:40.0];
    
    [self addConstraints:@[topBarTopContstraint, topBarLeftContstraint, topBarRightContstraint, topBarHeightContstraint]];
    
    return topBar;
}

- (UIButton*) createCancelButton
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelAnnotation:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.userInteractionEnabled = YES;
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.topBar addSubview:cancelButton];
    
    NSLayoutConstraint *cancelBtnLeadingConstraint = [NSLayoutConstraint constraintWithItem:cancelButton
                                                                                  attribute:NSLayoutAttributeLeading
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.topBar
                                                                                  attribute:NSLayoutAttributeLeading
                                                                                 multiplier:1.0
                                                                                   constant:20.0];
    
    NSLayoutConstraint *cancelBtnTopConstraint = [NSLayoutConstraint constraintWithItem:cancelButton
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.topBar
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0
                                                                               constant:10.0];
    
    NSLayoutConstraint *cancelBtnWidthConstraint = [NSLayoutConstraint constraintWithItem:cancelButton
                                                                                attribute:NSLayoutAttributeWidth
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1.0
                                                                                 constant:60.0];
    
    NSLayoutConstraint *cancelBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:cancelButton
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1.0
                                                                                  constant:30.0];
    
    [self addConstraints:@[cancelBtnLeadingConstraint, cancelBtnTopConstraint, cancelBtnWidthConstraint, cancelBtnHeightConstraint]];
    
    return cancelButton;
}

- (UIButton*) createSaveButton
{
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton addTarget:self action:@selector(saveAnnotation:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.userInteractionEnabled = YES;
    saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    saveButton.userInteractionEnabled = YES;
    
    [self.topBar addSubview:saveButton];
    
    NSLayoutConstraint *saveBtnTrailingConstraint = [NSLayoutConstraint constraintWithItem:saveButton
                                                                                 attribute:NSLayoutAttributeTrailing
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.topBar
                                                                                 attribute:NSLayoutAttributeTrailing
                                                                                multiplier:1.0
                                                                                  constant:-20.0];
    
    NSLayoutConstraint *saveBtnTopConstraint = [NSLayoutConstraint constraintWithItem:saveButton
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.topBar
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0
                                                                             constant:10.0];
    
    NSLayoutConstraint *saveBtnWidthConstraint = [NSLayoutConstraint constraintWithItem:saveButton
                                                                              attribute:NSLayoutAttributeWidth
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:nil
                                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                                             multiplier:1.0
                                                                               constant:45.0];
    
    NSLayoutConstraint *saveBtnHeightConstraint = [NSLayoutConstraint constraintWithItem:saveButton
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0
                                                                                constant:30.0];
    
    [self addConstraints:@[saveBtnTrailingConstraint, saveBtnTopConstraint, saveBtnWidthConstraint, saveBtnHeightConstraint]];
    
    return saveButton;
}

- (UIScrollView*) createScrollView
{
    UIScrollView *baseScrollView = [[UIScrollView alloc] init];
    baseScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:baseScrollView];
    
    NSLayoutConstraint *scrollViewTopContstraint = [NSLayoutConstraint constraintWithItem:baseScrollView
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.topBar
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0
                                                                                 constant:0];
    
    NSLayoutConstraint *scrollViewLeftContstraint = [NSLayoutConstraint constraintWithItem:baseScrollView
                                                                                 attribute:NSLayoutAttributeLeading
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self
                                                                                 attribute:NSLayoutAttributeLeading
                                                                                multiplier:1.0
                                                                                  constant:0];
    
    NSLayoutConstraint *scrollViewRightContstraint = [NSLayoutConstraint constraintWithItem:baseScrollView
                                                                                  attribute:NSLayoutAttributeTrailing
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeTrailing
                                                                                 multiplier:1.0
                                                                                   constant:0];
    
    NSLayoutConstraint *scrollViewBottomContstraint = [NSLayoutConstraint constraintWithItem:baseScrollView
                                                                                   attribute:NSLayoutAttributeBottom
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self
                                                                                   attribute:NSLayoutAttributeBottom
                                                                                  multiplier:1.0
                                                                                    constant:0];
    
    [self addConstraints:@[scrollViewTopContstraint, scrollViewLeftContstraint, scrollViewRightContstraint, scrollViewBottomContstraint]];
    
    return baseScrollView;
}

- (UITextView*) createSelectionTextViewInParentFrame:(CGRect)frame
{
    UITextView *selectionTextView = [[UITextView alloc] init];
    [selectionTextView setFont:[UIFont italicSystemFontOfSize:15.0f]];
    selectionTextView.textColor = [UIColor grayColor];
    selectionTextView.layer.backgroundColor = [[UIColor colorWithWhite:0.90f alpha:1] CGColor];
    selectionTextView.userInteractionEnabled = NO;
    selectionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    selectionTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [self.baseScrollView addSubview:selectionTextView];
    
    NSLayoutConstraint *selectionViewTopContstraint = [NSLayoutConstraint constraintWithItem:selectionTextView
                                                                                   attribute:NSLayoutAttributeTop
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.baseScrollView
                                                                                   attribute:NSLayoutAttributeTop
                                                                                  multiplier:1.0
                                                                                    constant:0];
    
    NSLayoutConstraint *selectionViewLeftContstraint = [NSLayoutConstraint constraintWithItem:selectionTextView
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self
                                                                                    attribute:NSLayoutAttributeLeading
                                                                                   multiplier:1.0
                                                                                     constant:0];
    
    NSLayoutConstraint *selectionViewRightContstraint = [NSLayoutConstraint constraintWithItem:selectionTextView
                                                                                     attribute:NSLayoutAttributeTrailing
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self
                                                                                     attribute:NSLayoutAttributeTrailing
                                                                                    multiplier:1.0
                                                                                      constant:0];
    
    NSLayoutConstraint *selectionViewHeightContstraint = [NSLayoutConstraint constraintWithItem:selectionTextView
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:nil
                                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                                     multiplier:1.0
                                                                                       constant:50.0];
    
    [self addConstraints:@[selectionViewTopContstraint, selectionViewLeftContstraint, selectionViewRightContstraint, selectionViewHeightContstraint]];
    
    selectionTextView.text = [self adjustLengthForSelection:self.contentSelection
                                                       frameSize:CGSizeMake(frame.size.width - SELECTION_VIEW_MARGIN,
                                                                            frame.size.height)];
    return selectionTextView;
}

- (UITextView*) createAnnotationTextViewForHighlightColor:(PxePlayerHighlightColor)color
{
    UITextView *annotationTextView = [[UITextView alloc] init];
    [annotationTextView setFont:[UIFont systemFontOfSize:16]];
    
    if (color != PxePlayerTurquoiseHighlight)
    {
        annotationTextView.userInteractionEnabled = YES;
    }
    else //instructor note - can't modify on mobile
    {
        annotationTextView.userInteractionEnabled = NO;
    }
    
    annotationTextView.translatesAutoresizingMaskIntoConstraints = NO;
    annotationTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    annotationTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    annotationTextView.text = (self.annotation)?self.annotation.noteText:@"";
    
    annotationTextView.delegate = self;
    
    [self.baseScrollView addSubview:annotationTextView];
    
    NSLayoutConstraint *annotationViewTopContstraint = [NSLayoutConstraint constraintWithItem:annotationTextView
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self.selectionTextView
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                   multiplier:1.0
                                                                                     constant:0];
    
    NSLayoutConstraint *annotationViewLeftContstraint = [NSLayoutConstraint constraintWithItem:annotationTextView
                                                                                     attribute:NSLayoutAttributeLeading
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self
                                                                                     attribute:NSLayoutAttributeLeading
                                                                                    multiplier:1.0
                                                                                      constant:0];
    
    NSLayoutConstraint *annotationViewRightContstraint = [NSLayoutConstraint constraintWithItem:annotationTextView
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self
                                                                                      attribute:NSLayoutAttributeTrailing
                                                                                     multiplier:1.0
                                                                                       constant:0];
    
    NSLayoutConstraint *annotationViewBottomContstraint = [NSLayoutConstraint constraintWithItem:annotationTextView
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                      multiplier:1.0
                                                                                        constant:0];
    
    [self addConstraints:@[annotationViewTopContstraint, annotationViewLeftContstraint, annotationViewRightContstraint,
                           annotationViewBottomContstraint]];
    
    return annotationTextView;
}

- (NSString*) adjustLengthForSelection:(NSString*)selection frameSize:(CGSize)size
{
    DLog(@"The selection is %@", selection);
    CGSize viewSize = [selection boundingRectWithSize:size
                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                           attributes:@{ NSFontAttributeName:[UIFont italicSystemFontOfSize:15.0f] }
                                              context:nil].size;
    
    if (viewSize.height <= SELECTION_VIEW_MAX_HEIGHT)
    {
        return selection;
    }
    for (int i = 2; i < selection.length; i++)
    {
        NSString *truncSelection = [NSString stringWithFormat:@"%@…", [selection substringToIndex:selection.length - i]];
        
        CGSize newSize = [truncSelection boundingRectWithSize:size
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{ NSFontAttributeName:[UIFont italicSystemFontOfSize:15.0f] }
                                                      context:nil].size;
        if (newSize.height <= SELECTION_VIEW_MAX_HEIGHT)
        {
            DLog(@"Returning truncated selection: %@", truncSelection);
            return truncSelection;
        }
    }
    
    return @"";
}
	
- (void) cancelAnnotation:(id)sender
{
    DLog(@"Cancelling annotation view and removing observers...");
    [self deRegisterForKeyboardNotifications];
    [self removeFromSuperview];
    [self.delegate closeNote];
    
}

- (void) saveAnnotation:(id)sender
{
    //TODO: if we ever decide not to close the note view after clicking Save - user interaction will have to be re-enabled after save completes
    self.saveButton.userInteractionEnabled = NO;
    [self saveAnnotationViaJS];
    [self cancelAnnotation:sender];
}

- (void) saveAnnotationViaJS
{
    DLog(@"Saving annotation from note with this annot Dttm: %@", self.currentAnnotationDttm);
    
    if([Reachability isReachable])
    {
        NSString *noteText = self.annotationTextView.text;
        NSInteger colorCode = [PxePlayerNHUtility translateHexColor:self.annotation.colorCode];
        NSString *jsCall = [PxePlayerNHUtility buildJSCallForNote:noteText
                                                        colorCode:colorCode
                                                webViewRequestUri:self.webViewRequestUri
                                                  isAnnotationNew:self.isNewAnnotation
                                                   annotationDttm:self.currentAnnotationDttm];
        
        [self.delegate saveAnnotationWithJavaScriptCall:jsCall];
    }
}

#pragma mark UITextView Delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.textColor =  [UIColor blackColor];

    return  YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self textViewShouldBeginEditing:_annotationTextView];
    
    // Not syncing offline so don't call javascript to save when not Reachable
    if ([Reachability isReachable])
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self saveAnnotationViaJS];
            
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

@end
