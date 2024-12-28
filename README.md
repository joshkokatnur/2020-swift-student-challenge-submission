# 2020 Swift Student Challenge Submission
My submission for the Apple's 2020 Swift Student Challenge. One of ~350 winners.

## Notices
This project was tested on Xcode 11.4.1 on macOS Catalina 10.15.4
A bug in a previous version of macOS made on-device speech recognition inaccessable, so this should be run on the latest version
I also tested it on Xcode 11.3 and noticed severe performance issues, so it should be run on 11.4.1
There is a bug with the share functionality that may cause Xcode to freeze the first time; Restarting Xcode fixed that for me
I had difficulty making certain classes public so that I could include them within the 'sources' section, so I kept them all in this file

## Inspiration
I was initially inspired by Apple's updates to voice control that they showed off at last year's WWDC. It made me interested in accessibility both because it enables everyone to fully utilize their devices and because of the machine-learing technology that it involves.
I decided to try to implement similar features into a game because I felt that it would be best if it had unique ways to interact with the content other than the generic voice control system.
I also decided to implement a face tracking feature, inspired by the recent addition of the head pointer for controlling the cursor.

## Playground Description
My playground showcases a simple pong game, in which the paddle can be controlled without touching the computer.
Using voice control, you control the paddle by saying numbers that correspond with set positions.
Using face tracking, you control the paddle by moving your head left and right.
Because voice recognition is a bit slow, I would say that face tracking is the better implementation for now
I have enjoyed working with SwiftUI over the past year, so I decided to create all of the intro screens and UI elements with it.

## Technologies
- **SwiftUI** - intro screens and UI elements
- **SFSpeechRecognizer** - on-device voice recognition
- **Vision** - face tracking
- **SpriteKit/GameplayKit** - pong game
