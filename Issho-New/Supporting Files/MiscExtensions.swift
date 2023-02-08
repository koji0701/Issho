//
//  MiscExtensions.swift
//  Issho-New
//
//  Created by Koji Wong on 2/7/23.
//

import Foundation
import UIKit

extension String {//for backspace
  var isBackspace: Bool {
    let char = self.cString(using: String.Encoding.utf8)!
    return strcmp(char, "\\b") == -92
  }
}

