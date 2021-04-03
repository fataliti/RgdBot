package com.raidandfade.haxicord.types.structs;

import com.raidandfade.haxicord.types.GuildMember;

typedef VoiceState = {
    @:optional var guild_id:String;
    var channel_id:String;
    var user_id:String;
    @:optional var member:GuildMember;
    var session_id:String;
    var deaf:Bool;
    var mute:Bool;
    var self_deaf:Bool;
    var self_mute:Bool;
    @:optional var self_stream:Bool;
    var self_video:Bool;
    var suppress:Bool;
}

typedef VoiceRegion = {
    var id:String;
    var name:String;
    var sample_hostname:String;
    var sample_port:Int;
    var vip:Bool;
    var optimal:Bool;
    var deprecated:Bool;
    var custom:Bool;
}