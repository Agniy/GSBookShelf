//
//  CellContainerView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-24.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "GSCellContainerView.h"
#import "GSBookShelfView.h"
#import "GSBookShelfCell.h"

typedef enum {
    ADD_TYPE_HEAD,
    ADD_TYPE_TAIL
}AddType;

typedef enum {
    RM_TYPE_HEAD,
    RM_TYPE_TAIL
}RemoveType;

@implementation GSCellContainerView

@synthesize parentBookShelfView = _parentBookShelfView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _firstVisibleRow = -1;
        _lastVisibleRow = -1;
        
        _reuseableCells = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        _visibleCells = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)reloadData {
    _firstVisibleRow = -1;
    _lastVisibleRow = -1;
    
    for (UIView *view in _visibleCells) {
        [view removeFromSuperview];
    }
    [_visibleCells removeAllObjects];
    
    [_reuseableCells removeAllObjects];
}

#pragma mark - Reuse

- (void)addReuseableCell:(UIView *)cell {
    NSString *reuseIdentifier = nil;
    if ([cell respondsToSelector:@selector(reuseIdentifier)]) {
        reuseIdentifier = [(id<GSBookShelfCell>)cell reuseIdentifier];
    }
    
    if (reuseIdentifier == nil) {
        return;
    }
    
    NSMutableSet *cellSet = [_reuseableCells objectForKey:reuseIdentifier];
    if (!cellSet) {
        cellSet = [[NSMutableSet alloc] initWithCapacity:0];
        [_reuseableCells setObject:cellSet forKey:reuseIdentifier];
    }
    //NSLog(@"cellset count: %d", [cellSet count]);
    [cellSet addObject:cell];
}

- (UIView *)dequeueReuseableCellWithIdentifier:(NSString *)identifier {
    NSMutableSet *cellSet = (NSMutableSet *)[_reuseableCells objectForKey:identifier];
    UIView *cell = [cellSet anyObject];
    if (cell) {
        [cellSet removeObject:cell];
    }
    return cell;
}

#pragma mark - layout

- (CGRect)cellRectAtRow:(NSInteger)row {
    CGFloat cellHeight = _parentBookShelfView.cellHeight;
    return CGRectMake(0, cellHeight * row, self.frame.size.width, cellHeight);
}

- (void)removeCellWithType:(RemoveType)type {
    NSUInteger rmIndex;
    switch (type) {
        case RM_TYPE_HEAD:
            rmIndex = 0;
            break;
        case RM_TYPE_TAIL:
            rmIndex = [_visibleCells count] - 1;
    }
    UIView *cell = [_visibleCells objectAtIndex:rmIndex];
    [self addReuseableCell:cell];
    [cell removeFromSuperview];
    
    [_visibleCells removeObjectAtIndex:rmIndex];
}

- (void)addCellAtRow:(NSInteger)row addType:(AddType)type{
    UIView *cell = [_parentBookShelfView.dataSource bookShelfView:_parentBookShelfView cellForRow:row];
    [cell setFrame:[self cellRectAtRow:row]];
    
    switch (type) {
        case ADD_TYPE_TAIL:
            [_visibleCells addObject:cell];
            [self insertSubview:cell atIndex:0];
            break;
        case ADD_TYPE_HEAD:
            [_visibleCells insertObject:cell atIndex:0];
            [self addSubview:cell];
            break;

    }
}

- (void)layoutSubviewsWithVisibleRect:(CGRect)visibleRect {
    
    CGFloat shelfShadowHeight = _parentBookShelfView.shelfShadowHeight;
    CGFloat newOriginY = fmaxf(visibleRect.origin.y - shelfShadowHeight, 0);
    CGFloat addHeight = visibleRect.origin.y - newOriginY;
    visibleRect.origin.y = newOriginY;
    visibleRect.size.height += addHeight;
    
    NSInteger numberOfBooksInCell = _parentBookShelfView.numberOfBooksInCell;
    
    NSInteger numberOfBooks = [_parentBookShelfView.dataSource numberOfBooksInBookShelfView:_parentBookShelfView];
    
    NSInteger numberOfCells = ceilf((float)numberOfBooks / (float)numberOfBooksInCell);
    
    
    NSInteger firstNeededRow = MAX(0, floorf(CGRectGetMinY(visibleRect) / _parentBookShelfView.cellHeight));
    NSInteger lastNeededRow = MIN(numberOfCells - 1, floorf(CGRectGetMaxY(visibleRect) / _parentBookShelfView.cellHeight));
    
    if (_firstVisibleRow == -1) {
        // First time 
        for (NSInteger row = firstNeededRow; row <= lastNeededRow; row++) {
            // add firstTime
            [self addCellAtRow:row addType:ADD_TYPE_TAIL];
        }
    }
    else {
        // Not first time
        
        if (lastNeededRow < _lastVisibleRow) {
            NSInteger rmFromRow = (_firstVisibleRow > lastNeededRow + 1) ? _firstVisibleRow : lastNeededRow + 1;
            for (NSInteger row = _lastVisibleRow; row >= rmFromRow; row--) {
                // rm from tail of the _visibleBookView
                // use reversed row to always remove at tile
                [self removeCellWithType:RM_TYPE_TAIL];
            }
        }
        
        if (firstNeededRow < _firstVisibleRow) {
            NSInteger addToRow = (_firstVisibleRow - 1 < lastNeededRow) ? _firstVisibleRow - 1 : lastNeededRow; 
            for (NSInteger row = addToRow; row >= firstNeededRow; row--) {
                // add to head of the _visibileBookView
                // use reversed row to always add to index 0
                [self addCellAtRow:row addType:ADD_TYPE_HEAD];
            }
        }
        
        if (firstNeededRow > _firstVisibleRow) {
            NSInteger rmToRow = (_lastVisibleRow  <= firstNeededRow - 1) ? _lastVisibleRow : firstNeededRow - 1;
            for (NSInteger row = _firstVisibleRow; row <= rmToRow; row++) {
                // rm from head
                [self removeCellWithType:RM_TYPE_HEAD];
            }
        }
        
        
        if (lastNeededRow > _lastVisibleRow) {
            NSInteger addFromRow = (_lastVisibleRow + 1 > firstNeededRow) ? _lastVisibleRow + 1 : firstNeededRow;
            for (NSInteger row = addFromRow; row <= lastNeededRow; row++) {
                // add to tail
                [self addCellAtRow:row addType:ADD_TYPE_TAIL];
            }
        }
    }
    
    //NSLog(@"visible count:%d", [_visibleCells count]);
    _firstVisibleRow = firstNeededRow;
    _lastVisibleRow = lastNeededRow;
    
}

#pragma mark - visible

- (NSArray *)visibleCells {
    return _visibleCells;
}

@end
