//
//  Photos Auth.swift
//  Issho-New
//
//  Created by Koji Wong on 3/2/23.
//

import Foundation
import Photos
import UIKit


extension PhotoSelectorController {
    
    func requestPhotosAuth() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
            DispatchQueue.main.async { [unowned self] in
                showUI(for: status)
            }
        }
    }
    
    private func showAlertForAuth() {
        let alert = UIAlertController(title: "Allow access to your photos",
                                          message: "This lets you select a profile pic from your camera roll. Go to your settings and tap \"Photos\".",
                                          preferredStyle: .alert)
            
            let notNowAction = UIAlertAction(title: "Not Now",
                                             style: .cancel,
                                             handler: nil)
            alert.addAction(notNowAction)
            
            let openSettingsAction = UIAlertAction(title: "Open Settings",
                                                   style: .default) { [unowned self] (_) in
                // Open app privacy settings
                gotoAppPrivacySettings()
            }
            alert.addAction(openSettingsAction)
            
            present(alert, animated: true, completion: nil)
    }
    
    private func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func showUI(for status: PHAuthorizationStatus) {
        
        switch status {
        case .authorized:
            //showFullAccessUI()
            fetchPhotos()
            print("photos authorized")

        case .limited:
            //showLimittedAccessUI()
            fetchPhotos()
            print("photos limited")

        case .restricted:
            //showRestrictedAccessUI()
            showAlertForAuth()
            print("photos restricted")

        case .denied:
            //showAccessDeniedUI()
            showAlertForAuth()
            print("photos denied")

        case .notDetermined:
            showAlertForAuth()
            print("photos not determined")
            break

        @unknown default:
            break
        }
    }
}
