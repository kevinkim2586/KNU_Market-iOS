//
//  DetailMessageViewController.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/21.
//

import UIKit

import ReactorKit

final class DetailMessageViewController: BaseViewController, View {
    
    typealias Reactor = DetailMessageViewReactor
    
    // MARK: - Constants
    fileprivate struct Metric {
        
    }
    
    fileprivate struct Font {
        
    }
    
    fileprivate struct Style {
        
    }
    
    // MARK: - Properties
    
    // MARK: - UI
    
    // MARK: - Inintializing
    init(reactor: Reactor) {
        super.init()
        defer {
            self.reactor = reactor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
    }
    
    override func setupStyle() {
        super.setupStyle()
        
    }
    
    // MARK: - Configuring
    func bind(reactor: Reactor) {
        
    }
}

