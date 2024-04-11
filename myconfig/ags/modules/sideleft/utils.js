import PopupWindow from '../.widgethacks/popupwindow.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
const { Box, Revealer } = Widget;
import toolbox from './toolbox.js';
const widgetContent = Revealer({
	revealChild: true,
	child: toolbox,
});

const tools =  Box({
    // vertical: true,
className:"side_chat",
    vexpand: true,
    hexpand: true,
    css: 'min-width: 2px;',
    children: [
        // EventBox({
        //     onPrimaryClick: () => App.closeWindow('sideleft'),
        //     onSecondaryClick: () => App.closeWindow('sideleft'),
        //     onMiddleClick: () => App.closeWindow('sideleft'),
        // }),
        widgetContent,
    ],

});
export default () => PopupWindow({
	className:"side_utils",
	visible: false,
    keymode: 'exclusive',
    anchor: ['bottom','top','right'],
    name: 'side_utils',
    layer: 'top',
    child: tools,
});
