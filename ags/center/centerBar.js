import Widget from "resource:///com/github/Aylur/ags/widget.js";
import clientInfoWidget from "./dymicBar/clientInfo.js";


export const centerBar = () => {
//   const mainControl  = Widget.Stack({
//     children: [
// clientInfoWidget()
//     ],
//   })

  const centerWidget = Widget.Revealer({
    className: "u-right-bar",
    hpack: "end",
    vpack: "fill",
	revealChild: true,
    // vertical: false,
    child: clientInfoWidget(),
  });

  return centerWidget;
};
