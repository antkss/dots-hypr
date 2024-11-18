const {  GLib } = imports.gi;
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { ConfigToggle, ConfigMulipleSelection } from '../.commonwidgets/configwidgets.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
const { execAsync } = Utils;
import { setupCursorHover } from '../.widgetutils/cursorhover.js';
import { showColorScheme } from '../../variables.js';
import { MaterialIcon } from '../.commonwidgets/materialicon.js';
import { fileExists } from '../.miscutils/files.js';
const ColorBox = ({
    name = 'Color',
    ...rest
}) => Widget.Box({
    ...rest,
    homogeneous: true,
    children: [
        Widget.Label({
            label: `${name}`,
        })
    ]
})

const ColorSchemeSettingsRevealer = () => {
    const headerButtonIcon = MaterialIcon('expand_more', 'norm');
    const header = Widget.Button({
        className: 'osd-settings-btn-arrow',
        onClicked: () => {
            content.revealChild = !content.revealChild;
            headerButtonIcon.label = content.revealChild ? 'expand_less' : 'expand_more';
        },
        setup: setupCursorHover,
        hpack: 'end',
        child: headerButtonIcon,
    });
    const content = Widget.Revealer({
        revealChild: false,
        // transition: 'slide_down',
        // transitionDuration: 200,
        child: ColorSchemeSettings(),
        setup: (self) => self.hook(isHoveredColorschemeSettings, (revealer) => {
            if (isHoveredColorschemeSettings.value == false) {
              setTimeout(() => {
                  if (isHoveredColorschemeSettings.value == false)
                    revealer.revealChild = false;
                    headerButtonIcon.label = 'expand_more';
              }, 1500);
            }
        }),
    });
    return Widget.EventBox({
        onHover: (self) => {
            isHoveredColorschemeSettings.setValue(true);
        },
        onHoverLost: (self) => {
            isHoveredColorschemeSettings.setValue(false);
        },
        child: Widget.Box({
          vertical: true,
          children: [
              header,
              content,
          ]
        }),
    });
}

function calculateSchemeInitIndex(optionsArr, searchValue = 'vibrant') {
  if (searchValue == '')
    searchValue = 'vibrant';
  const flatArray = optionsArr.flatMap(subArray => subArray);
  const result = flatArray.findIndex(element => element.value === searchValue);
  const rowIndex = Math.floor(result / optionsArr[0].length);
  const columnIndex = result % optionsArr[0].length;
  return [rowIndex, columnIndex];
}

const schemeOptionsArr = [
  [
    { name: 'Tonal Spot', value: 'tonalspot' },
    { name: 'Fruit Salad', value: 'fruitsalad' },
    { name: 'Fidelity', value: 'fidelity' },
    { name: 'Rainbow', value: 'rainbow' },
  ],
  [
    { name: 'Neutral', value: 'neutral' },
    { name: 'Monochrome', value: 'monochrome' },
    { name: 'Expressive',  value: 'expressive' },
    { name: 'Vibrant', value: 'vibrant' },
  ],
  //[
  //  { name: 'Content', value: 'content' },
  //]
];

const initColorMode = Utils.exec('bash -c "sed -n \'1p\' $HOME/.cache/ags/user/colormode.txt"');
const initColorVal = (initColorMode == "dark") ? 1 : 0;
const initTransparency = Utils.exec('bash -c "sed -n \'2p\' $HOME/.cache/ags/user/colormode.txt"');
const initTransparencyVal = (initTransparency == "transparent") ? 1 : 0;
const initScheme = Utils.exec('bash -c "sed -n \'3p\' $HOME/.cache/ags/user/colormode.txt"');
const initSchemeIndex = calculateSchemeInitIndex(schemeOptionsArr, initScheme);

const ColorSchemeSettings = () => Widget.Box({
  className: 'osd-colorscheme-settings spacing-v-5',
  vertical: true,
  vpack: 'center',
  children: [
    Widget.Box({
        children: [
            ConfigToggle({
                name: 'Dark Mode',
                initValue: initColorVal,
                onChange: (self, newValue) => {
		    if (fileExists(`${GLib.get_user_cache_dir()}/swww/eDP-1`)) {
			var contents = Utils.readFile(`${GLib.get_user_cache_dir()}/swww/eDP-1`).trim();
			let lightdark = newValue == 0 ? "light" : "dark";
			execAsync([`bash`,`-c`, `${App.configDir}/scripts/color_generation/generate_colors_material.py --path ${contents} --mode ${lightdark} --apply --ags`]).catch(print);
		    }else{
			execAsync([`bash`,`-c`,`notify-send "no wallpaper found!!!"`]).catch(print);
		    }
                     
                },
            }),
            ConfigToggle({
                name: 'Transparency',
                initValue: initTransparencyVal,
                onChange: (self, newValue) => {
                    let transparency = newValue == 0 ? "opaque" : "transparent";
		    if (fileExists(`${GLib.get_user_cache_dir()}/swww/eDP-1`)) {
			var contents = Utils.readFile(`${GLib.get_user_cache_dir()}/swww/eDP-1`).trim();
			execAsync([`bash`,`-c`, `${App.configDir}/scripts/color_generation/generate_colors_material.py --path ${contents} --mode ${initColorMode} --transparency ${transparency} --apply --ags`]).catch(print);
		    }else{
			execAsync([`bash`,`-c`,`notify-send "no wallpaper found!!!"`]).catch(print);
		    }
                },
            }),
        ]
    }),
    ConfigMulipleSelection({
        hpack: 'center',
        vpack: 'center',
        optionsArr: schemeOptionsArr,
        initIndex: initSchemeIndex,
        onChange: (value, name) => {
		if (fileExists(`${GLib.get_user_cache_dir()}/swww/eDP-1`)) {
		    var contents = Utils.readFile(`${GLib.get_user_cache_dir()}/swww/eDP-1`).trim();
		    execAsync([`bash`,`-c`, `${App.configDir}/scripts/color_generation/generate_colors_material.py --path ${contents} --mode ${initColorMode} --transparency ${initTransparency} --scheme ${value} --apply --ags`]).catch(print);
		}else{
		    execAsync([`bash`,`-c`,`notify-send "no wallpaper found!!!"`]).catch(print);
		}
        },
    }),
  ]
});

const ColorschemeContent = () => Widget.Box({
    className: 'osd-colorscheme spacing-v-5',
    vertical: true,
    hpack: 'center',
    children: [
        Widget.Label({
            xalign: 0,
            className: 'txt-norm titlefont txt',
            label: 'Colorscheme',
            hpack: 'center',
        }),
        Widget.Box({
            className: 'spacing-h-5',
            hpack: 'center',
            children: [
                ColorBox({ name: 'P', className: 'osd-color osd-color-primary' }),
                ColorBox({ name: 'S', className: 'osd-color osd-color-secondary' }),
                ColorBox({ name: 'T', className: 'osd-color osd-color-tertiary' }),
                ColorBox({ name: 'Sf', className: 'osd-color osd-color-surface' }),
                ColorBox({ name: 'Sf-i', className: 'osd-color osd-color-inverseSurface' }),
                ColorBox({ name: 'E', className: 'osd-color osd-color-error' }),
            ]
        }),
        Widget.Box({
            className: 'spacing-h-5',
            hpack: 'center',
            children: [
                ColorBox({ name: 'P-c', className: 'osd-color osd-color-primaryContainer' }),
                ColorBox({ name: 'S-c', className: 'osd-color osd-color-secondaryContainer' }),
                ColorBox({ name: 'T-c', className: 'osd-color osd-color-tertiaryContainer' }),
                ColorBox({ name: 'Sf-c', className: 'osd-color osd-color-surfaceContainer' }),
                ColorBox({ name: 'Sf-v', className: 'osd-color osd-color-surfaceVariant' }),
                ColorBox({ name: 'E-c', className: 'osd-color osd-color-errorContainer' }),
            ]
        }),
        ColorSchemeSettingsRevealer(),
    ]
});

const isHoveredColorschemeSettings = Variable(false);

export default () => Widget.Revealer({
    // transition: 'slide_down',
    // transitionDuration: userOptions.animations.durationLarge,
    child: ColorschemeContent(),
    setup: (self) => {
      self
        .hook(showColorScheme, (revealer) => {
            if (showColorScheme.value == true)
              revealer.revealChild = true;
            else
              revealer.revealChild = isHoveredColorschemeSettings.value;
        })
        .hook(isHoveredColorschemeSettings, (revealer) => {
            if (isHoveredColorschemeSettings.value == false) {
              setTimeout(() => {
                  if (isHoveredColorschemeSettings.value == false)
                    revealer.revealChild = showColorScheme.value;
              }, 2000);
            }
        })
    },
})
