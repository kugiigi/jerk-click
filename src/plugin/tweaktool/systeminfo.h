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

#ifndef SYSTEMINFO_H
#define SYSTEMINFO_H

#include <QObject>

class SystemInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString kernelVersion READ kernelVersion CONSTANT)
    Q_PROPERTY(QString buildCpuArchitecture READ buildCpuArchitecture CONSTANT)
    Q_PROPERTY(QString currentCpuArchitecture READ currentCpuArchitecture CONSTANT)
    Q_PROPERTY(QString productName READ productName CONSTANT)
    Q_PROPERTY(QString currentDesktop READ currentDesktop CONSTANT)
    Q_PROPERTY(QString deviceName READ deviceName CONSTANT)
    Q_PROPERTY(QString cpuName READ cpuName CONSTANT)
    Q_PROPERTY(int memoryTotal READ memoryTotal CONSTANT)

public:
    // Return the kernel version
    QString kernelVersion() const;

    // Return the CPU architecture that Qt was compiled for (may not match the actual CPU arch)
    QString buildCpuArchitecture() const;

    // Return the CPU architecture that the application is running on
    QString currentCpuArchitecture() const;

    // Return the Linux distro name (i.e. cat /etc/os-release | grep \"VERSION=\")
    QString productName() const;

    QString currentDesktop() const;
    QString deviceName() const;
    QString cpuName() const;
    int memoryTotal() const;

};

#endif // SYSTEMINFO_H
