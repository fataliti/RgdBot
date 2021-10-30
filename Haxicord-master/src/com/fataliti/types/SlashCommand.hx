package com.fataliti.types;

import com.raidandfade.haxicord.types.Snowflake;

typedef SlashCommand = {
    var name:String;
    var description:String;
    @:optional var options:Array<SlashCommandOption>;
    @:optional var default_permission:Bool;
}


typedef SlashCommandOption = {
    var name:String;
    var description:String;
    var type:SlashCommandArgumentType;
    @:optional var required:Bool;
    @:optional var choices:Array<SlashCommandOptionChoise>;
    @:optional var options:Array<SlashCommandOption>;
}

typedef SlashCommandOptionChoise = {
    var name:String;
    var value:Dynamic;
}

@:enum
abstract SlashCommandArgumentType(Int) {
    var SUB_COMMAND       = 1;
    var SUB_COMMAND_GROUP = 2;
    var STRING            = 3;
    var INTEGER           = 4;
    var BOOLEAN           = 5;
    var USER              = 6;
    var CHANNEL           = 7;
    var ROLE              = 8;
    var MENTIONABLE       = 9;
}


typedef SlashCommandRegister = {
    var id:String;
    var name:String;
    var application_id:String;
    var description:String;
    
    var type:Int;
    var version:Int;

    @:optional var guild_id:String;
    @:optional var default_permission:Bool;
    @:optional var options:SlashCommandOption;
}

typedef SlashCommandPermission = {
    var id:String;
    var type:CommandPermissionType;
    var permission:Bool;
} 

typedef SlashCommandPermissions = {
    var permissions:Array<SlashCommandPermission>;
}


@:enum
abstract CommandPermissionType(Int) {
    var ROLE = 1;
    var USER = 2;
}