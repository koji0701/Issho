//
//  CustomTabBar.swift
//  Issho-New
//
//  Created by Koji Wong on 2/28/23.
//

import Foundation
import UIKit

class CustomTabBarController: UITabBarController {

    let floatingTabbarView = FloatingBarView([
        [UIImage(systemName: "house")!, UIImage(systemName: "house.fill")!],
        [UIImage(systemName: "person.3")!, UIImage(systemName: "person.3.fill")!],
        [UIImage(named: "addFriends")!.withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .stretch), UIImage(named: "addFriends.fill")!.withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .stretch)]
        
    ])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isHidden = true

        setupFloatingTabBar()
    }

    

    func setupFloatingTabBar() {
        floatingTabbarView.delegate = self
        view.addSubview(floatingTabbarView)
        floatingTabbarView.centerXInSuperview()
        
        floatingTabbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true

        
        //floatingTabbarView.anchor(top: nil, leading: view.leadingAnchor + 30, bottom: view.safeAreaLayoutGuide.bottomAnchor,  trailing: view.trailingAnchor - 30, size: CGSize(width: 0, height: 70))

    }
    
    func toggle(hide: Bool) {
        floatingTabbarView.toggle(hide: hide)
    }
}

extension CustomTabBarController: FloatingBarViewDelegate {
    func did(selectindex: Int) {
        selectedIndex = selectindex
    }
}


