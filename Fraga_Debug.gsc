#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_blockers;

init()
{
	if(getDvarInt("FragaDebug"))
		level.debug = true;
	else
		level.debug = false;
	
	if(level.debug)
	{
		if(GetDvar("score") == "")
			setdvar( "score", "69420" );
		level.player_out_of_playable_area_monitor = 0;
		level thread debugmode();
		setdvar("sv_cheats", level.debug);
		setdvar("cg_ufo_scaler", 1);
		while(true)
		{
			level waittill( "connected", player );
			player thread connected();
		}
	}
}

connected()
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    flag_wait( "start_zombie_round_logic" );
	if(level.script == "zm_prison")
	{
		flag_wait( "afterlife_start_over" );
	}
	self.score = GetDvarInt("score");
	//self thread speak();
}

speak()
{
	wait 5;
	while(1)
	{
		/*
		if(!isdefined(level.forced_box_guns))
		{
			i = 0;
			self iprintln("a");
			foreach(weapon in level.zombie_weapons) 
			{
				i++;
				self iprintln(weapon.is_in_box + "   " + i);
				wait 1;
			}
		}
		else
		self iprintln(level.forced_box_guns.size);
		wait 1;
		*/

		self iprintln(level.plutoversion);
		i = 0;
		foreach(weapon in level.zombie_weapons)
		{
			i++;
			self iprintln(weapon.is_in_box + "   " + i);
			wait 1;
		}
		/*
		if(level.debug)
			self iprintln("Debug mode is active");
		else
			self iprintln("Debug mode is not active");
		wait 1;
		*/
	}
}

debugmode()
{
	level.debugmode.hidewheninmenu = 1;
    level.debugmode = createserverfontstring( "objective", 1.3 );
    level.debugmode.y = 20;
    level.debugmode.x = 0;
    level.debugmode.fontscale = 1;
    level.debugmode.alignx = "center";
    level.debugmode.horzalign = "user_center";
    level.debugmode.vertalign = "user_top";
    level.debugmode.aligny = "top";
    level.debugmode.alpha = 1;
    level.debugmode.label = &"DEBUG MODE";
}