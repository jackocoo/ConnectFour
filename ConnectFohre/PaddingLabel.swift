//
//  PaddingLabel.swift
//  ConnectFohre
//
//  Created by joconnor on 6/17/19.
//  Copyright © 2019 joconnor. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {
        
        var topInset: CGFloat = 5.0
        var bottomInset: CGFloat = 5.0
        var leftInset: CGFloat = 7.0
        var rightInset: CGFloat = 7.0
        
        override func drawText(in rect: CGRect) {
            let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
            super.drawText(in: rect.inset(by: insets))
        }
        
        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + leftInset + rightInset,
                          height: size.height + topInset + bottomInset)
        }
    }



