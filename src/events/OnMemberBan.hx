package events;

import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.Guild;

class OnMemberBan {
    public static function onMemberBan(g:Guild, u:User) {
        if (g.id.id != Rgd.rgdId) return;

		Rgd.bot.endpoints.sendMessage(Rgd.msgChan, {content: 'https://cdn.discordapp.com/attachments/697115584986349608/851896200252489778/91a6f1b8aa44.360.mp4'});

        var needToSave = Rgd.db.request('SELECT * FROM unban WHERE userId = "${u.id.id}"').results().isEmpty();
        if (!needToSave) {
            var cb = (e, d) -> {
                trace(e);
                trace(d);
            }
            Rgd.bot.endpoints.unbanMember(Rgd.rgdId, u.id.id, "under safe", cb);
        }

	}
}