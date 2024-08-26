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

#include <QtQml>
#include <QtQml/QQmlContext>
#include "backend.h"
#include "systemfile.h"
#include "singleprocess.h"
#include "applicationsmodel.h"
#include "packagesmodel.h"
#include "package_p.h"
#include "scopehelper.h"
#include "devicecapabilities.h"
#include "clickinstaller.h"
#include "storagemanager.h"
#include "systeminfo.h"

static QObject *registerStorageManager(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    StorageManager *storage = new StorageManager();
    return storage;
}

static QObject *registerSingletonProcess (QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    auto process = new SingleProcess();
    return process;
}

static QObject *registerSingletonScopeHelper (QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    auto scopeHelper = new ScopeHelper();
    return scopeHelper;
}

static QObject *registerSingletonDeviceCapabilities (QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    auto deviceCapabilities = new DeviceCapabilities();
    return deviceCapabilities;
}

void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("TweakTool"));

    qmlRegisterSingletonType<SingleProcess>(uri, 1, 0, "Process", registerSingletonProcess);
    qmlRegisterSingletonType<ScopeHelper>(uri, 1, 0, "ScopeHelper", registerSingletonScopeHelper);
    qmlRegisterSingletonType<DeviceCapabilities>(uri, 1, 0, "DeviceCapabilities", registerSingletonDeviceCapabilities);
    qmlRegisterSingletonType<StorageManager>(uri, 1, 0, "StorageManager", registerStorageManager);
    qmlRegisterType<SystemFile>(uri, 1, 0, "SystemFile");
    qmlRegisterType<ApplicationsModel>(uri, 1, 0, "ApplicationsModel");
    qmlRegisterType<SystemInfo>(uri, 1, 0, "SystemInfo");
    qmlRegisterType<PackagesModel>(uri, 1, 0, "PackagesModel");
    qmlRegisterType<ClickInstaller>(uri, 1, 0, "ClickInstaller");
    qmlRegisterUncreatableType<Package>(uri, 1, 0, "Package", "Package can only be created by PackagesModel, through the get(index) method.");
}

void BackendPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}

