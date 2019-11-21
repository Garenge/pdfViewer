//
//  ViewController.m
//  pdfViewer
//
//  Created by LZP on 2017/6/15.
//  Copyright © 2017年 lzp. All rights reserved.
//

#import "ViewController.h"
#import "ReaderViewController.h"
#import <QuickLook/QuickLook.h>
#import "JhtDocSDK.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, ReaderViewControllerDelegate, QLPreviewControllerDataSource, UIDocumentInteractionControllerDelegate>
@property (nonatomic, retain) UIDocumentInteractionController *documentInteraction;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataMArray;

@end

@implementation ViewController

- (NSMutableArray *)dataMArray {
    if(nil == _dataMArray) {
        _dataMArray = [NSMutableArray array];
    }
    return _dataMArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 打开网络资源(就是加个下载, 然后搞个进度条, 很简单, 不写了)
    
    /** 1.  cordova-pdf-viewer-master
            delegate : ReaderViewControllerDelegate
            file : source  文件夹
            缺点无返回, 没有详细研究, 太高级
     
        2.  QLPreviewController加载pdf文档
            导入QuickLook.framework
            #import <QuickLook/QuickLook.h>
            QLPreviewControllerDataSource
            实现两个方法 : - (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
                         - (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
     
        3.  UIPageViewController
            // 这个不喜欢, 不高兴写了
     
        4.  见GTMobile
            我觉得和上面的2 很类似
     
            UIDocumentInteractionControllerDelegate
            @property (nonatomic, retain) UIDocumentInteractionController *documentInteraction;
            首先导入QuickLook.framework支持库
            
            必须实现的代理方法 预览窗口以模式窗口的形式显示
            因此需要在该方法中返回一个view controller ，作为预览窗口的父窗口。如果你不实现该方法，或者在该方法中返回 nil，或者你返回的 view controller 无法呈现模式窗口，则该预览窗口不会显示。
            - (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{      return self; }
            可选的2个代理方法 （主要是调整预览视图弹出时候的动画效果，如果不实现，视图从底部推出）
            - (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller {     return self.view; }
            - (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller {      return self.view.frame; }

     
        5.  webView
            这个不多写, 有坑, 单纯的WKWebView有一个转码的问题, 存在少数文档打不开的情况
            可以用三方, 如第6点
     
        6.  DocViewer-master // JhyDocument
            // 这个本质上是webView
            #import "JhtDocSDK.h"
     
            file :JhtDocSDK
     
     */
    [self.dataMArray addObjectsFromArray:
                            @[@"cordova-pdf-viewer-master",
                              @"QLPreviewController加载pdf文档",
                              @"UIPageViewController不写",
                              @"documentInteraction加载",
                              @"DocViewer-master加载资源"
                            ]];
    [self setUpTableView];
}

- (void)setUpTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate, dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataMArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataMArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: {
            NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
            NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
            
            NSString *filePath = [pdfs firstObject]; assert(filePath != nil); // Path to first PDF file
            ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
            
            if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
            {
                ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
                
                readerViewController.delegate = self; // Set the ReaderViewController delegate to self
                
                #if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
                
                [self.navigationController pushViewController:readerViewController animated:YES];
                
                #else // present in a modal view controller
                
                readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                
                [self presentViewController:readerViewController animated:YES completion:NULL];
                
#endif // DEMO_VIEW_CONTROLLER_PUSH
            }
            else // Log an error so that we know that something went wrong
            {
                NSLog(@"%s [ReaderDocument withDocumentFilePath:'%@' password:'%@'] failed.", __FUNCTION__, filePath, phrase);
            }
        }
            break;
        case 1: {
            QLPreviewController *QLPVC = [[QLPreviewController alloc] init];
            QLPVC.dataSource = self;
//            [self presentViewController:QLPVC animated:YES completion:nil];
            [self.navigationController pushViewController:QLPVC animated:YES];
        }
            break;
        case 2: {
            
        }
            break;
        case 3: {
            NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
            
            NSString *filePath = [pdfs firstObject]; assert(filePath != nil); // Path to first PDF file
            self.documentInteraction = [UIDocumentInteractionController
                                        interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
            self.documentInteraction.delegate = self;

            [self.documentInteraction presentPreviewAnimated:YES];
        }
            break;
        case 4: {
            NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
            
            NSString *filePath = [pdfs firstObject]; assert(filePath != nil); // Path to first PDF file
            
            JhtLoadDocViewController *load = [[JhtLoadDocViewController alloc] init];
            JhtFileModel *model = [[JhtFileModel alloc] init];
            NSString *fileName = [filePath lastPathComponent];
            model.fileName = fileName;
            model.fileAbsolutePath = filePath;

            load.titleStr = model.fileName;
            load.currentFileModel = model;

            // 提示框model相关参数
            JhtShowDumpingViewParamModel *paramModel = [[JhtShowDumpingViewParamModel alloc] init];
            paramModel.showTintColor = UIColorFromRGB(0x666666);
            paramModel.showFont = [UIFont boldSystemFontOfSize:15];
            paramModel.showBackgroundColor = [UIColor whiteColor];
            paramModel.showBackgroundImageName = @"dumpView";
            load.paramModel = paramModel;
            
            [self.navigationController pushViewController:load animated:YES];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    
    NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
    NSString *filePath = [pdfs firstObject]; assert(filePath != nil); // Path to first PDF file
    return [NSURL fileURLWithPath:filePath];
}


#pragma mark UIDocumentInteractionControllerDelegate
//必须实现的代理方法 预览窗口以模式窗口的形式显示，因此需要在该方法中返回一个view controller ，作为预览窗口的父窗口。如果你不实现该方法，或者在该方法中返回 nil，或者你返回的 view controller 无法呈现模式窗口，则该预览窗口不会显示。
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}
//可选的2个代理方法 （主要是调整预览视图弹出时候的动画效果，如果不实现，视图从底部推出）
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller {
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller {
    return self.view.frame;
}

@end
