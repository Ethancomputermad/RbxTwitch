RBXTwitch
=========

A twitch library for ROBLOX, allows interaction via the twitch api (dev.twitch.tv)

Documentation:

Step 1) Starting RBXTwitch in your scripts
=========

If RBXTwitch is a Script:

You should call your Launch Function, by default this is _G.RBXTwitch(), but if you have changed settings.LaunchFunction replace RBXTwitch with your launch function name

If RBXTwitch is a ModuleScript:

You should call RBXTwitch using the following:
require(RBXTwitch.ModuleScript.GoesHere)()

Step 2) Getting channel information
=========

You can obtain information for a channel using the following function once RBXTwitch has started in your script

your_variable=twitch.tv('ChannelNameGoesHere')

Step 3) Documentation of the channel information provider
=========

[table] ChannelController - Made from twitch.tv('ChannelNameGoesHere')

Contains: 

[function] .online - Returns whether the channel is online

[function] .broadcaster - Returns the broadcasting software being used

[function] .viewers - Returns the amount of viewers watching the channel, if the channel is offline returns 0

[function] .game - Returns the game being played on the channel

[event] .start_streaming - Is an event that is fired whenever the script detects that the channel has begun streaming

[event] .stopped_streaming - Is an event that is fired whenever the script detects that the channel has finished streaming

[function] .flush_cache - When called flushes the script's cache, forcing all new values to be up to date

Suggestions?
=========
http://www.roblox.com/My/NewMessage.aspx?RecipientID=6710154
