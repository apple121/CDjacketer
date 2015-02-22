//
//  ViewController.m
//  Camera
//
//  Created by g-2016 on 2014/08/13.
//  Copyright (c) 2014年 aki120121. All rights reserved.
//

#import "ViewController.h"
#import <iAd/iAd.h>

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,ADBannerViewDelegate>
{
    BOOL observing_;
    UITextField *activeField; //選択されたテキストフィールドを入れる
}

@property (weak, nonatomic) IBOutlet UILabel *artist;
@property (weak, nonatomic) IBOutlet UILabel *antitle;

@property (weak, nonatomic) IBOutlet UILabel *trimPosition;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldArtist;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (nonatomic) bool flag;

@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;

-(IBAction)bkgTapped:(id)sender;

//一つ目
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // 全テキストフィールドのdelegateにselfを代入
    for (id v in _scrollView.subviews){
        if([NSStringFromClass([v class])isEqualToString:@"UITextField"]){
            ((UITextField*)v).delegate = self;

            
        }
        NSLog(@"%@",NSStringFromClass([v class]));
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)artistText:(UITextField *)sender {
    self.artist.text = sender.text;
}

- (IBAction)titleText:(UITextField *)sender {
    self.antitle.text = sender.text;
}

- (IBAction)switch:(UISwitch *)sender {
    
    if(sender.on){
        self.flag = true;
        [self showAlert:@"注意" text:@"画像の下部をトリミングします"];
        self.trimPosition.text = @"画像取り込み位置 : 下部";
        
        
    } else {
        self.flag = false;
        [self showAlert:@"注意" text:@"画像の上部をトリミングします"];
            self.trimPosition.text = @"画像取り込み位置 : 上部";

    }
}

- (IBAction)showImagePicker:(id)sender {
    
    
    
    
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //画像の取得先をカメラロールに
    
    if([UIImagePickerController isSourceTypeAvailable:sourceType]){
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = sourceType;
        picker.delegate = self;
        picker.allowsEditing = YES;
//        [self.navigationController pushViewController:picker animated:YES];
        
        [self presentViewController:picker animated:YES completion:NULL]; //カメラロール出現に関係
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // super
    [super viewWillAppear:animated]; // 画面が表示されるたびに実行される
    
    //Start observing
    if(!observing_){
        NSNotificationCenter *center;
        center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(keyboardWillShow:)
                       name:UIKeyboardWillShowNotification
                     object:nil];
        
        [center addObserver:self
                   selector:@selector(keyboardWillHide:)
                       name:UIKeyboardWillHideNotification
                     object:nil];                          // UIKeyboardWill~メソッドを呼び出す通知登録
        
        observing_ = YES;
    }
}

#pragma mark my method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    // メンバ変数activeFieldに選択されたテキストフィールドを代入
    activeField = textField;
    return YES;
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    // Get userInfo
    NSDictionary *userInfo;
    userInfo = [notification userInfo];
    
    // キーボードの表示完了時の場所と大きさを取得
    CGRect keyboardFrameEnd = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGRect screenBounds = [[UIScreen mainScreen]bounds];
    float screenHeight = screenBounds.size.height;
    if((activeField.frame.origin.y + activeField.frame.size.height)>(screenHeight - keyboardFrameEnd.size.height - 20)){
        // テキストフィールドがキーボードで隠れるようなら
        // 選択中のテキストフィールドの直ぐ下にキーボードの上端がつくように、スクロールビューの位置を上げる
        [UIView animateWithDuration:0.3
                         animations:^{
                             _scrollView.frame = CGRectMake(0, screenHeight - activeField.frame.origin.y - activeField.frame.size.height - keyboardFrameEnd.size.height - 20, _scrollView.frame.size.width, _scrollView.frame.size.height);
                         }];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    // viewのy座標を元に戻してキーボードをしまう
    [UIView animateWithDuration:0.2
                     animations:^{_scrollView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
                     }];
    activeField = nil;
    return;
}

// リターンキーでキーボードを閉じる。 delegate必須
- (BOOL)textFieldShouldReturn:(UITextField *)targetTextField{
    // viewのy座標をもとに戻してキーボードをしまう
    [UIView animateWithDuration:0.2
                     animations:^{_scrollView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
                     }];
    [targetTextField resignFirstResponder];
    return YES;
}

- (IBAction)bkgTapped:(id)sender{
    //keyboard hide
    [self.view endEditing:YES];
}

// アラートの表示
- (void)showAlert:(NSString *)title text:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage]; //トリミングした画像をimageに入れている
    float imageW = image.size.width; //縦横サイズが 640.000である
    float trimH = imageW / 307 * 241;
    NSLog(@"%f,%f,%d",imageW,trimH,self.flag);
    CGRect rect;
    UIImage *reRectImage;
    
    if (self.flag == true) {                        //スイッチオンで下をオフで上をトリミング
        rect = CGRectMake(0, -140, imageW, trimH);
    } else {
        rect = CGRectMake(0, 0, imageW, trimH);
    }
    
    UIGraphicsBeginImageContext(rect.size);
    [image drawAtPoint:rect.origin];
    reRectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    CGImageRef srcImageRef = [image CGImage];
//    CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
//    UIImage *trimmedImage = [UIImage imageWithCGImage:trimmedImageRef];
    
    
    [self dismissViewControllerAnimated:YES completion:^{   //ピッカーを閉じる
        self.imageView.image = reRectImage;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect bannerFrame = self.bannerView.frame;
    bannerFrame.origin.y = self.scrollView.frame.size.height;
    self.bannerView.frame = bannerFrame;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    CGRect bannerFrame = banner.frame;
    bannerFrame.origin.y = self.scrollView.frame.size.height - banner.frame.size.height;
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         banner.frame = bannerFrame;
                     }];
    NSLog(@"広告在庫あり");
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    CGRect bannerFrame = banner.frame;
    bannerFrame.origin.y = self.scrollView.frame.size.height;
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         banner.frame = bannerFrame;
                     }];
    NSLog(@"広告在庫なし");
}

@end

