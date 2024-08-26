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

#include "clickinstaller.h"
#include "scopehelper.h"

#include <QDebug>

// QtMir life cycle exceptions
#include <QGSettings/QGSettings>
#include <QtCore/QCoreApplication>

#define INSTALL_COMMAND_PROGRAM       "gdbus"
#define INSTALL_COMMAND_ARGS(path)    QStringList() << "call" << "--system" \
                                                    << "--dest" << "com.lomiri.click" \
                                                    << "--object-path" << "/com/lomiri/click" \
                                                    << "--method" << "com.lomiri.click.Install" << path

ClickInstaller::ClickInstaller(QObject *parent)
    : QObject(parent)
    , m_process(nullptr)
    , m_output("")
    , m_errorString("")
    , m_running(false)
{
    // Add this application to the life cycle exceptions list.
    QGSettings exceptions("com.canonical.qtmir", "/com/canonical/qtmir/");
    QStringList appIds = exceptions.get("lifecycle-exempt-appids").toStringList();
    bool lifecycleExempt = appIds.contains(QCoreApplication::applicationName());
    qDebug() << "Was app already allowed to run background?" << lifecycleExempt;

    if (!lifecycleExempt) {
        qDebug() << "Adding an exception in QtMir";
        appIds.append(QCoreApplication::applicationName());
        exceptions.set("lifecycle-exempt-appids", appIds);
    }

    m_process = new QProcess(this);

    connect(m_process, &QProcess::started, [=]() {
        qDebug() << Q_FUNC_INFO << "Started";

        m_running = true;
        Q_EMIT runningChanged();
    });

    connect(m_process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished), [=]() {
        qDebug() << Q_FUNC_INFO << "Exited";

        // Refresh click scope
        ScopeHelper::invalidateScope("clickscope");

        if (m_process->exitCode() != 0) {
            switch(m_process->exitCode()) {
            case 1:
                m_errorString = tr("Failed with miscellaneous internal error.");
                break;
            case 3:
                m_errorString = tr("Failed with syntax error, or failed to parse command.");
                break;
            case 4:
                m_errorString = tr("Failed as a file or directory was not found.");
                break;
            case 5:
                m_errorString = tr("Nothing useful was done.");
                break;
            case 6:
                m_errorString = tr("The initial setup failed, e.g. setting the network proxy.");
                break;
            case 7:
                m_errorString = tr("The transaction failed, see the detailed error for more information.");
                break;
            }
        }

        if (!m_errorString.isEmpty()) {
            Q_EMIT errorStringChanged();
            Q_EMIT error();
        }

        m_running = false;
        Q_EMIT runningChanged();
        Q_EMIT finished();
    });

    connect(m_process, &QProcess::readyReadStandardError, [=]() {
        qDebug() << Q_FUNC_INFO << "Ready read standard error";

        m_errorString = m_process->readAllStandardError();
        Q_EMIT errorStringChanged();
        Q_EMIT error();
    });

    connect(m_process, &QProcess::readyReadStandardOutput, [=]() {
        qDebug() << Q_FUNC_INFO << "Ready read standard output";
        m_output += m_process->readAllStandardOutput();
        Q_EMIT outputChanged();
    });
}

ClickInstaller::~ClickInstaller()
{
    delete m_process;

    // Remove this application from the life cycle exceptions list.
    qDebug() << "Removing the background exception...";
    QGSettings exceptions("com.canonical.qtmir", "/com/canonical/qtmir/");
    QStringList appIds = exceptions.get("lifecycle-exempt-appids").toStringList();

    if (appIds.contains(QCoreApplication::applicationName())) {
        appIds.removeAll(QCoreApplication::applicationName());
        exceptions.set("lifecycle-exempt-appids", appIds);
    }
}

bool ClickInstaller::installAllowUntrusted(const QString &clickPath)
{
    if (m_process && m_running)
        // Another installation has been already started. Return false.
        return false;

    qDebug() << Q_FUNC_INFO << clickPath;

    m_errorString = "";
    Q_EMIT errorStringChanged();

    m_output = "";
    Q_EMIT outputChanged();

    m_process->start(INSTALL_COMMAND_PROGRAM, INSTALL_COMMAND_ARGS(clickPath));
    return true;
}
