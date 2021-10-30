package events;


import com.fataliti.types.InteractionData;
import com.fataliti.types.SlashResponse;


class OnInteraction {
    public static function onInteraction(d:InteractionData) {
        var command = Rgd.slashCommands.get(d.data.name); 
        command(d);
    } 
}

