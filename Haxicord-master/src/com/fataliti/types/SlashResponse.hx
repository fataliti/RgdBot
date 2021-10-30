package com.fataliti.types;

import com.raidandfade.haxicord.types.structs.Embed;

typedef SlashResponse = {
    var type:InteractionCallbackType;
    var data:SlashResponseData;
}

typedef SlashResponseData = {
    @:optional var tts:Bool;
    @:optional var content:String;
    @:optional var embeds:Array<Embed>;
    @:optional var allowed_mentions:Bool;
    @:optional var flags:Int;
    @:optional var components:Array<Dynamic>;
} 


@:enum
abstract InteractionCallbackType(Int) {
    var PONG = 1;
    var CHANNEL_MESSAGE_WITH_SOURCE = 4;
    var DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE = 5;
    var DEFERRED_UPDATE_MESSAGE = 6;
    var UPDATE_MESSAGE = 7;
}