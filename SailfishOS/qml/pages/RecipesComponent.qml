/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../DbLayer/OliveDb/Persistance.js" as DB

//this page shows recipes to shop
//each click increases howMany by 1
//longpress shows context menu with reset to 0
//swipe to left or right (cancel / ok) will store items to db and update shoppingList

SilicaListView {
    id: page
    property string itemType

    // value of search..
    property string searchString
    onSearchStringChanged: filterPage(searchString)

    anchors.fill: parent

    function doAccept() {
        applicationWindow.page.initPage()
    }

    // should be obsolete
    // user has rejected editing entry data, check if there are unsaved details
    function doReject() {
        applicationWindow.page.initPage()
    }

    Component.onCompleted: { initPage();}

    function initPage()
    {
        var items = DB.getDatabase().getRecipes()
        itemModel.clear()
        fillItemsModel(items)
    }

    function filterPage(nameFilter)
    {
        var items = DB.getDatabase().filterRecipesByName(nameFilter)
        itemModel.clear()
        fillItemsModel(items)
    }

    function fillItemsModel(items)
    {
        print('number of items: ' +  items.length)
        for (var i = 0; i < items.length; i++)
        {
            itemModel.append({"uid": items[i].uid, "name": items[i].name, "servings": items[i].servings, "instruction": items[i].instruction, "ingredients": items[i].ingredients, "howMany": items[i].howMany, "type": items[i].type })
        }
    }

    Column {
        id: headerContainer
        width: parent.width

        SearchField {
            id: searchField
            width: parent.width
            opacity: 1

            Binding {
                target: page
                property: "searchString"
                value: searchField.text.toLowerCase().trim()
            }
        }
    }

    SilicaListView {
        id: itemList
        anchors.fill: parent
        anchors.topMargin: searchField.height

        model: itemModel
        VerticalScrollDecorator { flickable: itemList }

        ViewPlaceholder {
            enabled: itemModel.count === 0 // show placeholder text when no locations/artists are tracked
            text: qsTr("No recipes")
        }

        delegate: ListItem {
            id: listItem

            RecipeListItem {
                uid_: uid
                text: name
                servings_: servings
                instruction_: "-"
                type_: type
                ingredient_: ingredients
                howMany_: howMany
            }
        }


        ListModel {
            id: itemModel
            ListElement {uid: "123"; name: "dummy"; instruction:""; howMany: 0; ingredients:""; servings:0; type:"dummy"}

            function contains(uid) {
                for (var i=0; i<count; i++) {
                    if (get(i).uid === uid)  {
                        return [true, i];
                    }
                }
                return [false, i];
            }
        }
    }
}

