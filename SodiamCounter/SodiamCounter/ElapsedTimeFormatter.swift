//
//  ElapsedTimeFormatter.swift
//  SodiamCounter
//
//  Created by 伊藤総汰 on 2022/12/19.
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
        let hunredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        let decimalSperator = Locale.current.decimalSeparator ?? "."
        return String(format: "%@%@%0.2d", formattedString, decimalSperator, hunredths)
    }
}
