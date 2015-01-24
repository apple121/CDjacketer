//
//  ViewController.m
//  Camera
//
//  Created by g-2016 on 2014/08/13.
//  Copyright (c) 2014年 aki120121. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *artist;
@property (weak, nonatomic) IBOutlet UILabel *antitle;


//一つ目
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)artiistText:(UITextField *)sender {
    self.artist.text = sender.text;
}

- (IBAction)titleText:(UITextField *)sender {
    self.antitle.text = sender.text;
}


- (IBAction)showImagePicker:(id)sender {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if([UIImagePickerController isSourceTypeAvailable:sourceType]){
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = sourceType;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
}


//アラートの表示
- (void)showAlert:(NSString *)title text:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
    self.imageView.image = image;
  //
    }];

}


- (IBAction)saveImage:(id)sender {
    
    CGRect screenRect = CGRectMake(0,0,320,325);
    UIGraphicsBeginImageContextWithOptions(screenRect.size,NO,0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    [self.view.layer renderInContext:ctx];
    
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    //フォトアルバムへの書き込み
    UIImageWriteToSavedPhotosAlbum(screenImage,
                                   self,
                                   @selector(finishExport:didFinishSavingWithError:contextInfo:),
                                   nil);
    UIGraphicsEndImageContext();
    
    //シャッター音設定
    SystemSoundID sound_1;
    NSURL* soundURL = [[NSBundle mainBundle]URLForResource:@"camera1"
                                             withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound_1);
    AudioServicesPlayAlertSound(sound_1);
}

//フォト書き込み完了
- (void)finishExport:(UIImage *)image didFinishSavingWithError:(NSError *)error
         contextInfo:(void *)contextInfo {
    if (error == nil) {
        [self showAlert:@"" text:@"保存しました"];
    } else {
        [self showAlert:@"" text:@"保存に失敗しました"];
    }
}


@end

