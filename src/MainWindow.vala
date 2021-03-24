/*
* Copyright © 2020–2021 Cassidy James Blaede (https://cassidyjames.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Cassidy James Blaede <c@ssidyjam.es>
*/

public class Slack.MainWindow : Gtk.Window {
    private Slack.WebView web_view;
    private uint configure_id;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            border_width: 0,
            icon_name: App.instance.application_id,
            resizable: true,
            title: "Slack",
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        default_height = 700;
        default_width = 1000;

        var header = new Gtk.HeaderBar () {
            has_subtitle = false,
            show_close_button = true
        };
        header.get_style_context ().add_class ("default-decoration");

        web_view = new Slack.WebView ();
        web_view.load_uri ("https://" + App.instance.subdomain + ".slack.com");

        var logo = new Gtk.Image.from_resource ("/com/cassidyjames/slack/splash.png") {
            expand = true,
            margin_bottom = 48
        };

        var stack = new Gtk.Stack () {
            transition_duration = 300,
            transition_type = Gtk.StackTransitionType.UNDER_UP
        };
        stack.get_style_context ().add_class ("loading");
        stack.add_named (logo, "loading");
        stack.add_named (web_view, "web");

        set_titlebar (header);
        add (stack);

        int window_x, window_y;
        int window_width, window_height;
        App.settings.get ("window-position", "(ii)", out window_x, out window_y);
        App.settings.get ("window-size", "(ii)", out window_width, out window_height);

        if (window_x != -1 || window_y != -1) {
            move (window_x, window_y);
        }

        resize (window_width, window_height);

        if (App.settings.get_boolean ("window-maximized")) {
            maximize ();
        }

        web_view.notify["title"].connect (() => {
            string title_to_set = web_view.title;
            if (title_to_set != "") {
                title = title_to_set;
            } else {
                title = "Slack";
            }
        });

        web_view.load_changed.connect ((load_event) => {
            if (load_event == WebKit.LoadEvent.FINISHED) {
                stack.visible_child_name = "web";
            }
        });

        App.settings.bind ("zoom", web_view, "zoom-level", SettingsBindFlags.DEFAULT);

        var accel_group = new Gtk.AccelGroup ();

        accel_group.connect (
            Gdk.Key.plus,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                zoom_in ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.equal,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                zoom_in ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.minus,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                zoom_out ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.@0,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                zoom_default ();
                return true;
            }
        );

        add_accel_group (accel_group);
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id == 0) {
            // Avoid spamming the settings
            configure_id = Timeout.add (200, () => {
                configure_id = 0;

                if (is_maximized) {
                    App.settings.set_boolean ("window-maximized", true);
                } else {
                    App.settings.set_boolean ("window-maximized", false);

                    int width, height;
                    get_size (out width, out height);
                    App.settings.set ("window-size", "(ii)", width, height);

                    int root_x, root_y;
                    get_position (out root_x, out root_y);
                    App.settings.set ("window-position", "(ii)", root_x, root_y);
                }

                return GLib.Source.REMOVE;
            });
        }

        return base.configure_event (event);
    }

    private void zoom_in () {
        if (web_view.zoom_level < 5.0) {
            web_view.zoom_level = web_view.zoom_level + 0.1;
        } else {
            Gdk.beep ();
        }

        return;
    }

    private void zoom_out () {
        if (web_view.zoom_level > 0.2) {
            web_view.zoom_level = web_view.zoom_level - 0.1;
        } else {
            Gdk.beep ();
        }

        return;
    }

    private void zoom_default () {
        if (web_view.zoom_level != 1.0) {
            web_view.zoom_level = 1.0;
        } else {
            Gdk.beep ();
        }

        return;
    }
}
