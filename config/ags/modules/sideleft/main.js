// import { textbox } from './apiwidgets.js';
// const { Gdk } = imports.gi;
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
const { Box, Revealer,Window } = Widget;
import {apiWidgets} from './apiwidgets.js';
import {toolbox} from './toolbox.js'
const widgetContent = Revealer({
	revealChild: true,
	child: apiWidgets,
});

const side_chats = Box({
    // vertical: true,
// className: "side_chat",
    vexpand: false,
    hexpand: false,
    css: 'min-width: 1366px;',
    children: [
	widgetContent,
	Box({css:'min-width: 166px'}),
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
