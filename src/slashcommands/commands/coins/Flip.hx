package slashcommands.commands.coins;

import com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate;
import com.raidandfade.haxicord.types.structs.MessageStruct;
import haxe.Timer;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.structs.Embed;
import com.fataliti.types.SlashResponse;
import com.fataliti.types.SlashCommand.SlashCommandArgumentType;
import com.fataliti.types.InteractionData;

using Utils;

class Flip extends Slash {

    static var flips:Array<String> = new Array();

    override function initialize() {
        slashCommand = {
            name: 'flip',
            description: 'Бросить монетку',
            options: [
                {
                    name: 'ставка',
                    type: SlashCommandArgumentType.INTEGER,
                    description: 'Ставка на которую будет вестись флип'
                }
            ]
        }
        
        slashCommand.registerSlashCommand();
    }

    override function action(d:InteractionData) {

        if (flips.contains(d.member.user.id)) {
            d.resonseAnswer('Стоит подождать');
            return;
        }

        var coins:Null<Int> = d.getInteractionValue('ставка');
        if (coins == null) {
            coins = 0;
        }

        var balance = Rgd.db.request('SELECT coins FROM users WHERE userId = "${d.member.user.id}"').getIntResult(0);
        
        if (coins <= balance) {
            
            var user = new GuildMember(d.member, Rgd.bot.getGuildUnsafe(Rgd.rgdId), Rgd.bot);

            var response:SlashResponse = {
                type: InteractionCallbackType.CHANNEL_MESSAGE_WITH_SOURCE,
                data: {
                    embeds: [{
                        author: {
                            icon_url: user.user.avatarUrl,
                            name: '${user.displayName} подбросил монетку',
                        },
                        description: '**ПОДБРАСЫВАЕМ...**\n__Ставка:__ $coins <:rgd_coin_rgd:745172019619823657>\n__Баланс:__ $balance <:rgd_coin_rgd:745172019619823657>',
                        thumbnail: {
                            url: 'https://cdn.discordapp.com/emojis/518875396545052682.gif?v=1'
                        },
                        color: 0xFF9900,
                    }],
                }
            }

            Rgd.bot.endpoints.commandResponse(response, d.id, d.token, (dd, e)-> {
                if (e == null) {
                    flips.push(d.member.user.id);
                    var timer = new Timer(1000*3);
                    timer.run = function () {

                        var win = Std.random(100) % 2 == 0 ? true : false;
                        if (!win) {
                            coins *= -1;
                        }
                        Rgd.db.request('UPDATE users SET coins = coins + $coins WHERE userId = "${d.member.user.id}"');
                        flips.remove(d.member.user.id);

                        var embed:Embed = {
                            description: '**${win ? 'ПОБЕДА!' : 'ПРОИГРЫШ'}**\n__Ставка:__ ${Math.abs(coins)} <:rgd_coin_rgd:745172019619823657>\n__Баланс:__ ${balance+coins} <:rgd_coin_rgd:745172019619823657>',
                            thumbnail: {
                                url: win ? "https://cdn.discordapp.com/emojis/518875768814829568.png?v=1" : "https://cdn.discordapp.com/emojis/518875812913610754.png?v=1"
                            },
                            color: 0xFF9900,
                        }

                        Rgd.bot.endpoints.commandResponseGet(Rgd.appId, d.token, (msg, error) -> {
                            if (error == null) {
                                Rgd.bot.endpoints.commandResponseEdit(Rgd.appId, d.token, cast msg.id, {
                                    embeds: [embed]
                                });
                            }

                        });

                        timer.stop();
                    }
                }
            });
        } else {
            d.resonseAnswer('Извините, <@${d.member.user.id}>, но у вас недостаточно монет');
        }

    }
}