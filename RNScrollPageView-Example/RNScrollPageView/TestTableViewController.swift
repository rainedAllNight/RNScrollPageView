//
//  TestTableViewController.swift
//  RNScrollPageView
//
//  Created by 罗伟 on 2017/6/5.
//  Copyright © 2017年 罗伟. All rights reserved.
//

import UIKit

class TestTableViewController: UITableViewController {
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0...20 {
            self.images.append(UIImage(named: "\(arc4random()%20)")!)
        }
        self.tableView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HKCell", for: indexPath) as! HKCell
        cell.bgImageView.image = self.images[indexPath.row%20]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let hkCell = cell as? HKCell
        
        var rotation = CATransform3DMakeTranslation(0, 30, 20)
        rotation = CATransform3DScale(rotation, 0.90, 0.90, 1)
        rotation.m34 = 1.0 / -600
        cell.layer.transform = rotation
        
        UIView.animate(withDuration: 0.6) {
            cell.layer.transform = CATransform3DIdentity
        }
        
        hkCell?.updateBgImageViewFrame()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.image = self.images[indexPath.row%20]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells = self.tableView.visibleCells
        for cell in visibleCells {
            let hkCell = cell as? HKCell
            hkCell?.updateBgImageViewFrame()
        }
    }

}
