// This is for the right pills of the bar. 
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
const { Box, Button } = Widget;
const { GLib } = imports.gi;
import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';
const batteryProgress = Widget.CircularProgress({
    child: Widget.Icon({
	css: `font-size: 13px;`,
        icon: Battery.bind('icon_name')
    }),
    visible: Battery.bind('available'),
    value: Battery.bind('percent').as(p => p > 0 ? p / 100 : 0),
    class_name: 'battery'
	// Battery.bind('charging').as(ch => ch ? 'battery' : ''),
})
export const BarClock = () => Widget.Box({
    vpack: 'center',
    className: 'clock-bar',
    children: [
        Widget.Label({
            className: 'bar-time',
            label: GLib.DateTime.new_now_local().format(userOptions.time.format),
            setup: (self) => self.poll(userOptions.time.interval, label => {
                label.label = GLib.DateTime.new_now_local().format(userOptions.time.format);
            }),
        }),
        Widget.Label({
            className: 'txt-norm txt-onLayer1',
		css: `padding-left:3px;padding-right:3px;`,
            label: '•',
        }),
        Widget.Label({
            className: 'txt-smallie bar-date',
            label: GLib.DateTime.new_now_local().format(userOptions.time.dateFormatLong),
            setup: (self) => self.poll(userOptions.time.dateInterval, (label) => {
                label.label = GLib.DateTime.new_now_local().format(userOptions.time.dateFormatLong);
            }),
        }),
    ],
});

const UtilButton = ({ name, icon, onClicked }) => Button({
    vpack: 'center',
    tooltipText: name,
    onClicked: onClicked,
    className: 'bar-util-btn icon-material txt-norm',
    label: `${icon}`,
})

const Utilities = () => Box({
    hpack: 'center',
    className: 'bar-group bar-group-standalone bar-group-pad-system',
	css: `margin:3px;padding-left:5px;padding-right:5px;`,
    children: [
        UtilButton({
		className: 'spacing-h-4 bar-group-margin bar-sides',
            name: 'Screen snip', icon: 'screenshot_region', onClicked: () => {
                Utils.execAsync(`${App.configDir}/scripts/grimblast.sh copy area`)
                    .catch(print)
            }
        }),
        UtilButton({
		className: 'spacing-h-4 bar-group-margin bar-sides',
            name: 'Color picker', icon: 'colorize', onClicked: () => {
                Utils.execAsync(['hyprpicker', '-a']).catch(print)
            }
        }),
        UtilButton({
		className: 'spacing-h-4 bar-group-margin bar-sides',
            name: 'Toggle on-screen keyboard', icon: 'keyboard', onClicked: () => {
                App.toggleWindow('osk');
            }
        }),
    ]
})
export default () => Widget.Box({
        className: 'spacing-h-4',
        children: [
		BarClock(), 
		Utilities(),
		batteryProgress,
        ]
});
