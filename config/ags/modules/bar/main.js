import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import {  SCREEN_WIDTH } from '../../variables.js';
import WindowTitle from "./normal/spaceleft.js";
import Indicators from "./normal/spaceright.js";
import Music from "./normal/music.js";
import System from "./normal/system.js";
import hyprspace from './normal/workspaces_hyprland.js'
export const Bar = async (monitor = 0) => {

    const normalBarContent = Widget.CenterBox({
	hexpand: false,
        className: 'bar-bg',
	css:`border-radius:10px;min-width:${SCREEN_WIDTH-5}px`,
        startWidget: WindowTitle(),
        centerWidget: Widget.Box({
            className: 'spacing-h-4',
	    css:`background:transparent;`,
            children: [
                Music(),
		hyprspace(),
                // Widget.Box({
                //     homogeneous: true,
                //     children: [await NormalOptionalWorkspaces()],
                // }),
                System(),
            ]
        }),
        endWidget: Indicators(),
    });

    return Widget.Window({
        monitor,
        name: `bar${monitor}`,
        anchor: ['top'],
        exclusivity: 'exclusive',
        visible: true,
            child: normalBarContent,

    });
}

