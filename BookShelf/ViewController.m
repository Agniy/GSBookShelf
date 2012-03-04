//
//  ViewController.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-22.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "ViewController.h"
#import "GSBookView.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _bookShelfView = [[GSBookShelfView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) cellHeight:120 cellMarginWidth:20 bookViewBottomOffset:110 numberOfBooksInCell:3];
    [_bookShelfView setDataSource:self];
    [_bookShelfView setShelfViewDelegate:self];
    
    [self.view addSubview:_bookShelfView];
    
    CGRect rect1 = CGRectMake(0, 0, 10, 10);
    CGRect rect2 = CGRectMake(10, 0, 10, 10);
    
    if (CGRectIntersectsRect(rect1, rect2)) {
        NSLog(@"intersect");
    }
}


#pragma mark GSBookShelfViewDataSource

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView {
    return 200;
}

- (GSBookView *)bookShelfView:(GSBookShelfView *)bookShelfView bookViewAtIndex:(NSInteger)index {
    GSBookView *bookView = [[GSBookView alloc] initWithFrame:CGRectZero];
    int imageNO = index % 9;
    [bookView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.tiff", imageNO]]];
    return bookView;
}

- (GSBookShelfCellView *)bookShelfView:(GSBookShelfView *)bookShelfView cellForRow:(NSInteger)row {
    return nil;
}

@end
