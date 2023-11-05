---@diagnostic disable: undefined-global

awesome.connect_signal("lockscreen::show", function()
    awesome.spawn("lock")
end)
