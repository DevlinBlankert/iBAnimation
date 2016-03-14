//
// Created by Jake Lin on 2/24/16.
// Copyright (c) 2016 Jake Lin. All rights reserved.
//

import UIKit

/**
 Navigator for `UINavigationController` to support custom transition animation for Push and Pop
 */
public class Navigator: NSObject {
  var transitionAnimationType: TransitionAnimationType
  var transitionDuration: Duration = defaultTransitionDuration
  
  private var animator: AnimatedTransitioning?
  // Used for interactionController
  private var interactiveAnimator: PanInteractiveAnimator?
  
  
  public init(transitionAnimationType: TransitionAnimationType, transitionDuration: Duration = defaultTransitionDuration, interactiveGestureType: InteractiveGestureType? = nil) {
    self.transitionAnimationType = transitionAnimationType
    self.transitionDuration = transitionDuration
    
    super.init()
    
    animator = AnimatorFactory.generateAnimator(transitionAnimationType, transitionDuration: transitionDuration)
    
    // If interactiveGestureType has been set
    if let interactiveGestureType = interactiveGestureType {
      // If configured as `.Default` then use the default interactive gesture type from the Animator
      if interactiveGestureType == .Default {
        if let interactiveGestureType = animator?.interactiveGestureType {
          interactiveAnimator = PanInteractiveAnimator(interactiveGestureType: interactiveGestureType)
        }
      } else {
        interactiveAnimator = PanInteractiveAnimator(interactiveGestureType: interactiveGestureType)
      }
    }
  }
}

extension Navigator: UINavigationControllerDelegate {
  public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    interactiveAnimator?.connectGestureRecognizer(toVC)
    
    if operation == .Push {
      animator?.transitionDuration = transitionDuration
      return animator
    } else if operation == .Pop {
      // Use the reverse animation
      if let reverseTransitionAnimationType = animator?.reverseAnimationType {
        return AnimatorFactory.generateAnimator(reverseTransitionAnimationType, transitionDuration: transitionDuration)
      }
    }
    return nil
  }
  
  public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let interactiveAnimator = interactiveAnimator where interactiveAnimator.interacting {
      return interactiveAnimator
    } else {
      return nil
    }
  }
}
