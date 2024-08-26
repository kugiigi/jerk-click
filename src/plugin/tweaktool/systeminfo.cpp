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

#include "systeminfo.h"
#include "singleprocess.h"

#include <QSysInfo>
#include <QHostInfo>

#include <QFile>

QString SystemInfo::kernelVersion() const
{
    return QSysInfo::kernelVersion();
}

QString SystemInfo::buildCpuArchitecture() const
{
    return SingleProcess::launch("uname -p");
}

QString SystemInfo::currentCpuArchitecture() const
{
    return QSysInfo::currentCpuArchitecture();
}

QString SystemInfo::productName() const
{
    return QSysInfo::prettyProductName();
}

QString SystemInfo::currentDesktop() const
{
    return qgetenv("XDG_CURRENT_DESKTOP");
}

QString SystemInfo::deviceName() const
{
    if (QFile::exists("/android/system/build.prop")) {
        // It's an Ubuntu Touch device.

        QString machineInfo = SingleProcess::launch("cat /etc/machine-info");

        Q_FOREACH( const QString &line, machineInfo.split("\n"))
            if (line.contains("PRETTY_HOSTNAME="))
                machineInfo = line;

        machineInfo.replace("PRETTY_HOSTNAME=\"", "");
        machineInfo.remove(machineInfo.count() - 1, 1); // Remove last quote
        return machineInfo;
    }

    return QHostInfo::localHostName();
}

QString SystemInfo::cpuName() const
{
    QString cpuInfo = SingleProcess::launch("cat /proc/cpuinfo | grep 'model name' | uniq");
    QString cpuName;

    Q_FOREACH (const QString &line, cpuInfo.split("\n"))
        if (line.contains("model name"))
            cpuName = line;

    if (cpuName.isEmpty())
        Q_FOREACH (const QString &line, cpuInfo.split("\n"))
            if (line.contains("Hardware"))
                cpuName = line;

    cpuName.replace("model name", "");
    cpuName.replace("Hardware", "");

    return cpuName.trimmed().replace(":", "");
}

int SystemInfo::memoryTotal() const
{
    QFile fi("/proc/meminfo");
    fi.open(QIODevice::ReadOnly);

    int mem = -1;

    QTextStream stream(&fi);
    QString output = stream.readAll();

    QStringList tmp = output.split(" ", QString::SkipEmptyParts);
    mem = tmp.at(tmp.indexOf("MemTotal:") + 1).toInt();

    fi.close();

    return mem;
}
