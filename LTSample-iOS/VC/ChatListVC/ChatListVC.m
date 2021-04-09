//
//  ChatListVC.m
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/1/6.
//

#import "ChatListVC.h"
#import "ChatListCell.h"
#import "IMManager.h"
#import "ChatVC.h"

@interface ChatListVC()<UITableViewDelegate, UITableViewDataSource, IMManagerDelegate>
@property (nonatomic, strong) IBOutlet UITableView *chatTV;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, strong) NSMutableArray *channelArray;
@end

@implementation ChatListVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _channelArray = [[NSMutableArray alloc] init];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IMManager sharedInstance].currentChannel = nil;
    [[IMManager sharedInstance] addDelegate:self];
    [self.channelArray removeAllObjects];
    self.chatTV.hidden = YES;
    [self.activityView startAnimating];
    [[IMManager sharedInstance] queryChannels];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IMManager sharedInstance] removeDelegate:self];
}

- (void)initViews {
    [self.chatTV registerNib:[UINib nibWithNibName:@"ChatListCell" bundle:nil] forCellReuseIdentifier:@"ChatListCell"];
}

//MARK: - UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LTChannelResponse *channel = self.channelArray[indexPath.row];
    [IMManager sharedInstance].currentChannel = channel;
    [self performSegueWithIdentifier:@"goChatVC" sender:nil];
}

//MARK: - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channelArray.count;
}

- (ChatListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatListCell"];
    LTChannelResponse *channel = self.channelArray[indexPath.row];
    if (channel.subject.length > 0) {
        cell.lblSubject.text = channel.subject;
    } else {
        cell.lblSubject.text = channel.chID;
    }
    
    cell.lblMessage.text = channel.lastMsgContent;
    cell.lblSendTime.text = [NSString stringWithFormat:@"%lld", channel.lastMsgTime];
    
    return cell;
}

//MARK: - IMManagerDelegate
- (void)onQueryChannels:(NSArray<LTChannelResponse *> *)channels {
    [self.activityView stopAnimating];
    self.chatTV.hidden = NO;
    [self.channelArray setArray:channels];
    [self.chatTV reloadData];
}

@end
