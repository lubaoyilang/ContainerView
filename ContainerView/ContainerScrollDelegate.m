
//  Created by Rustam Motygullin on 11.07.2018.
//  Copyright © 2018 mrusta. All rights reserved.

#import "ContainerScrollDelegate.h"

@implementation ContainerScrollDelegate {
    BOOL bordersRunContainer;                   
    
    BOOL onceEnded;
    BOOL bottomDeceleratingDisable;
    
    BOOL onceScrollingBeginDragging;
    
    BOOL scrollBegin;
    CGFloat startScrollPosition;
    CGFloat _containerTop;
    CGAffineTransform selfTransform;
}



#pragma mark - Scroll Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat velocityInViewY    = [scrollView.panGestureRecognizer velocityInView:   WINDOW].y;
    CGFloat translationInViewY = [scrollView.panGestureRecognizer translationInView:WINDOW].y;
    
    if((scrollView.panGestureRecognizer.state) && (scrollView.contentOffset.y <= 0)) {
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.contentOffset = CGPointMake( scrollView.contentOffset.x, 0 );
    } else {
        scrollView.showsVerticalScrollIndicator = YES;
    }
    
    bordersRunContainer = ( (scrollView.contentOffset.y == 0) && (0 < velocityInViewY));

    selfTransform = self.containerView.transform;
    
    
//    if(NAV_ADDED) {
//        UINavigationController *nvc = (UINavigationController *)ROOT_VC;
//        if(!nvc.navigationBarHidden) {
//            top = (top + nvc.navigationBar.height);
//        }
//    }
    

    CGFloat top     = self.containerView.containerTop;
    
    if(scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded)
        onceScrollingBeginDragging = NO;
    
    if(bordersRunContainer) {
        
        onceEnded = NO;
        onceScrollingBeginDragging = NO;
        
        selfTransform.ty = ((top -startScrollPosition) +translationInViewY );
        if(selfTransform.ty < top) selfTransform.ty = top;
        
        if(scrollBegin)
        {
            ANIMATION_SPRING(.325, ^(void) {
                self.containerView.transform = self->selfTransform;
            });
            
            scrollBegin = NO;
            
        } else {
            self.containerView.transform = selfTransform;
        }
    }
    else
    {
        if((top == selfTransform.ty) && !onceScrollingBeginDragging) {
            onceScrollingBeginDragging = YES;
            
            CGFloat headerHeight = (self.containerView.headerView) ?self.containerView.headerView.height :0;
            CGFloat top = (self.containerView.containerTop == 0) ? CUSTOM_TOP : self.containerView.containerTop;
            CGFloat iphnX = (IS_IPHONE_X ? 24 :0);
            
            CGFloat height = (SCREEN_HEIGHT -(top +headerHeight +iphnX ));
            
            if(scrollView.height != height) {
                
                ANIMATION_SPRING( .45, ^(void) {
                    scrollView.y = headerHeight;
                    scrollView.height = height;
                });
            }
        }
        

        if(top < selfTransform.ty)
        {
            if (velocityInViewY < 0. )
            {
                if(self.containerView.containerPosition == ContainerMoveTypeTop) {
                    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0 );
                }
                
                selfTransform = self.containerView.transform;
                selfTransform.ty = ((top -startScrollPosition) +translationInViewY );
                
                if(selfTransform.ty < top) selfTransform.ty = top;
                
                self.containerView.transform = selfTransform;
            }
        }
    }
    
    if(self.blockTransform) self.blockTransform(selfTransform.ty);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    startScrollPosition = scrollView.contentOffset.y;
    
    if(bottomDeceleratingDisable) return;
    
    scrollBegin = YES;
    if(startScrollPosition < 0) startScrollPosition = 0;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(bottomDeceleratingDisable) return;
    CGFloat velocityInViewY = [scrollView.panGestureRecognizer velocityInView:WINDOW].y;
    
    if(!self.containerView) return;
    
    if(!onceEnded)
    {
        onceEnded = YES;
        [self.containerView containerMoveForVelocityInView:velocityInViewY];
    }
}

@end
