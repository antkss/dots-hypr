const { Gtk } = imports.gi;
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
// import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';
import { SCREEN_WIDTH } from '../../variables.js';
import WindowTitle from "./normal/spaceleft.js";
import Indicators from "./normal/spaceright.js";
import Music from "./normal/music.js";
import System from "./normal/system.js";
// import { enableClickthrough } from "../.widgetutils/clickthrough.js";
// import { RoundedCorner } from "../.commonwidgets/cairo_roundedcorner.js";
// import { currentShellMode } from '../../variables.js';
import hyprspace from './normal/workspaces_hyprland.js'
// import hyprfocus from './focus/workspaces_hyprland.js'

// const NormalOptionalWorkspaces = async () => {
//     try {
//         return (await import('./normal/workspaces_hyprland.js')).default();
//     } catch {
//         try {
//             return (await import('./normal/workspaces_sway.js')).default();
//         } catch {
//             return null;
//         }
//     }
// };
//
// const FocusOptionalWorkspaces = async () => {
//     try {
//         return (await import('./focus/workspaces_hyprland.js')).default();
//     } catch {
//         try {
//             return (await import('./focus/workspaces_sway.js')).default();
//         } catch {
//             return null;
//         }
//     }
// };

export const Bar = async (monitor = 0) => {
    // const SideModule = (children) => Widget.Box({
    //     className: 'bar-sidemodule',
    //     children: children,
    // });
    const normalBarContent = Widget.CenterBox({
        className: 'bar-bg',
	css:`border-radius:10px;min-width:${SCREEN_WIDTH-5}px;`,
        // setup: (self) => {
        //     const styleContext = self.get_style_context();
        //     const minHeight = styleContext.get_property('min-height', Gtk.StateFlags.NORMAL);
        //     execAsync(['bash', '-c', `hyprctl keyword monitor ,addreserved,${minHeight},0,0,0`]).catch(print);
        // },
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
 //    const focusedBarContent = Widget.CenterBox({
 //        className: 'bar-bg-focus',
 //        startWidget: Widget.Box({}),
 //        centerWidget: Widget.Box({
 //            className: 'spacing-h-4',
 //            children: [
 //                SideModule([]),
	// hyprfocus(),
 //                // Widget.Box({
 //                //     homogeneous: true,
 //                //     children: [await FocusOptionalWorkspaces()],
 //                // }),
 //                SideModule([]),
 //            ]
 //        }),
 //        endWidget: Widget.Box({}),
 //        setup: (self) => {
 //            self.hook(Battery, (self) => {
 //                if(!Battery.available) return;
 //                self.toggleClassName('bar-bg-focus-batterylow', Battery.percent <= userOptions.battery.low);
 //            })
 //        }
 //    });
    return Widget.Window({
        monitor,
        name: `bar${monitor}`,
        anchor: ['top'],
        exclusivity: 'exclusive',
        visible: true,
        // child: Widget.Stack({
            // homogeneous: false,
            // transition: 'slide_up_down',
            // transitionDuration: userOptions.animations.durationLarge,
            child: normalBarContent,
                // 'focus': focusedBarContent,
            // },
            // setup: (self) => self.hook(currentShellMode, (self) => {
            //     self.shown = currentShellMode.value;
            // })
        // }),
    });
}

// export const BarCornerTopleft = (monitor = 0) => Widget.Window({
//     monitor,
//     name: `barcornertl${monitor}`,
//     layer: 'top',
//     anchor: ['top', 'left'],
//     exclusivity: 'normal',
//     visible: true,
//     child: RoundedCorner('topleft', { className: 'corner', }),
//     setup: enableClickthrough,
// });
// export const BarCornerTopright = (monitor = 0) => Widget.Window({
//     monitor,
//     name: `barcornertr${monitor}`,
//     layer: 'top',
//     anchor: ['top', 'right'],
//     exclusivity: 'normal',
//     visible: true,
//     child: RoundedCorner('topright', { className: 'corner', }),
//     setup: enableClickthrough,
// });
