//
//  ViewController.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-22.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "ViewController.h"

#import "MyCellView.h"
#import "MyBookView.h"
#import "MyBelowBottomView.h"

#define CELL_HEIGHT 125

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)initBooks {
    NSInteger numberOfBooks = 200;
    _bookArray = [[NSMutableArray alloc] initWithCapacity:numberOfBooks];
    _bookStatus = [[NSMutableArray alloc] initWithCapacity:numberOfBooks];
    for (int i = 0; i < numberOfBooks; i++) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [_bookArray addObject:number];
        [_bookStatus addObject:[NSNumber numberWithInt:BOOK_UNSELECTED]];
    }
    
    _booksIndexsToBeRemoved = [NSMutableIndexSet indexSet];
}

- (void)initBarButtons {
    _editBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)];
    _cancleBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancleButtonClicked:)];
    
    _trashBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashButtonClicked:)];
    _addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)];
}

- (void)switchToNormalMode {
    _editMode = NO;
    
    [self.navigationItem setLeftBarButtonItem:_editBarButton];
    [self.navigationItem setRightBarButtonItem:_addBarButton];
}

- (void)switchToEditMode {
    _editMode = YES;
    [_booksIndexsToBeRemoved removeAllIndexes];
    [self.navigationItem setLeftBarButtonItem:_cancleBarButton];
    [self.navigationItem setRightBarButtonItem:_trashBarButton];
    
    for (int i = 0; i < [_bookArray count]; i++) {
        [_bookStatus addObject:[NSNumber numberWithInt:BOOK_UNSELECTED]];
    }
    
    for (MyBookView *bookView in [_bookShelfView visibleBookViews]) {
        [bookView setSelected:NO];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarButtons];
    [self switchToNormalMode];
    
	[self initBooks];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    //AboveTopView *aboveTop = [[AboveTopView alloc] initWithFrame:CGRectMake(0, 0, 320, 164)];
    MyBelowBottomView *belowBottom = [[MyBelowBottomView alloc] initWithFrame:CGRectMake(0, 0, 320, CELL_HEIGHT * 2)];
    
    _bookShelfView = [[GSBookShelfView alloc] initWithFrame:CGRectMake(0, 0, 320, 460 - 44) cellHeight:CELL_HEIGHT cellMarginWidth:20 bookViewBottomOffset:110 shelfShadowHeight:56 numberOfBooksInCell:3 aboveTopView:nil belowBottomView:belowBottom searchBar:searchBar];
    [_bookShelfView setDataSource:self];
    //[_bookShelfView setShelfViewDelegate:self];
    
    [self.view addSubview:_bookShelfView];
    
}


#pragma mark GSBookShelfViewDataSource

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView {
    return [_bookArray count];
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView bookViewAtIndex:(NSInteger)index {
    static NSString *identifier = @"bookView";
    MyBookView *bookView = (MyBookView *)[bookShelfView dequeueReuseableBookViewWithIdentifier:identifier];
    if (bookView == nil) {
        bookView = [[MyBookView alloc] initWithFrame:CGRectZero];
        bookView.reuseIdentifier = identifier;
        [bookView addTarget:self action:@selector(bookViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [bookView setIndex:index];
    [bookView setSelected:[(NSNumber *)[_bookStatus objectAtIndex:index] intValue]];
    int imageNO = [(NSNumber *)[_bookArray objectAtIndex:index] intValue] % 4 + 1;
    [bookView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png", imageNO]] forState:UIControlStateNormal];
    return bookView;
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView cellForRow:(NSInteger)row {
    static NSString *identifier = @"cell";
    MyCellView *cellView = (MyCellView *)[bookShelfView dequeueReuseableCellViewWithIdentifier:identifier];
    if (cellView == nil) {
        cellView = [[MyCellView alloc] initWithFrame:CGRectZero];
        cellView.reuseIdentifier = identifier;
    }
    return cellView;
}

- (void)bookShelfView:(GSBookShelfView *)bookShelfView moveBookFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [_bookArray moveObjectFromIndex:fromIndex toIndex:toIndex];
}

#pragma mark - BarButtonListener 

- (void)editButtonClicked:(id)sender {
    [self switchToEditMode];
}

- (void)cancleButtonClicked:(id)sender {
    [self switchToNormalMode];
}

- (void)trashButtonClicked:(id)sender {
    [_bookArray removeObjectsAtIndexes:_booksIndexsToBeRemoved];
    [_bookStatus removeObjectsAtIndexes:_booksIndexsToBeRemoved];
    [_bookShelfView removeBookViewsAtIndexs:_booksIndexsToBeRemoved animate:YES];
    [self switchToNormalMode];
}

- (void)addButtonClicked:(id)sender {
    int a[6] = {1, 2, 5, 7, 9, 22};
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *stat = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        [indexSet addIndex:a[i]];
        [arr addObject:[NSNumber numberWithInt:1]];
        [stat addObject:[NSNumber numberWithInt:BOOK_UNSELECTED]];
    }
    [_bookArray insertObjects:arr atIndexes:indexSet];
    [_bookStatus insertObjects:stat atIndexes:indexSet];
    [_bookShelfView insertBookViewsAtIndexs:indexSet animate:YES];
}

#pragma mark - BookView Listener

- (void)bookViewClicked:(UIButton *)button {
    MyBookView *bookView = (MyBookView *)button;
    
    if (_editMode) {
        NSNumber *status = [NSNumber numberWithInt:bookView.selected];
        [_bookStatus replaceObjectAtIndex:bookView.index withObject:status];
        
        if (bookView.selected) {
            [_booksIndexsToBeRemoved addIndex:bookView.index];
        }
        else {
            [_booksIndexsToBeRemoved removeIndex:bookView.index];
        }
    }
    else {
        [bookView setSelected:NO];
    }
}

@end
