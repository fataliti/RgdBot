import com.raidandfade.haxicord.endpoints.Endpoints.ErrorReport;
import com.fataliti.types.SlashResponse;
import com.fataliti.types.SlashCommand;
import com.fataliti.types.InteractionData;
import com.raidandfade.haxicord.types.Message;


class Utills {
    public static function answer(m:Message, text:String) {
        m.reply({embed: {description: text}});
    }   


    public static function isOtec(m:Message):Bool {
        return m.author.id.id == "371690693233737740";
    }


    public static function removeQuotes(txt:String):String {
        return StringTools.replace(txt, '"', '');
    }


    public static function isBossUser(userId:String):Bool {
        return InitData.userBossList.contains(userId);
    }


    public static function getInteractionValue(d:InteractionData, valueName:String):Null<Dynamic> {
        if (d.data.options == null) {
            return null;
        }

        for (interactionOption in d.data.options) {
            if (interactionOption.name == valueName) {
                return interactionOption.value;
            }
        }

        return null;
    }


    public static function getInteractionOption(d:InteractionData, valueName:String):Null<Dynamic> {
        if (d.data.options == null) {
            return null;
        }

        for (interactionOption in d.data.options) {
            if (interactionOption.name == valueName) {
                return interactionOption;
            }
        }

        return null;
    }


    public static function getInteractionOptionValue(d:InteractionDataOption, valueName:String):Null<Dynamic> {
        if (d.options == null) {
            return null;
        }

        for (interactionOption in d.options) {
            if (interactionOption.name == valueName) {
                return interactionOption.value;
            }
        }

        return null;
    }

    public static function registerSlashCommand(command:SlashCommand, cb:SlashCommandRegister->ErrorReport->Void = null) {
        Rgd.bot.endpoints.registerGuildCommand(command, Rgd.appId, Rgd.rgdId, cb);
    }

}

class InteractionTool {
    public static function response(d:InteractionData, response:SlashResponse):Void {
        Rgd.bot.endpoints.commandResponse(response, d.id, d.token);
    }

    public static function resonseAnswer(d:InteractionData, answer:String):Void {
        var responce_data:SlashResponse = {
            type: InteractionCallbackType.CHANNEL_MESSAGE_WITH_SOURCE,
            data: {
                embeds: [
                    {
                        description: answer
                    }
                ]
            }
        }

        Rgd.bot.endpoints.commandResponse(responce_data, d.id, d.token);
    }

}