import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import SystemTray from 'resource:///com/github/Aylur/ags/service/systemtray.js';
import Indicator from '../../../services/indicator.js';
import { StatusIcons } from '../../.commonwidgets/statusicons.js';
import { Tray } from "./tray.js";

export default () => {
    const barTray = Tray();
    const separatorDot = Widget.Revealer({
        // transition: 'slide_left',
        revealChild: false,
        attribute: {
            'count': SystemTray.items.length,
            'update': (self, diff) => {
                self.attribute.count += diff;
                self.revealChild = (self.attribute.count > 0);
            }
        },
        child: Widget.Box({
            vpack: 'center',
            className: 'separator-circle',
        }),
        setup: (self) => self
            .hook(SystemTray, (self) => self.attribute.update(self, 1), 'added')
            .hook(SystemTray, (self) => self.attribute.update(self, -1), 'removed')
        ,
    });
    const barStatusIcons = StatusIcons({
        className: 'bar-statusicons',
        setup: (self) => self.hook(App, (self, currentName, visible) => {
            if (currentName === 'sideright') {
                self.toggleClassName('bar-statusicons-active', visible);
            }
        }),
    });
    const SpaceRightDefaultClicks = (child) => Widget.EventBox({
        onHover: () => { barStatusIcons.toggleClassName('bar-statusicons-hover', true) },
        onHoverLost: () => { barStatusIcons.toggleClassName('bar-statusicons-hover', false) },
        child: child,
    });
    const emptyArea = SpaceRightDefaultClicks(Widget.Box({ hexpand: true, }));
    const indicatorArea = SpaceRightDefaultClicks(Widget.Box({
        children: [
            separatorDot,
            barStatusIcons
        ],
    }));
    const actualContent = Widget.Box({
        hexpand: true,
        className: 'spacing-h-5 bar-spaceright',
        children: [
            emptyArea,
            barTray,
            indicatorArea
        ],
    });

    return Widget.EventBox({
        onScrollUp: () => {
            if (!Audio.speaker) return;
            if (Audio.speaker.volume <= 0.09) Audio.speaker.volume += 0.01;
            else Audio.speaker.volume += 0.03;
            Indicator.popup(1);
        },
        onScrollDown: () => {
            if (!Audio.speaker) return;
            if (Audio.speaker.volume <= 0.09) Audio.speaker.volume -= 0.01;
            else Audio.speaker.volume -= 0.03;
            Indicator.popup(1);
        },
	onPrimaryClick: () => Utils.execAsync(['bash', '-c', 'xfce4-appearance-settings', '&']),
        child: Widget.Box({
            children: [
                actualContent,
                // SpaceRightDefaultClicks(Widget.Box({ className: 'bar-corner-spacing' })),
            ]
        })
    });
}
