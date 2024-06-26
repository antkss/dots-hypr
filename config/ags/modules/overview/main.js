import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { SearchAndWindows } from "./windowcontent.js";
import PopupWindow from '../.widgethacks/popupwindow.js';
// import overview_hyprland from './overview_hyprland.js';

export default (id = '') => PopupWindow({
    name: `overview${id}`,
    // exclusivity: 'ignore',
    keymode: 'on-demand',
    visible: false,
    anchor: ['top'],
    layer: 'overlay',
    child: Widget.Box({
        vertical: true,
        children: [
            SearchAndWindows(),
        ]
    }),
})
