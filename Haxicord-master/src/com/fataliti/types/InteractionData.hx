package com.fataliti.types;

import com.raidandfade.haxicord.types.structs.GuildMember;
import com.raidandfade.haxicord.types.structs.User;


typedef InteractionData = {
    var type:Int;
    var token:String;
    @:optional var member:GuildMember;
    @:optional var user:User;
    var id:String;
    var guild_id:String;
    var data: {
        var options: Array<InteractionDataOption>;
        var name:String;
        var id:String;
        @:optional var target_id:String;
    }
    var channel_id:String;
}


typedef  InteractionDataOption = {
    var name:String;
    var value:String;
    var options: Array<InteractionDataOption>;
}