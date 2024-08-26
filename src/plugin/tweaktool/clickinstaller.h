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

#ifndef CLICKINSTALLER_H
#define CLICKINSTALLER_H

#include <QObject>
#include <QProcess>

class ClickInstaller : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString output READ output NOTIFY outputChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)

public:
    explicit ClickInstaller(QObject *parent = 0);
    ~ClickInstaller();

    QString output() const { return m_output; }
    QString errorString() const { return m_errorString; }
    bool running() const { return m_running; }

    Q_INVOKABLE bool installAllowUntrusted(const QString &clickPath);

Q_SIGNALS:
    void outputChanged();
    void errorStringChanged();
    void runningChanged();
    void error();
    void finished();

private:
    QProcess *m_process;
    QString m_output;
    QString m_errorString;
    bool m_running;
};

#endif // CLICKINSTALLER_H
