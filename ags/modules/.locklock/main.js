import Widget from 'resource:///com/github/Aylur/ags/widget.js';
const greetd = await Service.import('greetd');

const name = Widget.Entry({
    placeholder_text: 'Username',
    on_accept: () => password.grab_focus(),
})

const password = Widget.Entry({
    placeholder_text: 'Password',
    visibility: false,
    on_accept: () => {
        greetd.login(name.text || '', password.text || '', 'Hyprland')
            .catch(err => response.label = JSON.stringify(err))
    },
})

const response = Widget.Label()

export default () => Widget.Window({
	name:"lockscreen",
    // css: 'background-color: transparent;',
	className:"session-bg",
	keymode:"exclusive",
    anchor: ['top', 'left', 'right', 'bottom'],
    child: Widget.Box({
        vertical: true,
        hpack: 'center',
        vpack: 'center',
        hexpand: true,
        vexpand: true,
        children: [
            name,
            password,
            response,
        ],
    }),
})

// App.config({ windows: [win] })
