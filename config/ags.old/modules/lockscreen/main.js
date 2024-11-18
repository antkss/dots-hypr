import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import Avatar from './Avatar.js';
import Lockscreen from './lockscreens.js';
import Layer from 'gi://GtkLayerShell';
import { SCREEN_HEIGHT, SCREEN_WIDTH } from '../../variables.js';
import {BarClock} from '../bar/normal/system.js'
const PasswordEntry = () => Widget.Box({
	className:'sidebar-chat-textarea',
    children: [
        Widget.Entry({
		placeholder_text: 'Password',
		setup: self => self.hook(Lockscreen, () => self.text = '', 'lock'),
		visibility: false,
		on_accept: ({ text }) => Lockscreen.auth(text || ''),
		hpack: 'center',
		hexpand: true,
        }),
        Widget.Spinner({
            active: true,
            vpack: 'center',
            setup: self => self.hook(Lockscreen, (_, auth) => self.visible = auth, 'authenticating'),
        }),
    ],
});

/** @param {number} monitor */
export default () => {
	const win = Widget.Window({
		name: `lockscreen`,
		class_name: 'lockscreen',
		keymode: 'exclusive',
		visible: false,
		    layer: 'overlay',
		    exclusivity: 'ignore',
		    anchor: ['top', 'bottom', 'left', 'right'],
		setup: self => self.hook(Lockscreen, (_, lock) => self.visible = lock, 'lock'),
		child: Widget.Box({
			hexpand: true,
			vexpand: true,
			vertical: false,
			hpack: 'center',
			vpack: 'center',
			children: [
				BarClock({
					css: `margin-top: 10px;`,
				}),
			    PasswordEntry(),
			],
		    }),
		
	    });
Layer.set_keyboard_mode(win, Layer.KeyboardMode.EXCLUSIVE);
return win
}

