//
//  SettingViewController.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/4/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "SettingViewController.h"
#import "IMGPickerManager.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *videoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *allTypeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *imageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *allowLivePhoto;
@property (weak, nonatomic) IBOutlet UISwitch *allowGif;
@property (weak, nonatomic) IBOutlet UISwitch *allowEditing;
@property (weak, nonatomic) IBOutlet UITextField *maxCountTextField;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    switch ([IMGConfigManager shareManager].targetMediaType) {
        case IMGAssetMediaTypeImage:
            self.imageSwitch.on = YES;
            break;
        case IMGAssetMediaTypeVideo:
            self.videoSwitch.on=YES;
            break;
        case IMGAssetMediaTypeAll:
            self.allTypeSwitch.on=YES;
            break;
        default:
            break;
    }
    
    self.allowGif.on = [IMGConfigManager shareManager].allowGif;
    self.allowLivePhoto.on = [IMGConfigManager shareManager].allowLivePhoto;
    self.allowEditing.on = [IMGConfigManager shareManager].allowsEditing;
    self.maxCountTextField.text = [NSString stringWithFormat:@"%ld",[IMGConfigManager shareManager].maxCount];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)chooseVideo:(UISwitch *)sender {
    if (sender.isOn) {
        [IMGConfigManager shareManager].targetMediaType = IMGAssetMediaTypeVideo;
    }
}
- (IBAction)chooseImage:(UISwitch *)sender {
    if (sender.isOn) { 
        [IMGConfigManager shareManager].targetMediaType = IMGAssetMediaTypeImage;
    }
}
- (IBAction)chooseAllType:(UISwitch *)sender {
    if (sender.isOn) {
        [IMGConfigManager shareManager].targetMediaType = IMGAssetMediaTypeAll;
    }
}
- (IBAction)doneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)allowLivePhotoAction:(UISwitch *)sender {
    [IMGConfigManager shareManager].allowLivePhoto = sender.isOn;
}
- (IBAction)allowGifAction:(UISwitch *)sender {
    [IMGConfigManager shareManager].allowGif = sender.isOn;
    
}
- (IBAction)allowEditingAction:(UISwitch *)sender {
    [IMGConfigManager shareManager].allowsEditing = sender.isOn;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textFieldDidChange:(NSNotification *)noti
{
    UITextField *textField = noti.object;
    if (textField!=self.maxCountTextField) {
        return;
    }
    
    [IMGConfigManager shareManager].maxCount = [textField.text integerValue];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
