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

#ifndef SYSTEMFILE_H
#define SYSTEMFILE_H

#include <QObject>
#include <QFile>
#include <QProcess>

class SystemFile : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filename READ filename WRITE setFilename NOTIFY filenameChanged)
    Q_PROPERTY(bool exists READ exists NOTIFY existsChanged)

public:
    explicit SystemFile(QObject *parent = 0);

    QString filename() const;
    void setFilename(const QString &filename);

    bool exists() const;

public slots:
    void touch();
    void rm();

    void providePassword(const QString &password);
    void cancel();

signals:
    void filenameChanged();
    void existsChanged();

    void passwordRequested();

private slots:
    void processReadyRead();
    void processFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    QFile m_file;
    QProcess *m_process;
};

#endif // SYSTEMFILE_H
