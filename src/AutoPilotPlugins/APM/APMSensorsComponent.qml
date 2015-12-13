/*=====================================================================

 QGroundControl Open Source Ground Control Station

 (c) 2009 - 2015 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>

 This file is part of the QGROUNDCONTROL project

 QGROUNDCONTROL is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 QGROUNDCONTROL is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with QGROUNDCONTROL. If not, see <http://www.gnu.org/licenses/>.

 ======================================================================*/

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Controllers 1.0

QGCView {
    id:         rootQGCView
    viewPanel:  panel

    // Help text which is shown both in the status text area prior to pressing a cal button and in the
    // pre-calibration dialog.

    readonly property string boardRotationText: "If the autopilot is mounted in flight direction, leave the default value (None)"
    readonly property string compassRotationText: "If the compass or GPS module is mounted in flight direction, leave the default value (None)"

    readonly property string compassHelp:   "For Compass calibration you will need to rotate your vehicle through a number of positions. Most users prefer to do this wirelessly with the telemetry link."
    readonly property string gyroHelp:      "For Gyroscope calibration you will need to place your vehicle on a surface and leave it still."
    readonly property string accelHelp:     "For Accelerometer calibration you will need to place your vehicle on all six sides on a perfectly level surface and hold it still in each orientation for a few seconds."
    readonly property string levelHelp:     "To level the horizon you need to place the vehicle in its level flight position and press OK."
    readonly property string airspeedHelp:  "For Airspeed calibration you will need to keep your airspeed sensor out of any wind and then blow across the sensor."

    readonly property string statusTextAreaDefaultText: "Start the individual calibration steps by clicking one of the buttons above."

    // Used to pass what type of calibration is being performed to the preCalibrationDialog
    property string preCalibrationDialogType

    // Used to pass help text to the preCalibrationDialog dialog
    property string preCalibrationDialogHelp

    readonly property int sideBarH1PointSize:  ScreenTools.mediumFontPixelSize
    readonly property int mainTextH1PointSize: ScreenTools.mediumFontPixelSize // Seems to be unused

    readonly property int rotationColumnWidth: 250
    readonly property var rotations: [
        "None",
        "Yaw 45",
        "Yaw 90",
        "Yaw 135",
        "Yaw 180",
        "Yaw 225",
        "Yaw 270",
        "Yaw 315",
        "Roll 180",
        "Roll 180. Yaw 45",
        "Roll 180. Yaw 90",
        "Roll 180. Yaw 135",
        "Pitch 180",
        "Roll 180. Yaw 225",
        "Roll 180, Yaw 270",
        "Roll 180, Yaw 315",
        "Roll 90",
        "Roll 90, Yaw 45",
        "Roll 90, Yaw 90",
        "Roll 90, Yaw 135",
        "Roll 270",
        "Roll 270, Yaw 45",
        "Roll 270, Yaw 90",
        "Roll 270, Yaw 136",
        "Pitch 90",
        "Pitch 270",
        "Pitch 180, Yaw 90",
        "Pitch 180, Yaw 270",
        "Roll 90, Pitch 90",
        "Roll 180, Pitch 90",
        "Roll 270, Pitch 90",
        "Roll 90, Pitch 180",
        "Roll 270, Pitch 180",
        "Roll 90, Pitch 270",
        "Roll 180, Pitch 270",
        "Roll 270, Pitch 270",
        "Roll 90, Pitch 180, Yaw 90",
        "Roll 90, Yaw 270",
        "Yaw 293, Pitch 68, Roll 90",
    ]

    property Fact cal_mag0_id:      controller.getParameterFact(-1, "COMPASS_DEV_ID")
    property Fact cal_mag1_id:      controller.getParameterFact(-1, "COMPASS_DEV_ID2")
    property Fact cal_mag2_id:      controller.getParameterFact(-1, "COMPASS_DEV_ID3")
    property Fact cal_mag0_rot:     controller.getParameterFact(-1, "COMPASS_ORIENT")
    property Fact cal_mag1_rot:     controller.getParameterFact(-1, "COMPASS_ORIENT2")
    property Fact cal_mag2_rot:     controller.getParameterFact(-1, "COMPASS_ORIENT3")

    property Fact sens_board_rot:   controller.getParameterFact(-1, "AHRS_ORIENTATION")

    /*
    property Fact cal_gyro0_id:     controller.getParameterFact(-1, "CAL_GYRO0_ID")
    property Fact cal_acc0_id:      controller.getParameterFact(-1, "CAL_ACC0_ID")

    property Fact sens_board_x_off: controller.getParameterFact(-1, "SENS_BOARD_X_OFF")
    property Fact sens_dpres_off:   controller.getParameterFact(-1, "SENS_DPRES_OFF")
    */

    property Fact ins_accoffs_x:    controller.getParameterFact(-1, "INS_ACCOFFS_X")
    property Fact ins_accoffs_y:    controller.getParameterFact(-1, "INS_ACCOFFS_Y")
    property Fact ins_accoffs_z:    controller.getParameterFact(-1, "INS_ACCOFFS_Z")

    property Fact compass_ofs_x:    controller.getParameterFact(-1, "COMPASS_OFS_X")
    property Fact compass_ofs_y:    controller.getParameterFact(-1, "COMPASS_OFS_Y")
    property Fact compass_ofs_z:    controller.getParameterFact(-1, "COMPASS_OFS_Z")

    property bool accelCalNeeded:   ins_accoffs_x.value == 0 && ins_accoffs_y.value == 0 && ins_accoffs_z.value == 0
    property bool compassCalNeeded: compass_ofs_x.value == 0 && compass_ofs_y.value == 0 && compass_ofs_y.value == 0

    // Id > = signals compass available, rot < 0 signals internal compass
    property bool showCompass0Rot: cal_mag0_id.value > 0 && cal_mag0_rot.value >= 0
    property bool showCompass1Rot: cal_mag1_id.value > 0 && cal_mag1_rot.value >= 0
    property bool showCompass2Rot: cal_mag2_id.value > 0 && cal_mag2_rot.value >= 0

    APMSensorsComponentController {
        id:                         controller
        factPanel:                  panel
        statusLog:                  statusTextArea
        progressBar:                progressBar
        compassButton:              compassButton
        accelButton:                accelButton
        nextButton:                 nextButton
        cancelButton:               cancelButton
        orientationCalAreaHelpText: orientationCalAreaHelpText

        onResetStatusTextArea: statusLog.text = statusTextAreaDefaultText

        onSetCompassRotations: {
            if (showCompass0Rot || showCompass1Rot || showCompass2Rot) {
            showDialog(compassRotationDialogComponent, "Set Compass Rotation(s)", 50, StandardButton.Ok)
            }
        }

        onWaitingForCancelChanged: {
            if (controller.waitingForCancel) {
                showMessage("Calibration Cancel", "Waiting for Vehicle to response to Cancel. This may take a few seconds.", 0)
            } else {
                hideDialog()
            }
        }
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: panel.enabled }

    Component {
        id: preCalibrationDialogComponent

        QGCViewDialog {
            id: preCalibrationDialog

            function accept() {
                if (preCalibrationDialogType == "gyro") {
                    controller.calibrateGyro()
                } else if (preCalibrationDialogType == "accel") {
                    controller.calibrateAccel()
                } else if (preCalibrationDialogType == "level") {
                    controller.calibrateLevel()
                } else if (preCalibrationDialogType == "compass") {
                    controller.calibrateCompass()
                } else if (preCalibrationDialogType == "airspeed") {
                    controller.calibrateAirspeed()
                }
                preCalibrationDialog.hideDialog()
            }

            Column {
                anchors.fill: parent
                spacing:                5

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       preCalibrationDialogHelp
                }

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    visible:    (preCalibrationDialogType != "airspeed") && (preCalibrationDialogType != "gyro")
                    text:       boardRotationText
                }

                FactComboBox {
                    width:      rotationColumnWidth
                    model:      rotations
                    visible:    preCalibrationDialogType != "airspeed" && (preCalibrationDialogType != "gyro")
                    fact:       sens_board_rot
                }
            }
        }
    }

    Component {
        id: compassRotationDialogComponent

        QGCViewDialog {
            id: compassRotationDialog

            Column {
                anchors.fill: parent
                spacing:      ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       compassRotationText
                }

                // Compass 0 rotation
                Component {
                    id: compass0ComponentLabel

                    QGCLabel {
                        font.pixelSize: sideBarH1PointSize
                        text: "External Compass Orientation"
                    }

                }
                Component {
                    id: compass0ComponentCombo

                    FactComboBox {
                        id:     compass0RotationCombo
                        width:  rotationColumnWidth
                        model:  rotations
                        fact:   cal_mag0_rot
                    }
                }
                Loader { sourceComponent: showCompass0Rot ? compass0ComponentLabel : null }
                Loader { sourceComponent: showCompass0Rot ? compass0ComponentCombo : null }
                // Compass 1 rotation
                Component {
                    id: compass1ComponentLabel

                    QGCLabel { text: "Compass 1 Orientation" }
                }
                Component {
                    id: compass1ComponentCombo

                    FactComboBox {
                        id:     compass1RotationCombo
                        width:  rotationColumnWidth
                        model:  rotations
                        fact:   cal_mag1_rot
                    }
                }
                Loader { sourceComponent: showCompass1Rot ? compass1ComponentLabel : null }
                Loader { sourceComponent: showCompass1Rot ? compass1ComponentCombo : null }

                // Compass 2 rotation
                Component {
                    id: compass2ComponentLabel

                    QGCLabel { text: "Compass 2 Orientation" }
                }
                Component {
                    id: compass2ComponentCombo

                    FactComboBox {
                        id:     compass1RotationCombo
                        width:  rotationColumnWidth
                        model:  rotations
                        fact:   cal_mag2_rot
                    }
                }
                Loader { sourceComponent: showCompass2Rot ? compass2ComponentLabel : null }
                Loader { sourceComponent: showCompass2Rot ? compass2ComponentCombo : null }
            } // Column
        } // QGCViewDialog
    } // Component - compassRotationDialogComponent

    QGCViewPanel {
        id:             panel
        anchors.fill:   parent

        Column {
            anchors.fill: parent

            Row {
                readonly property int buttonWidth: ScreenTools.defaultFontPixelWidth * 15

                spacing: ScreenTools.defaultFontPixelWidth

                QGCLabel { text: "Calibrate:"; anchors.baseline: compassButton.baseline }

                IndicatorButton {
                    id:             compassButton
                    width:          parent.buttonWidth
                    text:           "Compass - NYI"
                    indicatorGreen: !compassCalNeeded

                    onClicked: {
                        preCalibrationDialogType = "compass"
                        preCalibrationDialogHelp = compassHelp
                        showDialog(preCalibrationDialogComponent, "Calibrate Compass", 50, StandardButton.Cancel | StandardButton.Ok)
                    }
                }

                IndicatorButton {
                    id:             accelButton
                    width:          parent.buttonWidth
                    text:           "Accelerometer"
                    indicatorGreen: !accelCalNeeded

                    onClicked: {
                        preCalibrationDialogType = "accel"
                        preCalibrationDialogHelp = accelHelp
                        showDialog(preCalibrationDialogComponent, "Calibrate Accelerometer", 50, StandardButton.Cancel | StandardButton.Ok)
                    }
                }
                QGCButton {
                    id:         nextButton
                    showBorder: true
                    text:       "Next"
                    enabled:    false
                    onClicked:  controller.nextClicked()
                }

                QGCButton {
                    id:         cancelButton
                    showBorder: true
                    text:       "Cancel"
                    enabled:    false
                    onClicked:  controller.cancelCalibration()
                }
            }

            Item { height: ScreenTools.defaultFontPixelHeight; width: 10 } // spacer

            ProgressBar {
                id: progressBar
                width: parent.width - rotationColumnWidth
            }

            Item { height: ScreenTools.defaultFontPixelHeight; width: 10 } // spacer

            Item {
                property int calDisplayAreaWidth: parent.width - rotationColumnWidth

                width:  parent.width
                height: parent.height - y

                TextArea {
                    id:             statusTextArea
                    width:          parent.calDisplayAreaWidth
                    height:         parent.height
                    readOnly:       true
                    frameVisible:   false
                    text:           statusTextAreaDefaultText

                    style: TextAreaStyle {
                        textColor: qgcPal.text
                        backgroundColor: qgcPal.windowShade
                    }
                }

                Rectangle {
                    id:         orientationCalArea
                    width:      parent.calDisplayAreaWidth
                    height:     parent.height
                    visible:    controller.showOrientationCalArea
                    color:      qgcPal.windowShade

                    QGCLabel {
                        id:                 orientationCalAreaHelpText
                        anchors.margins:    ScreenTools.defaultFontPixelWidth
                        anchors.top:        orientationCalArea.top
                        anchors.left:       orientationCalArea.left
                        width:              parent.width
                        wrapMode:           Text.WordWrap
                        font.pixelSize:     ScreenTools.mediumFontPixelSize
                    }

                    Flow {
                        anchors.topMargin:  ScreenTools.defaultFontPixelWidth
                        anchors.top:        orientationCalAreaHelpText.bottom
                        anchors.left:       orientationCalAreaHelpText.left
                        width:              parent.width
                        height:             parent.height - orientationCalAreaHelpText.implicitHeight
                        spacing:            ScreenTools.defaultFontPixelWidth

                        VehicleRotationCal {
                            visible:            controller.orientationCalDownSideVisible
                            calValid:           controller.orientationCalDownSideDone
                            calInProgress:      controller.orientationCalDownSideInProgress
                            calInProgressText:  controller.orientationCalDownSideRotate ? "Rotate" : "Hold Still"
                            imageSource:        controller.orientationCalDownSideRotate ? "qrc:///qmlimages/VehicleDownRotate.png" : "qrc:///qmlimages/VehicleDown.png"
                        }
                        VehicleRotationCal {
                            visible:            controller.orientationCalUpsideDownSideVisible
                            calValid:           controller.orientationCalUpsideDownSideDone
                            calInProgress:      controller.orientationCalUpsideDownSideInProgress
                            calInProgressText:  controller.orientationCalUpsideDownSideRotate ? "Rotate" : "Hold Still"
                            imageSource:        "qrc:///qmlimages/VehicleUpsideDown.png"
                        }
                        VehicleRotationCal {
                            visible:            controller.orientationCalNoseDownSideVisible
                            calValid:           controller.orientationCalNoseDownSideDone
                            calInProgress:      controller.orientationCalNoseDownSideInProgress
                            calInProgressText:  controller.orientationCalNoseDownSideRotate ? "Rotate" : "Hold Still"
                            imageSource:        controller.orientationCalNoseDownSideRotate ? "qrc:///qmlimages/VehicleNoseDownRotate.png" : "qrc:///qmlimages/VehicleNoseDown.png"
                        }
                        VehicleRotationCal {
                            visible:            controller.orientationCalTailDownSideVisible
                            calValid:           controller.orientationCalTailDownSideDone
                            calInProgress:      controller.orientationCalTailDownSideInProgress
                            calInProgressText:  controller.orientationCalTailDownSideRotate ? "Rotate" : "Hold Still"
                            imageSource:        "qrc:///qmlimages/VehicleTailDown.png"
                        }
                        VehicleRotationCal {
                            visible:            controller.orientationCalLeftSideVisible
                            calValid:           controller.orientationCalLeftSideDone
                            calInProgress:      controller.orientationCalLeftSideInProgress
                            calInProgressText:  controller.orientationCalLeftSideRotate ? "Rotate" : "Hold Still"
                            imageSource:        controller.orientationCalLeftSideRotate ? "qrc:///qmlimages/VehicleLeftRotate.png" : "qrc:///qmlimages/VehicleLeft.png"
                        }
                        VehicleRotationCal {
                            visible:            controller.orientationCalRightSideVisible
                            calValid:           controller.orientationCalRightSideDone
                            calInProgress:      controller.orientationCalRightSideInProgress
                            calInProgressText:  controller.orientationCalRightSideRotate ? "Rotate" : "Hold Still"
                            imageSource:        "qrc:///qmlimages/VehicleRight.png"
                        }
                    }
                }

                Column {
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth
                    anchors.left:       orientationCalArea.right
                    x:                  parent.width - rotationColumnWidth
                    spacing:            ScreenTools.defaultFontPixelWidth

                    Column {
                        spacing: ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            font.pixelSize: sideBarH1PointSize
                            text: "Autopilot Orientation"
                        }

                        QGCLabel {
                            width:      parent.width
                            wrapMode:   Text.WordWrap
                            text: boardRotationText
                        }

                        FactComboBox {
                            id:     boardRotationCombo
                            width:  rotationColumnWidth;
                            model:  rotations
                            fact:   sens_board_rot
                        }
                    }

                    Column {
                        spacing: ScreenTools.defaultFontPixelWidth

                        // Compass 0 rotation
                        Component {
                            id: compass0ComponentLabel2

                            QGCLabel {
                                font.pixelSize: sideBarH1PointSize
                                text: "External Compass Orientation"
                            }
                        }

                        Component {
                            id: compass0ComponentCombo2

                            FactComboBox {
                                id:     compass0RotationCombo
                                width:  rotationColumnWidth
                                model:  rotations
                                fact:   cal_mag0_rot
                            }
                        }

                        Loader { sourceComponent: showCompass0Rot ? compass0ComponentLabel2 : null }
                        Loader { sourceComponent: showCompass0Rot ? compass0ComponentCombo2 : null }
                    }

                    Column {
                        spacing: ScreenTools.defaultFontPixelWidth

                        // Compass 1 rotation
                        Component {
                            id: compass1ComponentLabel2

                            QGCLabel {
                                font.pixelSize: sideBarH1PointSize
                                text: "External Compass 1 Orientation"
                            }
                        }

                        Component {
                            id: compass1ComponentCombo2

                            FactComboBox {
                                id:     compass1RotationCombo
                                width:  rotationColumnWidth
                                model:  rotations
                                fact:   cal_mag1_rot
                            }
                        }

                        Loader { sourceComponent: showCompass1Rot ? compass1ComponentLabel2 : null }
                        Loader { sourceComponent: showCompass1Rot ? compass1ComponentCombo2 : null }
                    }

                    Column {
                        spacing: ScreenTools.defaultFontPixelWidth

                        // Compass 2 rotation
                        Component {
                            id: compass2ComponentLabel2

                            QGCLabel {
                                font.pixelSize: sidebarH1PointSize
                                text: "Compass 2 Orientation"
                            }
                        }

                        Component {
                            id: compass2ComponentCombo2

                            FactComboBox {
                                id:     compass1RotationCombo
                                width:  rotationColumnWidth
                                model:  rotations
                                fact:   cal_mag2_rot
                            }
                        }
                        Loader { sourceComponent: showCompass2Rot ? compass2ComponentLabel2 : null }
                        Loader { sourceComponent: showCompass2Rot ? compass2ComponentCombo2 : null }
                    }
                }
            }
        }
    } // QGCViewPanel
} // QGCView
