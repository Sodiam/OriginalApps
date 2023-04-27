//
//  ContentView.swift
//  SodiamTracker
//
//  Created by 伊藤総汰 on 2021/07/01.
//

import SwiftUI
import MapKit

var spotlist = [Spot]()

struct ContentView: View {
    @State var labelText: String = "Press Button to Start Tracking!"
    @State var buttonText: String = "Start Tracking"
    @State var tracking: Bool = false
    @State var pushed: Bool = false
    @State var save: Bool = false
    @State var deletea: Bool = false
    @State var filename: String = ""
    @State var dt: Date = Date()
    @State var dateFormatter: DateFormatter = DateFormatter()
    @State var count: Int = 0
    @ObservedObject var manager = LocationManager()
    
    var body: some View {
        VStack {
            Text(String(spotlist.count) + "," + String(self.count)).padding(.bottom, 5)
            Text(dateFormatter.string(from: dt)).padding(.bottom, 5)
            Text(labelText).font(.title).padding(.bottom, 5)
            Button(action: {self.pushed = true}) {
                Text(buttonText).font(.largeTitle).frame(width: 250, height:60, alignment: .center).foregroundColor(.white).background(Color.blue).cornerRadius(15, antialiased: true)
            }.alert(isPresented: $pushed) {
                if !self.tracking {
                    return Alert(title: Text("Start tracking"), message: Text("Press OK button to start tracking."), primaryButton: .default(Text("OK"), action: {
                        self.dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMddHHmmss", options: 0, locale: Locale(identifier: "en_JP"))
                        self.filename = createFilename()
                        manager.manager.startUpdatingLocation()
                        self.labelText = "Now Tracking"
                        self.buttonText = "Stop Tracking"
                        self.tracking = true
                    }), secondaryButton: .cancel(Text("Cancel")))
                }
                return Alert(title: Text("Stop tracking"), message: Text("Do you want to stop tracking?"), primaryButton: .destructive(Text("Stop tracking"), action: {
                    manager.manager.stopUpdatingLocation()
                    self.labelText = "Tracking Is Stopped"
                    self.buttonText = "Start Tracking"
                    self.tracking = false
                }), secondaryButton: .cancel(Text("Cancel")))
            }
            .padding(.bottom, 15)
            Button(action: {self.save = true}) {
                Text("Save GPS Data as CSV").font(.largeTitle).frame(width: 350, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).foregroundColor(.white).background(Color.blue).cornerRadius(15, antialiased: true)
            }
            .alert(isPresented: $save) {
                if spotlist.count != 0 {
                    return Alert(title: Text("Save annotation data"), message: Text("Press OK button to save GPS data manually."), primaryButton: .default(Text("OK"), action: {saveToCSV()}), secondaryButton: .cancel(Text("Cancel")))
                }
                return Alert(title: Text("Data is empty!"), message: Text("GPS data has NOT been recorded yet."), dismissButton: .default(Text("OK")))
            }
            .padding(.bottom, 15)
            Button(action: {self.deletea = true}) {
                Text("Delete GPS Data").font(.largeTitle).frame(width: 300, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).foregroundColor(.white).background(Color.red).cornerRadius(15, antialiased: true)
            }
            .alert(isPresented: $deletea) {
                if spotlist.count != 0 {
                    return Alert(title: Text("Delete annotation data"), message: Text("Press OK button to delete GPS data. This operation is unrevivable."), primaryButton: .destructive(Text("OK"), action: {spotlist.removeAll()}), secondaryButton: .cancel(Text("Cancel")))
                }
                return Alert(title: Text("Data is empty!"), message: Text("GPS data has NOT been recorded yet."), dismissButton: .default(Text("OK")))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear() {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.dt = Date()
                if (self.tracking) {
                    _ = saveToCSVAuto()
                    spotlist.append(self.manager.toSpot())
                    self.count += 1
                }
            }
        }
    }
    
    func saveToCSVAuto() -> Bool {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Failed to access folder.")
        }
        let fileurl = url.appendingPathComponent(self.filename + ".csv")
        guard let file = OutputStream(url: fileurl, append: true) else {
            return false
        }
        file.open()
        defer {
            file.close()
        }
        file.write(self.dateFormatter.string(from: self.dt) + "," + self.manager.toString(), maxLength: (self.dateFormatter.string(from: self.dt) + "," + self.manager.toString()).utf8.count)
        return false
    }
    
    func saveToCSV() {
        let fname = createFilename()
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Folder URL Error")
        }
        let fileurl = url.appendingPathComponent(fname + ".csv")
        for i in 0 ..< spotlist.count {
            do {
                try spotlist[i].toString().write(to: fileurl, atomically: true, encoding: .utf8)
            } catch {
                print("Error: \(error)")
            }
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
}

struct Spot: Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func toString() -> String {
        return String(self.latitude) + "," + String(self.longitude) + "\n"
    }
    
    func toStringManual(_ date: Date, _ datef: DateFormatter) -> String {
        return datef.string(from: date) + "," + String(self.latitude) + "," + String(self.longitude) + "\n"
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
