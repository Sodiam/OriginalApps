//
//  ElapsedTimeFormatter.swift
//  SodiamTimer
//
//  Created by 伊藤総汰 on 2023/03/20.
//

import Foundation

class ElapsedTimeFormatter: Formatter {
    let componentFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    override func string(for obj: Any?) -> String? {
        guard let time = obj as? TimeInterval else { return nil }
        guard let formattedString = componentFormatter.string(from: time) else { return nil }
        let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        return String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths)
    }
}
