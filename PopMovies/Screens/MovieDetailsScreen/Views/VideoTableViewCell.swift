//
//  VideoTableViewCell.swift
//  PopMovies
//
//  Created by ecovali on 3/9/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit

class VideoTableViewCell: UITableViewCell {
 
    public func setup(video: Video) {
        textLabel?.text = video.name
        detailTextLabel?.text = video.type
    }
}
