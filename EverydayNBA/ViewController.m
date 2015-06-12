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

@interface ViewController (){
    UIView          *playerView;
    UITableView     *videoTable;
    NSMutableArray  *videoList;
    VideoItem       *topItem;
    
    UIButton        *fullscrenButton;
    
    BOOL            isFullScreen;
}

@property (nonatomic) VideoView *playbackView;
@property (nonatomic, strong) NSTimer *progressTimer;

@end

@implementation ViewController

-(void) loadView{
    [super loadView];
    
    //background
    UIImageView *backImage = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [backImage setImage:[UIImage imageNamed:@"backgroundImage"]];
    [self.view addSubview:backImage];
    
    //video view
    self.playbackView = [[VideoView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width/16*9)];
    [self.view addSubview:self.playbackView];
    [self setControlView];
    
    videoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, self.playbackView.frame.origin.y + self.playbackView.frame.size.height + 50, self.view.frame.size.width, self.view.frame.size.height - self.playbackView.frame.origin.y - self.playbackView.frame.size.height - 50)];
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
}

-(void) viewDidAppear:(BOOL)animated{
    //parse data
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
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
        AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
        NSError *error;
        topItem.remotePath = tempString;
        [player playItem: topItem error:&error];
        [self setPlayerLayer];
        [player play];
    }
    
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setPlayerLayer {
    AVPlayerLayer *layer = (AVPlayerLayer *)self.playbackView.layer;
    [layer setPlayer:[self player].player];
}

- (AUMediaPlayer *)player {
    return [AUMediaPlayer sharedInstance];
}

- (void) setControlView{
    [fullscrenButton removeFromSuperview];
    fullscrenButton = [[UIButton alloc]initWithFrame:CGRectMake(self.playbackView.frame.size.width - 24, self.playbackView.frame.size.height - 24, 20, 20)];
    [fullscrenButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    [self.playbackView addSubview:fullscrenButton];
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
    
    if (indexPath.row==0) {
        AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
        NSError *error;
        //
        
        [player playItem:topItem error:&error];
        [player play];
    }
    else{
        VideoItem *item = [videoList objectAtIndex:indexPath.row];
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:item.uid]];
        [_webView loadRequest:request];
    }
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
    if (!library.downloadingItems && library.downloadingItems.count == 0) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    if (self.progressTimer == nil) {
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateDownloadProgress) userInfo:nil repeats:YES];
    }
    for (id<AUMediaItem> item in library.downloadingItems) {
        NSLog(@"%@", [item uid]);
    }
}

@end
