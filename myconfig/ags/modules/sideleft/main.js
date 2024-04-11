import PopupWindow from '../.widgethacks/popupwindow.js';
import SidebarLeft from "./sideleft.js";

export default () => PopupWindow({
	visible: false,
    keymode: 'exclusive',
    anchor: ['bottom','top','left'],
    name: 'side_chat',
    layer: 'top',
    child: SidebarLeft(),
});
