import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
const { execAsync } = Utils;
const { Box, Button,  Icon, Label } = Widget;
import SidebarModule from './module.js';
import { MaterialIcon } from '../../.commonwidgets/materialicon.js';

export default () => SidebarModule({
    icon: MaterialIcon('colorize', 'norm'),
    name: 'Material picker',
    child: Box({
        vertical: true,
        className: 'spacing-v-5',
        children: [
             Box({
                className: 'spacing-h-5 txt',
                children: [
                    Icon({
                        className: 'sidebar-module-btn-icon txt-large',
                    }),
                    Label({
                        className: 'txt-small',
                        hpack: 'start',
                        hexpand: true,
                        label: "Click the button to proceed",
                    }),
                    Button({
                        className: 'sidebar-module-scripts-button',
			    label: "💕",
                        onClicked: () => {
                            App.closeWindow('side_utils');
                            execAsync([`bash`, `-c`, `$HOME/.config/ags/scripts/color_generation/switchcolor.sh --pick`]).catch(print)
                        },
                    }),

                ],
            }),
             Box({
                className: 'spacing-h-5 txt',
                children: [
                    Icon({
                        className: 'sidebar-module-btn-icon txt-large',
                    }),
                    Label({
                        className: 'txt-small',
                        hpack: 'start',
                        hexpand: true,
                        label: "Click to restart the ags widgets",
                    }),
                    Button({
                        className: 'sidebar-module-scripts-button',
			    label: "🔄",
                        onClicked: () => {
                            // App.closeWindow('side_utils');
                            execAsync([`bash`, `-c`, `killall ags && ags &`]).catch(print)
                        },
                    }),

                ],
            }),
        ],
    })
});
