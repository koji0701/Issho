//
//  Photo Selector Controller.swift
//  Issho-New
//
//  Created by Koji Wong on 2/28/23.
//

import Foundation

import UIKit
import Photos

class PhotoSelectorController: UICollectionViewController {

    let cellId = "cellId"
    let headerId = "headerId"
    var header: PhotoSelectorHeader?
    
    var mosiacLayout: MosiacLayout?
    
    func setMosiacLayout() {
        mosiacLayout = MosiacLayout()
        mosiacLayout?.delegate = self
        collectionView?.collectionViewLayout = mosiacLayout!
    }
    
    
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
    }
    /*
    override func loadView() {
        collectionView?.collectionViewLayout = MosiacLayout()
        collectionView?.collectionViewLayout.delegate = self
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let tabBar = tabBarController as? CustomTabBarController else { return }
        tabBar.toggle(hide: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let tabBar = tabBarController as? CustomTabBarController else { return }
        tabBar.toggle(hide: false)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("photo selector controller view did load collectionView: ", collectionView)
        collectionView?.backgroundColor = .black
        
        
        setupNavigationButtons()
        
        mosiacLayout?.delegate = self
        print("photo selector controller view did load mosiacLayout: ", mosiacLayout)
        
        collectionView.frame.origin.y += topbarHeight + 40
        //navigationController?.navigationBar.isHidden = true
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        navigationController?.navigationBar.shadowImage = UIImage()
        collectionView.contentInsetAdjustmentBehavior = .never
        //collectionView.backgroundColor = .black
        
        collectionView?.register(PhotoSelectorCell.self,
                                 forCellWithReuseIdentifier: cellId)
        
        collectionView?.register(PhotoSelectorHeader.self,
                                 forSupplementaryViewOfKind: Element.header.kind,
                                 withReuseIdentifier: headerId)
        
        //authentication
        let photosAuth = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if (photosAuth == .authorized || photosAuth == .limited) {
            fetchPhotos()
        }
        else {
            requestPhotosAuth()
        }
        
    }
    
    var selectedImage : UIImage?
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    private func assetFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    func fetchPhotos() {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetFetchOptions())
        
        DispatchQueue.global().async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset,
                                          targetSize: targetSize,
                                          contentMode: .aspectFit,
                                          options: options,
                                          resultHandler:
                    { (image, info) in
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                    
                })
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.backgroundColor = .clear
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(handleNext))
    }
    
    /*@objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }*/
    
    /*
    private func cropImage() -> UIImage {
        guard let headerView = headerView else {return UIImage(systemName: "person.circle")!}
        
        let contextImage = UIImage(cgImage: selectedImage!.cgImage!)
        let diameter = headerView.photoImageView.frame.height
        let radius = diameter / 2
        let centerX = headerView.photoImageView.center.x
        let centerY = headerView.photoImageView.center.y
        
        let x = centerX - radius
        let y = centerY - radius
        
        let rect = CGRect(x: x, y: y, width: diameter, height: diameter)
        guard let imageRef = contextImage.cgImage?.cropping(to: rect) else {
            return UIImage(systemName: "person.circle")!
        }
        
        let croppedImage = UIImage(cgImage: imageRef, scale: selectedImage!.scale, orientation: selectedImage!.imageOrientation)
        return croppedImage
    }*/
    private func cropImage() -> UIImage {
        
        
        
        let contextImage = UIImage(cgImage: selectedImage!.cgImage!)
        let contextSize: CGSize = contextImage.size
        /*
        let cropDiameter = headerView.photoImageView.frame.height
        let cropRect = CGRect(x: (selectedImage!.size.width - cropDiameter) / 2,
                              y: (selectedImage!.size.height - cropDiameter) / 2,
                              width: cropDiameter,
                              height: cropDiameter)
        print("cropRect", cropRect)*/
        
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = 0.0
        var cgheight: CGFloat = 0.0
        
        if contextSize.width > contextSize.height {
                    posX = ((contextSize.width - contextSize.height) / 2)
                    posY = 0
                    cgwidth = contextSize.height
                    cgheight = contextSize.height
                } else {
                    posX = 0
                    posY = ((contextSize.height - contextSize.width) / 2)
                    cgwidth = contextSize.width
                    cgheight = contextSize.width
                }
        
        let rect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        print("rect", rect)
        guard let imageRef = contextImage.cgImage?.cropping(to: rect) else {
            return UIImage(systemName: "person.circle")!
        }
        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: selectedImage!.scale, orientation: selectedImage!.imageOrientation)

        return croppedImage
    }

    
    @objc
    private func handleNext() {
        selectedImage = cropImage()
        
        print("GOT TO HANDLE NEXT")
        navigationController?.popViewController(animated: true)
        if let editVC = navigationController?.viewControllers.last as? EditProfileVC {
            print("found the edit vc")
            editVC.setPic(image: selectedImage ?? nil)
        }
        
    }
    
    
    
    weak var headerView: PhotoSelectorHeader?
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let contentOffsetY = scrollView.contentOffset.y
//        headerView?.animator.fractionComplete = abs(contentOffsetY)/100
//    }
    
}

extension PhotoSelectorController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        let selectedImage = images[indexPath.item]
        self.selectedImage = selectedImage
        self.collectionView?.reloadData()
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        let width = view.frame.width
//        return CGSize(width: width, height: width)
//    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: Element.header.kind,
                                                                     withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        headerView = header
        header.photoImageView.image = selectedImage
        self.header = header
        if let selectedImage = selectedImage {
            if let index = self.images.firstIndex(of: selectedImage) {
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                //let targetSize = CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
                imageManager.requestImage(for: selectedAsset,
                                          targetSize: targetSize,
                                          contentMode: .default,
                                          options: nil) {
                                            (image, info) in
                    header.photoImageView.image = image
                    
                }
            }
        }
        return header
    }
 
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }
}

extension PhotoSelectorController: MosiacLayoutDelegate {
    func collectionView(heightForTabBar collectionView: UICollectionView) -> CGFloat {
        topbarHeight
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForHeader indexPath: IndexPath) -> CGFloat {
        
        /*
        guard let selectedImage = selectedImage else { return 0 }
        return collectionView.frame.width/selectedImage.size.width * selectedImage.size.height*/
        
        return UIScreen.main.bounds.height / 3
    }
    
    
}
