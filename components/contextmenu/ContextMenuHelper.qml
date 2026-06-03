import QtQuick

QtObject {
    id: helper

    function openMenu(menu, targetWindow, anchorItem, menuModel) {
        if (!menu || !anchorItem)
            return;
        menu.menuModel = menuModel;
        menu.anchor.window = targetWindow;
        const windowPos = anchorItem.mapToItem(null, 0, anchorItem.height);
        menu.anchor.rect.x = windowPos.x - (menu.implicitWidth / 2) + (anchorItem.width / 2);
        menu.anchor.rect.y = windowPos.y + 5;
        menu.visible = true;
    }
}
