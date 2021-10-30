package slashcommands;

import com.fataliti.types.InteractionData;
import com.fataliti.types.SlashCommand;

class Slash {

    public var slashCommand:SlashCommand;

    public function action(d:InteractionData):Void {};
    public function initialize():Void {};
    public function down():Void {};


    public function new() {
        initialize();
        
        Rgd.slashCommands.set(slashCommand.name, action);
    }
}

