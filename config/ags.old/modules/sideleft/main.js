// import { textbox } from './apiwidgets.js';
// const { Gdk } = imports.gi;
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
const { Box, Revealer,Window,Scrollable } = Widget;
import {apiWidgets} from './apiwidgets.js';
// import {toolbox} from './toolbox.js'
// import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import QuickScripts from './tools/quickscripts.js';
import ColorPicker from './tools/colorpicker.js';
import materialpick from './tools/materialswitch.js' 
import notification from './notificationlist.js';
import {SCREEN_WIDTH,SCREEN_HEIGHT} from '../../variables.js';

const toolbox =  Scrollable({
    hscroll: "never",
    vscroll: "automatic",
    hexpand: false,
    css: `min-width: ${SCREEN_WIDTH*0.1}px`,
    child: Box({
        vertical: true,
        className: 'side_chat',
        children: [
		QuickScripts(),
		ColorPicker(),
		materialpick(),
		notification(),
        ]
    })
});
const widgetContent = Revealer({
	revealChild: true,
	css: `min-width: ${SCREEN_WIDTH*0.7}px;`,
	child: apiWidgets,
});

const side_chats = Box({
    // vertical: true,
// className: "side_chat",
    vexpand: false,
    hexpand: false,
    css: `min-width: ${SCREEN_WIDTH}px;`,
    children: [
	toolbox,
	Box({css:`min-width: ${SCREEN_WIDTH*0.2}px`}),
	widgetContent,
    ],

});
export default () => Window({
	// className:"side_chat",
    visible: false,
    keymode: 'exclusive',
    anchor: ['bottom','top','left'],
    name: 'side_chat',
    layer: 'overlay',
    child: side_chats,
});
