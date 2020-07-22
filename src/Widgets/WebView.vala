/*
* Copyright © 2020 Cassidy James Blaede (https://cassidyjames.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
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

public class Slack.WebView : WebKit.WebView {
    public WebView () {
        Object (
            expand: true,
            user_content_manager: new WebKit.UserContentManager ()
        );
    }

    construct {
        var webkit_settings = new WebKit.Settings () {
            default_font_family = Gtk.Settings.get_default ().gtk_font_name,
            enable_accelerated_2d_canvas = true,
            enable_back_forward_navigation_gestures = true,
            enable_dns_prefetching = true,
            enable_html5_database = true,
            enable_html5_local_storage = true,
            enable_smooth_scrolling = true,
            enable_webgl = true,
            hardware_acceleration_policy = WebKit.HardwareAccelerationPolicy.ALWAYS
        };

        settings = webkit_settings;
        web_context = new Slack.WebContext ();

        button_release_event.connect ((event) => {
            if (event.button == 8) {
                go_back ();
                return true;
            } else if (event.button == 9) {
                go_forward ();
                return true;
            }

            return false;
        });
    }
}
