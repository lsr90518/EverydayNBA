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
    VideoItem *video = [[VideoItem alloc] init];
    video.author = @"Video author";
    video.title = @"現地11日のベストスティール／マシュー・デラベドバ ";
    video.uid = @"00000000004";
    video.thumnail = @"http://www.nba.co.jp/javaImages/66/61/0,,~13787494,00.jpeg?&w=400&h=222";
    video.remotePath = @"http://qn.vc/files/data/1541/2%20Many%20Girls%20-%20Fazilpuria,%20Badshah%20[mobmp4.com].mp4";
    
    VideoItem *video2 = [[VideoItem alloc] init];
    video2.author = @"Video author";
    video2.title = @"現地11日  M・デラベドバからL・ジェイムズのアリウープ ";
    video2.uid = @"00000000004";
    video2.thumnail = @"http://www.nba.co.jp/javaImages/66/61/0,,~13787494,00.jpeg?&w=400&h=222";
    video2.remotePath = @"http://qn.vc/files/data/1541/2%20Many%20Girls%20-%20Fazilpuria,%20Badshah%20[mobmp4.com].mp4";
    
    VideoItem *video3 = [[VideoItem alloc] init];
    video3.author = @"Video author";
    video3.title = @"現地11日のベストブロック／ジェイムズ・ジョーンズ ";
    video3.uid = @"00000000004";
    video3.thumnail = @"http://www.nba.co.jp/javaImages/66/61/0,,~13787494,00.jpeg?&w=400&h=222";
    video3.remotePath = @"http://www.tonycuffe.com/mp3/pipers%20hut.mp3";
    
    VideoItem *video4 = [[VideoItem alloc] init];
    video4.author = @"Video author";
    video4.title = @"現地11日 トップ5プレー ";
    video4.uid = @"00000000004";
    video4.thumnail = @"http://www.nba.co.jp/javaImages/66/61/0,,~13787494,00.jpeg?&w=400&h=222";
    video4.remotePath = @"http://qn.vc/files/data/1541/2%20Many%20Girls%20-%20Fazilpuria,%20Badshah%20[mobmp4.com].mp4";
    [videoList addObject:video];
    [videoList addObject:video2];
    [videoList addObject:video3];
    [videoList addObject:video4];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewDidAppear:(BOOL)animated{
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    NSError *error;
    
    topItem = [[VideoItem alloc]init];
    topItem.author = @"";
    topItem.title = @"Video";
    topItem.uid = @"00000000001";
    topItem.remotePath = @"http://vod.nbajapan.aka.oss1.performgroup.com/20150612/rwoh0gnnuz7q17989s012dks0.mp4";
    
    [player playItem: topItem error:&error];
    [self setPlayerLayer];
    [player play];
    
//    [self updateDownloadProgress];
//    [self setFullscreen];
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
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    NSError *error;
    
    [player playItem:[videoList objectAtIndex:indexPath.row] error:&error];
    [player play];
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
