import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import { centerBar  } from "./centerBar.js";
const topBar = function(monitor = 1) {
  const mainBox = Widget.CenterBox({
    className: 'f-bar',
    spacing: 1,
    vertical: false,
    centerWidget: centerBar(),
  })


  const win = Widget.Window({
	// keymode: 'exclusive',
	  visible: false,
    monitor,
    name: `center`,
    // anchor: ['top-center'],
    child: mainBox,
    margins:[5,0,2,0],
    // exclusivity: "exclusive",
  });
  return win
}


export default topBar
