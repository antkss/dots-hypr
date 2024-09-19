import Widget from "resource:///com/github/Aylur/ags/widget.js";
import { getClientIcon, ignoreAppsClass } from "../lib/client.js";
import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";
import * as Utils from "resource:///com/github/Aylur/ags/utils.js";
const { Gdk, GLib, Gtk } = imports.gi;

// const barHeight = 5;
const workspaceDotCss = {
  active:
    "min-width:1rem;min-height:1rem;border-radius:999rem;background-color:#fff",
  noActive:
    "min-width:1rem;min-height:1rem;border-radius:999rem;background-color:#666",
  notice:
    "min-width:1rem;min-height:1rem;border-radius:999rem;background-color:red",
};

const clientInfoWidget = () => {
  const clientIconBox = Widget.Box({
    css: `min-height:3rem;min-width:3rem;`,
    hpack: "fill",
    vpack: "fill",
    child: Widget.Icon({
      setup: (self) =>
        Utils.timeout(10, () => {
          if (self._destroyed) {
            return;
          }
          const styleContext = self.get_parent().get_style_context();
          const height = styleContext.get_property(
            "min-height",
            Gtk.StateFlags.NORMAL,
          );
          self.size = height - 3;
        }),
    }).hook(Hyprland.active.client, (self) => {
          const appClass = Hyprland.active.client.class.toLowerCase();
          const title=Hyprland.active.client.title
          if (!appClass) {
            return;
          }
          if (ignoreAppsClass.indexOf(appClass) !== -1) {
            return;
          }
          self.icon = getClientIcon(appClass,title);
        }),
  });

const labels = Widget.Label({
	label: `${Hyprland.active.workspace.id}`,
});

  const singleDots = () => {
    return Widget.Box({
	className: 'no_active_dot',
      // css: workspaceDotCss["noActive"],
    });
  };
  const workspaceStatus = Widget.Box({
    vpack: "center",
    hpack: "center",
    spacing: 7,
    attribute: {
      "update": (self) => {
        const workspace = Hyprland.active.workspace;
        const childs = self.children;
        childs.map((item, index) => {
          if (index == workspace.id - 1) {
            item.setCss(workspaceDotCss["active"]);
          } else {
            item.setCss(workspaceDotCss["noActive"]);
          }
        });
      },
    },
    setup: (self) => {
      const childs = [];
      const nums = 7;
      for (let index = 0; index < nums; index++) {
        const dots = singleDots();
        childs.push(dots);
      }
      self.children = childs;
    },

  }).hook(Hyprland.active.workspace, (self) => {
	  self.attribute.update(self)
	  App.openWindow("center");
	Utils.timeout(2000, () => {
	App.closeWindow("center");
	});
	  
});
  const widget = Widget.CenterBox({
	  className: "recent_panel",
    startWidget: clientIconBox,
    centerWidget: workspaceStatus,
    // endWidget: clientStatus,
  });

  return widget;
};

export default clientInfoWidget;
