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

#include "scopehelper.h"
#include <QDBusInterface>


void ScopeHelper::invalidateScope(const QString &scope)
{
    /*
     * Copyright (C) 2014 Canonical Ltd
     *
     * This program is free software: you can redistribute it and/or modify
     * it under the terms of the GNU General Public License version 3 as
     * published by the Free Software Foundation.
     *
     * This program is distributed in the hope that it will be useful,
     * but WITHOUT ANY WARRANTY; without even the implied warranty of
     * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     * GNU General Public License for more details.
     *
     * You should have received a copy of the GNU General Public License
     * along with this program.  If not, see <http://www.gnu.org/licenses/>.
     *
     * Authors:
     * Diego Sarmentero <diego.sarmentero@canonical.com>
     *
    */

    QDBusMessage signal = QDBusMessage::createSignal(
                "/com/canonical/unity/scopes",
                "com.canonical.unity.scopes",
                "InvalidateResults");
    signal << scope;
    QDBusConnection::sessionBus().send(signal);
}
