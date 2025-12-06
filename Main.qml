/*
 *      [Main.qml]
 *
 *      Main script for SDDM Theme "Sourced" (By WhenThe1@github.com), forked from "Reactionary" (By phob1an@opencode.net).
 *
 *      Overall layout and functionality by phob1an, asset changes and additional functionality by WhenThe1.
 *
 *      This work is under the GPLv3 license.
 */







import QtQuick
import QtQuick.Controls
import QtCore
import QtMultimedia
import SddmComponents 2.0
import "."


Rectangle {
    id: container
    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    property int sessionIndex: session.index
    property date dateTime: new Date()

    TextConstants {
        id: textConstants

    }


    Connections {
        target: sddm
        function onLoginSucceeded() {
            errorMessage.text = textConstants.loginSucceeded
        }
        function onLoginFailed() {
            password.text = ""
            errorMessage.color = "#ff3333"
            errorMessage.text = textConstants.loginFailed
        }
    }

    Timer {
        interval: 100; running: true; repeat: true;
        onTriggered: container.dateTime = new Date()
    }


    // Fonts

    FontLoader {
        id: myfontNormal
        source: "./assets/gordin-regular.ttf"
    }

    FontLoader {
        id: myfontBold
        source: "./assets/gordin-semibold.ttf"
    }

    Image {
        id: behind
        anchors.fill: parent
         source: config.background
         fillMode: Image.Stretch
         onStatusChanged: {
             if (config.type === "color") {
                 source = config.defaultBackground
             }
         }
    }

    //Sfx Category

    MediaDevices {
        id: defaultOutput
    }

    MediaPlayer {
        id: backgroundTheme
        audioOutput: AudioOutput { device: defaultOutput.defaultAudioOutput; volume: config.backgroundVolume }
        source: config.stringValue("backgroundTheme") ? config.backgroundTheme : config.intValue("newSrcboxTheme") ? "audio/newBox.mp3" : "audio/oldBox.mp3"
        loops: MediaPlayer.Infinite
    }

    SoundEffect {
        id: typingEffect
        source: config.stringValue("typingEffect") ? config.typingEffect : "audio/click.wav"
        volume: config.typingVolume
    }

    SoundEffect {
        id: clickEffect
        source: config.stringValue("clickEffect") ? config.clickEffect : "audio/friend_join.wav"
        volume: config.clickVolume
    }

    SoundEffect {
        id: loginEffect
        source: config.stringValue("loginEffect") ? config.loginEffect : "audio/cone.wav"
        volume: config.loginVolume
    }

    // Input Fields and Avatar Picture flickering animation

    SequentialAnimation {
        id: loginFlicker

        PropertyAction{targets: [textback, textback1]; property: "visible"; value: false}
        PropertyAction{target: userPicture; property: "source"; value: "broke"}
        PauseAnimation{duration: 75}
        PropertyAction{targets: [textback, textback1]; property: "visible"; value: true}
        PropertyAction{target: userPicture; property: "source"; value: "/var/lib/AccountsService/icons/" + nameinput.text}
        PauseAnimation{duration: 75}
        PropertyAction{targets: [textback, textback1]; property: "visible"; value: false}
        PropertyAction{target: userPicture; property: "source"; value: "broke"}
        PauseAnimation{duration: 75}
        PropertyAction{targets: [textback, textback1]; property: "visible"; value: true}
        PropertyAction{target: userPicture; property: "source"; value: "/var/lib/AccountsService/icons/" + nameinput.text}
        PauseAnimation{duration: 75}

        //as you can see i am very good at QML /j
    }

    // Main UI

    Image {
        id: promptBox
        anchors.centerIn : parent
        source : "assets/promptbox.svg"
        opacity: 0.7
        width: 480
        height: 320

        onStatusChanged: if (promptBox.status == Image.Ready) backgroundTheme.play()

        Text {
            id: greetingText
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 18
            anchors.topMargin: 10
            color: "white"
            text: "Welcome back '" + userModel.lastUser + "'!"
            font.family: myfontBold.name
            font.bold: true
            font.pointSize: 10
        }

        Text {
            id: productName
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 40
            anchors.leftMargin: 18
            color: "white"
            text: SystemInformation.prettyProductName + " V" + SystemInformation.kernelVersion + " loaded!"
            font.family: myfontBold.name
            font.bold: true
            font.pointSize: 10

            Text {
                id : date
                anchors.left: parent.left
                anchors.top: parent.bottom
                anchors.topMargin: 10
                color : "white"
                text: Qt.formatDateTime(container.dateTime, "ddd - d/M/yy - hh:mm")
                font.pointSize: 18
                font.family: myfontBold.name
                font.bold: true
            }
        }


        //Username Input

        Image {
            id: imageinput
            source: "assets/input.svg"
            y: parent.height / 2 + 8
            anchors.right: parent.right
            anchors.rightMargin: 25
            width: 260
            height: 28

            TextField {
                id: nameinput
                focus: true
                font.family: myfontBold.name
                font.bold: true
                anchors.fill: parent
                text: userModel.lastUser
                font.pointSize: 10
                leftPadding: 8
                color: "#000000"
                selectByMouse: true
                selectionColor: "#22476d"
                selectedTextColor: "#f4f4ff"

                onTextEdited: typingEffect.play()

                Image {
                    id: userPictureCorners
                    anchors.top: userPictureMissing.top
                    anchors.left: userPictureMissing.left
                    anchors.topMargin: 0
                    anchors.leftMargin: 0
                    source: "assets/avatarCorners.svg"
                    width: userPictureMissing.width
                    height: userPictureMissing.height

                    visible: config.boolValue("userAvatarRendering") ? true : false
                }

                Image {
                    id: userPictureMissing
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: -180
                    anchors.topMargin: -40
                    source: "assets/missingTexture.svg"
                    width: 128
                    height:128

                    visible: config.boolValue("userAvatarRendering") ? true : false

                    Image {
                        id: userPicture
                        anchors.top: parent.top
                        source: "/var/lib/AccountsService/icons/" + parent.parent.text
                        width: 128
                        height: 128
                        onStatusChanged: if (userPicture.status == Image.Ready) userPictureMissing.source = "broke"; else if (userPicture.status == Image.Error) userPictureMissing.source = "assets/missingTexture.svg"
                    }
                }

                background: Image {
                    id: textback
                    source: "assets/inputhi.svg"

                    states: [
                        State {
                            name: "yay"
                            PropertyChanges {target: textback; opacity: 1}
                        },
                        State {
                            name: "nay"
                            PropertyChanges {target: textback; opacity: 0}
                        }
                    ]

                    transitions: [
                        Transition {
                            to: "yay"
                            NumberAnimation { target: textback; property: "opacity"; from: 0; to: 1; duration: 200; }
                        },

                        Transition {
                            to: "nay"
                            NumberAnimation { target: textback; property: "opacity"; from: 1; to: 0; duration: 200; }
                        }
                    ]
                }

                KeyNavigation.tab: password
                KeyNavigation.backtab: password

                Keys.onPressed: (event)=> {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        password.focus = true
                    }
                }

                onActiveFocusChanged: {
                    if (activeFocus) {
                        textback.state = "yay"
                    } else {
                        textback.state = "nay"
                    }
                }
            }
        }

        // Password Input

        Image {
            id: imagepassword
            source: "assets/input.svg"
            anchors.top: imageinput.bottom
            anchors.horizontalCenter: imageinput.horizontalCenter
            anchors.topMargin: 4
            width: 260
            height: 28

            TextField {
                id: password
                font.family: myfontNormal.name
                anchors.fill: parent
                font.pointSize: 8
                leftPadding: 8
                echoMode: TextInput.Password
                color: "#000000"
                selectionColor: "#22476d"
                selectedTextColor: "#f4f4ff"

                onTextEdited: typingEffect.play()

                background: Image {
                    id: textback1
                    source: "assets/inputhi.svg"

                    states: [
                        State {
                            name: "yay1"
                            PropertyChanges {target: textback1; opacity: 1}
                        },
                        State {
                            name: "nay1"
                            PropertyChanges {target: textback1; opacity: 0}
                        }
                    ]

                    transitions: [
                        Transition {
                            to: "yay1"
                            NumberAnimation { target: textback1; property: "opacity"; from: 0; to: 1; duration: 200; }
                        },

                        Transition {
                            to: "nay1"
                            NumberAnimation { target: textback1; property: "opacity"; from: 1; to: 0; duration: 200; }
                        }
                    ]
                }

                KeyNavigation.tab: nameinput
                KeyNavigation.backtab: nameinput

                Keys.onPressed: (event)=> {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        loginEffect.play()
                        config.realValue("loginVolume") ? loginTimer.start() : sddm.login(nameinput.text, password.text, sessionIndex)
                        config.boolValue("loginFlickering") ? loginFlicker.restart() : loginFlicker.stop()
                        event.accepted = true
                    }
                }

                onActiveFocusChanged: {
                    if (activeFocus) {
                        textback1.state = "yay1"
                    } else {
                        textback1.state = "nay1"
                    }
                }
            }
        }

        Text {
            id: userlabel
            anchors.left: promptBox.left
            anchors.verticalCenter: imageinput.verticalCenter
            anchors.leftMargin: 160
            font.family: myfontNormal.name
            font.pointSize: 8
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            height: 28
            text: "USER:"
            color: "white"
        }

        Text {
            id: passwordlabel
            anchors.left: promptBox.left
            anchors.bottom: imagepassword.bottom
            anchors.leftMargin: 160
            anchors.topMargin: 1
            font.family: myfontNormal.name
            font.pointSize: 8
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            height: 28
            text: "PASS:"
            color: "white"
        }

        Image {
            id : loginButton
            anchors.right: promptBox.right
            anchors.bottom: promptBox.bottom
            anchors.rightMargin: 12
            anchors.bottomMargin: 8
            width : 78
            height : 26
            source : "assets/buttonup.svg"

            property string toolTipText3: textConstants.login
            ToolTip.text: toolTipText3
            ToolTip.delay: 500
            ToolTip.visible: toolTipText3 ? ma3.containsMouse : false

            MouseArea {
                id: ma3
                anchors.fill: parent
                hoverEnabled: true

                onHoveredChanged: {
                    if (containsMouse) {
                        parent.source = "assets/buttonhover.svg"
                    }
                    else {
                        parent.source = "assets/buttonup.svg"
                    }
                }

                onPressed: parent.source = "assets/buttondown.svg"
                onReleased: parent.source = "assets/buttonup.svg", loginEffect.play(),
                config.realValue("loginVolume") ? loginTimer.start() : sddm.login(nameinput.text, password.text, sessionIndex),
                config.boolValue("loginFlickering") ? loginFlicker.restart() : loginFlicker.stop()

                Timer {
                    id: loginTimer
                    interval: 1500
                    onTriggered: sddm.login(nameinput.text, password.text, sessionIndex)
                }
            }

            Text{
                anchors.centerIn: parent
                color: "#313131"
                font.family: myfontNormal.name
                font.pointSize: 8
                text: textConstants.login
            }
        }

        // Session Selector - Find a way to fix the stupid annoying bug where it gets stuck open

        ComboBox {
            id : session
            anchors.right: loginButton.left
            anchors.bottom: promptBox.bottom
            anchors.rightMargin: 12
            anchors.bottomMargin: 8
            width : 176
            height : 26
            font.pointSize: 8
            font.family : myfontNormal.name
            model : sessionModel
            index : sessionModel.lastIndex
            borderColor : "#212121"
            color : "#a3a3a3"
            menuColor : "#A2A2A2"
            textColor : "black"
            hoverColor : "#FF9C00"
            focusColor : "#595959"
            arrowBox: "assets/comboarrow.svg"
            backgroundNormal: "assets/cbox.svg"
            backgroundHover: "assets/cboxhover.svg"
            backgroundPressed: "assets/cbox.svg"
            KeyNavigation.backtab : password
            KeyNavigation.tab : nameinput
        }

        //Power Options

        Image {
            id : shutdownButton
            anchors.left: promptBox.left
            anchors.bottom: promptBox.bottom
            anchors.leftMargin: 12
            anchors.bottomMargin: 8
            width : 26
            height : 26
            source : "assets/powerup.svg"

            property string toolTipText1: textConstants.shutdown
            ToolTip.text: toolTipText1
            ToolTip.delay: 500
            ToolTip.visible: toolTipText1 ? ma1.containsMouse : false

            MouseArea {
                id: ma1
                anchors.fill : parent
                hoverEnabled : true
                onEntered : {
                    parent.source = "assets/powerhover.svg"
                }
                onExited : {
                    parent.source = "assets/powerup.svg"
                }
                onPressed : {
                    parent.source = "assets/powerdown.svg"
                }
                onReleased : {
                    parent.source = "assets/powerup.svg"
                    clickEffect.play()
                    config.realValue("clickVolume") ? shutdownTimer.start() : sddm.powerOff()
                }
            }
        }

        Image {
            id : rebootButton
            anchors.left: shutdownButton.right
            anchors.bottom: promptBox.bottom
            anchors.leftMargin: 12
            anchors.bottomMargin: 8
            width : 26
            height : 26
            source : "assets/rebootup.svg"

            property string toolTipText2: textConstants.reboot
            ToolTip.text: toolTipText2
            ToolTip.delay: 500
            ToolTip.visible: toolTipText2 ? ma2.containsMouse : false

            MouseArea {
                id: ma2
                anchors.fill : parent
                hoverEnabled : true
                onEntered : {
                    parent.source = "assets/reboothover.svg"
                }
                onExited : {
                    parent.source = "assets/rebootup.svg"
                }
                onPressed : {
                    parent.source = "assets/rebootdown.svg"
                }
                onReleased : {
                    parent.source = "assets/rebootup.svg"
                    clickEffect.play()
                    config.realValue("clickVolume") ? rebootTimer.start() : sddm.reboot()
                }
            }
        }
    } //promptbox

    //Power options timers

    Timer {
        id: shutdownTimer
        interval: 700
        onTriggered: sddm.powerOff()
    }

    Timer {
        id: rebootTimer
        interval: 700
        onTriggered: sddm.reboot()
    }

    Component.onCompleted : {
        nameinput.focus = true
        textback1.state = "nay1"  //dunno why both inputs get focused
    }
}
