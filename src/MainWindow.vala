/*
* Copyright © 2020 Cassidy James Blaede (https://cassidyjames.com)
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

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            border_width: 0,
            icon_name: Application.instance.application_id,
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
        web_view.load_uri ("https://" + Application.instance.subdomain + ".slack.com");

        var logo = new Gtk.Image.from_resource ("/com/github/cassidyjames/slack/splash.png") {
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

        web_view.load_changed.connect ((load_event) => {
            if (load_event == WebKit.LoadEvent.FINISHED) {
                stack.visible_child_name = "web";
            }
        });
    }
}
