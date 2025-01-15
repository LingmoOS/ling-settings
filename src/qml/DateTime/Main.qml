/*
 * Copyright (C) 2021 LingmoOS Team.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import LingmoUI 1.0 as LingmoUI
import Lingmo.Settings 1.0
import "../"

ItemPage {
    headerTitle: qsTr("Date & Time")

    TimeZoneDialog {
        id: timeZoneDialog
    }

    TimeZoneMap {
        id: timeZoneMap
    }

    Time {
        id: time
    }

    Scrollable {
        anchors.fill: parent
        contentHeight: layout.implicitHeight

        ColumnLayout {
            id: layout
            anchors.fill: parent
            spacing: LingmoUI.Units.largeSpacing * 2

            Canvas {
                id: analogClock
                width: 200
                height: 200
                anchors.horizontalCenter: parent.horizontalCenter

                onPaint: {
                    var ctx = getContext("2d");
                    var now = new Date();
                    var sec = now.getSeconds();
                    var min = now.getMinutes();
                    var hr = now.getHours();

                    ctx.reset();
                    ctx.clearRect(0, 0, width, height);

                    var gradient = ctx.createRadialGradient(width / 2, height / 2, width / 2 - 8, width / 2, height / 2, width / 2);
                    gradient.addColorStop(0, "#C0C0C0");
                    gradient.addColorStop(1, "#FFFFFF");
                    ctx.strokeStyle = gradient;
                    ctx.lineWidth = 8;
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2, width / 2 - 8, 0, 2 * Math.PI);
                    ctx.stroke();

                    // 绘制表盘背景
                    var bgGradient = ctx.createRadialGradient(width / 2, height / 2, 0, width / 2, height / 2, width / 2 - 10);
                    bgGradient.addColorStop(0, "#FFFFFF");
                    bgGradient.addColorStop(1, "#E0E0E0");
                    ctx.fillStyle = bgGradient;
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2, width / 2 - 10, 0, 2 * Math.PI);
                    ctx.fill();

                    // 绘制刻度
                    ctx.strokeStyle = "#000";
                    for (var i = 0; i < 60; i++) {
                        ctx.save();
                        ctx.translate(width / 2, height / 2);
                        ctx.rotate((Math.PI / 30) * i);
                        ctx.beginPath();
                        ctx.moveTo(0, -width / 2 + 10);
                        if (i % 5 === 0) {
                            ctx.lineWidth = 4; // 每5个刻度加粗
                            ctx.lineTo(0, -width / 2 + 20);
                        } else {
                            ctx.lineWidth = 2;
                            ctx.lineTo(0, -width / 2 + 15);
                        }
                        ctx.stroke();
                        ctx.restore();
                    }

                    // 绘制数字时间
                    ctx.fillStyle = "#FF4C4C4C";
                    ctx.font = "20px sans-serif";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    var timeString = ("0" + hr).slice(-2) + ":" + ("0" + min).slice(-2) + ":" + ("0" + sec).slice(-2);
                    ctx.fillText(timeString, width / 2, height / 2 + width / 4);

                    // 绘制时针
                    ctx.save();
                    ctx.translate(width / 2, height / 2);
                    ctx.rotate((Math.PI / 6) * (hr + min / 60));
                    ctx.strokeStyle = "#000";
                    ctx.lineWidth = 8;
                    ctx.lineCap = "round";
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(0, -width / 4);
                    ctx.stroke();
                    ctx.restore();

                    // 绘制分针
                    ctx.save();
                    ctx.translate(width / 2, height / 2);
                    ctx.rotate((Math.PI / 30) * (min + sec / 60));
                    ctx.strokeStyle = "#000";
                    ctx.lineWidth = 6;
                    ctx.lineCap = "round";
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(0, -width / 3);
                    ctx.stroke();
                    ctx.restore();

                    // 绘制秒针
                    ctx.save();
                    ctx.translate(width / 2, height / 2);
                    ctx.rotate((Math.PI / 30) * sec);
                    ctx.strokeStyle = "#FF0000";
                    ctx.lineWidth = 4;
                    ctx.lineCap = "round";
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(0, -width / 2.5);
                    ctx.stroke();
                    ctx.restore();

                    // 绘制玻璃效果
                    var glassGradient = ctx.createRadialGradient(width / 2, height / 2, 0, width / 2, height / 2, width / 2);
                    glassGradient.addColorStop(0, "rgba(255, 255, 255, 0.4)");
                    glassGradient.addColorStop(1, "rgba(255, 255, 255, 0)");
                    ctx.fillStyle = glassGradient;
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2, width / 2 - 8, 0, 2 * Math.PI);
                    ctx.fill();
                }

                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: analogClock.requestPaint()
                }
            }

            RoundedItem {
                spacing: LingmoUI.Units.largeSpacing * 1.5

                RowLayout {
                    Label {
                        text: qsTr("Auto Sync")
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Switch {
                        Layout.fillHeight: true
                        rightPadding: 0
                        rightInset: 0
                        checked: time.useNtp
                        onCheckedChanged: time.useNtp = checked
                    }
                }

                RowLayout {
                    Label {
                        text: qsTr("24-Hour Time")
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Switch {
                        Layout.fillHeight: true
                        rightPadding: 0
                        rightInset: 0
                        checked: time.twentyFour
                        onCheckedChanged: time.twentyFour = checked
                    }
                }
            }

            StandardButton {
                Layout.fillWidth: true
                text: ""
                // onClicked: timeZoneDialog.visibility = "Maximized"
                onClicked: timeZoneDialog.show()

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: LingmoUI.Units.largeSpacing * 1.5
                    anchors.rightMargin: LingmoUI.Units.largeSpacing * 1.5

                    Label {
                        text: qsTr("Time Zone")
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: timeZoneMap.currentTimeZone
                    }
                }
            }
        }
    }
}
