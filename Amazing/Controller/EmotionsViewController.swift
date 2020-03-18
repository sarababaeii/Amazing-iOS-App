//
//  ViewController.swift
//  Amazing
//
//  Created by Sara Babaei on 3/18/20.
//  Copyright © 2020 Sara Babaei. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class EmotionsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    
    @IBOutlet weak var happyButton: UIButton!
    @IBOutlet weak var sadButton: UIButton!
    @IBOutlet weak var neutralButton: UIButton!
    @IBOutlet weak var snoozButton: NSLayoutConstraint!
    
    let dataController = DataController()
    
    @IBAction func moodButtonPressed(_ sender: Any) {
        var emotion = Emotion.snooze
        
        switch (sender as! UIButton).tag {
        case 0:
            emotion = Emotion.happy
        case 1:
            emotion = Emotion.neutral
        case 2:
            emotion = Emotion.sad
        case 3:
            emotion = Emotion.snooze
        default:
            return
        }
        
        dataController.log(emotion: emotion)
        moodLabel.text = emotion.rawValue + "..."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        dataController.creatDummyLogsFor(days: 5)
        let logs = dataController.logs(from: nil, to: nil)
        dataController.printDetails(logs: logs)

    }


}

