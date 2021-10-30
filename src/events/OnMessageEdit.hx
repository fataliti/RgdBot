package events;

import commands.RoleMessage;
import com.raidandfade.haxicord.types.Message;

class OnMessageEdit {
    
    public static function onMessageEdit(m:Message) {
        if (RoleMessage.managerInstance.messages.exists(m.id.id)) {
            RoleMessage.managerInstance.messages.set(m.id.id, m);
        }
    }

}