/*
  Copyright (C) 2015, 2016 Stefano Verzegnassi

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

#include "applicationsmodel.h"
#include "desktopfileutils.h"

#include <QDir>
#include <QDirIterator>
#include <QSettings>
#include <QFileInfo>

#include <QDebug>

ApplicationsModel::ApplicationsModel(QAbstractListModel *parent)
    : QAbstractListModel(parent)
{
    qRegisterMetaType<AppEntryList>("AppEntryList");
    refresh();
}

ApplicationsModel::~ApplicationsModel()
{ }

QHash<int, QByteArray> ApplicationsModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles.insert(NameRole, "name");
    roles.insert(IconRole, "icon");
    roles.insert(ExecRole, "exec");

    return roles;
}

int ApplicationsModel::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent)
    return m_entries.count();
}

QVariant ApplicationsModel::data(const QModelIndex & index, int role) const
{
    if (index.row() < 0 || index.row() > m_entries.count())
        return QVariant();

    const AppEntry &appEntry = m_entries.at(index.row());

    switch (role) {
    case NameRole:
        return appEntry.name;
    case IconRole:
        return appEntry.icon;
    case ExecRole:
        return appEntry.exec;

    default:
        return 0;
    }
}

void ApplicationsModel::refresh()
{
    qDebug() << Q_FUNC_INFO << "called";

    beginResetModel();
    m_entries.clear();
    endResetModel();

    QStringList desktopFiles;

    desktopFiles << searchDesktopFiles(DESKTOP_FILES_FOLDER_USER);
    desktopFiles << searchDesktopFiles(DESKTOP_FILES_FOLDER_SYSTEM);

    Q_FOREACH(const QString &path, desktopFiles) {
        AppEntry entry = processDesktopFile(path);

        if (entry.valid) {
            beginInsertRows(QModelIndex(), rowCount(), rowCount());
            m_entries.append(entry);
            endInsertRows();
        }
    }
}

QVariantMap ApplicationsModel::get(QString exec) const
{
    QVariantMap map;

    Q_FOREACH(const AppEntry &entry, m_entries) {
        if (entry.exec == exec) {
            map["name"] = entry.name;
            map["icon"] = entry.icon;
            map["exec"] = entry.exec;

            break;
        }
    }

    return map;
}

AppEntry ApplicationsModel::processDesktopFile(QString path)
{
    QSettings appInfo(path, QSettings::IniFormat);
    appInfo.setIniCodec("UTF-8");

    AppEntry appEntry;

    if (DesktopFileUtils::isDesktopFileVisible(appInfo)) {
        appEntry.name = DesktopFileUtils::getNameFromDesktopFile(appInfo);
        appEntry.icon = DesktopFileUtils::getIconFromDesktopFile(appInfo);
        appEntry.exec = DesktopFileUtils::getExecFromDesktopFile(appInfo);
        appEntry.valid = true;
    }

    return appEntry;
}

QStringList ApplicationsModel::searchDesktopFiles(const QString &path)
{
    QDirIterator dir(path, QDir::Files | QDir::NoDotAndDotDot | QDir::Readable,
                     QDirIterator::Subdirectories);

    QStringList results;
    QRegExp rx;

    while (dir.hasNext()) {
        dir.next();

        rx = QRegExp(QString("*.desktop"), Qt::CaseInsensitive);
        rx.setPatternSyntax(QRegExp::Wildcard);

        if (rx.exactMatch(dir.fileName()))
            results.append(dir.fileInfo().absoluteFilePath());
    }

    return results;
}
