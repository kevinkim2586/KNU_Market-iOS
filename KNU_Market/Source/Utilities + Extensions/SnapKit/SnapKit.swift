//
//  SnapKit.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/03.
//

import UIKit

import SnapKit

extension ConstraintMakerRelatable {
    @discardableResult
    public func equalToSafeArea(_ rootView: UIView, _ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        return self.equalTo(rootView.safeAreaLayoutGuide, file, line)
    }
}
