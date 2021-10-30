package slashcommands.commands.coins;


import com.raidandfade.haxicord.types.structs.Embed;
import com.fataliti.types.SlashResponse;
using Utils;

import com.raidandfade.haxicord.types.User;

import com.fataliti.types.SlashCommand.SlashCommandArgumentType;
import com.fataliti.types.InteractionData;

class Coin extends Slash {

    override function initialize() {
        slashCommand = {
            name: "coin",
            description: "Узнать колличество монет у пользователя",
            options: [
                {
                    type: SlashCommandArgumentType.SUB_COMMAND,
                    name: 'top',
                    description: 'рейтинг пользователей по монетам'
                },
                {
                    name: 'balance',
                    description: 'узнать сколько у пользователя монет',
                    type: SlashCommandArgumentType.SUB_COMMAND,
                    options: [
                        {
                            name: 'user',
                            type: SlashCommandArgumentType.USER,
                            description: 'тэг человека',
                        }
                    ]
                }
            ]
        }

        Utills.registerSlashCommand(slashCommand);
    }


    override function action(d:InteractionData) {

        var user_option:Null<InteractionDataOption> = d.getInteractionOption('balance');
        var top_option:Null<InteractionDataOption> = d.getInteractionOption('top');

        if (top_option != null)  {
            
            var top = Rgd.db.request('SELECT userId,coins FROM users WHERE here = 1 ORDER BY coins DESC LIMIT 10');
            var c = '';
            var p = 1;

            for (pos in top) 
                c += '${p++}. <@${pos.userId}> :`${pos.coins}` \n';
            

            var embed:Embed = {
                author: {icon_url: 'https://cdn.discordapp.com/emojis/518875768814829568.png?v=1', name: 'Топ по монетам'},
                fields: [
                    {name: '**Никнейм**', value: c, _inline: true}, 
                ]
            }

            var responseData:SlashResponse = {
                type: InteractionCallbackType.CHANNEL_MESSAGE_WITH_SOURCE,
                data: {
                    embeds: [ embed ]
                }
            }
            
            d.response(responseData);

        } else if (user_option != null) {
            
            var user:Null<String> = user_option.getInteractionOptionValue('user');
            var userId:String;
            if (user != null) {
                userId = user;
            } else {
                userId = d.member.user.id;
            }
            var has = Rgd.db.request('SELECT coins FROM users WHERE userId = "${userId}"').getIntResult(0);
            var responseData:SlashResponse = {
                type: InteractionCallbackType.CHANNEL_MESSAGE_WITH_SOURCE,
                data: {
                    embeds: [
                        {
                            description: 'У <@$userId> `$has` монет<:rgd_coin_rgd:745172019619823657>'
                        }
                    ]
                }
            }
            d.response(responseData);
        }
    }
}