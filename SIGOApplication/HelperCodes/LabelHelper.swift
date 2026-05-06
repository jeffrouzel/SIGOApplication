//
//  LabelHelper.swift
//  SIGOApplication
//
//  Created by training2 on 5/7/26.
//
import UIKit

// MARK: - TIME/DATE LABELS
func isDayTime(unix: Int, timezone: Int) -> Bool {
    let date = Date(timeIntervalSince1970: TimeInterval(unix))
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(secondsFromGMT: timezone) ?? .current
    let hour = calendar.component(.hour, from: date)
    return hour >= 6 && hour < 18
}
func formatTime(_ unix: Int, timezone: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(unix))
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    formatter.timeZone = TimeZone(secondsFromGMT: timezone)
    return formatter.string(from: date)
}
func formatDate(_ unix: Int, timezone: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(unix))
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    formatter.timeZone = TimeZone(secondsFromGMT: timezone)
    return formatter.string(from: date)
}
func formatDateRangeText(startDate: Date, endDate: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    let start = formatter.string(from: startDate)
    
    formatter.dateFormat = "MMM d, yyyy"
    let end = formatter.string(from: endDate)
    
    return "\(start) – \(end)"
}

