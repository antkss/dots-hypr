// TODO: execAsync(['identify', '-format', '{"w":%w,"h":%h}', imagePath])
// to detect img dimensions

const { Gdk, GdkPixbuf, Gio, GLib, Gtk } = imports.gi;
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
const { Box, Button, Label, Overlay, Revealer, Scrollable, Stack } = Widget;
const { execAsync, exec } = Utils;
import { fileExists } from '../../.miscutils/files.js';
import { MaterialIcon } from '../../.commonwidgets/materialicon.js';
import { MarginRevealer } from '../../.widgethacks/advancedrevealers.js';
import { setupCursorHover, setupCursorHoverInfo } from '../../.widgetutils/cursorhover.js';
import BooruService from '../../../services/booru.js';
const Grid = Widget.subclass(Gtk.Grid, "AgsGrid");

async function getImageViewerApp(preferredApp) {
    Utils.execAsync(['bash', '-c', `command -v ${preferredApp}`])
        .then((output) => {
            if (output != '') return preferredApp;
            else return 'xdg-open';
        });
}

const IMAGE_REVEAL_DELAY = 13; // Some wait for inits n other weird stuff
const IMAGE_VIEWER_APP = getImageViewerApp(userOptions.apps.imageViewer); // Gnome's image viewer cuz very comfortable zooming
const USER_CACHE_DIR = GLib.get_user_cache_dir();

// Create cache folder and clear pics from previous session
Utils.exec(`bash -c 'mkdir -p ${USER_CACHE_DIR}/ags/media/waifus'`);
Utils.exec(`bash -c 'rm ${USER_CACHE_DIR}/ags/media/waifus/*'`);

const CommandButton = (command) => Button({
    className: 'sidebar-chat-chip sidebar-chat-chip-action txt txt-small',
    onClicked: () => sendMessage(command),
    setup: setupCursorHover,
    label: command,
});

export const booruTabIcon = Box({
    hpack: 'center',
    className: 'sidebar-chat-apiswitcher-icon',
    homogeneous: true,
    children: [
        MaterialIcon('gallery_thumbnail', 'norm'),
    ]
});

const BooruInfo = () => {
    const booruLogo = Label({
        hpack: 'center',
        className: 'sidebar-chat-welcome-logo',
        label: 'gallery_thumbnail',
    })
    return Box({
        vertical: true,
        vexpand: true,
        className: 'spacing-v-15',
        children: [
            booruLogo,
            Label({
                className: 'txt txt-title-small sidebar-chat-welcome-txt',
                wrap: true,
                justify: Gtk.Justification.CENTER,
                label: 'Anime booru',
            }),
            Box({
                className: 'spacing-h-5',
                hpack: 'center',
                children: [
                    Label({
                        className: 'txt-smallie txt-subtext',
                        wrap: true,
                        justify: Gtk.Justification.CENTER,
                        label: 'Powered by yande.re',
                    }),
                    Button({
                        className: 'txt-subtext txt-norm icon-material',
                        label: 'info',
                        tooltipText: 'An image booru. May contain NSFW content.\nWatch your back.\n\nDisclaimer: Not affiliated with the provider\nnor responsible for any of its content.',
                        setup: setupCursorHoverInfo,
                    }),
                ]
            }),
        ]
    });
}

const booruWelcome = Box({
    vexpand: true,
    homogeneous: true,
    child: Box({
        className: 'spacing-v-15',
        vpack: 'center',
        vertical: true,
        children: [
            BooruInfo(),
        ]
    })
});

const BooruPage = (taglist) => {
    const PageState = (icon, name) => Box({
        className: 'spacing-h-5 txt',
        children: [
            Label({
                className: 'sidebar-waifu-txt txt-smallie',
                xalign: 0,
                label: name,
            }),
            MaterialIcon(icon, 'norm'),
        ]
    })
    const ImageAction = ({ name, icon, action }) => Button({
        className: 'sidebar-waifu-image-action txt-norm icon-material',
        tooltipText: name,
        label: icon,
        onClicked: action,
        setup: setupCursorHover,
    })
    const PreviewImage = (data) => {
        return Overlay({
            child: Box({
                className: 'sidebar-booru-image',
                css: `background-image: url('${data.preview_url}');`,
                // setup: (self) => {
                // Utils.timeout(1000, () => {
                //     self.css = `background-image: url('${data.preview_url}');`;
                // })
                // }
            }),
            overlays: [
                Box({
                    vpack: 'start',
                    className: 'sidebar-booru-image-actions spacing-h-3',
                    children: [
                        Box({ hexpand: true }),
                        ImageAction({
                            name: 'Go to file url',
                            icon: 'file_open',
                            action: () => execAsync(['xdg-open', `${data.file_url}`]).catch(print),
                        }),
                        ImageAction({
                            name: 'Go to source',
                            icon: 'open_in_new',
                            action: () => execAsync(['xdg-open', `${data.source}`]).catch(print),
                        }),
                    ]
                })
            ]
        })
    }
    const colorIndicator = Box({
        className: `sidebar-chat-indicator`,
    });
    const downloadState = Stack({
        homogeneous: false,
        transition: 'slide_up_down',
        transitionDuration: userOptions.animations.durationSmall,
        children: {
            'api': PageState('api', 'Calling API'),
            'download': PageState('downloading', 'Downloading image'),
            'done': PageState('done', 'Finished!'),
            'error': PageState('error', 'Error'),
        },
    });
    const downloadIndicator = MarginRevealer({
        vpack: 'center',
        transition: 'slide_left',
        revealChild: true,
        child: downloadState,
    });
    const pageHeading = Box({
        homogeneous: false,
        children: [
            Scrollable({
                hexpand: true,
                vscroll: 'never',
                hscroll: 'automatic',
                child: Box({
                    hpack: 'fill',
                    className: 'sidebar-waifu-content spacing-h-5',
                    children: [
                        ...taglist.map((tag) => CommandButton(tag)),
                        Box({ hexpand: true }),
                    ]
                })
            }),
            downloadIndicator,
        ]
    });
    const pageActions = Revealer({
        transition: 'crossfade',
        revealChild: false,
        child: Box({
            vertical: true,
            children: [
                Box({
                    className: 'sidebar-waifu-image-actions spacing-h-3',
                    children: [
                        Box({ hexpand: true }),
                        ImageAction({
                            name: 'Go to source',
                            icon: 'link',
                            action: () => execAsync(['xdg-open', `${thisPage.attribute.imageData.source}`]).catch(print),
                        }),
                        ImageAction({
                            name: 'Hoard',
                            icon: 'save',
                            action: () => execAsync(['bash', '-c', `mkdir -p ~/Pictures/homework${thisPage.attribute.isNsfw ? '/🌶️' : ''} && cp ${thisPage.attribute.imagePath} ~/Pictures/homework${thisPage.attribute.isNsfw ? '/🌶️/' : ''}`]).catch(print),
                        }),
                        ImageAction({
                            name: 'Open externally',
                            icon: 'open_in_new',
                            action: () => execAsync([IMAGE_VIEWER_APP, `${thisPage.attribute.imagePath}`]).catch(print),
                        }),
                    ]
                })
            ],
        })
    })
    const pageImageGrid = Grid({
        columnHomogeneous: true,
        rowHomogeneous: true,
        className: 'sidebar-waifu-image',
        // css: 'min-height: 90px;'
    });
    const pageImageRevealer = Revealer({
        transition: 'slide_down',
        transitionDuration: userOptions.animations.durationLarge,
        revealChild: false,
        child: pageImageGrid,
    });
    const thisPage = Box({
        className: 'sidebar-chat-message',
        attribute: {
            'imagePath': '',
            'isNsfw': false,
            'imageData': '',
            'update': (data, force = false) => {
                const imageData = data;
                thisPage.attribute.imageData = imageData;
                if (data.length == 0) {
                    downloadState.shown = 'error';
                    return;
                }
                const imageColumns = userOptions.sidebar.imageColumns;
                const imageRows = data.length / imageColumns;
                // Add stuff
                for (let i = 0; i < imageRows; i++) {
                    for (let j = 0; j < imageColumns; j++) {
                        if (i * imageColumns + j >= userOptions.sidebar.imageBooruCount) break;
                        // if (i * imageColumns + j >= data.length) break;
                        pageImageGrid.attach(PreviewImage(data[i * imageColumns + j]), j, i, 1, 1);
                    }
                }
                pageImageGrid.show_all();

                // Reveal stuff
                Utils.timeout(IMAGE_REVEAL_DELAY,
                    () => pageImageRevealer.revealChild = true
                );
                Utils.timeout(IMAGE_REVEAL_DELAY + pageImageRevealer.transitionDuration,
                    () => pageActions.revealChild = true
                );
                downloadIndicator.attribute.hide();
            },
        },
        children: [
            colorIndicator,
            Box({
                vertical: true,
                className: 'spacing-v-5',
                children: [
                    pageHeading,
                    Box({
                        vertical: true,
                        children: [pageImageRevealer],
                    })
                ]
            })
        ],
    });
    return thisPage;
}

const booruContent = Box({
    className: 'spacing-v-15',
    vertical: true,
    attribute: {
        'map': new Map(),
    },
    setup: (self) => self
        .hook(BooruService, (box, id) => {
            if (id === undefined) return;
            const newPage = BooruPage(BooruService.queries[id]);
            box.add(newPage);
            box.show_all();
            box.attribute.map.set(id, newPage);
        }, 'newResponse')
        .hook(BooruService, (box, id) => {
            if (id === undefined) return;
            const data = BooruService.responses[id];
            if (!data) return;
            const page = box.attribute.map.get(id);
            page?.attribute.update(data);
        }, 'updateResponse')
    ,
});

export const booruView = Scrollable({
    className: 'sidebar-chat-viewport',
    vexpand: true,
    child: Box({
        vertical: true,
        children: [
            booruWelcome,
            booruContent,
        ]
    }),
    setup: (scrolledWindow) => {
        // Show scrollbar
        scrolledWindow.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        const vScrollbar = scrolledWindow.get_vscrollbar();
        vScrollbar.get_style_context().add_class('sidebar-scrollbar');
        // Avoid click-to-scroll-widget-to-view behavior
        Utils.timeout(1, () => {
            const viewport = scrolledWindow.child;
            viewport.set_focus_vadjustment(new Gtk.Adjustment(undefined));
        })
        // Always scroll to bottom with new content
        const adjustment = scrolledWindow.get_vadjustment();
        adjustment.connect("changed", () => {
            adjustment.set_value(adjustment.get_upper() - adjustment.get_page_size());
        })
    }
});

const booruTags = Revealer({
    revealChild: false,
    transition: 'crossfade',
    transitionDuration: userOptions.animations.durationLarge,
    child: Box({
        className: 'spacing-h-5',
        children: [
            Scrollable({
                vscroll: 'never',
                hscroll: 'automatic',
                hexpand: true,
                child: Box({
                    className: 'spacing-h-5',
                    children: [
                        CommandButton('hololive'),
                    ]
                })
            }),
            Box({ className: 'separator-line' }),
        ]
    })
});

export const booruCommands = Box({
    className: 'spacing-h-5',
    setup: (self) => {
        self.pack_end(CommandButton('/clear'), false, false, 0);
        self.pack_start(Button({
            className: 'sidebar-chat-chip-toggle',
            setup: setupCursorHover,
            label: 'Tags →',
            onClicked: () => {
                booruTags.revealChild = !booruTags.revealChild;
            }
        }), false, false, 0);
        self.pack_start(booruTags, true, true, 0);
    }
});

const clearChat = () => { // destroy!!
    booruContent.attribute.map.forEach((value, key, map) => {
        value.destroy();
        value = null;
    });
}

export const sendMessage = (text) => {
    // Commands
    if (text.startsWith('/')) {
        if (text.startsWith('/clear')) clearChat();
    }
    else BooruService.fetch(text);
}