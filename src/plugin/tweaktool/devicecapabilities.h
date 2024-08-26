/*
  This file is part of ut-tweak-tool
  Copyright (C) 2016 Stefano Verzegnassi

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License 3 as published by
  the Free Software Foundation.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see http://www.gnu.org/licenses/.
*/

#ifndef DEVICECAPABILITIES_H
#define DEVICECAPABILITIES_H

#include <QObject>

class DeviceCapabilities : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool hasBattery READ hasBattery CONSTANT)
    Q_PROPERTY(bool isAndroidDevice READ isAndroidDevice CONSTANT)

public:
    bool hasBattery() const;
    bool isAndroidDevice() const;
};

#endif // DEVICECAPABILITIES_H
