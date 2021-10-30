package events;

import com.fataliti.types.SlashCommand;
import com.fataliti.types.SlashCommand.SlashCommandArgumentType;
import commands.User;
import commands.Help;
import haxe.Timer;
import events.OnVoiceStateUpdate.VoiceUpdateStruck;
import sys.db.Sqlite;
import haxe.rtti.Meta;

import slashcommands.Slash;

class OnReady {
    public static function onReady() {


        Rgd.db = Sqlite.open("rgd.db");

        CompileTime.importPackage("commands");
        var classList = CompileTime.getAllClasses("commands");
        for (_class in classList) {
            var statics = Meta.getStatics(_class);

            for(s in Reflect.fields(statics)) {
                if (s == "initialize") {
                    Reflect.callMethod(_class, Reflect.field(_class,s),[]);
                    continue;
                }

                var field = Reflect.field(statics, s);

                if (!Reflect.hasField(field, "command"))
                    continue;

                var names:Array<String> = field.command[0];
                for(name in  names) {
                    var command:Rgd.Command = {_class:_class, command: s, admin: Reflect.hasField(field, "admin"), inbot: Reflect.hasField(field, "inbot")}
                    Rgd.commandMap.set(name, command);
                }
            } 
        }

        CompileTime.importPackage("slashcommands");
        CompileTime.importPackage("slashcommands.commands");
        var slashClass:List<Class<Slash>> = CompileTime.getAllClasses("slashcommands.commands");
        for (_class_type in slashClass) {
            var d = Type.createInstance(_class_type, []);
        }


        Rgd.bot.getGuild(Rgd.rgdId, guild -> {
            for (member in guild.members) {
                Rgd.db.request('
                    INSERT OR IGNORE INTO 
                    users(userId, first, here)
                    VALUES("${member.user.id.id}", "${member.joined_at.toString()}", 1)
                ');
                for (s in member.roles) {
                    var has = Rgd.db.request('SELECT count(*) FROM usersRole WHERE userId = "${member.user.id.id}" and roleId = "$s"').getIntResult(0);
                    if (has == 0) 
                        Rgd.db.request('INSERT INTO usersRole(userId, roleId) VALUES("${member.user.id.id}", "$s")');
                }
            }

            var voice_states:Array<VoiceUpdateStruck> = guild.voice_states;
            for (m in voice_states) {
                if (m.member == null || m.member.user.bot) continue;
                OnVoiceStateUpdate.voiceMap.set(m.user_id, Date.now());
            }
        });


        Rgd.db.request('INSERT OR IGNORE INTO day(userId) SELECT userId FROM users');
        Rgd.db.request('INSERT OR IGNORE INTO week(userId) SELECT userId FROM users');


        var time = Date.now();


        if (time.getHours() < 15) {
            var daylyTimer = new Timer((1000*60)*(((15-(time.getHours()+1))*60) - (time.getMinutes()+1)));
            daylyTimer.run = function () {
                Help.postDay(Rgd.msgChan);
                Rgd.db.request('DELETE FROM day');
                daylyTimer.stop();
            }
        }

        if (time.getDay() == 6 && time.getHours() < 15) {
            var weekTimer = new Timer((1000*60)*(((15-(time.getHours()+1))*60) - (time.getMinutes()+1)));
            weekTimer.run = function () {
                Help.postWeek(Rgd.msgChan);
                Rgd.db.request('DELETE FROM week');
                weekTimer.stop();
            }
        }


        if (time.getHours() < 5) {
            var birthdayTimer = new Timer((1000*60)*(((5-(time.getHours()+1))*60) - (time.getMinutes()+1)));
            birthdayTimer.run = function () {
                User.postBirth(Rgd.msgChan);
                birthdayTimer.stop();
            }
        }

        // Rgd.bot.endpoints.registerCommand({
        //     name: "aboba",
        //     type: 1,
        //     description: "pososi"
        // }, Rgd.appId, Rgd.rgdId);

        trace("RGD online");
    }

    
}