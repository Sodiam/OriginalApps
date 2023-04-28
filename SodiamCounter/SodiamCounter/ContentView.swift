//
//  ContentView.swift
//  SodiamCounter
//
//  Created by 伊藤総汰 on 2022/12/19.
//

import SwiftUI

var peds = [Double]()

struct ContentView: View {
    @State private var timeInterval: TimeInterval = 0
    private let formatter = ElapsedTimeFormatter()
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var is_timerRunning: Bool = false
    @State var stopped: Bool = false
    @State var pushed: Bool = false
    @State var in_count: Int = 0
    @State var section_count: Int = 0
    @State var button_text: String = "Press to Start!"
    @State var button_color: Color = Color.indigo
    @State var dt: Date = Date()
    @State var dateFormatter: DateFormatter = DateFormatter()
    @State var filename: String = ""
    @State var will_save: Bool = false
    var body: some View {
        VStack {
            Text(NSNumber(value: self.timeInterval), formatter: self.formatter).font(Font(UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .light))).onReceive(self.timer) {_ in
                if self.is_timerRunning {
                    self.timeInterval += 0.01
                }
                if self.is_timerRunning && self.stopped {
                    self.stop_measuring()
                }
            }.padding(.bottom, 30)
            Text(String(self.in_count)).font(.system(size: 30))
            Button(action:{if self.is_timerRunning {
                self.in_count += 1
                peds.append(timeInterval)
            }}) {
                Text("IN").font(.largeTitle).frame(width: 280, height: 60, alignment: .center).foregroundColor(.white).background(Color.blue).cornerRadius(15, antialiased: true)
                    }.padding(.all, 15)
            Button(action: {if !self.is_timerRunning {
                self.pushed = true
            } else {
                self.stopped = true
            }
            }) {
                Text(button_text).font(.largeTitle).frame(width: 280, height: 60, alignment: .center).foregroundColor(.white).background(button_color).cornerRadius(15, antialiased: true)
            }.alert(isPresented: $pushed) {
                return Alert(title: Text("Start count."), message: Text("Press OK button to start count."), primaryButton: .default(Text("OK"), action: {
                    self.dateFormatter.dateFormat =
                    DateFormatter.dateFormat(fromTemplate: "yyyyMMddHHmmss", options: 0, locale: Locale(identifier: "en_JP"))
                    peds.removeAll()
                    self.filename = createFilename()
                    self.in_count = 0
                    self.button_text = "Press here to stop"
                    self.button_color = Color.gray
                    self.is_timerRunning = true
                }), secondaryButton: .cancel(Text("Cancel")))
            }.padding(.top, 50)
            Button(action: {
                if !self.is_timerRunning {
                    self.will_save = true
                }
            }) {
                Text("Save data as CSV").font(.largeTitle).frame(width: 280, height: 60, alignment: .center).foregroundColor(.white).background(Color.green).cornerRadius(15, antialiased: true)
            }.alert(isPresented: $will_save) {
                var al: Alert
                if peds.count == 0 {
                    al = Alert(title: Text("Empty error!"), message: Text("I can\'t save data due to empty data stock!"), dismissButton: .default(Text("OK")))
                } else {
                    al = Alert(title: Text("Save"), message: Text("Press OK button to save data as CSV file."), primaryButton: .default(Text("OK"), action: {
                        self.saveToFile()
                    }), secondaryButton: .cancel(Text("Cancel")))
                }
                return al
            }.padding(.top, 30)
        }
        .padding()
    }
    
    func saveToFile() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Folder URL Error.")
        }
        let fileurl = url.appendingPathComponent(self.filename + ".csv")
        guard let file = OutputStream(url: fileurl, append: true) else {
            fatalError("Failed to Open File.")
        }
        file.open()
        defer {
            file.close()
        }
        for i in 0 ..< peds.count {
            file.write(String(peds[i]) + "\n", maxLength: (String(peds[i]) + "\n").utf8.count)
        }
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
    
    func stop_measuring() {
        self.timeInterval = 0
        self.stopped = false
        self.button_text = "Press to start!"
        self.button_color = Color.indigo
        self.is_timerRunning = false
        self.saveToFile()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
