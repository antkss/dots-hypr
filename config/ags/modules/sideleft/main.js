import PopupWindow from '../.widgethacks/popupwindow.js';
import SidebarLeft from "./sideleft.js";

export default () => PopupWindow({
    keymode: 'exclusive',
    anchor: ['left', 'top', 'bottom'],
    name: 'sideleft',
    layer: 'top',
    child: SidebarLeft(),
}).keybind([ "CONTROL"], "c", (self, event) => {
	App.closeWindow(self.name);
});
