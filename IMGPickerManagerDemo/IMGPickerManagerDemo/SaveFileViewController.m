//
//  SaveFileViewController.m
//  IMGPickerManagerDemo
//
//  Created by admin on 2018/4/16.
//  Copyright © 2018年 tongfangyuan. All rights reserved.
//

#import "SaveFileViewController.h"

@interface SaveFileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation SaveFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveButtonAction:(id)sender {
    if (self.textField.text.length) {
        if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.textField.text)){
            UISaveVideoAtPathToSavedPhotosAlbum(self.textField.text,nil,nil,nil);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
