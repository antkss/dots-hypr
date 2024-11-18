import PopupWindow from '../.widgethacks/popupwindow.js';
import SidebarRight from "./sideright.js";

export default () => PopupWindow({
    keymode: 'exclusive',
    anchor: ['right', 'top', 'bottom'],
    name: 'sideright',
    child: SidebarRight(),
}).keybind([ "CONTROL"], "c", (self, event) => {
	App.closeWindow(self.name);
});
