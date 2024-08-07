const { GLib } = imports.gi;
import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
const { exec, execAsync } = Utils;
const { Box, Label, Button } = Widget;
import SidebarModule from '../sideleft/tools/module.js';
import { fileExists } from '../.miscutils/files.js';
// import { AnimatedCircProg } from "../.commonwidgets/cairo_circularprogress.js";
// import { showMusicControls } from '../../variables.js';
import { darkMode } from '../.miscutils/system.js';
const COMPILED_STYLE_DIR = `${GLib.get_user_cache_dir()}/ags/user/generated`
const COVER_COLORSCHEME_SUFFIX = '_colorscheme.css';
const players = Mpris.bind("players")
var lastCoverPath = '';


function detectMediaSource(link) {
    if (link.startsWith("file://")) {
        if (link.includes('firefox-mpris'))
            return '󰈹 Firefox'
        return "󰈣 File";
    }
    let url = link.replace(/(^\w+:|^)\/\//, '');
    let domain = url.match(/(?:[a-z]+\.)?([a-z]+\.[a-z]+)/i)[1];
    if (domain == 'ytimg.com') return '󰗃 Youtube';
    if (domain == 'discordapp.net') return '󰙯 Discord';
    if (domain == 'sndcdn.com') return '󰓀 SoundCloud';
    return domain;
}

const DEFAULT_MUSIC_FONT = 'Gabarito, sans-serif';
function getTrackfont(player) {
    const title = player.trackTitle;
    const artists = player.trackArtists.join(' ');
    if (artists.includes('TANO*C') || artists.includes('USAO') || artists.includes('Kobaryo'))
        return 'Chakra Petch'; // Rigid square replacement
    if (title.includes('東方'))
        return 'Crimson Text, serif'; // Serif for Touhou stuff
    return DEFAULT_MUSIC_FONT;
}
function trimTrackTitle(title) {
    if (!title) return '';
    const cleanPatterns = [
        /【[^】]*】/,         // Touhou n weeb stuff
        " [FREE DOWNLOAD]", // F-777
    ];
    cleanPatterns.forEach((expr) => title = title.replace(expr, ''));
    return title;
}

const TrackTitle = ({ player, ...rest }) => Label({
    ...rest,
    label: 'No music playing',
    xalign: 0,
    truncate: 'end',
    // wrap: true,
    className: 'osd-music-title',
    setup: (self) => self.hook(player, (self) => {
        // Player name
        self.label = player.trackTitle.length > 0 ? trimTrackTitle(player.trackTitle) : 'No media';
        // Font based on track/artist
        const fontForThisTrack = getTrackfont(player);
        self.css = `font-family: ${fontForThisTrack}, ${DEFAULT_MUSIC_FONT};`;
    }, 'notify::track-title'),
});

const TrackArtists = ({ player, ...rest }) => Label({
    ...rest,
    xalign: 0,
    className: 'osd-music-artists',
    truncate: 'end',
    setup: (self) => self.hook(player, (self) => {
        self.label = player.trackArtists.length > 0 ? player.trackArtists.join(', ') : '';
    }, 'notify::track-artists'),
})

const CoverArt = ({ player, ...rest }) => {
    const fallbackCoverArt = Box({ // Fallback
        className: 'osd-music-cover-fallback',
        homogeneous: true,
        children: [Label({
            className: 'icon-material txt-gigantic txt-thin',
            label: 'music_note',
        })]
    });
    const realCoverArt = Box({
        className: 'osd-music-cover-art',
        homogeneous: true,
        // children: [coverArtDrawingArea],
        attribute: {
            'pixbuf': null,
                       'updateCover': (self) => {
                // Player closed
                // Note that cover path still remains, so we're checking title
                if (!player || player.trackTitle == "") {
                    self.css = `background-image: none;`; // CSS image
                    App.applyCss(`${COMPILED_STYLE_DIR}/style.css`);
                    return;
                }

                const coverPath = player.coverPath;
                const stylePath = `${player.coverPath}${darkMode ? '' : '-l'}${COVER_COLORSCHEME_SUFFIX}`;
                if (player.coverPath == lastCoverPath) { // Since 'notify::cover-path' emits on cover download complete
                    Utils.timeout(200, () => {
                        // self.attribute.showImage(self, coverPath);
                        self.css = `background-image: url('${coverPath}');`; // CSS image
                    });
                }
                lastCoverPath = player.coverPath;

                // If a colorscheme has already been generated, skip generation
                if (fileExists(stylePath)) {
                    // self.attribute.showImage(self, coverPath)
                    self.css = `background-image: url('${coverPath}');`; // CSS image
                    App.applyCss(stylePath);
                    return;
                }

                // Generate colors
                execAsync(['bash', '-c',`${App.configDir}/scripts/color_generation/generate_colors_material.py --path '${coverPath}' > ${App.configDir}/scss/_musicmaterial.scss ${darkMode ? '' : '-l'}`])
                    .then(() => {
                        exec(`wal -i "${player.coverPath}" -n -t -s -e -q ${darkMode ? '' : '-l'}`);
                        exec(`cp ${GLib.get_user_cache_dir()}/wal/colors.scss ${App.configDir}/scss/_musicwal.scss`);
                        exec(`sass ${App.configDir}/scss/_music.scss ${stylePath}`);
                        Utils.timeout(200, () => {
                            // self.attribute.showImage(self, coverPath)
                            self.css = `background-image: url('${coverPath}');`; // CSS image
                        });
                        App.applyCss(`${stylePath}`);
                    })
                    .catch(print);
            },
        },
        setup: (self) => self
            .hook(player, (self) => {
                self.attribute.updateCover(self);
            }, 'notify::cover-path')
        ,
    });
    return Box({
        ...rest,
        className: 'osd-music-cover',
        children: [
            Widget.Overlay({
                child: fallbackCoverArt,
                overlays: [realCoverArt],
            })
        ],
    })
}

const TrackControls = ({ player, ...rest }) => Widget.Revealer({
    revealChild: false,
    transition: 'slide_right',
    transitionDuration: userOptions.animations.durationSmall,
    child: Widget.Box({
        ...rest,
        vpack: 'center',
        className: 'osd-music-controls spacing-h-5',
        children: [
            Button({
                className: 'osd-music-controlbtn',
                onClicked: () => player.previous(),
                child: Label({
                    className: 'icon-material osd-music-controlbtn-txt',
                    label: 'skip_previous',
                })
            }),
            Button({
                className: 'osd-music-controlbtn',
                onClicked: () => player.next(),
                child: Label({
                    className: 'icon-material osd-music-controlbtn-txt',
                    label: 'skip_next',
                })
            }),
        ],
    }),
    setup: (self) => self.hook(Mpris, (self) => {
        const player = Mpris.getPlayer();	
        if (!player)
            self.revealChild = false;
        else
            self.revealChild = true;
    }, 'notify::play-back-status'),
});


const TrackSource = ({ player, ...rest }) => Widget.Revealer({
    revealChild: false,
    transition: 'slide_left',
    transitionDuration: userOptions.animations.durationLarge,
    child: Widget.Box({
        ...rest,
        className: 'osd-music-pill spacing-h-5',
        homogeneous: true,
        children: [
            Label({
                hpack: 'fill',
                justification: 'center',
                className: 'icon-nerd',
                setup: (self) => self.hook(player, (self) => {
                    self.label = String(detectMediaSource(player.trackCoverUrl));
                }, 'notify::cover-path'),
            }),
        ],
    }),
    setup: (self) => self.hook(Mpris, (self) => {
        const mpris = Mpris.getPlayer('');
        if (!mpris)
            self.revealChild = false;
        else
            self.revealChild = true;
    }),
});


const PlayState = ({ player }) => {
    return Widget.Button({
        className: 'osd-music-playstate',
               onClicked: () => player.playPause(),
            child: Widget.Button({
                    className: 'osd-music-playstate-btn',
                    child: Widget.Label({
                        justification: 'center',
                        hpack: 'fill',
                        vpack: 'center',
                        setup: (self) => self.hook(player, (label) => {
                            label.label = `${player.playBackStatus == 'Playing' ? 'pause' : 'play_arrow'}`;
                        }, 'notify::play-back-status'),
                    }),
                }),
    });
}
const MusicControlsWidget = (player) => Box({
    // className: 'osd-music',
    children: [
        CoverArt({ player: player, vpack: 'center' }),
        Box({
            vertical: true,
            // className: 'spacing-v-5',
            children: [
                Box({
                    vertical: true,
                    vpack: 'center',
                    hexpand: true,
                    children: [
                        TrackTitle({ player: player }),
                        TrackArtists({ player: player }),
                    ]
                }),
                Box({
                    className: 'control_bar',
                    setup: (box) => {
                        box.pack_start(TrackControls({ player: player }), false, false, 0);
                        box.pack_end(PlayState({ player: player }), false, false, 0);
                        box.pack_end(TrackSource({ vpack: 'center', player: player }), false, false, 0);
                    }
                })
            ]
        })
    ]
});
export default () => SidebarModule({

    name: 'Music control',

    child: Box({
  children: players.as(p => p.map(MusicControlsWidget)),
    }),
})


