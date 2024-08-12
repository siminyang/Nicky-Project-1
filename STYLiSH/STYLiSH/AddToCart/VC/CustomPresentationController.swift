//
//  CustomPresentationController.swift
//  STYLiSH
//
//  Created by Nicky Y on 2024/7/29.
//

import UIKit

// Presenting VC methods.
class CustomPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect.zero
        }
        let containerBounds = containerView.bounds
        let height: CGFloat = 700
        let frame = CGRect(x: 0, y: containerBounds.height - height, width: containerBounds.width, height: height)
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        presentedView?.isUserInteractionEnabled = true
        containerView?.isUserInteractionEnabled = true
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentedView?.isUserInteractionEnabled = true
        containerView?.isUserInteractionEnabled = true
    }
}

