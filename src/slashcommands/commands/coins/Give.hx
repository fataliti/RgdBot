package slashcommands.commands.coins;

import com.fataliti.types.InteractionData;
import com.fataliti.types.SlashCommand.SlashCommandArgumentType;
using Utils;

class Give extends Slash {
    
    override function initialize() {
        slashCommand = {
            name: 'give',
            description: 'передать кому-то часть своих монет',
            options: [
                {
                    name: 'ping',
                    description: 'кому передать',
                    required: true,
                    type: SlashCommandArgumentType.USER,
                },
                {
                    name: 'amount',
                    description: 'колличество передаваемых монет',
                    required: true,
                    type: SlashCommandArgumentType.INTEGER,
                }
            ]
        }
        
        slashCommand.registerSlashCommand();
    }


    override function action(d:InteractionData) {
        
        var user:String = d.getInteractionValue('ping');
        var amount:Int  = d.getInteractionValue('amount');

        if (user == d.member.user.id) {
            d.resonseAnswer('зачем передавать самому себе');
            return;
        }

        if (amount <= 0) {
            d.resonseAnswer('Нельзя передавать такие числа');
            return;
        }

        var has = Rgd.db.request('SELECT coins FROM users WHERE userId = "${d.member.user.id}"').getIntResult(0);
        if (has < amount) {
            d.resonseAnswer('Недостаточно монет для передачи');
            return;
        } 

        Rgd.db.request('UPDATE users SET coins = coins - $amount WHERE userId = "${d.member.user.id}"');
        Rgd.db.request('UPDATE users SET coins = coins + $amount WHERE userId = "${user}"');

        
        d.resonseAnswer('<@${d.member.user.id}> передал <@${user}> `$amount` <:rgd_coin_rgd:745172019619823657>');

    }

}