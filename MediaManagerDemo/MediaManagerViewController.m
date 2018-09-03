//
//  MediaManagerViewController.m
//  MediaManagerDemo
//
//  Created by DJI on 1/8/2017.
//  Copyright © 2017 DJI. All rights reserved.
//

#import "MediaManagerViewController.h"
#import "DemoUtility.h"
#import "DJIAlertView.h"
#import "DJIScrollView.h"
#import <DJIWidget/DJIVideoPreviewer.h>
#import <DJIWidget/DJIRTPlayerRenderView.h>

@interface MediaManagerViewController ()<DJICameraDelegate, DJIMediaManagerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *positionTextField;
@property (weak, nonatomic) IBOutlet UITableView *mediaTableView;
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@property (weak, nonatomic) IBOutlet UIImageView *displayImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property(nonatomic, strong) NSMutableArray* mediaList;
@property (nonatomic, weak) DJIMediaManager *mediaManager;
@property(nonatomic, strong) DJIAlertView* statusAlertView;
@property(nonatomic) DJIMediaFile *selectedMedia;
@property(nonatomic) NSUInteger previousOffset;
@property(nonatomic) NSMutableData *fileData;
@property (nonatomic) DJIScrollView *statusView;
@property (nonatomic, strong) NSIndexPath *selectedCellIndexPath;
@property (nonatomic, strong) DJIRTPlayerRenderView *renderView;

@end

@implementation MediaManagerViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DJICamera *camera = [DemoUtility fetchCamera];
    if (camera != nil) {
        camera.delegate = self;
        self.mediaManager = camera.mediaManager;
        self.mediaManager.delegate = self;
        [camera setMode:DJICameraModeMediaDownload withCompletion:^(NSError *error) {
            if (error) {
                NSLog(@"setMode failed: %@", error.description);
            }
        }];
        [self loadMediaList];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    DJICamera *camera = [DemoUtility fetchCamera];
    [camera setMode:DJICameraModeShootPhoto withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Set CameraWorkModeShootPhoto Failed, %@", error.description);
        }
    }];
    
    if (camera && camera.delegate == self) {
        [camera setDelegate:nil];
        self.mediaManager.delegate = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Custom Methods
- (void)initData
{
    self.mediaList = [[NSMutableArray alloc] init];
    [self.deleteBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
    [self.reloadBtn setEnabled:NO];
    [self.editBtn setEnabled:NO];
    
    self.fileData = nil;
    self.selectedMedia = nil;
    self.previousOffset = 0;
    
    self.statusView = [DJIScrollView viewWithViewController:self];
    [self.statusView setHidden:YES];
    
    //Support Video Playback for Phantom 4 Professional, Inspire 2
    H264EncoderType encoderType = H264EncoderType_unknown;
    DJICamera *camera = [DemoUtility fetchCamera];
    if (camera && ([camera.displayName isEqualToString:DJICameraDisplayNamePhantom4ProCamera] ||
         [camera.displayName isEqualToString:DJICameraDisplayNamePhantom4AdvancedCamera]||
         [camera.displayName isEqualToString:DJICameraDisplayNameX4S] ||
         [camera.displayName isEqualToString:DJICameraDisplayNameX5S])) { //Phantom 4 Professional, Phantom 4 Advanced and Inspire 2
        encoderType = H264EncoderType_H1_Inspire2;
    }

    self.renderView = [[DJIRTPlayerRenderView alloc] initWithDecoderType:LiveStreamDecodeType_VTHardware
                                                             encoderType:encoderType];
    self.renderView.frame = self.videoPreviewView.bounds;
    [self.videoPreviewView addSubview:self.renderView];
    [self.renderView setHidden:YES];

}

-(void) loadMediaList
{
    [self.loadingIndicator setHidden:NO];
    if (self.mediaManager.sdCardFileListState == DJIMediaFileListStateSyncing ||
             self.mediaManager.sdCardFileListState == DJIMediaFileListStateDeleting) {
        NSLog(@"Media Manager is busy. ");
    }else {
        WeakRef(target);
        [self.mediaManager refreshFileListOfStorageLocation:DJICameraStorageLocationSDCard withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"Fetch Media File List Failed: %@", error.localizedDescription);
            }
            else {
                NSLog(@"Fetch Media File List Success.");
                NSArray *mediaFileList = [target.mediaManager sdCardFileListSnapshot];
                [target updateMediaList:mediaFileList];
            }
            [target.loadingIndicator setHidden:YES];
        }];
        
    }
}

-(void) updateMediaList:(NSArray*)mediaList
{
    [self.mediaList removeAllObjects];
    [self.mediaList addObjectsFromArray:mediaList];
    
    DJIFetchMediaTaskScheduler *mediaTaskScheduler = [DemoUtility fetchCamera].mediaManager.taskScheduler;
    mediaTaskScheduler.suspendAfterSingleFetchTaskFailure = NO;
    [mediaTaskScheduler resumeWithCompletion:nil];
    for (DJIMediaFile *file in self.mediaList) {
        if (file.thumbnail == nil) {
            WeakRef(target);
            DJIFetchMediaTask *task = [DJIFetchMediaTask taskWithFile:file content:DJIFetchMediaTaskContentThumbnail andCompletion:^(DJIMediaFile * _Nullable file, DJIFetchMediaTaskContent content, NSError * _Nullable error) {
                WeakReturn(target);
                [target.mediaTableView reloadData];
            }];
            [mediaTaskScheduler moveTaskToEnd:task];
        }
    }
    
    [self.reloadBtn setEnabled:YES];
    [self.editBtn setEnabled:YES];
}

-(void) showPhotoWithData:(NSData*)data
{
    if (data) {
        UIImage* image = [UIImage imageWithData:data];
        if (image) {
            [self.displayImageView setImage:image];
            [self.displayImageView setHidden:NO];
        }
    }
}

-(NSString *)statusToString:(DJIMediaVideoPlaybackStatus)status {
    switch (status) {
        case DJIMediaVideoPlaybackStatusPaused:
            return @"Paused";
        case DJIMediaVideoPlaybackStatusPlaying:
            return @"Playing";
        case DJIMediaVideoPlaybackStatusStopped:
            return @"Stopped";
        default:
            break;
    }
    return nil;
}

-(NSString *)orientationToString:(DJICameraOrientation)orientation {
    switch (orientation) {
        case DJICameraOrientationLandscape:
            return @"Landscape";
        case DJICameraOrientationPortrait:
            return @"Portrait";
        default:
            break;
    }
    return nil;
}

-(void) dismissStatusAlertView
{
    [self.statusAlertView dismissAlertView];
    self.statusAlertView = nil;
}

#pragma mark - IBAction Methods
- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editBtnAction:(id)sender {
    [self.mediaTableView setEditing:YES animated:YES];
    [self.deleteBtn setEnabled:YES];
    [self.cancelBtn setEnabled:YES];
    [self.editBtn setEnabled:NO];
}

- (IBAction)cancelBtnAction:(id)sender {
    [self.mediaTableView setEditing:NO animated:YES];
    [self.editBtn setEnabled:YES];
    [self.deleteBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
}

- (IBAction)reloadBtnAction:(id)sender {
    [self loadMediaList];
}

- (IBAction)statusBtnAction:(id)sender {
    [self.statusView setHidden:NO];
    [self.statusView show];
}

- (IBAction)downloadBtnAction:(id)sender {
    
    BOOL isPhoto = self.selectedMedia.mediaType == DJIMediaTypeJPEG || self.selectedMedia.mediaType == DJIMediaTypeTIFF;
    WeakRef(target);
    if (self.statusAlertView == nil) {
        NSString* message = [NSString stringWithFormat:@"Fetch Media Data \n 0.0"];
        self.statusAlertView = [DJIAlertView showAlertViewWithMessage:message titles:@[@"Cancel"] action:^(NSUInteger buttonIndex) {
            WeakReturn(target);
            if (buttonIndex == 0) {
                [target.selectedMedia stopFetchingFileDataWithCompletion:^(NSError * _Nullable error) {
                    target.statusAlertView = nil;
                }];
            }
        }];
    }
    
    [self.selectedMedia fetchFileDataWithOffset:self.previousOffset updateQueue:dispatch_get_main_queue() updateBlock:^(NSData * _Nullable data, BOOL isComplete, NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            [target.statusAlertView updateMessage:[[NSString alloc] initWithFormat:@"Download Media Failed:%@",error]];
            [target performSelector:@selector(dismissStatusAlertView) withObject:nil afterDelay:2.0];
        }
        else
        {
            if (isPhoto) {
                if (target.fileData == nil) {
                    target.fileData = [data mutableCopy];
                }
                else {
                    [target.fileData appendData:data];
                }
            }
            target.previousOffset += data.length;
            float progress = target.previousOffset * 100.0 / target.selectedMedia.fileSizeInBytes;
            [target.statusAlertView updateMessage:[NSString stringWithFormat:@"Downloading: %0.1f%%", progress]];
            if (target.previousOffset == target.selectedMedia.fileSizeInBytes && isComplete) {
                [target dismissStatusAlertView];
                if (isPhoto) {
                    [target showPhotoWithData:target.fileData];
                    [target savePhotoWithData:target.fileData];
                }
            }
        }
    }];
}

- (IBAction)playBtnAction:(id)sender {

    [self.displayImageView setHidden:YES];
    
    DJICamera *camera = [DemoUtility fetchCamera];
    if (camera &&
        ([camera.displayName isEqualToString:DJICameraDisplayNamePhantom4ProCamera] ||
         [camera.displayName isEqualToString:DJICameraDisplayNamePhantom4AdvancedCamera]||
         [camera.displayName isEqualToString:DJICameraDisplayNameX4S] ||
         [camera.displayName isEqualToString:DJICameraDisplayNameX5S] ||
         [camera.displayName isEqualToString:DJICameraDisplayNameX3] ||
         [camera.displayName isEqualToString:DJICameraDisplayNameXT] ||
         [camera.displayName isEqualToString:DJICameraDisplayNameZ3] ||
         [camera.displayName isEqualToString:DJICameraDisplayNameZ30])) {
        [self.renderView setHidden:NO];
    } else {
        [self.renderView setHidden:YES];
    }
    
    if ((self.selectedMedia.mediaType == DJIMediaTypeMOV) || (self.selectedMedia.mediaType == DJIMediaTypeMP4)) {
        [self.positionTextField setPlaceholder:[NSString stringWithFormat:@"%d sec", (int)self.selectedMedia.durationInSeconds]];
        [self.mediaManager playVideo:self.selectedMedia withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Play Video Failed: %@", error.description);
            }
        }];
    }
}

- (IBAction)resumeBtnAction:(id)sender {
    
    [self.mediaManager resumeWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Resume failed: %@", error.description);
        }
    }];
}

- (IBAction)pauseBtnAction:(id)sender {
    [self.mediaManager pauseWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Pause failed: %@", error.description);
        }
    }];
}

- (IBAction)stopBtnAction:(id)sender {
    [self.mediaManager stopWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Stop failed: %@", error.description);
        }
    }];
}

- (IBAction)moveToPositionAction:(id)sender {
    NSUInteger second = 0;
    if (self.positionTextField.text.length) {
        second = [self.positionTextField.text floatValue];
    }
    
    WeakRef(target);
    [self.mediaManager moveToPosition:second withCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"Move to position failed: %@", error.description);
        }
        [target.positionTextField setText: @""];
    }];
    
}

- (IBAction)showStatusBtnAction:(id)sender {
    [self.statusView setHidden:NO];
    [self.statusView show];
}

#pragma mark Save Download Images
-(void) savePhotoWithData:(NSData*)data
{
    if (data) {
        UIImage* image = [UIImage imageWithData:data];
        if (image) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString* message = @"";
    if (error != NULL)
    {
        //Show message when save image failed
        message = [NSString stringWithFormat:@"Save Image Failed! Error: %@", error];
    }
    else
    {
        //Show message when save image successfully
        message = [NSString stringWithFormat:@"Saved to Photo Album"];
    }
    
    WeakRef(target);
    if (self.statusAlertView == nil) {
        self.statusAlertView = [DJIAlertView showAlertViewWithMessage:message titles:@[@"Dismiss"] action:^(NSUInteger buttonIndex) {
            WeakReturn(target);
            if (buttonIndex == 0) {
                [target dismissStatusAlertView];
            }
        }];
    }
}

#pragma mark - DJIMediaManagerDelegate Method

- (void)manager:(DJIMediaManager *)manager didUpdateVideoPlaybackState:(DJIMediaVideoPlaybackState *)state {
    NSMutableString *stateStr = [NSMutableString string];
    if (state.playingMedia == nil) {
        [stateStr appendString:@"No media\n"];
    }
    else {
        [stateStr appendFormat:@"media: %@\n", state.playingMedia.fileName];
        [stateStr appendFormat:@"Total: %f\n", state.playingMedia.durationInSeconds];
        [stateStr appendFormat:@"Orientation: %@\n", [self orientationToString:state.playingMedia.videoOrientation]];
    }
    [stateStr appendFormat:@"Status: %@\n", [self statusToString:state.playbackStatus]];
    [stateStr appendFormat:@"Position: %f\n", state.playingPosition];
    
    [self.statusView writeStatus:stateStr];
}

-(void)manager:(DJIMediaManager *)manager didUpdateVideoPlaybackData:(uint8_t *)data length:(size_t)length forRendering:(BOOL)forRendering {
    [self.renderView decodeH264CompleteFrameData:data
                                      length:length
                                  decodeOnly:!forRendering];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.mediaList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaFileCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"mediaFileCell"];
    }
    
    if (self.selectedCellIndexPath == indexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    DJIMediaFile * media = [self.mediaList objectAtIndex:indexPath.row];
    cell.textLabel.text = media.fileName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Create Date: %@ Size: %0.1fMB Duration:%f cusotmInfo:%@", media.timeCreated, media.fileSizeInBytes / 1024.0 / 1024.0,media.durationInSeconds, media.customInformation];
    if (media.thumbnail == nil) {
        [cell.imageView setImage:[UIImage imageNamed:@"dji.png"]];
    }
    else
    {
        [cell.imageView setImage:media.thumbnail];
    }
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.mediaTableView.isEditing) {
        return;
    }
    
    self.selectedCellIndexPath = indexPath;

    DJIMediaFile *currentMedia = [self.mediaList objectAtIndex:indexPath.row];
    if (![currentMedia isEqual:self.selectedMedia]) {
        self.previousOffset = 0;
        self.selectedMedia = currentMedia;
        self.fileData = nil;
    }
    
    [tableView reloadData];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    DJIMediaFile* currentMedia = [self.mediaList objectAtIndex:indexPath.row];
    [self.mediaManager deleteFiles:@[currentMedia] withCompletion:^(NSArray<DJIMediaFile *> * _Nonnull failedFiles, NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Delete File Failed:%@",error.description);
            for (DJIMediaFile * media in failedFiles) {
                NSLog(@"%@ delete failed",media.fileName);
            }
        }else
        {
            ShowResult(@"Delete File Successfully");
            [self.mediaList removeObjectAtIndex:indexPath.row];
            [self.mediaTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        
    }];
}

@end
