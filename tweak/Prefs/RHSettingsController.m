/**
 * Rhino Instagram Tweak - Preferences Bundle
 */

@interface RHSettingsController : UIViewController
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sections;
@end

@implementation RHSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Rhino";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.sections = @[
        @"General",
        @"Downloads",
        @"Privacy",
        @"Audio",
        @"Appearance",
        @"About"
    ];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = (id)self;
    self.tableView.dataSource = (id)self;
    [self.view addSubview:self.tableView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSelf)];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.rhino.instagram.prefschanged"), NULL, NULL, YES);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 2;  // General
        case 1: return 4;  // Downloads
        case 2: return 4;  // Privacy
        case 3: return 2;  // Audio
        case 4: return 1;  // Appearance
        case 5: return 3;  // About
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    switch (indexPath.section) {
        case 0: // General
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Enable Rhino";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_Enabled" default:YES];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 0;
                cell.accessoryView = toggle;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.textLabel.text = @"Disable Analytics";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_DisableAnalytics" default:YES];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 1;
                cell.accessoryView = toggle;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            break;

        case 1: // Downloads
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Download Stories";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_DownloadStories" default:YES];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 2;
                cell.accessoryView = toggle;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Download Reels";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_DownloadReels" default:YES];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 3;
                cell.accessoryView = toggle;
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"Download Feed Media";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_DownloadFeed" default:YES];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 4;
                cell.accessoryView = toggle;
            } else {
                cell.textLabel.text = @"Download Voice Messages";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_DownloadVoiceMessages" default:YES];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 5;
                cell.accessoryView = toggle;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;

        case 2: // Privacy
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Anonymous Story View";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_HideViewStory" default:YES];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 6;
                cell.accessoryView = toggle;
                cell.detailTextLabel.text = @"View stories without being seen";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Hide Story Viewers";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_HideStoryViewers" default:YES];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 7;
                cell.accessoryView = toggle;
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"Disable Typing Indicator";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_DisableTyping" default:NO];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 8;
                cell.accessoryView = toggle;
            } else {
                cell.textLabel.text = @"Disable Read Receipts";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_DisableReadReceipts" default:NO];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 9;
                cell.accessoryView = toggle;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;

        case 3: // Audio
            if (indexPath.row == 0) {
                cell.textLabel.text = @"HiFi Audio";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_HiFiAudio" default:YES];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 10;
                cell.accessoryView = toggle;
                cell.detailTextLabel.text = @"Boost audio quality";
            } else {
                cell.textLabel.text = @"Disable Ads";
                UISwitch *toggle = [[UISwitch alloc] init];
                toggle.on = [defaults boolForKey:@"rhino_DisableAds" default:YES];
                [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
                toggle.tag = 11;
                cell.accessoryView = toggle;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;

        case 4: // Appearance
            cell.textLabel.text = @"Hide Like Counts";
            UISwitch *toggle = [[UISwitch alloc] init];
            toggle.on = [defaults boolForKey:@"rhino_HideLikeCount" default:NO];
            [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
            toggle.tag = 12;
            cell.accessoryView = toggle;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;

        case 5: // About
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Rhino v2.4.1";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"View Source on GitHub";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.textLabel.text = @"Reload SpringBoard";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.textColor = [UIColor systemRedColor];
            }
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 5 && indexPath.row == 2) {
        // Respring
        pid_t pid;
        const char* args[] = {"sbreload", "-u", NULL};
        posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
    }

    if (indexPath.section == 5 && indexPath.row == 1) {
        NSURL *url = [NSURL URLWithString:@"https://github.com/RhinoDev/InstagramTweak"];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)toggleChanged:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    switch (sender.tag) {
        case 0: [defaults setBool:sender.on forKey:@"rhino_Enabled"]; break;
        case 1: [defaults setBool:sender.on forKey:@"rhino_DisableAnalytics"]; break;
        case 2: [defaults setBool:sender.on forKey:@"rhino_DownloadStories"]; break;
        case 3: [defaults setBool:sender.on forKey:@"rhino_DownloadReels"]; break;
        case 4: [defaults setBool:sender.on forKey:@"rhino_DownloadFeed"]; break;
        case 5: [defaults setBool:sender.on forKey:@"rhino_DownloadVoiceMessages"]; break;
        case 6: [defaults setBool:sender.on forKey:@"rhino_HideViewStory"]; break;
        case 7: [defaults setBool:sender.on forKey:@"rhino_HideStoryViewers"]; break;
        case 8: [defaults setBool:sender.on forKey:@"rhino_DisableTyping"]; break;
        case 9: [defaults setBool:sender.on forKey:@"rhino_DisableReadReceipts"]; break;
        case 10: [defaults setBool:sender.on forKey:@"rhino_HiFiAudio"]; break;
        case 11: [defaults setBool:sender.on forKey:@"rhino_DisableAds"]; break;
        case 12: [defaults setBool:sender.on forKey:@"rhino_HideLikeCount"]; break;
    }

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.rhino.instagram.prefschanged"), NULL, NULL, YES);
}

@end
