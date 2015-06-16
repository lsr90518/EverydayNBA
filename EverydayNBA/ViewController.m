//
//  ViewController.m
//  EverydayNBA
//
//  Created by 劉 松然 on 2015/06/12.
//  Copyright (c) 2015年 lsr. All rights reserved.
//

#import "ViewController.h"
#import <AUMediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoView.h"
#import "MediaItem.h"
#import "NBAVideoParser.h"
#import <SVProgressHUD.h>
#import "ENTableViewCell.h"

static void *AUMediaPlaybackCurrentTimeObservationContext = &AUMediaPlaybackCurrentTimeObservationContext;
static void *AUMediaPlaybackDurationObservationContext = &AUMediaPlaybackDurationObservationContext;
static void *AUMediaPlaybackTimeValidityObservationContext = &AUMediaPlaybackTimeValidityObservationContext;

@interface ViewController (){
    NSUInteger _currentItemDuration;
    
    UIView          *playerView;
    UITableView     *videoTable;
    NSMutableArray  *videoList;
    VideoItem       *topItem;
    
    UIButton        *fullscrenButton;
    
    BOOL            isFullScreen;
    BOOL            isShowControlView;
    BOOL _playbackTimesAreValid;
    
    UIButton        *controlView;
    UIButton        *playButton;
    UISlider        *seekBar;
    
    UIView          *navigationView;
    UILabel         *title;
}

@property (nonatomic) VideoView *playbackView;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, strong) NSTimer *controlTimer;

@end

@implementation ViewController

-(void) loadView{
    [super loadView];
    
    //background
    UIImageView *backImage = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [backImage setImage:[UIImage imageNamed:@"backgroundImage"]];
    [self.view addSubview:backImage];
    
    //navigation title
    navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 40)];
    [self.view addSubview:navigationView];
    
    title = [[UILabel alloc]initWithFrame:CGRectMake(0, 11, navigationView.frame.size.width, 20)];
    title.font = [UIFont fontWithName:@"Baskerville" size:20];
    title.textColor = [UIColor whiteColor];
    title.text = @"Everyday Basketball";
    title.textAlignment = NSTextAlignmentCenter;
    [navigationView addSubview:title];
    
    //init control view
    controlView = [[UIButton alloc]init];
    playButton = [[UIButton alloc]init];
    seekBar = [[UISlider alloc]init];
    fullscrenButton= [[UIButton alloc]init];

    //video view
    self.playbackView = [[VideoView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width/16*9)];
    [self.view addSubview:self.playbackView];
    [self setControlView];
    [self initControlView];
    
    
    videoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, self.playbackView.frame.origin.y + self.playbackView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.playbackView.frame.origin.y - self.playbackView.frame.size.height)];
    videoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    videoTable.delegate = self;
    videoTable.dataSource = self;
    [videoTable setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:videoTable];
    
    //test data
    videoList = [[NSMutableArray alloc]init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _webView = [[UIWebView alloc]initWithFrame:CGRectZero];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    urlString = @"http://www.nba.co.jp/nba/video";
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [_webView loadRequest:request];
    
    [self musicPlayerStateChanged:nil];
}

-(void) viewDidAppear:(BOOL)animated{
    //parse data
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    
    //notification center
    AUMediaPlayer *player = [self player];
    [player addObserver:self forKeyPath:@"currentPlaybackTime" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AUMediaPlaybackCurrentTimeObservationContext];
    [player addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AUMediaPlaybackDurationObservationContext];
    [player addObserver:self forKeyPath:@"playbackTimesAreValid" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AUMediaPlaybackTimeValidityObservationContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicPlayerStateChanged:)
                                                 name:kAUMediaPlaybackStateDidChangeNotification
                                               object:nil];
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@", error);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [videoList removeAllObjects];
    
    NSString *body = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSDictionary *dic = [NBAVideoParser topSiteDataDictionaryWithHTMLSource:body];
    NSString *tempString = [NBAVideoParser videoSourceWithHTMLSource:body];
    
    if (dic[@"OtherArray"]!=nil) {
        
//        AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
//        NSError *error;
        
        topItem = [[VideoItem alloc]init];
        topItem.author = @"";
        topItem.title = dic[@"TopDictionary"][@"Title"];
        topItem.uid = dic[@"TopDictionary"][@"ThumbnailURL"];

        NSArray *itemArray = [[NSArray alloc]initWithArray:dic[@"OtherArray"]];
        for (NSDictionary *n in itemArray){
            VideoItem *item = [[VideoItem alloc]init];
            item.uid = n[@"ClipId"];
            item.thumnail = n[@"ThumbnailURL"];
            item.title = n[@"Title"];
            [videoList addObject:item];
        }
        
        [videoTable reloadData];
    }
    
    
    if (![tempString isEqualToString:@""]) {
        topItem.remotePath = tempString;
        
        [self initView];
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setPlayerLayer {
    AVPlayerLayer *layer = (AVPlayerLayer *)self.playbackView.layer;
    [layer setPlayer:[self player].player];
}

-(void) initView{
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    NSError *error;
    [player playItem: topItem error:&error];
    [self setPlayerLayer];
    [player play];
    [playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];

    //controlview
    [self initControlView];
}

-(void) initControlView{
    isShowControlView = NO;
    [controlView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0]];
    for(UIView *view in [controlView subviews]){
        [view setHidden:YES];
    }
}

- (AUMediaPlayer *)player {
    return [AUMediaPlayer sharedInstance];
}

- (void) setControlView{
    [controlView removeFromSuperview];
    
    [controlView setFrame:self.playbackView.frame];
    [controlView addTarget:self action:@selector(toggleControlView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:controlView];
    
    //play button
    [playButton setFrame:CGRectMake(controlView.frame.size.width/2 - 32, controlView.frame.size.height/2 - 32, 64, 64)];
    [playButton addTarget:self action:@selector(togglePlayAction) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:playButton];
    
    //seek
    [seekBar setFrame:CGRectMake(5, controlView.frame.size.height - 25, controlView.frame.size.width - 40, 20)];
    seekBar.tintColor = [UIColor orangeColor];
    [seekBar addTarget:self action:@selector(didSlide) forControlEvents:UIControlEventValueChanged];
    [controlView addSubview:seekBar];
    
    //    [fullscrenButton removeFromSuperview];
    //fllscreen
    [fullscrenButton setFrame:CGRectMake(controlView.frame.size.width - 26, controlView.frame.size.height - 26, 20, 20)];
    [fullscrenButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    [controlView addSubview:fullscrenButton];
    [fullscrenButton addTarget:self action:@selector(toggleFullscreen) forControlEvents:UIControlEventTouchUpInside];
}

- (void)toggleFullscreen{
    if(isFullScreen){
        isFullScreen = NO;
        [videoTable setHidden:NO];
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
        [self.playbackView setFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/16*9)];
        [self setControlView];
    } else {
        isFullScreen = YES;
        [videoTable setHidden:YES];
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        [self.playbackView setFrame:[UIScreen mainScreen].bounds];
        [self setControlView];
    }
}

#pragma tableview delegate
#pragma mark - TableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [videoList count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    ENTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[ENTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    VideoItem *item = [videoList objectAtIndex:indexPath.row];
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:item.uid]];
    [_webView loadRequest:request];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(ENTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];

    [cell setData:[videoList objectAtIndex:indexPath.row]];
}

#pragma mark - Download progress

- (void)updateDownloadProgress {
    AUMediaLibrary *library = [AUMediaPlayer sharedInstance].library;
    NSLog(@"%lu", (unsigned long)library.downloadingItems.count);

    if (!library.downloadingItems && library.downloadingItems.count == 0) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    if (self.progressTimer == nil) {
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateDownloadProgress) userInfo:nil repeats:YES];
    }
    for (id<AUMediaItem> item in library.downloadingItems) {
        NSLog(@"%@", [item uid]);
    }
}

#pragma show control view
-(void) updateControlViewStatus{
    
}

-(void) toggleControlView{
    if (isShowControlView) {
        isShowControlView = NO;
        [controlView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0]];
        
        for(UIView *view in [controlView subviews]){
            [view setHidden:YES];
        }
    } else {
        isShowControlView = YES;
        [controlView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        for(UIView *view in [controlView subviews]){
            [view setHidden:NO];
        }
    }
}

#pragma notification method
- (void)musicPlayerStateChanged:(NSNotification *)notification {
    [self updateButtonsForStatus:[[AUMediaPlayer sharedInstance] playbackStatus]];
}
- (void)updateButtonsForStatus:(AUMediaPlaybackStatus)status {
    if (status == 1) {
        [SVProgressHUD dismiss];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == AUMediaPlaybackTimeValidityObservationContext) {
        BOOL playbackTimesValidaity = [change[NSKeyValueChangeNewKey] boolValue];
        _playbackTimesAreValid = playbackTimesValidaity;

    } else if (context == AUMediaPlaybackCurrentTimeObservationContext) {
        NSUInteger currentPlaybackTime = [change[NSKeyValueChangeNewKey] integerValue];
        [self updatePlaybackProgressSliderWithTimePassed:currentPlaybackTime];
    } else if (context == AUMediaPlaybackDurationObservationContext) {
        NSUInteger currentDuration = [change[NSKeyValueChangeNewKey] integerValue];
        _currentItemDuration = currentDuration;

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updatePlaybackProgressSliderWithTimePassed:(NSUInteger)time {
    if (_playbackTimesAreValid && _currentItemDuration > 0) {
        seekBar.value = (float)time/(float)_currentItemDuration;
    } else {
        seekBar.value = 0.0;
    }
}

-(void) didSlide {
    [[self player] seekToMoment:seekBar.value];
}

-(void) togglePlayAction{
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
//    if (player.playbackStatus == AUMediaPlaybackStatusPlayerInactive || (topItem && ![[player.nowPlayingItem uid] isEqualToString:topItem.uid])) {
//        NSError *error;
//        [player playItem: topItem error:&error];
//        [self setPlayerLayer];
//        [player play];
//
//    } else
    if (player.playbackStatus == AUMediaPlaybackStatusPlaying) {
        [player pause];
        [playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    } else {
        [playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [player play];
    }
}


@end