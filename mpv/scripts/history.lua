mp.register_event("file-loaded", function()
    local url = mp.get_property("path")
    local title = mp.get_property("media-title")

    if not url then return end

    local file = os.getenv("HOME") .. "/.local/share/rmpc/history.tsv"
    os.execute("mkdir -p " .. os.getenv("HOME") .. "/.local/share/rmpc")

    local f = io.open(file, "a")
    if f then
        f:write(os.time() .. "\t" .. url .. "\t" .. (title or "unknown") .. "\n")
        f:close()
    end
end)
