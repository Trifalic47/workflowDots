local function next_song()
    local handle = io.popen(os.getenv("HOME") .. "/workflowDots/rmpc/rmpc/next_song.sh")
    local url = handle:read("*a")
    handle:close()

    url = url:gsub("%s+", "")

    if url ~= "" then
        mp.commandv("loadfile", url, "replace")
    end
end

mp.register_event("end-file", next_song)
