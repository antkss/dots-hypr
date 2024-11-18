const { Gtk } = imports.gi;
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { Keybinds } from "./keybinds.js";
import { setupCursorHover } from "../.widgetutils/cursorhover.js";
import PopupWindow from '../.widgethacks/popupwindow.js';
import {SCREEN_WIDTH} from '../../variables.js';
//calculated size
let scale_factor = 1;
try {
    scale_factor = JSON.parse(exec('hyprctl monitors -j'))
        .filter(monitor => monitor.focused)[0]
        .scale;
} catch {}
 const SCALE_FACTOR = scale_factor;
 const SCREEN_REAL_WIDTH = SCREEN_WIDTH / SCALE_FACTOR;

const cheatsheetHeader = () => Widget.CenterBox({
    vertical: false,
    startWidget: Widget.Box({}),
    centerWidget: Widget.Box({
        vertical: true,
        className: "spacing-h-15",
        children: [
            Widget.Box({
                hpack: 'center',
                className: 'spacing-h-5 cheatsheet-title',
                children: [
                    Widget.Label({
                        hpack: 'center',
                        css: 'margin-right: 0.682rem;',
                        className: 'txt-title',
                        label: 'Cheat sheet',
                    }),
                    Widget.Label({
                        vpack: 'center',
                        className: "cheatsheet-key txt-small",
                        label: "",
                    }),
                    Widget.Label({
                        vpack: 'center',
                        className: "cheatsheet-key-notkey txt-small",
                        label: "+",
                    }),
                    Widget.Label({
                        vpack: 'center',
                        className: "cheatsheet-key txt-small",
                        label: "/",
                    })
                ]
            }),
            Widget.Label({
                useMarkup: true,
                selectable: true,
                justify: Gtk.Justification.CENTER,
                className: 'txt-small txt',
                label: 'Sheet data stored in <tt>~/.config/ags/modules/cheatsheet/data_keybinds.js</tt>\nChange keybinds in <tt>~/.config/hypr/hyprland/keybinds.conf</tt>'
            }),
        ]
    }),
    endWidget: Widget.Button({
        vpack: 'start',
        hpack: 'end',
        className: "cheatsheet-closebtn icon-material txt txt-hugeass",
        onClicked: () => {
            App.toggleWindow('cheatsheet');
        },
        child: Widget.Label({
            className: 'icon-material txt txt-hugeass',
            label: 'close'
        }),
        setup: setupCursorHover,
    }),
});

const clickOutsideToClose = Widget.EventBox({
    onPrimaryClick: () => App.closeWindow('cheatsheet'),
    onSecondaryClick: () => App.closeWindow('cheatsheet'),
    onMiddleClick: () => App.closeWindow('cheatsheet'),
});
export default () => {
    // values from ags inspector
    const cheatsheetWidth = 1588;
    const defaultDPI = 96;

    let scale_factor = 1;
    if (cheatsheetWidth > SCREEN_REAL_WIDTH) {
        scale_factor = SCREEN_REAL_WIDTH / cheatsheetWidth;
    }
    return PopupWindow({
        name: 'cheatsheet',
        exclusivity: 'ignore',
        keymode: 'exclusive',
        visible: false,
        child: Widget.Box({
            vertical: true,
            children: [
                clickOutsideToClose,
                Widget.Box({
                    vertical: true,
                    className: "cheatsheet-bg spacing-v-15",
                    css: `${scale_factor < 1 ? `-gtk-dpi: ${defaultDPI * scale_factor}` : ''}`,
                    children: [
                        cheatsheetHeader(),
                        Keybinds(),
                    ]
                }),
            ],
        })
    });
}
