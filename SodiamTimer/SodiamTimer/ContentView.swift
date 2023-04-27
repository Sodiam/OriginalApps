//
//  ContentView.swift
//  SodiamTimer
//
//  Created by 伊藤総汰 on 2023/03/20.
//

import SwiftUI

var timesL = [Double]()
var timesR = [Double]()

struct ContentView: View {
    @State private var timeL: TimeInterval = 0
    @State private var timeR: TimeInterval = 0
    private let formatter = ElapsedTimeFormatter()
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var is_timerRunningL: Bool = false
    @State var is_timerRunningR: Bool = false
    @State var pushed_save: Bool = false
    @State var textL: String = "Start"
    @State var textR: String = "Start"
    @State var colorL: Color = Color.blue
    @State var colorR: Color = Color.blue
    @State var dt: Date = Date()
    @State var dateFormatter: DateFormatter = DateFormatter()
    @State var will_save: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text(String(timesL.count))
                Text(String(timesR.count))
            }
            HStack {
                Text(NSNumber(value: self.timeL), formatter: self.formatter).font(Font(UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .light))).onReceive(self.timer) {_ in
                    if self.is_timerRunningL {
                        self.timeL += 0.01
                    } else {
                        self.timeL = 0
                    }
                }.padding(.horizontal, 10)
                Text(NSNumber(value: self.timeR), formatter: self.formatter).font(Font(UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .light))).onReceive(self.timer) {_ in
                    if self.is_timerRunningR {
                        self.timeR += 0.01
                    } else {
                        self.timeR = 0
                    }
                }.padding(.horizontal, 10)
            }.padding(.vertical, 50)
            HStack {
                Button(action:{ self.is_timerRunningL = !self.is_timerRunningL
                    if self.is_timerRunningL {
                        self.textL = "Stop"
                        self.colorL = Color.red
                    } else {
                        timesL.append(self.timeL)
                        self.textL = "Start"
                        self.colorL = Color.blue
                    }
                }) {
                    Text(self.textL).font(.largeTitle).frame(width: 130, height: 60, alignment: .center).foregroundColor(.white).background(self.colorL).cornerRadius(15, antialiased: true)
                }.padding(.horizontal, 10)
                Button(action:{
                    self.is_timerRunningR = !self.is_timerRunningR
                    if self.is_timerRunningR {
                        self.textR = "Stop"
                        self.colorR = Color.red
                    } else {
                        timesR.append(self.timeR)
                        self.textR = "Start"
                        self.colorR = Color.blue
                    }
                }) {
                    Text(self.textR).font(.largeTitle).frame(width: 130, height: 60, alignment: .center).foregroundColor(.white).background(self.colorR).cornerRadius(15, antialiased: true)
                }.padding(.horizontal, 10)
            }.padding(.vertical, 20)
            Button(action: { self.will_save = true }) {
                Text("Save").font(.largeTitle).frame(width: 280, height: 60, alignment: .center).foregroundColor(.white).background(Color.brown).cornerRadius(15, antialiased: true)
            }.alert(isPresented: $will_save) {
                return Alert(title: Text("Save"), message: Text("Press OK Button to save data as CSV file."), primaryButton: .default(Text("OK"), action: {
                    self.dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMddHHmmss", options: 0, locale: Locale(identifier: "en_JP"))
                    self.saveToFile()
                }), secondaryButton: .cancel(Text("Cancel")))
            }.padding(.vertical, 30)
        }
        .padding()
    }
    
    func createFilename() -> String {
        var fname: String = ""
        let datel: [String] = self.dateFormatter.string(from: self.dt).components(separatedBy: " ")[0].components(separatedBy: "/")
        let timel: [String] = self.dateFormatter.string(from: self.dt).components(separatedBy: " ")[1].components(separatedBy: ":")
        for i in 0 ..< datel.count {
            fname += datel[i]
        }
        for j in 0 ..< timel.count {
            fname += timel[j]
        }
        return fname
    }
    
    func saveToFile() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Folder URL Error.")
        }
        let filen: String = self.createFilename()
        let fileurlL = url.appendingPathComponent(filen + "L.csv")
        let fileurlR = url.appendingPathComponent(filen + "R.csv")
        guard let fileL = OutputStream(url: fileurlL, append: true) else {
            fatalError("Failed to Open File.")
        }
        guard let fileR = OutputStream(url: fileurlR, append: true) else {
            fatalError("Failed to Open File.")
        }
        fileL.open()
        fileR.open()
        defer {
            fileL.close()
            fileR.close()
        }
        for i in 0 ..< timesL.count {
            fileL.write(String(timesL[i]) + "\n", maxLength: (String(timesL[i]) + "\n").utf8.count)
        }
        for i in 0 ..< timesR.count {
            fileR.write(String(timesR[i]) + "\n", maxLength: (String(timesR[i]) + "\n").utf8.count)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
