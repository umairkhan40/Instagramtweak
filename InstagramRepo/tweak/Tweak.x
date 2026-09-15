#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

// MARK: - Preferences
static BOOL kEnabled = YES;
static BOOL kDownloadStories = YES;
static BOOL kDownloadReels = YES;
static BOOL kDownloadFeed = YES;
static BOOL kHideViewStory = YES;
static BOOL kDisableAds = YES;
static BOOL kDisableTyping = NO;
static BOOL kDisableReadReceipts = NO;
static BOOL kHideStoryViewers = YES;
static BOOL kHiFiAudio = YES;
static BOOL kDisableAnalytics = YES;
static BOOL kHideLikeCount = NO;
static BOOL kAllowLongPressMedia = YES;
static BOOL kDownloadVoiceMessages = YES;
static BOOL kHideSeenStories = NO;
static BOOL kDarkMode = NO;

static void loadPrefs() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    kEnabled            = [defaults boolForKey:@"rhino_Enabled" default:YES];
    kDownloadStories    = [defaults boolForKey:@"rhino_DownloadStories" default:YES];
    kDownloadReels      = [defaults boolForKey:@"rhino_DownloadReels" default:YES];
    kDownloadFeed       = [defaults boolForKey:@"rhino_DownloadFeed" default:YES];
    kHideViewStory      = [defaults boolForKey:@"rhino_HideViewStory" default:YES];
    kDisableAds         = [defaults boolForKey:@"rhino_DisableAds" default:YES];
    kDisableTyping      = [defaults boolForKey:@"rhino_DisableTyping" default:NO];
    kDisableReadReceipts= [defaults boolForKey:@"rhino_DisableReadReceipts" default:NO];
    kHideStoryViewers   = [defaults boolForKey:@"rhino_HideStoryViewers" default:YES];
    kHiFiAudio          = [defaults boolForKey:@"rhino_HiFiAudio" default:YES];
    kDisableAnalytics   = [defaults boolForKey:@"rhino_DisableAnalytics" default:YES];
    kHideLikeCount      = [defaults boolForKey:@"rhino_HideLikeCount" default:NO];
    kAllowLongPressMedia= [defaults boolForKey:@"rhino_AllowLongPressMedia" default:YES];
    kDownloadVoiceMessages = [defaults boolForKey:@"rhino_DownloadVoiceMessages" default:YES];
    kHideSeenStories    = [defaults boolForKey:@"rhino_HideSeenStories" default:NO];
    kDarkMode           = [defaults boolForKey:@"rhino_DarkMode" default:NO];
}

// MARK: - Header Declarations
@interface IGStoryItem : NSObject
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, copy) NSString *mediaType;
@property (nonatomic, strong) id user;
@property (nonatomic, assign) long long expiringAt;
@property (nonatomic, copy) NSString *storyId;
@end

@interface IGStoryViewer : UIViewController
@property (nonatomic, strong) IGStoryItem *item;
- (void)storyViewerDidAppear;
- (void)storyViewerDidDisappear;
@end

@interface IGStoryTrayViewController : UIViewController
- (void)fetchTray;
@end

@interface IGReelItem : NSObject
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, copy) NSString *pk;
@property (nonatomic, copy) NSString *mediaType;
@end

@interface IGReelViewerViewController : UIViewController
@property (nonatomic, strong) IGReelItem *currentItem;
- (void)downloadCurrentReel;
@end

@interface IGFeedItem : NSObject
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, copy) NSString *mediaType;
@property (nonatomic, copy) NSString *pk;
@end

@interface IGDirectMessage : NSObject
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, copy) NSString *messageType;
@end

@interface IGListAdapter : NSObject
@property (nonatomic, strong) NSArray *objects;
@end

@interface IGPost : NSObject
@property (nonatomic, strong) IGFeedItem *media;
@property (nonatomic, strong) id user;
@property (nonatomic, copy) NSString *pk;
@end

@interface IGAnalyticsManager : NSObject
+ (instancetype)sharedManager;
- (void)logEvent:(NSString *)event parameters:(NSDictionary *)params;
@end

@interface IGStoryTrayCell : UICollectionViewCell
@property (nonatomic, strong) IGStoryItem *viewModel;
@property (nonatomic, strong) UIView *seenIndicator;
@property (nonatomic, strong) UIImageView *avatarImageView;
@end

@interface IGStoryTrayContainerCell : UICollectionViewCell
@property (nonatomic, strong) NSArray *trayItems;
- (NSInteger)numberOfTrayItems;
- (IGStoryItem *)trayItemAtIndex:(NSInteger)index;
@end

@interface IGSponsoredPostConfiguration : NSObject
@end

@interface IGSponsoredPost : NSObject
@property (nonatomic, strong) IGSponsoredPostConfiguration *configuration;
@end

@interface IGFeedItemStoryPillOverlayView : UIView
@end

@interface IGPlaybackTimelineView : UIView
@end

@interface IGAudioTrackMedia : NSObject
@property (nonatomic, copy) NSString *audioClusterId;
@property (nonatomic, assign) BOOL isCopyrighted;
@property (nonatomic, strong) NSURL *originalMediaAudioURL;
@property (nonatomic, assign) double audioVolume;
@end

@interface IGVideoPlayerView : UIView
@property (nonatomic, strong) AVPlayer *player;
@end

// MARK: - Story Download Manager
@interface RhinoStoryDownloadManager : NSObject
+ (instancetype)sharedManager;
- (void)downloadStory:(IGStoryItem *)item fromSource:(NSString *)source;
- (void)downloadMedia:(NSURL *)url ofType:(NSString *)type withCompletion:(void(^)(BOOL success, NSError *error))completion;
@end

@implementation RhinoStoryDownloadManager

+ (instancetype)sharedManager {
    static RhinoStoryDownloadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RhinoStoryDownloadManager alloc] init];
    });
    return manager;
}

- (void)downloadStory:(IGStoryItem *)item fromSource:(NSString *)source {
    if (!kEnabled || !item) return;

    NSURL *mediaURL = nil;
    NSString *mediaType = nil;

    if ([item.mediaType isEqualToString:@"video"] && item.videoURL) {
        mediaURL = item.videoURL;
        mediaType = @"video";
    } else if (item.imageURL) {
        mediaURL = item.imageURL;
        mediaType = @"image";
    }

    if (!mediaURL) {
        NSLog(@"[Rhino] No media URL found for story item");
        return;
    }

    [self downloadMedia:mediaURL ofType:mediaType withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"[Rhino] Successfully downloaded story from %@", source);
            dispatch_async(dispatch_get_main_queue(), ^{
                UILabel *toast = [[UILabel alloc] init];
                toast.text = @"Story saved to camera roll ✓";
                toast.textColor = [UIColor whiteColor];
                toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
                toast.textAlignment = NSTextAlignmentCenter;
                toast.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
                toast.layer.cornerRadius = 20;
                toast.clipsToBounds = YES;
                toast.frame = CGRectMake(80, [UIScreen mainScreen].bounds.size.height - 120, 230, 40);

                UIWindow *keyWindow = nil;
                for (UIWindow *window in [UIApplication sharedApplication].windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
                [keyWindow addSubview:toast];

                [UIView animateWithDuration:0.3 delay:1.5 options:0 animations:^{
                    toast.alpha = 0;
                } completion:^(BOOL finished) {
                    [toast removeFromSuperview];
                }];
            });
        } else {
            NSLog(@"[Rhino] Download failed: %@", error.localizedDescription);
        }
    }];
}

- (void)downloadMedia:(NSURL *)url ofType:(NSString *)type withCompletion:(void(^)(BOOL success, NSError *error))completion {
    if ([type isEqualToString:@"video"]) {
        [self downloadVideo:url withCompletion:completion];
    } else {
        [self downloadImage:url withCompletion:completion];
    }
}

- (void)downloadVideo:(NSURL *)url withCompletion:(void(^)(BOOL success, NSError *error))completion {
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(NO, error);
            return;
        }

        NSData *videoData = [NSData dataWithContentsOfURL:location];
        if (!videoData) {
            completion(NO, [NSError errorWithDomain:@"Rhino" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to read video data"}]);
            return;
        }

        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        __block PHObjectPlaceholder *placeholder = nil;

        [photoLibrary performChanges:^{
            PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:location];
            placeholder = request.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError *error) {
            completion(success, error);
        }];
    }];
    [task resume];
}

- (void)downloadImage:(NSURL *)url withCompletion:(void(^)(BOOL success, NSError *error))completion {
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) {
            completion(NO, error ?: [NSError errorWithDomain:@"Rhino" code:2 userInfo:@{NSLocalizedDescriptionKey: @"No data received"}]);
            return;
        }

        UIImage *image = [UIImage imageWithData:data];
        if (!image) {
            completion(NO, [NSError errorWithDomain:@"Rhino" code:3 userInfo:@{NSLocalizedDescriptionKey: @"Failed to create image"}]);
            return;
        }

        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        [photoLibrary performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        } completionHandler:^(BOOL success, NSError *error) {
            completion(success, error);
        }];
    }];
    [task resume];
}

@end

// MARK: - Download Button Creator
@interface RhinoDownloadButton : UIButton
@property (nonatomic, strong) id mediaItem;
@property (nonatomic, copy) NSString *mediaType;
@end

@implementation RhinoDownloadButton

- (void)downloadTapped {
    if (!self.mediaItem) return;

    RhinoStoryDownloadManager *manager = [RhinoStoryDownloadManager sharedManager];

    if ([self.mediaItem isKindOfClass:[IGStoryItem class]]) {
        [manager downloadStory:(IGStoryItem *)self.mediaItem fromSource:@"story"];
    }
}

@end

// MARK: - HiFi Audio Manager
@interface RhinoHiFiManager : NSObject
+ (instancetype)sharedManager;
- (void)enhanceAudioForPlayer:(AVPlayer *)player;
- (void)setVolumeBoost:(BOOL)enabled forPlayer:(AVPlayer *)player;
@end

@implementation RhinoHiFiManager

+ (instancetype)sharedManager {
    static RhinoHiFiManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RhinoHiFiManager alloc] init];
    });
    return manager;
}

- (void)enhanceAudioForPlayer:(AVPlayer *)player {
    if (!kHiFiAudio || !player) return;

    AVPlayerItem *item = player.currentItem;
    if (!item) return;

    AVMutableAudioMixInputParameters *params = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:[item.asset tracksWithMediaType:AVMediaTypeAudio].firstObject];
    [params setVolume:1.5 atTime:kCMTimeZero];

    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = @[params];

    item.audioMix = audioMix;
}

- (void)setVolumeBoost:(BOOL)enabled forPlayer:(AVPlayer *)player {
    if (!player) return;
    AVPlayerItem *item = player.currentItem;
    if (!item) return;

    if (enabled) {
        NSArray *audioTracks = [item.asset tracksWithMediaType:AVMediaTypeAudio];
        if (audioTracks.count > 0) {
            AVMutableAudioMixInputParameters *params = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTracks.firstObject];
            [params setVolume:2.0 atTime:kCMTimeZero];

            AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
            audioMix.inputParameters = @[params];
            item.audioMix = audioMix;
        }
    } else {
        item.audioMix = nil;
    }
}

@end

// MARK: - Analytics Blocker
@interface RhinoAnalyticsBlocker : NSObject
+ (void)blockAnalytics;
@end

@implementation RhinoAnalyticsBlocker

+ (void)blockAnalytics {
    if (!kDisableAnalytics) return;

    // Block analytics endpoint
    Method originalMethod = class_getClassMethod([NSURLSession class], @selector(sessionWithConfiguration:delegate:delegateQueue:));
    Method swizzledMethod = class_getClassMethod([NSURLSession class], @selector(rhino_sessionWithConfiguration:delegate:delegateQueue:));

    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end

// MARK: - Story Viewer Anonymous Mode
%hook IGStoryViewer

- (void)storyViewerDidAppear {
    if (!kEnabled || !kHideViewStory) {
        %orig;
        return;
    }

    // Don't send "seen" to server
    // Original implementation sends seen receipt
    // We skip the analytics/reporting call but keep UI updates

    NSLog(@"[Rhino] Anonymous story view enabled");
}

- (void)storyViewerDidDisappear {
    if (!kEnabled || !kHideViewStory) {
        %orig;
        return;
    }
    // Don't mark story as seen on server
    NSLog(@"[Rhino] Story viewed anonymously - not marking as seen");
}

%end

// MARK: - Story Tray - Hide Seen
%hook IGStoryTrayCell

- (void)configureWithViewModel:(id).viewModel {
    %orig(viewModel);

    if (!kEnabled || !kHideSeenStories) return;

    // Remove the seen ring around avatar
    if ([viewModel respondsToSelector:@selector(hasSeen)]) {
        BOOL hasSeen = [[viewModel valueForKey:@"hasSeen"] boolValue];
        if (hasSeen) {
            self.seenIndicator.hidden = YES;
        }
    }
}

%end

// MARK: - Story Tray - Download Button
%hook IGStoryViewer

- (void)viewDidLoad {
    %orig;

    if (!kEnabled || !kDownloadStories) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        UIImage *downloadImage = [UIImage systemImageNamed:@"arrow.down.circle.fill"];
        if (downloadImage) {
            downloadImage = [downloadImage imageWithConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:28 weight:UIImageSymbolWeightBold]];
        }
        [downloadBtn setImage:downloadImage forState:UIControlStateNormal];
        downloadBtn.tintColor = [UIColor whiteColor];
        downloadBtn.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 60, 100, 44, 44);
        downloadBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        downloadBtn.layer.cornerRadius = 22;
        downloadBtn.clipsToBounds = YES;
        [downloadBtn addTarget:self action:@selector(rhino_downloadStory) forControlEvents:UIControlEventTouchUpInside];
        downloadBtn.tag = 77777;
        downloadBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

        if ([self.view viewWithTag:77777]) {
            [[self.view viewWithTag:77777] removeFromSuperview];
        }
        [self.view addSubview:downloadBtn];
    });
}

%new
- (void)rhino_downloadStory {
    IGStoryItem *item = [self valueForKey:@"item"];
    if (!item) {
        item = self.item;
    }

    if (item) {
        [[RhinoStoryDownloadManager sharedManager] downloadStory:item fromSource:@"story"];
    }
}

%end

// MARK: - Reels Download
%hook IGReelViewerViewController

- (void)viewDidLoad {
    %orig;

    if (!kEnabled || !kDownloadReels) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        UIImage *downloadImage = [UIImage systemImageNamed:@"arrow.down.circle.fill"];
        if (downloadImage) {
            downloadImage = [downloadImage imageWithConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:28 weight:UIImageSymbolWeightBold]];
        }
        [downloadBtn setImage:downloadImage forState:UIControlStateNormal];
        downloadBtn.tintColor = [UIColor whiteColor];
        downloadBtn.frame = CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 160, 44, 44);
        downloadBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        downloadBtn.layer.cornerRadius = 22;
        downloadBtn.clipsToBounds = YES;
        [downloadBtn addTarget:self action:@selector(rhino_downloadReel) forControlEvents:UIControlEventTouchUpInside];
        downloadBtn.tag = 88888;
        downloadBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;

        if ([self.view viewWithTag:88888]) {
            [[self.view viewWithTag:88888] removeFromSuperview];
        }
        [self.view addSubview:downloadBtn];
    });
}

%new
- (void)rhino_downloadReel {
    IGReelItem *item = self.currentItem;
    if (!item) {
        item = [self valueForKey:@"currentReelItem"];
    }

    if (!item) return;

    NSURL *mediaURL = item.videoURL ?: item.imageURL;
    if (!mediaURL) {
        mediaURL = [item valueForKey:@"videoURL"];
    }

    if (mediaURL) {
        NSString *type = item.videoURL ? @"video" : @"image";
        [[RhinoStoryDownloadManager sharedManager] downloadMedia:mediaURL ofType:type withCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"[Rhino] Reel downloaded successfully");
            }
        }];
    }
}

%end

// MARK: - Feed Video/Image Download
%hook IGFeedItem

%new
- (void)rhino_downloadFeedItem {
    if (!kEnabled || !kDownloadFeed) return;

    NSURL *mediaURL = self.videoURL ?: self.imageURL;
    if (!mediaURL) return;

    NSString *type = self.videoURL ? @"video" : @"image";
    [[RhinoStoryDownloadManager sharedManager] downloadMedia:mediaURL ofType:type withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"[Rhino] Feed item downloaded");
        }
    }];
}

%end

// MARK: - Feed Cell Long Press Download
%hook IGFeedCell

- (void)configureWithPost:(id)post {
    %orig(post);

    if (!kEnabled || !kAllowLongPressMedia) return;

    if ([self.gestureRecognizers count] == 0 || YES) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rhino_longPress:)];
        longPress.minimumPressDuration = 0.5;
        [self addGestureRecognizer:longPress];
    }
}

%new
- (void)rhino_longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"Download Media" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        id post = [self valueForKey:@"post"];
        if (post && [post isKindOfClass:[IGPost class]]) {
            IGPost *feedPost = (IGPost *)post;
            if (feedPost.media) {
                NSURL *url = feedPost.media.videoURL ?: feedPost.media.imageURL;
                if (url) {
                    NSString *type = feedPost.media.videoURL ? @"video" : @"image";
                    [[RhinoStoryDownloadManager sharedManager] downloadMedia:url ofType:type withCompletion:^(BOOL success, NSError *error) {}];
                }
            }
        }
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self.viewController presentViewController:alert animated:YES completion:nil];
}

%end

// MARK: - HiFi Audio Enhancement
%hook IGVideoPlayerView

- (void)setPlayer:(AVPlayer *)player {
    %orig(player);

    if (!kEnabled || !kHiFiAudio) return;

    [[RhinoHiFiManager sharedManager] enhanceAudioForPlayer:player];
}

- (void)play {
    %orig;

    if (!kEnabled || !kHiFiAudio) return;

    AVPlayer *player = self.player;
    if (player) {
        [[RhinoHiFiManager sharedManager] enhanceAudioForPlayer:player];
    }
}

%end

// MARK: - Audio Track Enhancement
%hook IGAudioTrackMedia

- (double)audioVolume {
    double vol = %orig;

    if (!kEnabled || !kHiFiAudio) return vol;

    return MIN(vol * 1.5, 2.0);
}

%end

// MARK: - Disable Ads
%hook IGSponsoredPostConfiguration

- (BOOL)shouldShowBrandedContent {
    return !kDisableAds;
}

- (BOOL)isValidSponsoredPost {
    return !kDisableAds;
}

%end

%hook IGSponsoredPost

- (BOOL)shouldShowAd {
    return !kDisableAds;
}

- (BOOL)isSponsored {
    if (kDisableAds) return NO;
    return %orig;
}

%end

// MARK: - Hide Sponsored in Feed
%hook IGFeedItemStoryPillOverlayView

- (void)setHidden:(BOOL)hidden {
    if (kDisableAds) {
        %orig(YES);
    } else {
        %orig(hidden);
    }
}

%end

// MARK: - Disable Typing Indicator
%hook IGDirectMessageService

- (void)sendTypingIndicator {
    if (!kEnabled || !kDisableTyping) {
        %orig;
    }
}

- (void)sendActivePresence {
    if (!kEnabled || !kDisableTyping) {
        %orig;
    }
}

%end

// MARK: - Disable Read Receipts
%hook IGDirectInboxService

- (void)markThreadAsSeen:(id)thread {
    if (!kEnabled || !kDisableReadReceipts) {
        %orig;
    }
}

- (void)markMessagesAsSeen:(id)messages forThread:(id)thread {
    if (!kEnabled || !kDisableReadReceipts) {
        %orig;
    }
}

%end

// MARK: - Block Analytics/Tracking
%hook IGAnalyticsManager

- (void)logEvent:(NSString *)event parameters:(NSDictionary *)params {
    if (!kEnabled || !kDisableAnalytics) {
        %orig;
        return;
    }

    NSArray *blockedEvents = @[
        @"impression",
        @"ad_impression",
        @"ad_click",
        @"time_spent",
        @"app_backgrounded",
        @"app_foregrounded",
        @"feed_scroll",
        @"video_play",
        @"session_start",
        @"session_end"
    ];

    for (NSString *blocked in blockedEvents) {
        if ([event containsString:blocked]) {
            NSLog(@"[Rhino] Blocked analytics event: %@", event);
            return;
        }
    }

    %orig;
}

%end

// MARK: - Hide Like Count
%hook IGPost
- (long long)likeCount {
    if (kHideLikeCount) return 0;
    return %orig;
}

- (BOOL)shouldHideLikeCount {
    if (kHideLikeCount) return YES;
    return %orig;
}
%end

// MARK: - Long Press Media Detection
%hook IGPlaybackTimelineView

%new
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    %orig;

    if (!kEnabled || !kAllowLongPressMedia) return;
}

%end

// MARK: - DM Voice Message Download
%hook IGDirectMessage

%new
- (void)rhino_downloadVoiceMessage {
    if (!kEnabled || !kDownloadVoiceMessages) return;
    if (![self.messageType isEqualToString:@"voice_message"] && ![self.messageType isEqualToString:@"audio"]) return;

    NSURL *url = self.mediaURL;
    if (!url) return;

    [[RhinoStoryDownloadManager sharedManager] downloadMedia:url ofType:@"audio" withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"[Rhino] Voice message downloaded");
        }
    }];
}

%end

// MARK: - Hide Seen Stories in Tray
%hook IGStoryTrayContainerCell

- (void)setTrayItems:(NSArray *)items {
    if (kEnabled && kHideSeenStories && items) {
        NSMutableArray *filtered = [NSMutableArray array];
        for (id item in items) {
            BOOL hasSeen = NO;
            if ([item respondsToSelector:@selector(hasSeen)]) {
                hasSeen = [[item valueForKey:@"hasSeen"] boolValue];
            }
            if (!hasSeen) {
                [filtered addObject:item];
            }
        }
        %orig(filtered);
    } else {
        %orig;
    }
}

%end

// MARK: - NSUserDefaults Convenience
@interface NSUserDefaults (Rhino)
- (BOOL)boolForKey:(NSString *)key default:(BOOL)defaultValue;
@end

@implementation NSUserDefaults (Rhino)
- (BOOL)boolForKey:(NSString *)key default:(BOOL)defaultValue {
    if ([self objectForKey:key] == nil) {
        [self setBool:defaultValue forKey:key];
        return defaultValue;
    }
    return [self boolForKey:key];
}
@end

// MARK: - Preference Changed Notification
static void preferenceChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
}

// MARK: - Constructor
%ctor {
    loadPrefs();

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        preferenceChanged,
        CFSTR("com.rhino.instagram.prefschanged"),
        NULL,
        CFNotificationSuspensionBehaviorCoalesce
    );

    if (!kEnabled) {
        NSLog(@"[Rhino] Tweak disabled via preferences");
        return;
    }

    if (kDisableAnalytics) {
        [RhinoAnalyticsBlocker blockAnalytics];
    }

    NSLog(@"[Rhino] Instagram tweak loaded successfully");
    NSLog(@"[Rhino] Stories: %@ | Reels: %@ | HiFi: %@ | Anonymous: %@ | Ads: %@",
          kDownloadStories ? @"ON" : @"OFF",
          kDownloadReels ? @"ON" : @"OFF",
          kHiFiAudio ? @"ON" : @"OFF",
          kHideViewStory ? @"ON" : @"OFF",
          kDisableAds ? @"BLOCKED" : @"SHOWN");
}
