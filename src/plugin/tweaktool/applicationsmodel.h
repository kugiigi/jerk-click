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

#ifndef APPLICATIONSMODEL_H
#define APPLICATIONSMODEL_H

#include <QAbstractListModel>
#include <QSettings>

struct AppEntry
{
    bool valid = false;

    QString name;
    QString icon;
    QString exec;
};

typedef QList<AppEntry> AppEntryList;

class ApplicationsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(ApplicationsModel)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        NameRole,
        IconRole,
        ExecRole
    };

    explicit ApplicationsModel(QAbstractListModel *parent = 0);
    virtual ~ApplicationsModel();

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    int rowCount(const QModelIndex & parent = QModelIndex()) const Q_DECL_OVERRIDE;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const Q_DECL_OVERRIDE;

    Q_INVOKABLE QVariantMap get(QString exec) const;
    Q_INVOKABLE void refresh();

Q_SIGNALS:
    void countChanged();

private:
    AppEntry processDesktopFile(QString path);
    QStringList searchDesktopFiles(const QString &path);
    Q_INVOKABLE void finalizeRefresh(const AppEntryList &entriesList);

private:
    AppEntryList m_entries;
};

#endif // APPLICATIONSMODEL_H
