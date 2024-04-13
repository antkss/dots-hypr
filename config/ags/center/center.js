// import { centerBar  } from "./centerBar.js";
// import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import clientInfoWidget from "./dymicBar/clientInfo.js";
// import { MarginRevealer } from '../modules/.widgethacks/advancedrevealers.js';
// import hypr from '../services/hypr.js';
import Widget from "resource:///com/github/Aylur/ags/widget.js";
const topBar = function(monitor = 1) {
  // const mainBox = Widget.CenterBox({
  //   className: 'f-bar',
  //   spacing: 1,
  //   vertical: false,
  //   centerWidget: centerBar(),
  // })

const centerWidget = Widget.Revealer({
    // className: "u-right-bar",
    hpack: "end",
    vpack: "fill",
	revealChild: true,

// extraSetup: (self) => self
//     .hook(hypr, (revealer, value) => {
// 	if (value > -1) revealer.attribute.show();
// 	else revealer.attribute.hide();
//     }, 'pop'),
    // vertical: false,
    child: clientInfoWidget(),
  });
	
  const win = Widget.Window({
	// keymode: 'exclusive',
	  visible: false,
	  // css:'background:transparent;',
    monitor,
    name: `center`,
    // anchor: ['bottom'],
    child: centerWidget,
    margins:[5,0,2,0],
    // exclusivity: "exclusive",
  });
  return win
}


export default topBar
