//
//  ViewController.swift
//  SwiftExample
//
//  Created by Wenchao Ding on 9/3/15.
//  Copyright (c) 2015 wenchao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.selectDate(NSDate())
        calendar.scrollDirection = .Vertical
        calendar.appearance.titleTextSize = 15.0
        calendar.appearance.weekdayTextSize = 15.0
        
        calendar.appearance.selectionColor = UIColor.grayColor()
        calendar.appearance.selectionStrokeColor = UIColor.clearColor()
        
        calendar.appearance.todayStrokeColor = UIColor.blackColor()//  UIColor(red: 14.0/256.0, green: 69.0/256.0, blue: 221.0/256.0, alpha: 1.0)
        calendar.appearance.todayColor = UIColor.clearColor()
        calendar.appearance.titleTodayColor = UIColor.blackColor()//   UIColor(red: 14.0/256.0, green: 69.0/256.0, blue: 221.0/256.0, alpha: 1.0)
        
        calendar.appearance.todaySelectionColor = UIColor.grayColor()
        
        calendar.scope = .Month
    }
    
    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
        return false
    }

    func calendar(calendar: FSCalendar!, imageForDate date: NSDate!) -> UIImage! {
        return (date.fs_day == 7) ? UIImage(named: "down_round") : nil
    }
    
    func calendar(calendar: FSCalendar!, backgroundColorForDate date: NSDate!) -> UIColor! {
        if ([7,11].contains(date.fs_day)) {
            return UIColor(red: 1.0/256.0, green: 150.0/256.0, blue: 65.0/256.0, alpha: 1.0)
        }
        else if ([9,15].contains(date.fs_day)) {
            return UIColor(red: 196.0/256.0, green: 1.0/256.0, blue: 29.0/256.0, alpha: 1.0)
        }
        else if ([4,21].contains(date.fs_day)) {
            return UIColor(red: 226.0/256.0, green: 202.0/256.0, blue: 44.0/256.0, alpha: 1.0)
        }
        else {
            return nil
        }
    }

    func calendarCurrentPageDidChange(calendar: FSCalendar!) {
        print("change page to \(calendar.currentPage.fs_string())")
    }
    
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        print("calendar did select date \(date.fs_string())")
    }
    
    func calendarCurrentScopeWillChange(calendar: FSCalendar!, animated: Bool) {
        calendarHeightConstraint.constant = calendar.sizeThatFits(CGSizeZero).height
    }
    
}

