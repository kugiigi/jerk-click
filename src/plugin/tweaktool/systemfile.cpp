/*****************************************************************************
 * Copyright: 2015 Michael Zanetti <michael_zanetti@gmx.net>                 *
 *                                                                           *
 * This file is part of tweakgeek                                            *
 *                                                                           *
 * This prject is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, version 3 of the License.                   *
 *                                                                           *
 * This project is distributed in the hope that it will be useful,           *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                           *
 ****************************************************************************/

#include "systemfile.h"
#include <iostream>
using namespace std;

SystemFile::SystemFile(QObject *parent) :
    QObject(parent),
    m_process(0)
{
}

QString SystemFile::filename() const
{
    return m_file.fileName();
}

void SystemFile::setFilename(const QString &filename)
{
    if (m_file.fileName() != filename) {
        m_file.setFileName(filename);
        emit filenameChanged();
        emit existsChanged();
    }
}

bool SystemFile::exists() const
{
    return m_file.exists();
}

void SystemFile::touch()
{
    if (m_process) {
        return;
    }
    m_process = new QProcess(this);
    connect(m_process, &QProcess::readyReadStandardError, this, &SystemFile::processReadyRead);
    connect(m_process, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(processFinished(int,QProcess::ExitStatus)));
    m_process->start("sudo", QStringList() << "-S" << "-p" << "pwdprompt" << "touch" << m_file.fileName());
}

void SystemFile::rm()
{
    if (m_process) {
        return;
    }
    m_process = new QProcess(this);
    connect(m_process, &QProcess::readyReadStandardError, this, &SystemFile::processReadyRead);
    connect(m_process, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(processFinished(int,QProcess::ExitStatus)));
    m_process->start("sudo", QStringList() << "-S" << "-p" << "pwdprompt" << "rm" << m_file.fileName());
}

void SystemFile::providePassword(const QString &password)
{
    if (m_process) {
        m_process->write(password.toLatin1());
        m_process->write("\n");
        cout << "password provided" << endl;
    }
}

void SystemFile::cancel()
{
    if (m_process) {
        m_process->kill();
        m_process->deleteLater();
        m_process = 0;
        cout << "cancelled" << endl;
    }
}

void SystemFile::processReadyRead()
{
    QByteArray data = m_process->readAllStandardError();
    cout << "data:" << data.data() << endl;
    if (data == "pwdprompt") {
        emit passwordRequested();
    }
}

void SystemFile::processFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    cout << "process finished" << exitCode << exitStatus << endl;
    m_process->deleteLater();
    m_process = 0;
    emit existsChanged();
}
