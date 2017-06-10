//
//  ViewController.swift
//  RNScrollPageView
//
//  Created by 罗伟 on 2017/5/31.
//  Copyright © 2017年 罗伟. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var pageView: RNScrollPageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titles = ["关注", "热门", "科技", "游戏", "时事新闻", "这是一个长标题", "美女", "体育", "娱乐", "社会"]
        
        let viewControllers = titles.map { (title) -> UIViewController in
            let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestTableViewController") as! TestTableViewController
            viewController.title = title
            return viewController
        }
        
        self.pageView.viewControllers = viewControllers
        self.pageView.titles = titles
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

