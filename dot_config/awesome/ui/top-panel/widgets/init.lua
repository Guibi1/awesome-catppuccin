-- require(... .. ".tasklist")
require(... .. ".taglist")

return {
    clock = require(... .. ".clock"),
    cpu = require(... .. ".cpu"),
    date = require(... .. ".date"),
    battery = require(... .. ".battery"),
    disk = require(... .. ".disk"),
    keyboard = require(... .. ".keyboard"),
    layoutbox = require(... .. ".layoutbox"),
    mem = require(... .. ".mem"),
    menu = require(... .. ".menu"),
    notifications = require(... .. ".notifications"),
    systray = require(... .. ".systray"),
    volume = require(... .. ".volume"),
    seperator = require(... .. ".seperator"),
}
