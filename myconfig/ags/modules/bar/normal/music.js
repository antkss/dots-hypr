const { GLib } = imports.gi;
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
const { Box, EventBox, Label, Overlay} = Widget;
const { execAsync } = Utils;
import { AnimatedCircProg } from "../../.commonwidgets/cairo_circularprogress.js";
import { showMusicControls } from '../../../variables.js';

const CUSTOM_MODULE_CONTENT_INTERVAL_FILE = `${GLib.get_home_dir()}/.cache/ags/user/scripts/custom-module-interval.txt`;
const CUSTOM_MODULE_CONTENT_SCRIPT = `${GLib.get_home_dir()}/.cache/ags/user/scripts/custom-module-poll.sh`;
const CUSTOM_MODULE_LEFTCLICK_SCRIPT = `${GLib.get_home_dir()}/.cache/ags/user/scripts/custom-module-leftclick.sh`;
const CUSTOM_MODULE_RIGHTCLICK_SCRIPT = `${GLib.get_home_dir()}/.cache/ags/user/scripts/custom-module-rightclick.sh`;
const CUSTOM_MODULE_MIDDLECLICK_SCRIPT = `${GLib.get_home_dir()}/.cache/ags/user/scripts/custom-module-middleclick.sh`;
const CUSTOM_MODULE_SCROLLUP_SCRIPT = `${GLib.get_home_dir()}/.cache/ags/user/scripts/custom-module-scrollup.sh`;
const CUSTOM_MODULE_SCROLLDOWN_SCRIPT = `${GLib.get_home_dir()}/.cache/ags/user/scripts/custom-module-scrolldown.sh`;

function trimTrackTitle(title) {
    if (!title) return '';
    const cleanPatterns = [
        /【[^】]*】/,         // Touhou n weeb stuff
        " [FREE DOWNLOAD]", // F-777
    ];
    cleanPatterns.forEach((expr) => title = title.replace(expr, ''));
    return title;
}

const BarGroup = ({ child }) => Box({
    className: 'bar-group-margin bar-sides',
    children: [
        Box({
            className: 'bar-group bar-group-standalone bar-group-pad-system',
            children: [child],
        }),
    ]
});

const TrackProgress = () => {
       return AnimatedCircProg({
        className: 'bar-music-circprog',
        vpack: 'center', hpack: 'center',
        extraSetup: (self) => self
        ,
    })
}

const switchToRelativeWorkspace = async (self, num) => {
    try {
        const Hyprland = (await import('resource:///com/github/Aylur/ags/service/hyprland.js')).default;
        Hyprland.messageAsync(`dispatch workspace ${num > 0 ? '+' : ''}${num}`).catch(print);
    } catch {
        execAsync([`${App.configDir}/scripts/sway/swayToRelativeWs.sh`, `${num}`]).catch(print);
    }
}

export default () => {
    // TODO: use cairo to make button bounce smaller on click, if that's possible
    const playingState = Box({ // Wrap a box cuz overlay can't have margins itself
        homogeneous: true,
        children: [Overlay({
            child: Box({
                vpack: 'center',
                className: 'bar-music-playstate',
                homogeneous: true,
                children: [Label({
                    vpack: 'center',
                    className: 'bar-music-playstate-txt',
                    justification: 'center',
                    setup: (self) => self.hook(Mpris, label => {
                        const mpris = Mpris.getPlayer('');
                        label.label = `${mpris !== null && mpris.playBackStatus == 'Playing' ? 'pause' : 'play_arrow'}`;
                    }),
                })],
                setup: (self) => self.hook(Mpris, label => {
                    const mpris = Mpris.getPlayer('');
                    if (!mpris) return;
                    label.toggleClassName('bar-music-playstate-playing', mpris !== null && mpris.playBackStatus == 'Playing');
                    label.toggleClassName('bar-music-playstate', mpris !== null || mpris.playBackStatus == 'Paused');
                }),
            }),
            overlays: [
                TrackProgress(),
            ]
        })]
    });
    const trackTitle = Label({
        hexpand: true,
        className: 'txt-smallie bar-music-txt',
        truncate: 'end',
        maxWidthChars: 10, // Doesn't matter, just needs to be non negative
        setup: (self) => self.hook(Mpris, label => {
            const mpris = Mpris.getPlayer('');
            if (mpris)
                label.label = `${trimTrackTitle(mpris.trackTitle)} • ${mpris.trackArtists.join(', ')}`;
            else
                label.label = 'No media';
        }),
    })
    const musicStuff = Box({
        className: 'spacing-h-10',
        hexpand: true,
        children: [
            playingState,
            trackTitle,
        ]
    })
    return EventBox({
        onScrollUp: (self) => switchToRelativeWorkspace(self, -1),
        onScrollDown: (self) => switchToRelativeWorkspace(self, +1),
        child: Box({
            className: 'spacing-h-4',
            children: [
                // SystemResourcesOrCustomModule(),
                EventBox({
                    child: BarGroup({ child: musicStuff }),
                    onPrimaryClick: () => execAsync('playerctl play-pause').catch(print),
                    onSecondaryClick: () => showMusicControls.setValue(!showMusicControls.value),
                    onMiddleClick: () => execAsync(['bash', '-c', 'playerctl next']).catch(print),
                    setup: (self) => self.on('button-press-event', (self, event) => {
                        if (event.get_button()[1] === 8) // Side button
                            execAsync('playerctl previous').catch(print)
                    }),
                })
            ]
        })
    });
}
