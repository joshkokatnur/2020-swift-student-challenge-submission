import SwiftUI
import PlaygroundSupport
import SpriteKit
import GameplayKit
import Speech
import Vision

// MARK: - Notices
// This project was tested on Xcode 11.4.1 on macOS Catalina 10.15.4
// A bug in a previous version of macOS made on-device speech recognition inaccessable, so this should be run on the latest version
// I also tested it on Xcode 11.3 and noticed severe performance issues, so it should be run on 11.4.1
// There is a bug with the share functionality that may cause Xcode to freeze the first time; Restarting Xcode fixed that for me
// I had difficulty making certain classes public so that I could include them within the 'sources' section, so I kept them all in this file

// MARK: - Inspiration
// I was initially inspired by Apple's updates to voice control that they showed off at last year's WWDC. It made me interested in accessibility both because it enables everyone to fully utilize their devices and because of the machine-learing technology that it involves.
// I decided to try to implement similar features into a game because I felt that it would be best if it had unique ways to interact with the content other than the generic voice control system.
// I also decided to implement a face tracking feature, inspired by the recent addition of the head pointer for controlling the cursor.

// MARK: - Playground Description
// My playground showcases a simple pong game, in which the paddle can be controlled without touching the computer.
// Using voice control, you control the paddle by saying numbers that correspond with set positions.
// Using face tracking, you control the paddle by moving your head left and right.
// Because voice recognition is a bit slow, I would say that face tracking is the better implementation for now
// I have enjoyed working with SwiftUI over the past year, so I decided to create all of the intro screens and UI elements with it.

// MARK: - Technologies
// SwiftUI - intro screens and UI elements
// SFSpeechRecognizer - on-device voice recognition
// Vision - face tracking
// SpriteKit/GameplayKit - pong game


// MARK: - Main View

struct ContentView: View {
    @State var appeared: Bool = false
    @ObservedObject var speechHandler = SpeechHandler.sharedInstance
    @ObservedObject var faceTrackingHandler = FaceTrackingHandler.sharedInstance
    @ObservedObject var timerHandler = TimerHandler.sharedInstance
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(#colorLiteral(red: 0.1568627451, green: 0.168627451, blue: 0.2078431373, alpha: 1)))
                    .frame(width: 450, height: timerHandler.introScreenIndex == 4 ? 625 : 600)
                VStack {
                    nextView
                    ProgressIndicator(length: 4, position: $timerHandler.introScreenIndex)
                }
            }
            .padding(.bottom, 10)
            BottomBar()
                .padding(.bottom, -500)
        }
        .frame(width: 750, height: 750)
        .scaleEffect(appeared ? 1 : 0.5)
        .onAppear() {
            withAnimation(.spring()) {
                self.appeared = true
            }
        }
    }
    
    var nextView: some View {
        let p = timerHandler.introScreenIndex
        return ZStack {
            if p == 1 {
                IntroView()
            } else if p == 2 {
                SelectionView(position: $timerHandler.introScreenIndex)
            } else if p == 3 {
                if speechHandler.recording {
                    VoiceTrackingInfoView()
                }
                if faceTrackingHandler.tracking {
                    FaceTrackingInfoView()
                }
            } else if p == 4 {
                if timerHandler.restart {
                    GameView()
                }
                if !timerHandler.restart {
                    GameView()
                }
            }
        }
    }
}


// MARK: - SwiftUI Icons

struct VoiceIcon: View {
    var fillColor: Color
    
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: .infinity)
                .fill(fillColor)
                .frame(width: 10, height: 20)
            RoundedRectangle(cornerRadius: .infinity)
                .fill(fillColor)
                .frame(width: 15, height: 35)
            RoundedRectangle(cornerRadius: .infinity)
                .fill(fillColor)
                .frame(width: 12, height: 60)
            RoundedRectangle(cornerRadius: .infinity)
                .fill(fillColor)
                .frame(width: 16, height: 120)
            RoundedRectangle(cornerRadius: .infinity)
                .fill(fillColor)
                .frame(width: 12, height: 150)
            RoundedRectangle(cornerRadius: .infinity)
                .fill(fillColor)
                .frame(width: 13, height: 80)
            RoundedRectangle(cornerRadius: .infinity)
                .fill(fillColor)
                .frame(width: 12, height: 40)
            RoundedRectangle(cornerRadius: .infinity)
                .fill(fillColor)
                .frame(width: 10, height: 15)
        }
    }
}

struct FaceTrackIcon: View {
    var fillColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .trim(from: 0.05, to: 0.2)
                .stroke(fillColor, style: .init(lineWidth: 25, lineCap: .round))
                .frame(width: 250, height: 250)
            RoundedRectangle(cornerRadius: 40)
                .trim(from: 0.3, to: 0.45)
                .stroke(fillColor, style: .init(lineWidth: 25, lineCap: .round))
                .frame(width: 250, height: 250)
            RoundedRectangle(cornerRadius: 40)
                .trim(from: 0.55, to: 0.7)
                .stroke(fillColor, style: .init(lineWidth: 25, lineCap: .round))
                .frame(width: 250, height: 250)
            RoundedRectangle(cornerRadius: 40)
                .trim(from: 0.8, to: 0.95)
                .stroke(fillColor, style: .init(lineWidth: 25, lineCap: .round))
                .frame(width: 250, height: 250)
            Capsule()
                .fill(fillColor)
                .frame(width: 130, height: 160)
        }
    }
}

struct ShareIcon: View {
    var fillColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .trim(from: 0.09, to: 0.91)
                .stroke(fillColor, style: .init(lineWidth: 50, lineCap: .round))
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-90))
            Capsule()
                .foregroundColor(fillColor)
                .frame(width: 50, height: 250)
                .offset(x: 0, y: -110)
            HStack(spacing: 25) {
                Capsule()
                    .foregroundColor(fillColor)
                    .frame(width: 50, height: 150)
                    .rotationEffect(.degrees(45))
                Capsule()
                    .foregroundColor(fillColor)
                    .frame(width: 50, height: 150)
                    .rotationEffect(.degrees(-45))
            }
            .offset(x: 0, y: -230)
        }
    }
}

struct VirtualPin: View {
    var voice: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)))
                .frame(width: 275, height: 275)
            Circle()
                .fill(Color(#colorLiteral(red: 0.03622731855, green: 0.03622731855, blue: 0.03622731855, alpha: 1)))
                .frame(width: 250, height: 250)
            VStack(spacing: -40) {
                Text("20")
                    .foregroundColor(Color(#colorLiteral(red: 0.0744170368, green: 0.0744170368, blue: 0.0744170368, alpha: 1)))
                    .font(.system(size: 110, weight: .black, design: .rounded))
                    .bold()
                Text("20")
                    .foregroundColor(Color(#colorLiteral(red: 0.1011857551, green: 0.1011857551, blue: 0.1011857551, alpha: 1)))
                    .font(.system(size: 110, weight: .black, design: .rounded))
                    .bold()
            }
            .padding(.leading, 10)
            .padding(.bottom, 10)
            HStack(spacing: voice ? 50 : 10) {
                ZStack {
                    Circle()
                        .fill(Color(#colorLiteral(red: 0.7940633169, green: 0.7940633169, blue: 0.7940633169, alpha: 1)))
                        .frame(width: 140, height: 140)
                    Circle()
                        .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                        .frame(width: 125, height: 125)
                    if voice {
                        VoiceIcon(fillColor: Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)))
                            .scaleEffect(0.5)
                    } else {
                        FaceTrackIcon(fillColor: Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)))
                            .scaleEffect(0.25)
                    }
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(#colorLiteral(red: 0.7940633169, green: 0.7940633169, blue: 0.7940633169, alpha: 1)))
                        .frame(width: 60, height: 265)
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                        .frame(width: 45, height: 250)
                }
                
            }
            .padding(.trailing, voice ? 70 : 110)
            .rotationEffect(.degrees(30))
        }
        .shadow(radius: 10)
    }
}


// MARK: - SwiftUI Supporting Views

struct IntroView: View {
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(nsImage: NSImage(named: "josh_memoji.png")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(-10))
                Text("Hey\nthere!")
                    .font(.system(size: 100))
                    .bold()
                    .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
            }
            .padding(.top, -50)
            .padding(.trailing, 35)
            Image(nsImage: NSImage(named: "josh_description.png")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400)
        }
    }
}

struct SelectionView: View {
    @Binding var position: Int
    
    var body: some View {
        VStack(spacing: 18) {
            Text("Choose a mode of\ninteraction . . .")
                .font(.system(size: 40))
                .bold()
                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                .padding(.trailing, 60)
                .fixedSize()
            Text("//This playground is intended to showcase accessibility features that are made possible by Apple’s machine learning frameworks")
                .font(.custom("Menlo", size: 12))
                .foregroundColor(Color(#colorLiteral(red: 0.3481602073, green: 0.6836696267, blue: 0.3272986114, alpha: 1)))
                .frame(width: 360)
                .lineSpacing(10)
            Button(action: {
                //set voice control
                withAnimation(.spring()) {
                    self.position += 1
                }
                do {
                    try SpeechHandler.sharedInstance.startRecording()
                } catch {
                    print(error)
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(#colorLiteral(red: 0.3025372402, green: 0.3241358967, blue: 0.3995123485, alpha: 1)))
                        .shadow(radius: 10)
                    HStack {
                        Text("Voice\nControl")
                            .font(.system(size: 45))
                            .bold()
                            .foregroundColor(Color(#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)))
                            .padding(.leading, 20)
                        Spacer()
                        VoiceIcon(fillColor: Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
                            .scaleEffect(0.65)
                            .frame(width: 100, height: 100)
                            .padding(.trailing, 25)
                    }
                }
                .frame(width: 360, height: 150)
            }
            .buttonStyle(CustomButtonStyle())
            Button(action: {
                //set face tracking
                withAnimation(.spring()) {
                    self.position += 1
                }
                FaceTrackingHandler.sharedInstance.configureSession()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(#colorLiteral(red: 0.3025372402, green: 0.3241358967, blue: 0.3995123485, alpha: 1)))
                        .shadow(radius: 10)
                    HStack {
                        Text("Face\nTracking")
                            .font(.system(size: 45))
                            .bold()
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                            .padding(.leading, 20)
                        Spacer()
                        FaceTrackIcon(fillColor: Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
                            .scaleEffect(0.35)
                            .frame(width: 100, height: 100)
                            .padding(.trailing, 25)
                    }
                }
                .frame(width: 360, height: 150)
            }
            .buttonStyle(CustomButtonStyle())
            .padding(.bottom, 20)
        }
    }
}

struct VoiceTrackingInfoView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("How to Play")
                .font(.system(size: 40))
                .bold()
                .fixedSize()
                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                .padding(.top, 18)
                .padding(.bottom, 10)
            Text("//How it Works")
                .font(.custom("Menlo", size: 14))
                .foregroundColor(Color(#colorLiteral(red: 0.3481602073, green: 0.6836696267, blue: 0.3272986114, alpha: 1)))
                .bold()
                .padding(.bottom, 5)
            Text("SFSpeechRecognizer enables offline speech-to-text conversion and my program searches through possible transcriptions for preselected commands. At the bottom of the screen, you can see the list of words that it hears and the blue microphone shows that it is listening. Say 'hello!'")
                .font(.system(size: 13))
                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                .lineSpacing(10)
                .padding(.bottom, 20)
            Text("//The Game")
                .font(.custom("Menlo", size: 14))
                .foregroundColor(Color(#colorLiteral(red: 0.3481602073, green: 0.6836696267, blue: 0.3272986114, alpha: 1)))
                .bold()
                .padding(.bottom, 5)
            Text("Just like standard pong, your goal is to not let the ball get past your paddle. Instead of scoring points, your goal is to try to last as long as possible against an unbeatable opponent. If you lose, the game will automatically restart. Last 30 seconds or longer to receive a virtual pin!")
                .font(.system(size: 13))
                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                .lineSpacing(10)
                .padding(.bottom, 20)
            Text("//Controlling the Paddle")
                .font(.custom("Menlo", size: 14))
                .foregroundColor(Color(#colorLiteral(red: 0.3481602073, green: 0.6836696267, blue: 0.3272986114, alpha: 1)))
                .bold()
                .padding(.bottom, 5)
            Text("Numbers 1 - 9 will be displayed under the paddle. To move the\npaddle to a set position, simply say the corresponding number. To\npause, say 'pause'")
                .font(.system(size: 13))
                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                .lineSpacing(10)
                .fixedSize()
                .padding(.bottom, 50)
        }
        .frame(width: 400)
    }
}

struct FaceTrackingInfoView: View {

    var body: some View {
        VStack(alignment: .leading) {
            Text("How to Play")
                .font(.system(size: 40))
                .bold()
                .fixedSize()
                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                .padding(.top, 18)
                .padding(.bottom, 10)
            Text("//How it Works")
                .font(.custom("Menlo", size: 14))
                .foregroundColor(Color(#colorLiteral(red: 0.3481602073, green: 0.6836696267, blue: 0.3272986114, alpha: 1)))
                .bold()
                .padding(.bottom, 5)
            Text("The Vision framework enables machine-learning based image processing. I used it to track the user's face by passing the camera buffer to a dedicated face-detection class. At the bottom of the screen, you can see your head's position relative to the screen and the blue icon shows that it is tracking.")
                .font(.system(size: 13))
                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                .lineSpacing(10)
                .padding(.bottom, 20)
            Text("//The Game")
                .font(.custom("Menlo", size: 14))
                .foregroundColor(Color(#colorLiteral(red: 0.3481602073, green: 0.6836696267, blue: 0.3272986114, alpha: 1)))
                .bold()
                .padding(.bottom, 5)
            Text("Just like standard pong, your goal is to not let the ball get past your paddle. Instead of scoring points, your goal is to try to last as long as possible against an unbeatable opponent. If you lose, the game will automatically restart. Last 60 seconds or longer to receive a virtual pin!")
                .font(.system(size: 13))
                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                .lineSpacing(10)
                .padding(.bottom, 20)
            Text("//Controlling the Paddle")
                .font(.custom("Menlo", size: 14))
                .foregroundColor(Color(#colorLiteral(red: 0.3481602073, green: 0.6836696267, blue: 0.3272986114, alpha: 1)))
                .bold()
                .padding(.bottom, 5)
            Text("Move your head left and right to move the paddle. It is best to keep\nyour face pointing forward. To calibrate the tracking, keep your face\nin the middle position and press the 're-center' button. To pause,\nopen your mouth")
                .font(.system(size: 13))
                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                .lineSpacing(10)
                .fixedSize()
                .padding(.bottom, 30)
        }
        .frame(width: 400)
    }
}

struct ProgressIndicator: View {
    var length: Int
    @Binding var position: Int
    @ObservedObject var speechHandler = SpeechHandler.sharedInstance
    @ObservedObject var faceTrackingHandler = FaceTrackingHandler.sharedInstance
    @ObservedObject var timerHandler = TimerHandler.sharedInstance

    var body: some View {
        ZStack {
            HStack {
                ForEach(1...length, id: \.self) {
                        Circle()
                            .frame(height: 8)
                            .foregroundColor(Color($0 == self.position ? #colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1) : #colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 0.15)))
                }
            }
            .frame(width: 100)
            HStack {
                if position > 1 {
                    Button(action: {
                        if self.position == 3 {
                            if self.speechHandler.recording {
                                self.speechHandler.stopRecording()
                            }
                            if self.faceTrackingHandler.tracking {
                                self.faceTrackingHandler.stopSession()
                            }
                        }
                        if self.position == 4 {
                            self.timerHandler.stop()
                            self.timerHandler.showAwardView = false
                            self.timerHandler.paused = false
                        }
                        withAnimation(.spring()) {
                            self.position -= 1
                        }
                    }) {
                        HStack {
                            Image(nsImage: NSImage(named: "arrow.png")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                            Text("Previous")
                                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                                .font(.system(size: 12))
                                .bold()
                        }
                    }
                    .padding(.leading, 170)
                    .buttonStyle(CustomButtonStyle())
                }
                Spacer()
                if position < length && position != 2 {
                    Button(action: {
                        if self.position == 3 {
                            self.timerHandler.start(delay: 5)
                        }
                        withAnimation(.spring()) {
                            self.position += 1
                        }
                    }) {
                        HStack {
                            Text("Next")
                                .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                                .font(.system(size: 12))
                                .bold()
                            Image(nsImage: NSImage(named: "arrow.png")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .rotationEffect(.degrees(180))
                        }
                    }
                    .padding(.trailing, 170)
                    .buttonStyle(CustomButtonStyle())
                }
            }
        }
    }
}

struct BottomBar: View {
    @State var indicatorAppeared: Bool = false
    @ObservedObject var speechHandler = SpeechHandler.sharedInstance
    @ObservedObject var faceTrackingHandler = FaceTrackingHandler.sharedInstance
    
    var body: some View {
        HStack(alignment: .top) {
            if speechHandler.recording {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(self.speechHandler.recentTranscriptions.reversed().enumerated()), id: \.element){ (i, item) in
                        Text(item)
                            .font(.system(size: 15))
                            .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                            .bold()
                            .opacity(Double(4 - i) / 4)
                    }
                    Spacer()
                }
                .frame(height: 500)
                Spacer()
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color(#colorLiteral(red: 0.2392156863, green: 0.6745098039, blue: 0.968627451, alpha: 0.75)))
                        .shadow(color: Color(#colorLiteral(red: 0.2392156863, green: 0.6745098039, blue: 0.968627451, alpha: 0.75)), radius: 10)
                    VoiceIcon(fillColor: Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
                        .scaleEffect(0.12)
                        .frame(width: 18, height: 18)
                }
                .opacity(indicatorAppeared ? 1 : 0.5)
                .onAppear() {
                    withAnimation(Animation.easeInOut(duration: 2).repeatForever()) {
                        self.indicatorAppeared = true
                    }
                }
            }
            if faceTrackingHandler.tracking {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2518518519)))
                        .frame(width: 90, height: 65)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.5)))
                        .frame(width: 15, height: 15)
                        .offset(x: (faceTrackingHandler.centerFacePos -  faceTrackingHandler.facePosX) * 125, y: 0)
                }
                Spacer()
                Button(action: {
                    self.faceTrackingHandler.centerFacePos = self.faceTrackingHandler.facePosX
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: .infinity)
                            .frame(width: 100, height: 40)
                            .foregroundColor(Color(#colorLiteral(red: 0.2392156863, green: 0.6745098039, blue: 0.968627451, alpha: 0.75)))
                        Text("Re-center")
                    }
                }
                .buttonStyle(CustomButtonStyle())
                .padding(.trailing)
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color(#colorLiteral(red: 0.2392156863, green: 0.6745098039, blue: 0.968627451, alpha: 0.75)))
                        .shadow(color: Color(#colorLiteral(red: 0.2392156863, green: 0.6745098039, blue: 0.968627451, alpha: 0.75)), radius: 10)
                    FaceTrackIcon(fillColor: Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
                        .scaleEffect(0.075)
                        .frame(width: 18, height: 18)
                }
                .opacity(indicatorAppeared ? 1 : 0.5)
                .onAppear() {
                    withAnimation(Animation.easeInOut(duration: 2).repeatForever()) {
                        self.indicatorAppeared = true
                    }
                }
            }
        }
        .frame(width: 400)
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring())
    }
}


// MARK: - Game Views

struct PauseMenu: View {
    @ObservedObject var faceTrackingHandler = FaceTrackingHandler.sharedInstance
    @State var appeared = false
    
    var body: some View {
        ZStack {
            BlurView()
                .opacity(appeared ? 1 : 0)
                .animation(.easeInOut)
            HStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.05)))
                        .frame(width: 130)
                    Text("Restart")
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.25)))
                        .font(.system(size: 25))
                        .bold()
                        .rotationEffect(.degrees(-90))
                    Text("Restart")
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75)))
                        .font(.system(size: 25))
                        .bold()
                        .mask(
                            Rectangle()
                                .padding(.trailing, (faceTrackingHandler.centerFacePos - faceTrackingHandler.facePosX) < -0.1 ? 0 : 250)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 2))
                }
                Spacer()
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.05)))
                        .frame(width: 130)
                    Text("Resume")
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.25)))
                        .font(.system(size: 25))
                        .bold()
                        .rotationEffect(.degrees(90))
                    Text("Resume")
                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75)))
                        .font(.system(size: 25))
                        .bold()
                        .mask(
                            Rectangle()
                                .padding(.trailing, (faceTrackingHandler.centerFacePos - faceTrackingHandler.facePosX) > 0.1 ? 0 : 250)
                        )
                        .rotationEffect(.degrees(90))
                        .animation(.easeInOut(duration: 2))
                }
            }
            if faceTrackingHandler.tracking {
                Text("//To restart or resume, move the blue cursor with your head to the corresponding side and hold it there for 2 seconds. ")
                    .font(.custom("Menlo", size: 12))
                    .foregroundColor(Color(#colorLiteral(red: 0.3481602073, green: 0.6836696267, blue: 0.3272986114, alpha: 1)))
                    .frame(width: 360)
                    .lineSpacing(10)
                    .offset(x: 0, y: -200)
                    .zIndex(1)
                Circle()
                    .fill(Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.5)))
                    .frame(width: 50, height: 50)
                    .offset(x: (faceTrackingHandler.centerFacePos - faceTrackingHandler.facePosX) * 1000, y: 0)
            } else {
                Text("//To restart, say 'restart' and to resume, say 'resume'")
                    .font(.custom("Menlo", size: 12))
                    .foregroundColor(Color(#colorLiteral(red: 0.3481602073, green: 0.6836696267, blue: 0.3272986114, alpha: 1)))
                    .frame(width: 360)
                    .lineSpacing(10)
                    .offset(x: 0, y: -200)
            }
        }
        .frame(width: 452, height: 627)
        .cornerRadius(15)
        .offset(x: 0, y: faceTrackingHandler.tracking ? 11 : 23)
        .onAppear() {
            self.appeared = true
        }
    }
}

struct AwardView: View {
    @ObservedObject var faceTrackingHandler = FaceTrackingHandler.sharedInstance
    @ObservedObject var timerHandler = TimerHandler.sharedInstance
    @State var appeared = false
    @State var showShareMenu = false
    
    var body: some View {
        ZStack {
            BlurView()
                .opacity(appeared ? 1 : 0)
                .animation(.easeInOut)
            VStack(spacing: 10) {
                HStack {
                    Text("Nice Job!")
                        .font(.system(size: 50))
                        .bold()
                        .padding(.leading, 50)
                    Spacer()
                }
                Text("//It looks like you've mastered the art of\ntelekinesis! Here's a virtual pin that I designed\nentirely in SwiftUI. Tap the share button to save\nor share it:")
                    .font(.custom("Menlo", size: 12))
                    .foregroundColor(Color(#colorLiteral(red: 0.3481602073, green: 0.6836696267, blue: 0.3272986114, alpha: 1)))
                    .fixedSize()
                    .frame(width: 360)
                    .lineSpacing(10)
                HStack {
                    Spacer()
                    Button(action: {
                        self.showShareMenu = true
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.25)))
                            ShareIcon(fillColor: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                .scaleEffect(0.09)
                                .offset(x: 0, y: 5)
                        }
                    }
                    .buttonStyle(CustomButtonStyle())
                    .background(SharingHandler(isPresented: $showShareMenu, sharingItems: [NSImage(named: "\(faceTrackingHandler.tracking ? "ft" : "voice")_virtualpin.png")!]))
                }
                .padding(.trailing, -50)
                .padding(.top, -115)
                .padding(.bottom, -480)
                VirtualPin(voice: !faceTrackingHandler.tracking)
                    .scaleEffect(appeared ? 1 : 0.5)
                    .opacity(appeared ? 1 : 0)
                    .rotation3DEffect(.degrees(appeared ? 0 : 60), axis: (x: 1, y: 0, z: 0))
                    .animation(Animation.easeOut(duration: 1).delay(0.5))
                    .padding(.bottom, 25)
                Button(action: {
                    self.timerHandler.paused = false
                    self.timerHandler.showAwardView = false
                    self.timerHandler.restart.toggle()
                    self.timerHandler.start(delay: 5)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 200, height: 50)
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.25)))
                        Text("Done")
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                            .font(.system(size: 25))
                            .bold()
                    }
                }
                .buttonStyle(CustomButtonStyle())
            }
        }
        .frame(width: 452, height: 627)
        .cornerRadius(15)
        .offset(x: 0, y: faceTrackingHandler.tracking ? 11 : 23)
        .onAppear() {
            self.appeared = true
        }
    }
}

struct GameView: View {
    @ObservedObject var speechHandler = SpeechHandler.sharedInstance
    @ObservedObject var timerHandler = TimerHandler.sharedInstance
    @State var three: Bool = false
    @State var two: Bool = false
    @State var one: Bool = false
    @State var start: Bool = false
    @State var timerFlash: Bool = false
    @State var showTimer: Bool = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                ZStack {
                    GameViewRepresentable(gamePaused: timerHandler.paused)
                        .frame(width: 425, height: 550)
                    Group {
                        Text("3")
                            .font(.system(size: 100))
                            .bold()
                            .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                            .offset(x: three ? 100 : -50, y: 0)
                            .opacity(two ? 0 : (three ? 1 : 0))
                        Text("2")
                            .font(.system(size: 100))
                            .bold()
                            .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                            .offset(x: two ? 100 : -50, y: 0)
                            .opacity(one ? 0 : (two ? 1 : 0))
                        Text("1")
                            .font(.system(size: 100))
                            .bold()
                            .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                            .offset(x: one ? 100 : -50, y: 0)
                            .opacity(start ? 0 : (one ? 1 : 0))
                    }
                    .frame(width: 160)
                    .clipShape(Rectangle().offset(x: 50, y: 0))
                    Circle()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)))
                        .opacity(start ? 0 : 1)
                        .scaleEffect(start ? 0 : 1)
                }
                .overlay(
                    Group {
                        if timerHandler.showAwardView {
                            AwardView()
                        } else if timerHandler.paused {
                            PauseMenu()
                        }
                    }
                )
                Group {
                    Text(showTimer ? "\(timerHandler.count)" : "0")
                        .font(.system(size: 100))
                        .bold()
                        .foregroundColor(Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)))
                    + Text("sec")
                        .font(.system(size: 50))
                        .bold()
                        .foregroundColor(Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)))
                }
                .offset(x: -50, y: -90)
                .rotationEffect(.degrees(-10))
                .hueRotation(.degrees(timerFlash ? 360 : 0))
            }
            if speechHandler.recording {
                HStack(spacing: 25) {
                    ForEach(1...9, id: \.self) {
                        Text("\($0)")
                            .font(.system(size: 25))
                            .bold()
                            .foregroundColor(Color(self.speechHandler.paddlePos == CGFloat($0 - 5) ? #colorLiteral(red: 0.2588235294, green: 0.6759131551, blue: 0.9697930217, alpha: 0.75) : #colorLiteral(red: 0.2573392689, green: 0.6759131551, blue: 0.9697930217, alpha: 0.2517925942)))
                    }
                }
                .zIndex(-1)
                .padding(.leading, 2)
                .padding(.top, -15)
            }
        }
        .onAppear() {
            withAnimation(Animation.easeInOut(duration: 1).delay(1)) {
                    self.three = true
            }
            withAnimation(Animation.easeInOut(duration: 1).delay(2)) {
                self.two = true
            }
            withAnimation(Animation.easeInOut(duration: 1).delay(3)) {
                self.one = true
            }
            withAnimation(Animation.easeInOut(duration: 1).delay(4)) {
                self.start = true
            }
            withAnimation(Animation.easeInOut(duration: 1).delay(4).repeatForever()) {
                self.timerFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                self.showTimer = true
            }
        }
    }
}

struct GameViewRepresentable: NSViewRepresentable {
    var gamePaused: Bool
    
    func makeNSView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
        }
        
        return view
    }

    func updateNSView(_ nsView: SKView, context: Context) {
        if gamePaused {
            nsView.isPaused = true
        } else {
            nsView.isPaused = false
        }
    }
}

class GameScene: SKScene {
    @ObservedObject var speechHandler = SpeechHandler.sharedInstance
    @ObservedObject var faceTrackingHandler = FaceTrackingHandler.sharedInstance
    @ObservedObject var timerHandler = TimerHandler.sharedInstance
    
    //create variables for objects in scene
    var ball = SKSpriteNode()
    var player = SKSpriteNode()
    var enemy = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        //assign objects from gamescene to the variables
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        player = self.childNode(withName: "player") as! SKSpriteNode
        enemy = self.childNode(withName: "enemy") as! SKSpriteNode
        
        //create border
        let border  = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        //The ball wasn't bouncing properly, decreasing the speed of the world and increasing the speed of the ball fixes it
        if speechHandler.recording {
            physicsWorld.speed = (0.5)
        }
            
        //make ball start moving after countdown
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            let x = Int.random(in: 200...400)
            let y = Int.random(in: 200...400)
            let dir = Bool.random()
            self.ball.physicsBody?.applyImpulse(CGVector(dx: dir ? x : -1 * x, dy: y))
        }
    }
    
    func endGame() {
        if timerHandler.count >= (speechHandler.recording ? 30 : 60) {
            timerHandler.showAwardView = true
            timerHandler.pause()
        } else {
            timerHandler.stop()
            ball.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 1))
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            timerHandler.restart.toggle()
            timerHandler.start(delay: 5)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if speechHandler.recording {
            player.run(SKAction.moveTo(x: 50 * speechHandler.paddlePos, duration: 0.5))
        }
        if faceTrackingHandler.tracking {
            player.position.x = (faceTrackingHandler.centerFacePos -  faceTrackingHandler.facePosX) * 1000
        }
        enemy.run(SKAction.moveTo(x: ball.position.x, duration: 0.05))
        
        if ball.position.y <= player.position.y + 12 {
            endGame()
        }
    }
}

struct BlurView: NSViewRepresentable {

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .withinWindow
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

class TimerHandler: ObservableObject {
    static let sharedInstance = TimerHandler()
    
    @Published var introScreenIndex: Int = 2
    @Published var showAwardView: Bool = false
    @Published var paused: Bool = false
    @Published var restart: Bool = false
    @Published var count = 0
    
    var timer: Timer?
    
    func start(delay: Double) {

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
            //cancel timer if already running
            self.stop()
            
            //start timer if not already paused
            if !self.paused {
                self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.count += 1
                }
                self.timer?.tolerance = 0.1
                RunLoop.current.run()
            }
        }
    }
    
    func resume() {
        DispatchQueue.global(qos: .background).async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.count += 1
            }
            self.timer?.tolerance = 0.1
            RunLoop.current.run()
        }
    }
    
    func stop() {
        if let timer = timer {
            timer.invalidate()
        }
        count = 0
        timer = nil
    }
    
    func pause() {
        if let timer = timer {
            timer.invalidate()
        }
        timer = nil
        paused = true
    }
}


// MARK: - On-device Speech Recognition

class SpeechHandler: ObservableObject {
    //Based on: https://developer.apple.com/documentation/speech/recognizing_speech_in_live_audio
    //I made some small modifications so that it would run properly on macOS
    //I wrote my own algorithm for sorting through the transcriptions
    
    static let sharedInstance = SpeechHandler()
    
    @ObservedObject var timerHandler = TimerHandler.sharedInstance
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    
    @Published var paddlePos: CGFloat = 0
    @Published var recentTranscriptions: [String] = ["Listening . . ."]
    @Published var recording: Bool = false
    
    func startRecording() throws {
        // Cancel the previous task if it's running
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        // Create and configure the speech recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if speechRecognizer.supportsOnDeviceRecognition {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        
        // Create a recognition task for the speech recognition session
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            
            if let result = result {
                var possibleTranscriptions: [String] = []
                
                //sort through all possible transcriptions
                for trans in result.transcriptions {
                    for seg in trans.segments {
                        possibleTranscriptions.append(seg.substring.lowercased())
                    }
                }
 
                //add recent transcriptions to array to be displayed
                withAnimation(.easeInOut) {
                    self.recentTranscriptions = possibleTranscriptions.suffix(4)
                }
                    
                for str in possibleTranscriptions {
                    switch str {
                        case "1": self.paddlePos = -4
                        case "2": self.paddlePos = -3
                        case "3": self.paddlePos = -2
                        case "4": self.paddlePos = -1
                        case "5": self.paddlePos = 0
                        case "6": self.paddlePos = 1
                        case "7": self.paddlePos = 2
                        case "8": self.paddlePos = 3
                        case "9": self.paddlePos = 4
                        case "one": self.paddlePos = -4
                        case "to": self.paddlePos = -3
                        case "too": self.paddlePos = -3
                        case "two": self.paddlePos = -3
                        case "three": self.paddlePos = -2
                        case "for": self.paddlePos = -1
                        case "or": self.paddlePos = -1
                        case "four": self.paddlePos = -1
                        case "five": self.paddlePos = 0
                        case "six": self.paddlePos = 1
                        case "seven": self.paddlePos = 2
                        case "it": self.paddlePos = 3
                        case "eight": self.paddlePos = 3
                        case "nine": self.paddlePos = 4
                        case "pause":
                            if self.timerHandler.introScreenIndex == 4 && !self.timerHandler.paused {
                                self.timerHandler.pause()
                            }
                        case "zoom":
                            if self.timerHandler.paused {
                                self.timerHandler.paused = false
                                self.timerHandler.resume()
                            }
                        case "resume":
                            if self.timerHandler.paused {
                                self.timerHandler.paused = false
                                self.timerHandler.resume()
                            }
                        case "restart":
                            if self.timerHandler.paused {
                                self.timerHandler.paused = false
                                self.timerHandler.restart.toggle()
                                self.timerHandler.start(delay: 5)
                            }
                        default:
                            //reset so that context doesn't influence word choice
                            possibleTranscriptions.removeAll()
                            self.recognitionTask?.finish()
                            do {
                                try SpeechHandler.sharedInstance.startRecording()
                            } catch {
                                print(error)
                            }
                    }
                }
                
                if error != nil {
                    self.stopRecording()
                    inputNode.removeTap(onBus: 0)
                }
            }
        }
        
        // Configure the microphone input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 128, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print(error)
            return
        }
        self.recording = true
    }
    
    func stopRecording() {
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        
        //reset variables
        self.recognitionRequest = nil
        self.recognitionTask = nil
        self.recording = false
    }
}


// MARK: - On-device Face Recognition

class FaceTrackingHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    //Based on: https://developer.apple.com/documentation/vision/tracking_the_user_s_face_in_real_time
    
    static let sharedInstance = FaceTrackingHandler()
    
    @ObservedObject var timerHandler = TimerHandler.sharedInstance
    
    @Published var centerFacePos: CGFloat = 0.55
    @Published var facePosX: CGFloat = 0.55
    @Published var tracking: Bool = false
    let captureSession = AVCaptureSession()
    
    //Pause menu action handling
    var actionCalled = false
    
    // Vision requests
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    private var trackingRequests: [VNTrackObjectRequest]?
    
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    
    func configureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.low
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
                print("Can't create default camera.")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(input)
        } catch {
            print("Can't create AVCaptureDeviceInput.")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        let dataOutputQueue = DispatchQueue(label: "video data queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        
        prepareVisionRequest()
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            captureSession.startRunning()
            tracking = true
        }
    }
    
    func stopSession() {
        captureSession.stopRunning()
        detectionRequests = nil
        trackingRequests = nil
        tracking = false
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        var requestHandlerOptions: [VNImageOption: AnyObject] = [:]
        
        let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil)
        if cameraIntrinsicData != nil {
            requestHandlerOptions[VNImageOption.cameraIntrinsics] = cameraIntrinsicData
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to obtain a CVPixelBuffer for the current output frame.")
            return
        }
        
        guard let requests = self.trackingRequests, !requests.isEmpty else {
            // No tracking object detected, so perform initial detection
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: requestHandlerOptions)
            
            do {
                guard let detectRequests = self.detectionRequests else {
                    return
                }
                try imageRequestHandler.perform(detectRequests)
            } catch let error as NSError {
                NSLog("Failed to perform FaceRectangleRequest: %@", error)
            }
            return
        }
        
        do {
            try self.sequenceRequestHandler.perform(requests, on: pixelBuffer)
        } catch let error as NSError {
            NSLog("Failed to perform SequenceRequest: %@", error)
        }
        
        // Setup the next round of tracking.
        var newTrackingRequests = [VNTrackObjectRequest]()
        for trackingRequest in requests {
            
            guard let results = trackingRequest.results else {
                return
            }
            
            guard let observation = results[0] as? VNDetectedObjectObservation else {
                return
            }
            
            if !trackingRequest.isLastFrame {
                if observation.confidence > 0.3 {
                    trackingRequest.inputObservation = observation
                } else {
                    trackingRequest.isLastFrame = true
                }
                newTrackingRequests.append(trackingRequest)
            }
        }
        self.trackingRequests = newTrackingRequests
        
        if newTrackingRequests.isEmpty {
            // Nothing to track, so abort.
            return
        }
        
        // Perform face landmark tracking on detected faces
        var faceLandmarkRequests = [VNDetectFaceLandmarksRequest]()
        
        // Perform landmark detection on tracked faces
        for trackingRequest in newTrackingRequests {
            
            let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request, error) in
                
                if error != nil {
                    print("FaceLandmarks error: \(String(describing: error)).")
                }
                
                guard let landmarksRequest = request as? VNDetectFaceLandmarksRequest,
                    let results = landmarksRequest.results as? [VNFaceObservation] else {
                        return
                }
                
                DispatchQueue.main.async {
                    for faceObservation in results {
                        //set position of face
                        self.facePosX = faceObservation.boundingBox.midX
                        
                        //detect if mouth is open to pause
                        if self.timerHandler.introScreenIndex == 4 && !self.timerHandler.paused {
                            let pointsM = faceObservation.landmarks?.outerLips?.normalizedPoints
                            let distM = (pointsM?[2].y)! - (pointsM?[10].y)!
                            if distM > 0.25 {
                                self.timerHandler.pause()
                            }
                        }
                        
                        //if paused, track position to restart or resume
                        if self.timerHandler.paused && !self.actionCalled && !self.timerHandler.showAwardView {
                            if (self.centerFacePos - self.facePosX) > 0.1 {
                                self.actionCalled = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    if (self.centerFacePos - self.facePosX) > 0.1 {
                                        self.timerHandler.paused = false
                                        self.timerHandler.resume()
                                    }
                                    self.actionCalled = false
                                }
                            }
                            if (self.centerFacePos - self.facePosX) < -0.1 {
                                self.actionCalled = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    if (self.centerFacePos - self.facePosX) < -0.1 {
                                        self.timerHandler.paused = false
                                        self.timerHandler.restart.toggle()
                                        self.timerHandler.start(delay: 5)
                                    }
                                    self.actionCalled = false
                                }
                            }
                        }
                    }
                }
            })
            
            guard let trackingResults = trackingRequest.results else {
                return
            }
            
            guard let observation = trackingResults[0] as? VNDetectedObjectObservation else {
                return
            }
            let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
            faceLandmarksRequest.inputFaceObservations = [faceObservation]
            
            // Continue to track detected facial landmarks.
            faceLandmarkRequests.append(faceLandmarksRequest)
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: requestHandlerOptions)
            
            do {
                try imageRequestHandler.perform(faceLandmarkRequests)
            } catch let error as NSError {
                NSLog("Failed to perform FaceLandmarkRequest: %@", error)
            }
        }
    }
    
    func prepareVisionRequest() {
        var requests = [VNTrackObjectRequest]()
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
            
            if error != nil {
                print("FaceDetection error: \(String(describing: error)).")
            }
            
            guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
                let results = faceDetectionRequest.results as? [VNFaceObservation] else {
                    return
            }
            DispatchQueue.main.async {
                // Add the observations to the tracking list
                for observation in results {
                    let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
                    requests.append(faceTrackingRequest)
                }
                self.trackingRequests = requests
            }
        })
        
        // Start with detection, find face, then track it
        self.detectionRequests = [faceDetectionRequest]
        self.sequenceRequestHandler = VNSequenceRequestHandler()
    }
}


// MARK: - Share Functionality

struct SharingHandler: NSViewRepresentable {
    @Binding var isPresented: Bool
    var sharingItems: [Any] = []

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented {
            let picker = NSSharingServicePicker(items: sharingItems)
            picker.delegate = context.coordinator

            DispatchQueue.main.async {
                picker.show(relativeTo: .zero, of: nsView, preferredEdge: .minY)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }

    class Coordinator: NSObject, NSSharingServicePickerDelegate {
        let owner: SharingHandler

        init(owner: SharingHandler) {
            self.owner = owner
        }

        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
            sharingServicePicker.delegate = nil
            self.owner.isPresented = false
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())
