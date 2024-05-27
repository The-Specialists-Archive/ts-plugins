#include <amxmodx>
#include <fun>

public plugin_init() 
{
    register_plugin("Conditionmod", "1.0", "Shin Lee")
    set_task(1.0,"heal_hud",0,"",0,"b")
}

public heal_hud() 
{
   	new num, players[32]
	get_players(players,num,"ac")
	for( new i = 0;  i < num; i++ ) 
        {
        switch (get_user_health(players[i])) 
        {
        case 0 .. 9 : 
        {
            set_hudmessage(255,0,0,-1.0,-10.0,0,0.0,99.9,0.0,0.0,4)
            show_hudmessage(0, "Physical Condition: VERY CRITICAL!")
        }
        case 10 .. 24 : 
        {
            set_hudmessage(255,0,0,-1.0,-10.0,0,0.0,99.9,0.0,0.0,4)
            show_hudmessage(0, "Physical Condition: Critical!")
        }
        case 25 .. 49 : 
        {
            set_hudmessage(255,0,0,-1.0,-10.0,0,0.0,99.9,0.0,0.0,4)
            show_hudmessage(0, "Physical Condition: Hurt")
        }
        case 50 .. 74 : 
        {
            set_hudmessage(255,0,0,-1.0,-10.0,0,0.0,99.9,0.0,0.0,4)
            show_hudmessage(0,"Physical Condition: Scratched")
        }
        case 75 .. 99 : 
        {
            set_hudmessage(255,0,0,-1.0,-10.0,0,0.0,99.9,0.0,0.0,4)
            show_hudmessage(0,"Physical Condition: Fine")
        }
        case 100 .. 199 : 
        {
            set_hudmessage(255,0,0,-1.0,-10.0,0,0.0,99.9,0.0,0.0,4)
            show_hudmessage(0,"Physical Condition: Excellent")
        }
        default : 
        {
            set_hudmessage(255,0,0,-1.0,-10.0,0,0.0,99.9,0.0,0.0,4)
            show_hudmessage(0,"Physical Condition: Overcharged!")
        }
      }
   }
}