import {
  Label,
  Box,
  Icon,
  Window,
  Button,
  Revealer,
EventBox,
} from 'resource:///com/github/Aylur/ags/widget.js';


import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
const hyprland = await Service.import('hyprland')
const { execAsync } = Utils;
const worksbuts = () => {
	// var child_array = []

const buttons = (iconbut) => Button({
    vpack: 'center',
    className: 'recent_icon',
    label: iconbut,
});
// hyprland.workspaces.forEach((w) => {
// child_array = Object.assign(child_array, [ button(`${w.id}`)] )
//
// });
// const WsIndicator = ws => Button({
// 	className: 'recent_box',
//     child: Label(`${ws.name}`),
//     onClicked: () => execAsync(`hyprctl dispatch workspace ${ws.id}`),
// });
	// print(JSON.stringify(hyprland.monitors))
 const row1 = Box({
            children:Array.from({ length: 10 }, (_, i) => i + 1).map(i => Button({
	className: 'recent_box',
            attribute: i,
            label: `${i}`,
            onClicked: () => dispatch(i),
        })),
 });
// 	 .hook(hyprland,box => {
// // set the box's children when Hyprland signals a change
// box.children = hyprland.workspaces
//     // filter to only show active monitor
//     .filter(ws =>print(ws.workspaces))
//     // make a widget for every workspaces
//     .map(WsIndicator);
//
// });

const focusedTitle = Label({
    label: hyprland.active.client.bind('title'),
	className: 'recent_box',
    visible: hyprland.active.client.bind('address')
        .as(addr => !!addr),
})

const dispatch = ws => hyprland.messageAsync(`dispatch workspace ${ws}`);

return  EventBox({
    onScrollUp: () => dispatch('+1'),
    onScrollDown: () => dispatch('-1'),
    child: Box({
		children: Array.from({ length: 10 }, (_, i) => i + 1).map(i => Button({
		className: 'recent_box',
		attribute: i,
		// child: focusedTitle,
		label: `${i}`,
        })),

        // remove this setup hook if you want fixed number of buttons
        setup: self => self.hook(hyprland, () => self.children.forEach(btn => {
            btn.visible = hyprland.workspaces.some(ws => ws.id === btn.attribute);
        })),
    }),
})

};


const widgets = Box({
children: [worksbuts()],
});
const revealer = Revealer({
    revealChild: true,
    child: Box({
      // className: 'osd-music spacing-h-10 test',
      child: Box({
        child:worksbuts(),
      }),
    }),
  });


export const Recent = () => Window({
    name: "recent",
    layer: 'overlay',
    visible: true,
        child:Box({
		children: [revealer],
	}),


});

