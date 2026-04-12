local utils = require "mp.utils"

local function save_video()
    local url = mp.get_property("path")

    if not url or not string.match(url, "youtube%.com") then
        mp.osd_message("Not a YouTube URL")
        return
    end

    utils.subprocess_detached({
        args = {
            os.getenv("HOME") .. "/.config/mpv/save_youtube.sh",
            url
        }
    })

    mp.osd_message("⬇ Download started")
end

mp.add_key_binding("S", "save-video", save_video)
