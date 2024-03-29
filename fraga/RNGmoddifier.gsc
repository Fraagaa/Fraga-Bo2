#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_perk_random;
#include maps\mp\zombies\_zm_perks;

Templars( s_last_recapture_zone )
{
	a_s_player_zones = [];

	foreach ( str_key, s_zone in level.zone_capture.zones )
	{
		if ( s_zone ent_flag( "player_controlled" ) )
			a_s_player_zones[str_key] = s_zone;
	}

	s_recapture_zone = undefined;

	if ( a_s_player_zones.size )
	{
		if ( isdefined( s_last_recapture_zone ) )
		{
			n_distance_closest = undefined;

			foreach ( s_zone in a_s_player_zones )
			{
				n_distance = distancesquared( s_zone.origin, s_last_recapture_zone.origin );

				if ( !isdefined( n_distance_closest ) || n_distance < n_distance_closest )
				{
					s_recapture_zone = s_zone;
					n_distance_closest = n_distance;
				}
			}
		}
		else if (GetDvarInt("Templars") != 0)  
		{
			s_recapture_zone = level.zone_capture.zones["generator_nml_right"];
		}
		else
		{
			s_recapture_zone = random( a_s_player_zones );
		}
	}

	return s_recapture_zone;

}


TemplarsManipulated()
{
	self endon( "disconnect" );
	if(GetDvarInt("Templars") != 0)
	{
		flag_wait("initial_blackscreen_passed");
		wait(0.2);
		self iprintln("^6Templars ^1Manipulated");
	}
}

/*
perkRNG()
{
	switch(GetDvarInt("perkRNG"))
	{
	case 0:
		replaceFunc(maps\mp\zombies\_zm_perk_random::get_weighted_random_perk, ::getWeightedRandomPerk);
		break;
	case 2:
		replaceFunc(maps\mp\zombies\_zm_perk_random::get_weighted_random_perk, ::getWeightedRandomPerk2);
		break;
	case 3:
		replaceFunc(maps\mp\zombies\_zm_perk_random::get_weighted_random_perk, ::getWeightedRandomPerk3);
		break;
	case 4:
		replaceFunc(maps\mp\zombies\_zm_perk_random::get_weighted_random_perk, ::getWeightedRandomPerk4);
		break;
	}
}

getWeightedRandomPerk( player )
{
	if(!player hasperk("specialty_armorvest"))
c		return("specialty_armorvest");
	}
	else
	{
		if(!player hasperk("specialty_rof"))
		{	
			return("specialty_rof");
		}
		else
		{
			if(!player hasperk("specialty_flakjacket"))
			{	
				return("specialty_flakjacket");
			}
			else
			{
				if(!player hasperk("specialty_fastreload"))
				{	
					return("specialty_fastreload");
				}
				else
				{
					if(!player hasperk("specialty_longersprint"))
					{	
						return("specialty_longersprint");
					}
					else
					{
						if(!player hasperk("specialty_additionalprimaryweapon"))
						{	
							return("specialty_additionalprimaryweapon");
						}
						else
						{
							if(!player hasperk("specialty_quickrevive"))
							{	
								return("specialty_quickrevive");
							}
							else
							{
								if(!player hasperk("specialty_grenadepulldeath"))
								{	
									return("specialty_grenadepulldeath");
								}
								else
								{
									return("specialty_deadshot");
								}
							}
						}
					}
				}
			}
		}
	}
}
*/


perfectperks()
{
	if(GetDvarInt("perkrng") == 0)
	{
		replaceFunc(maps\mp\zombies\_zm_perks::give_random_perk, ::giverandomperk);
	}
}

giverandomperk()
{
	random_perk = undefined;
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	perks = [];
	i = 0;
	while ( i < vending_triggers.size )
	{
		perk = vending_triggers[ i ].script_noteworthy;
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			i++;
			continue;
		}
		if ( perk == "specialty_weapupgrade" )
		{
			i++;
			continue;
		}
		if ( !self hasperk( perk ) && !self has_perk_paused( perk ) )
		{
			perks[ perks.size ] = perk;
		}
		i++;
	}
	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		random_perk = perks[ 0 ];
		while ( random_perk == "specialty_nomotionsensor" && perks.size > 1 )
		{
			perks = array_randomize( perks );
			random_perk = perks[ 0 ];
		}
		self give_perk( random_perk );
	}
	else
	{
		self playsoundtoplayer( level.zmb_laugh_alias, self );
	}
	return random_perk;
}