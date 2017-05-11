//
//  ViewController.swift
//  hangge_1513
//
//  Created by hangge on 2017/1/11.
//  Copyright © 2017年 hangge.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let images = ["image1.jpg","image2.jpg","image3.jpg"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //修改导航栏返回按钮文字
//        let item = UIBarButtonItem(title: "返回", style: .plain, target: self, action: nil)
//        self.navigationItem.backBarButtonItem = item;
        
        
        //生成缩略图
        for i in 0..<images.count{
            //创建ImageView
            let imageView = UIImageView()
            imageView.frame = CGRect(x:20+i*70, y:80, width:60, height:60)
            imageView.tag = i
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = UIImage(named: images[i])
            //设置允许交互（后面要添加点击）
            imageView.isUserInteractionEnabled = true
            self.view.addSubview(imageView)
            //添加单击监听
            let tapSingle=UITapGestureRecognizer(target:self,
                                                 action:#selector(imageViewTap(_:)))
            tapSingle.numberOfTapsRequired = 1
            tapSingle.numberOfTouchesRequired = 1
            imageView.addGestureRecognizer(tapSingle)
        }
    }
    
    
    //缩略图imageView点击
    func imageViewTap(_ recognizer:UITapGestureRecognizer){
        //图片索引
        let index = recognizer.view!.tag
        //进入图片全屏展示
        let previewVC = ImagePreviewVC(images: images, index: index)
        
        self.present(previewVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

