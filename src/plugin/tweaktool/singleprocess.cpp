/*
  This file is part of ut-tweak-tool
  Copyright (C) 2015 Stefano Verzegnassi

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

#include "singleprocess.h"
#include <QProcess>
#include <QTextStream>

QString SingleProcess::launch(QString command, bool inc_stderr) {
    QProcess p;

    p.start(command, QIODevice::ReadOnly);
    // Wait for process to finish
    p.waitForFinished(-1);

    QByteArray bytes = p.readAllStandardOutput();
    if (inc_stderr) bytes += p.readAllStandardError();
    QString output = QString::fromLocal8Bit(bytes).trimmed();

    return output;
}

