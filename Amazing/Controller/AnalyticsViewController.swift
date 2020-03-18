//
//  AnalyticsViewController.swift
//  Amazing
//
//  Created by Sara Babaei on 3/18/20.
//  Copyright © 2020 Sara Babaei. All rights reserved.
//

import Foundation
import UIKit
import Charts
import CoreData

@available(iOS 13.0, *)
class AnalyticsViewController: UIViewController {
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var timeSegment: UISegmentedControl!
    
    let dataController = DataController()
    
    @IBAction func timeSegmentValueChanged(_ sender: Any) {
        setData()
    }
    
    func configure(){
        let legend = pieChartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
    }
    
    func setData(){
        var logs: [NSManagedObject]
        
        if timeSegment.selectedSegmentIndex == 0 {
            var date = dataController.today
            date = date.addingTimeInterval(-Double(30 * 24 * 3600))
            logs = dataController.logs(from: date, to: nil)
        }
        else{
            logs = dataController.logs(from: nil, to: nil)
        }
        
        var entries = [PieChartDataEntry(value: 0, label: "No data")]
        var centerText = ""
        var chartDescription = ""
        
        if let firstDate = (logs.first as! Mood).createdAt {
            let lasDate = (logs.last as! Mood).createdAt!
            let totalDays = Calendar.current.dateComponents([.day], from: lasDate, to: firstDate).day! + 1
            
            let loggedDays = logs.count
            let noLogDays = totalDays - loggedDays
            
            centerText = "Logged \(loggedDays) days"
            chartDescription = "From \(dataController.dateCaption(for: firstDate)) to \(dataController.dateCaption(for: lasDate))"
            
            entries = [
                PieChartDataEntry(value: Double(dataController.count(logs: logs, emotion: .happy)), label: Emotion.happy.rawValue, icon: #imageLiteral(resourceName: "Happy")),
                PieChartDataEntry(value: Double(dataController.count(logs: logs, emotion: .neutral)), label: Emotion.neutral.rawValue, icon: #imageLiteral(resourceName: "Alright")),
                PieChartDataEntry(value: Double(dataController.count(logs: logs, emotion: .sad)), label: Emotion.sad.rawValue, icon: #imageLiteral(resourceName: "Sad")),
                PieChartDataEntry(value: Double(dataController.count(logs: logs, emotion: .snooze)), label: Emotion.snooze.rawValue, icon: #imageLiteral(resourceName: "Snooze")),
                PieChartDataEntry(value: Double(noLogDays), label: "Slacking")
            ]
        }
        
        pieChartView.centerText = centerText
        pieChartView.chartDescription?.text = chartDescription
        
        let set = PieChartDataSet(entries: entries, label: "My mood summary")
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        
        set.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        let data = PieChartData(dataSet: set)
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(.systemFont(ofSize: 17, weight: .light))
        data.setValueTextColor(.white)
        
        pieChartView.data = data
        pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional setup after loading the view, typically from a nib
        
        configure()
        setData()
    }
}
