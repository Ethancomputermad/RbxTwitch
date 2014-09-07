--[[
The MIT License (MIT)

Copyright (c) 2014 Ethancomputermad

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

oauth_token='' --Enter an OAuth token here for access to cool functions

--TwitchAPI by Ethancomputermad
settings={}

settings.GlobalCache=true --If set to true, then the cache is shared between all scripts, otherwise each script has its own cache
settings.LaunchFunction='RBXTwitch'
settings.UpdateSpeed=10 --Checks events every X seconds
--[[
  
--]]
http=function(addr,data)
	addr=addr.."?oauth_token="..oauth_token
	print('Connecting to ',addr)
	res=game:GetService('HttpService'):GetAsync(addr) wait()
	print('Responce was ',res)
	pcall(function() res=LoadLibrary('RbxUtility').DecodeJSON(res) end)
	return res
end
function CreateSignal()
	local this = {}

	local mBindableEvent = Instance.new('BindableEvent')
	local mAllCns = {} --all connection objects returned by mBindableEvent::connect

	--main functions
	function this:connect(func)
		if self ~= this then error("connect must be called with `:`, not `.`", 2) end
		if type(func) ~= 'function' then
			error("Argument #1 of connect must be a function, got a "..type(func), 2)
		end
		local cn = mBindableEvent.Event:connect(func)
		mAllCns[cn] = true
		local pubCn = {}
		function pubCn:disconnect()
			cn:disconnect()
			mAllCns[cn] = nil
		end
		return pubCn
	end
	function this:disconnect()
		if self ~= this then error("disconnect must be called with `:`, not `.`", 2) end
		for cn, _ in pairs(mAllCns) do
			cn:disconnect()
			mAllCns[cn] = nil
		end
	end
	function this:wait()
		if self ~= this then error("wait must be called with `:`, not `.`", 2) end
		return mBindableEvent.Event:wait()
	end
	local that={}
	function that:fire(...)
		if self ~= this then error("fire must be called with `:`, not `.`", 2) end
		mBindableEvent:Fire(...)
	end

	return this,that
end
if settings.GlobalCache then cache={}
end
twitch={['tv']=function(channel)
	--Create channel obj
	local onlineLast=false
	function online(cn) local d=cache[cn..' Stream'] if d==nil then
		local n=http('https://api.twitch.tv/kraken/streams/'..channel,auth)
		cache[cn..' Stream']=n
		d=n end
	return d['stream']~=nil end
	local onlineEvnt
	local offlineEvnt
	coroutine.wrap(function()
		local onlineEvnt_control
		onlineEvnt,onlineEvnt_control=CreateSignal()
		local offlineEvent_control
		offlineEvnt,offlineEvnt_control=CreateSignal()
		while true do
			local online_now=online(channel)
			if online_now~=onlineLast then
				onlineLast=online_now pcall(function()
				if online_now==true then 
					onlineEvnt_control:fire()
				else
					offlineEvnt_control:fire()
				end end)
			end
			wait(settings.UpdateSpeed)
		end
	end)()
	if not settings.GlobalCache then local cache={} end
	if cache[channel..' Stream']==nil then
		cache[channel..' Stream']=http('https://api.twitch.tv/kraken/streams/'..channel,auth)
		repeat wait() until cache[channel..' Stream']~=nil --Wait for inital request
	end 
	print('Defining gcs')
	function gcs(cn) return cache[cn..' Stream'] end
	c_obj={}
    setmetatable(c_obj,{['__index']=function(_,request)
		if request=='online' then
			if gcs(channel)~=nil then
				return gcs(channel)['stream']~=nil
			end
			local chreq=http('https://api.twitch.tv/kraken/streams/'..channel,auth)
			cache[channel..' Stream']=chreq
			return chreq['stream']~=nil
		elseif request=='broadcaster' then
			if online(channel)==true then
				local r=gcs(channel).stream.broadcaster return r==nil and "" or r
			else return "" end
		elseif request=='viewers' then
			if online(channel)==true then
				return gcs(channel).stream.viewers
			else return 0 end
		elseif request=='game' then
			if online(channel)==true then
				return gcs(channel).stream.game
			else return 0 end
		elseif request=='flush_cache' then
			return function(what) if what==nil then cache={} else cache[what]=nil end end
		elseif request=='start_streaming' then
			return onlineEvnt
		elseif request=='stopped_streaming' then
			return offlineEvnt
		end
	end})
	return c_obj
end}
if script.ClassName=='ModuleScript' then
	return function() getfenv(0)['twitch']=twitch end
else
_G[settings.LaunchFunction]=function()
	getfenv(0)['twitch']=twitch	
end
end
