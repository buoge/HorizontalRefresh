//
//  ImagePreviewVC.swift
//  hangge_1513
//
//  Created by hangge on 2017/1/11.
//  Copyright © 2017年 hangge.com. All rights reserved.
//

import UIKit

//图片浏览控制器
class ImagePreviewVC: UIViewController {
    
    //存储图片数组
    var images:[String]
    
    //默认显示的图片索引
    var index:Int
    
    //用来放置各个图片单元
    var collectionView:UICollectionView!
    
    //页控制器（小圆点）
    var pageControl : UIPageControl!
    
    
    // 小于0时是左侧刷新，大于0为右侧刷新
    var mUserReleaseOffsetX: CGFloat = 0
    var isLoading = false
    
    var loadingViewFooter: UIActivityIndicatorView?
    
    let appHeight = UIScreen.main.bounds.height
    let appWidth = UIScreen.main.bounds.width
    
    //初始化
    init(images:[String], index:Int = 0){
        self.images = images
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        //背景设为黑色
        self.view.backgroundColor = UIColor.black
        
        //collectionView尺寸样式设置
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = self.view.bounds.size
        //横向滚动
        layout.scrollDirection = .horizontal
       
        //不自动调整内边距，确保全屏
        self.automaticallyAdjustsScrollViewInsets = true
        
        //collectionView初始化
        collectionView = UICollectionView(frame: self.view.bounds,
                                          collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.black
        collectionView.register(ImagePreviewCell.self, forCellWithReuseIdentifier:ImagePreviewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        self.view.addSubview(collectionView)
        
        addPageControl()
        upatePageControl(currentPage:0)
        
        addLoadingView(collectionView: collectionView)
        
        //将视图滚动到默认图片上
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        
    }
    
    func addLoadingView(collectionView: UICollectionView){
        // 头部的header
        let loadingView = UIActivityIndicatorView(frame: CGRect(x: -60, y: 0, width: 60, height:appHeight))
        loadingView.startAnimating()
        loadingView.backgroundColor = UIColor.clear
        collectionView.addSubview(loadingView)
        
        // 添加尾部
        addFooterLoadMore()
    }
    
    func upatePageControl(currentPage: Int){
        pageControl.numberOfPages = images.count
        pageControl.currentPage = currentPage
    }
    
    func addPageControl(){
        pageControl = UIPageControl()
        pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                     y: UIScreen.main.bounds.height - 20)
        pageControl.isUserInteractionEnabled = false
        view.addSubview(self.pageControl)
    }
    
    func addFooterLoadMore(){
        let pageCount = images.count
        
        // 尾部位置，每次加载完成后需要重新计算
        // 再次加载数据，是改变frame? 还是删除了再次添加？
        let appWidth = UIScreen.main.bounds.width
        let lastPositionX = appWidth * CGFloat(pageCount)
        loadingViewFooter = UIActivityIndicatorView(frame: CGRect(x: lastPositionX, y: 0, width: 60, height:appHeight))
        loadingViewFooter?.startAnimating()
        loadingViewFooter?.backgroundColor = UIColor.clear
        if let _loadingViewFooter = loadingViewFooter {
            collectionView.addSubview(_loadingViewFooter)
        }
    }
    
    //视图显示时
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
 
    //视图消失时
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //显示导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadingMoreData(){
        let pageCountBeforeReload = images.count
        if (pageCountBeforeReload == 3) {
            images.append("m1.jpg")
            images.append("m2.jpg")
            images.append("m3.jpg")
        }
        else if (images.count == 6) {
            images.append("m4.jpg")
            images.append("m5.jpg")
            images.append("m6.jpg")
        }
        else if (images.count == 9) {
            print(":::::::::::没有更多数据........")
            return
        }
        collectionView.reloadData()
        
        // 去除loadingview? 还是改变loadingview 的frame
        addFooterLoadMore()
        
        upatePageControl(currentPage: pageCountBeforeReload)
        
        let delaySecon = DispatchTime.now() + .milliseconds(0)
        DispatchQueue.main.asyncAfter(deadline: delaySecon) { [weak self] in
            let nextPath = IndexPath(item: pageCountBeforeReload, section: 0)
            self?.collectionView.scrollToItem(at: nextPath, at: UICollectionViewScrollPosition.left, animated: true)
        }
        
    }
}

//ImagePreviewVC的CollectionView相关协议方法实现
extension ImagePreviewVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    //collectionView单元格创建
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePreviewCell.reuseIdentifier,
                                            for: indexPath) as! ImagePreviewCell
        let image = UIImage(named: self.images[indexPath.row])
        cell.imageView.image = image
        return cell
    }
    
    //collectionView单元格数量
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    //collectionView将要显示
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImagePreviewCell{
            //由于单元格是复用的，所以要重置内部元素尺寸
            cell.resetSize()
            //设置页控制器当前页
            self.pageControl.currentPage = indexPath.item
        }
    }
}

extension ImagePreviewVC: UIScrollViewDelegate {
    
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
         print("========滑动结束 contentOffset is \(scrollView.contentOffset)")
        
        if (isLoading) {
            print(":::::::::::恢复位置取消loading::::::::::::")
            isLoading = false
            if (mUserReleaseOffsetX < 0) {
                resetLeftLoading(scrollView)
            } else {
                resetRightLoading(scrollView)
            }
            mUserReleaseOffsetX = 0
            return
        } else {
            mUserReleaseOffsetX = scrollView.contentOffset.x
        }
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        
        // 获取屏幕中间cell的indexPath
        let pInView = self.view.convert(collectionView.center, to: collectionView)
        
        // 获取这一点的indexPath
        let indexPathNow = collectionView.indexPathForItem(at: pInView)
        
        
        
        if (mUserReleaseOffsetX < 0 && abs(mUserReleaseOffsetX) > 40) {
            print(":::::::::::展示loading header::::::::::::")
            scrollView.setContentOffset(CGPoint(x:-60,y:0), animated: true)
            isLoading = true
        }
        else if (mUserReleaseOffsetX > 0) {
            
            // 赋值给记录当前坐标的变量
            let indexNow = indexPathNow?.item ?? 0
            let maxIndexNow = images.count - 1
            if (indexNow < maxIndexNow ){
                print("========没到最后一页返回不处理=========")
                return
            }
            
            if (mUserReleaseOffsetX > (appWidth * CGFloat(maxIndexNow) + 40)) {
                print(":::::::::::展示loading footer::::::::::::")
                let finalPosition = appWidth * CGFloat(maxIndexNow) + 60
                scrollView.setContentOffset(CGPoint(x:finalPosition,y:0), animated: true)
                isLoading = true
                
                //获取Global Dispatch Queue
                let deadline = DispatchTime.now() + .seconds(3)
                DispatchQueue.main.asyncAfter(deadline: deadline, execute: { [weak self,weak scrollView] in
                    print(":::::::::::3s 过后加载数据::::::::::::")
                    if let _scrollView = scrollView {
                        // 取消动画
                        self?.resetRightLoading(_scrollView)
                        self?.loadingViewFooter?.removeFromSuperview()
                        self?.loadingViewFooter = nil
                        // 加载更多数据
                        self?.loadingMoreData()
                    }
                })
            }
        }
    }
    
    func resetLeftLoading(_ scrollView: UIScrollView){
        scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    func resetRightLoading(_ scrollView: UIScrollView){
        isLoading = false
        let pageCount = images.count
        let appWidth = UIScreen.main.bounds.width
        let positionReset = appWidth * CGFloat(pageCount - 1)
        scrollView.setContentOffset(CGPoint(x:positionReset,y:0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         print("========减速完成")
        
    }
    
}





















