import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { SearchAndWindows } from "./windowcontent.js";
import PopupWindow from '../.widgethacks/popupwindow.js';
import overhypr from './overview_hyprland.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
export default (id = '') => PopupWindow({
    name: `recent${id}`,
    exclusivity: 'ignore',
    keymode: 'exclusive',
    visible: false,
    anchor: ['top'],
    layer: 'overlay',
    child: Widget.Box({
        vertical: true,
        children: [
            // SearchAndWindows(),
	overhypr(),
        ]
    }),
})
