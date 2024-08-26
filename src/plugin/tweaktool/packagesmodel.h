/*
  This file is part of ut-tweak-tool
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

#ifndef PACKAGESMODEL_H
#define PACKAGESMODEL_H


#include <QAbstractListModel>
#include <QJsonObject>

class Package;
class QProcess;

typedef QList<Package*> PackageList;

class PackagesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(PackagesModel)
    Q_ENUMS(ShowFilters)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
    Q_PROPERTY(ShowFilters showFilter MEMBER m_showFilter NOTIFY showFilterChanged)

public:
    enum Roles {
        AppIdRole,
        DirectoryRole,
        IsRemovableRole,
        ArchitectureRole,
        DescriptionRole,
        FrameworkRole,
        IconPathRole,
        MaintainerRole,
        TitleRole,
        VersionRole
    };

    enum ShowFilters {
        ShowAll,
        ShowAppsOnly,
        ShowScopesOnly
    };

    explicit PackagesModel(QAbstractListModel *parent = 0);
    virtual ~PackagesModel();

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    int rowCount(const QModelIndex & parent = QModelIndex()) const Q_DECL_OVERRIDE;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;

    bool ready() const { return m_ready; }

    Q_INVOKABLE void refresh();

    Q_INVOKABLE Package* get(int index) const;
    Q_INVOKABLE Package* get(const QString &appId) const;

    Q_INVOKABLE void uninstallPackage(int index);
    Q_INVOKABLE void uninstallPackage(Package *package);

Q_SIGNALS:
    void countChanged();
    void showFilterChanged();
    void readyChanged();

private:
    Package* processPackage(const QJsonObject &pkg);
    Q_INVOKABLE void finalizeRefresh();
    void appendSystemApps();

private:
    QProcess* m_clickProcess;
    PackageList m_packagesList;
    ShowFilters m_showFilter;
    bool m_ready;
};

#endif // PACKAGESMODEL_H
