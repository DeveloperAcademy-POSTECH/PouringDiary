//
//  PermissionController.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/08/04.
//

import Foundation
import Photos

class PermissionController {
    var currentPhotosPermissionStatus: PHAuthorizationStatus
    init() {
        currentPhotosPermissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    func requestPhotosPermission() {
        let requiredAccessLevel: PHAccessLevel = .readWrite
        PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { [weak self] authorizationStatus in
            self?.currentPhotosPermissionStatus = authorizationStatus
        }
    }
}
