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
    css: `min-width: ${SCREEN_WIDTH*0.4}px`,
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
	child: apiWidgets,
});

const side_chats = Box({
    // vertical: true,
// className: "side_chat",
    vexpand: false,
    hexpand: false,
    css: `min-width: ${SCREEN_WIDTH}px;`,
    children: [
	widgetContent,
	Box({css:`min-width: ${SCREEN_WIDTH*0.12}px`}),
	toolbox
    ],
    // setup: (self) => self
     //    .on('key-press-event', (widget, event) => { // Handle keybinds
		   // if ((
     //                !(event.get_state()[1] & Gdk.ModifierType.CONTROL_MASK) &&
     //                event.get_keyval()[1] >= 32 && event.get_keyval()[1] <= 126 &&
     //                widget != textbox && event.get_keyval()[1] != Gdk.KEY_space)
     //                ||
     //                ((event.get_state()[1] & Gdk.ModifierType.CONTROL_MASK) &&
     //                    event.get_keyval()[1] === Gdk.KEY_V)
     //            ) {
     //                textbox.grab_focus();
     //                const buffer = textbox.get_buffer();
     //                buffer.set_text(String.fromCharCode(event.get_keyval()[1]), 1);
		   //  textbox.set_position(1);
					//
     //            }
					//
     //    }),
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
