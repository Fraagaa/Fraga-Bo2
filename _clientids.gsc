#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\zombies\_zm_craftables;
#include maps\mp\zombies\_zm_ai_leaper;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zm_prison_sq_bg;
#include maps\mp\zm_alcatraz_craftables;
#include maps\mp\zombies\_zm_afterlife;
#include maps\mp\zombies\_zm_weap_tomahawk;
#include maps\mp\zombies\_zm_perk_random;
#include maps\mp\zombies\_zm_unitrigger;
#using_animtree("fxanim_props");
/* No tiene lo de las kills en fr */
/* No tiene lo de la velocidad en fr */
/* Solo está en inglés */
/* No tiene modo noche*/
/* No le cambie los graficos */
/* La llave no sigue a la caja en mob*/
/* La wunderfizz no está fija en el gen 4 */
/* Perk order can not be manipulated */
init()
{
    level.trackers = 1;
    self endon( "disconnect" );
	thread setdvars();
	thread fix_highround();
    if(!isDefined(level.total_chest_accessed))
        level.total_chest_accessed = 0;

    level thread firstbox();
	level thread boxhits();
	level thread detect_cheats();
	level thread frkills();
	thread buried_init();
	thread dierise_init();
	thread origins_init();
	thread mob_init();
	thread tranzit_init();
    thread nuketown_init();
    while(true)
    {
        level waittill("connecting", player);
        player thread connected();
    }
}


connected()
{
	self endon("disconnect");
	self waittill("spawned_player");
	self thread timer_fraga();
	self thread timerlocation();
	self thread velocity_meter();
    self thread setFragaLanguage();
}

origins_init()
{
	if(level.script != "zm_tomb")
		return;
	level thread origins_connected();	
	level thread boxlocation();
}

origins_connected()
{
	while(1)
	{
		level waittill("connecting", player);
        if(level.trackers)
        {
            player thread PanzerTracker();
            player thread TemplarTracker();
		    player thread tankTracker();
        }
		if(getDvarInt("character") != 0)
			level.givecustomcharacters = ::set_character_option_origins;
	}
}

/* Buried */

buried_init()
{
	if(level.script != "zm_buried")
		return;
    level thread connected_buried();
	level thread buildable_controller();
}

connected_buried()
{
	while(1)
	{
		level waittill("connecting", player);
		player thread onconnect_buried();
		player thread bank();
		player thread award_permaperks_safe();
		player thread fridge();
		if(getDvarInt("character") != 0)
			level.givecustomcharacters = ::set_character_option_buried;
	}
}

/* Die Rise */
onconnect_buried()
{
	self.initial_stats = array();
	self thread watch_stat( "springpad_zm", array( "zm_highrise", "zm_buried" ) );
	self thread watch_stat( "turbine" );
	self thread watch_stat( "subwoofer_zm" );
}


dierise_init()
{
	if(level.script != "zm_highrise")
		return;
    level thread dierise_connected();
	level thread buildable_controller();
}

dierise_connected()
{
	while(1)
	{
		level waittill("connecting", player);
		player thread dierise_onconnect();
    	player thread bank();
    	player thread award_permaperks_safe();
        player thread fridge();
        if(level.trackers)
		    player thread leapertracker();
		self.initial_stats = array();
		self thread watch_stat("springpad_zm");
		if(getDvarInt("character") != 0)
			level.givecustomcharacters = ::set_character_option_dierise;
	}
}

dierise_onconnect()
{
	self.initial_stats = array();
	self thread watch_stat( "springpad_zm", array( "zm_highrise", "zm_buried" ) );
}

/* MOB */
mob_init()
{
	if(level.script != "zm_prison")
		return;
	level thread setup_master_key_override();
    level thread mob_connected();
	level thread boxlocation();
}

mob_connected()
{
	while(1)
	{
		level waittill("connecting", player);
        if(level.trackers)
		    player thread BrutusTracker();
		if(getDvarInt("character") != 0)
			level.givecustomcharacters = ::set_character_option_mob;
		player thread trap_timer_fraga();
		player thread givetomahawk();
	}
}

/* Tranzit */

tranzit_init()
{
	if(level.script != "zm_transit")
		return;
    if (istranzit())
		level thread connected();
	if(!istranzit())
		level thread avg();
	if(istown())
		level thread boxlocation();
}

tranzit_connected()
{
	while(1)
	{
		level waittill("connecting", player);
        player thread fridge();
    	player thread bank();
    	player thread award_permaperks_safe();
		if(getDvarInt("character") != 0)
			level.givecustomcharacters = ::set_character_option_transit;
	}
}


nuketown_init()
{
    if(level.script != "zm_nuked")
        return;
    level thread connected();
	level thread boxlocation();
	level thread avg();
	level waittill("connecting", player);
	player thread checkpaplocation();
	//level.nextperkindex = -1;
	//replacefunc(maps\mp\zm_nuked_perks::bring_random_perk, ::perk_order);
}

nuketown_connected()
{
	if(getDvarInt("character") != 0)
		level.givecustomcharacters = ::set_character_option_nuketown;
}

/* General use */
timer_fraga()
{
	self endon("disconnect");

	self thread roundtimer_fraga();
	self.timer_fraga = newclienthudelem(self);
	self.timer_fraga.alpha = 0;
	self.timer_fraga.color = (1, 1, 1);//(0.505, 0.478, 0.721);
	self.timer_fraga.hidewheninmenu = 1;
	self.timer_fraga.fontscale = 1.7;
	self thread timer_fraga_watcher();
	flag_wait("initial_blackscreen_passed");
	self.timer_fraga settimerup(0);
	level waittill("end_game");
	level.total_time = level.total_time - 0.1;

	while(1)
	{
		self.timer_fraga settimer(level.total_time);
		wait(0.1);
	}
}

timer_fraga_watcher()
{
	self endon("disconnect");
	level endon("end_game");

	while(1)
	{
		while(GetDvarInt("timer") == 0)
		{
			wait(0.1);
		}
		self.timer_fraga.alpha = 1;
		while(GetDvarInt("timer") >= 1)
		{
			wait(0.1);
		}
		self.timer_fraga.alpha = 0;
	}
}

roundtimer_fraga()
{
	self endon("disconnect");

	self.roundtimer_fraga = newclienthudelem(self);
	self.roundtimer_fraga.alpha = 0;
	self.roundtimer_fraga.fontscale = 1.7;
	self.roundtimer_fraga.color = (0.8, 0.8, 0.8);
	self.roundtimer_fraga.hidewheninmenu = 1;
	self.roundtimer_fraga.x = self.timer_fraga.x;
	self.roundtimer_fraga.y = self.timer_fraga.y + 15;
	flag_wait("initial_blackscreen_passed");
	self thread roundtimer_fraga_watcher();
	level.fade_time = 0.2;

	while(1)
	{
		zombies_this_round = level.zombie_total + get_round_enemy_array().size;
		hordes = zombies_this_round / 24;
		dog_round = flag("dog_round");
		leaper_round = flag("leaper_round");
		self.roundtimer_fraga settimerup(0);
		start_time = int(GetTime() / 1000);
		level waittill("end_of_round");
		end_time = int(GetTime() / 1000);
		time = end_time - start_time;
		self display_round_time(time, hordes, dog_round, leaper_round);
		level waittill("start_of_round");
		self.roundtimer_fraga.label = &"";
		if(GetDvarInt("roundtimer") >= 1)
		{
			self.roundtimer_fraga fadeovertime(level.fade_time);
			self.roundtimer_fraga.alpha = 1;
		}
	}
}

display_round_time(time, hordes, dog_round, leaper_round)
{
	timer_for_hud = time - 0.1;
	sph_off = 1;

	if(level.round_number > GetDvarInt("sph") && !dog_round && !leaper_round)
		sph_off = 0;

	self.roundtimer_fraga fadeovertime(level.fade_time);
	self.roundtimer_fraga.alpha = 0;
	wait(level.fade_time * 2);
	self.roundtimer_fraga.label = &"Round time: ";
	self.roundtimer_fraga fadeovertime(level.fade_time);
	self.roundtimer_fraga.alpha = 1;
	if(sph_off)
	{
		for(i = 0; i < 225; i++)
		{
			self.roundtimer_fraga settimer(timer_for_hud);
			wait(0.05);
		}
	}
	else
	{
		for(i = 0; i < 100; i++)
		{
			self.roundtimer_fraga settimer(timer_for_hud);
			wait(0.05);
		}
		self.roundtimer_fraga fadeovertime(level.fade_time);
		self.roundtimer_fraga.alpha = 0;
		wait(level.fade_time * 2);
		self display_sph(time, hordes);
	}
}

display_sph(time, hordes)
{
	sph = time / hordes;
	self.roundtimer_fraga fadeovertime(level.fade_time);
	self.roundtimer_fraga.alpha = 1;
	self.roundtimer_fraga.label = &"SPH: ";
	self.roundtimer_fraga setvalue(sph);

	for(i = 0; i < 5; i++)
	{
		wait(1);
	}

	self.roundtimer_fraga fadeovertime(level.fade_time);
	self.roundtimer_fraga.alpha = 0;
	wait(level.fade_time);
}

roundtimer_fraga_watcher()
{
	self endon("disconnect");
	level endon("end_game");

	while(1)
	{
		while(GetDvarInt("roundtimer") == 0)
		{
			wait(0.1);
		}

		self.roundtimer_fraga.y = GetDvarInt("timery") + 15;
		self.roundtimer_fraga.alpha = 1;

		while(GetDvarInt("roundtimer") >= 1)
		{
			wait(0.1);
		}

		self.roundtimer_fraga.alpha = 0;
	}
}

timerlocation()
{
	self endon("disconnect");

	while(true)
	{
		switch(getDvarInt("timer"))
		{
			case 0:
				self.timer_fraga.alpha = 0;
				self.roundtimer_fraga.alpha = 0;
				break;
			case 1:
				self.timer_fraga.alignx = "left";
				self.timer_fraga.aligny = "top";
				self.timer_fraga.horzalign = "user_left";
				self.timer_fraga.vertalign = "user_top";
				self.roundtimer_fraga.alignx = "left";
				self.roundtimer_fraga.aligny = "top";
				self.roundtimer_fraga.horzalign = "user_left";
				self.roundtimer_fraga.vertalign = "user_top";
				self.timer_fraga.x = 1;
				self.timer_fraga.y = 250;
				self.timer_fraga.alpha = 1;
				self.roundtimer_fraga.alpha = 1;
				break;
			case 2:
				self.roundtimer_fraga.alignx = "left";
				self.roundtimer_fraga.aligny = "top";
				self.roundtimer_fraga.horzalign = "user_left";
				self.roundtimer_fraga.vertalign = "user_top";
				self.timer_fraga.alignx = "left";
				self.timer_fraga.aligny = "top";
				self.timer_fraga.horzalign = "user_left";
				self.timer_fraga.vertalign = "user_top";
				self.timer_fraga.x = 1;
				self.timer_fraga.y = 0;
				self.timer_fraga.alpha = 1;
				self.roundtimer_fraga.alpha = 1;
				if(isorigins())
					self.timer_fraga.y = 45;
				if(issurvivalmap())
					self.timer_fraga.y = 40;
				if(isdierise() && level.springpad_hud.alpha != 0)
					self.timer_fraga.y = 10;
				if(isburied() && level.springpad_hud.alpha != 0)
					self.timer_fraga.y = 35;
				if(istranzit() && getDvarInt("bus"))
					self.timer_fraga.y = 21;
				if(istranzit() && getDvarInt("bus") && GetDvar("language") == "japanese")
					self.timer_fraga.y = 25;
				break;
			case 3:
				self.roundtimer_fraga.alignx = "right";
				self.roundtimer_fraga.aligny = "top";
				self.roundtimer_fraga.horzalign = "user_right";
				self.roundtimer_fraga.vertalign = "user_top";
				self.timer_fraga.alignx = "right";
				self.timer_fraga.aligny = "top";
				self.timer_fraga.horzalign = "user_right";
				self.timer_fraga.vertalign = "user_top";
				self.timer_fraga.x = -1;
				self.timer_fraga.y = 13;
				self.timer_fraga.alpha = 1;
				self.roundtimer_fraga.alpha = 1;
				if(getDvar("cg_drawFPS") != "Off")
					self.timer_fraga.y += 4;
				if(getDvar("cg_drawFPS") != "Off" && GetDvar("language") == "japanese")
					self.timer_fraga.y += 10;
				if(ismob())
				{
					self.timer_fraga.y = 40;
					self.trap_timer_fraga.y = 19;
				}
				if(isdierise())
					self.timer_fraga.y = 30;
				break;
			case 4:
				self.roundtimer_fraga.alignx = "right";
				self.roundtimer_fraga.aligny = "top";
				self.roundtimer_fraga.horzalign = "user_right";
				self.roundtimer_fraga.vertalign = "user_top";
				self.timer_fraga.alignx = "right";
				self.timer_fraga.aligny = "top";
				self.timer_fraga.horzalign = "user_right";
				self.timer_fraga.vertalign = "user_top";
				self.timer_fraga.x = -170;
				self.timer_fraga.y = 415;
				self.timer_fraga.alpha = 1;
				self.roundtimer_fraga.alpha = 1;
				break;

			default: break;
		}
		self.roundtimer_fraga.x = self.timer_fraga.x;
		self.roundtimer_fraga.y = self.timer_fraga.y + 15;
		
		wait 0.1;
		if(GetDvar("language") == "japanese")
		{
			self.timer_fraga.fontscale = 1.5;
			self.roundtimer_fraga.fontscale = self.timer_fraga.fontscale;
		}
	}
}


istown()
{
	return (level.script == "zm_transit" && level.scr_zm_map_start_location == "town" && level.scr_zm_ui_gametype_group == "zsurvival");
}

isfarm()
{
	return (level.script == "zm_transit" && level.scr_zm_map_start_location == "farm" && level.scr_zm_ui_gametype_group == "zsurvival");
}

isdepot()
{
	return (level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zsurvival");
}

istranzit()
{
	return (level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zclassic");
}

isnuketown()
{
	return (level.script == "zm_nuked");
}

isdierise()
{
	return (level.script == "zm_highrise");
}

ismob()
{
	return (level.script == "zm_prison");
}

isburied()
{
	return (level.script == "zm_buried");
}

isorigins()
{
	return (level.script == "zm_tomb");
}

is_round(round)
{
	return round <= level.round_number;
}

issurvivalmap()
{
	return (isnuketown() || istown() || isfarm() || isdepot());
}

isvictismap()
{
	return (istranzit() || isburied() || isdierise());
}

setDvars()
{
    setdvar("sv_cheats", 0 );
    setdvar("player_strafeSpeedScale", 1 );
    setdvar("player_backSpeedScale", 1 );
    setdvar("r_dof_enable", 0 );
	if(GetDvar("box") == "")
		setdvar("box", 1);
	if(GetDvar("character") == "")
		setdvar("character", 0);
	if(GetDvar("FragaDebug") == "")
		setdvar("FragaDebug", 0);
    if(getdvar("SR") == "")
        setdvar("SR", 0 );
    if(getdvar("bus") == "")
        setdvar("bus", 0 );
    if(getdvar("graphictweaks") == "")
        setdvar("graphictweaks", 0 );
    if(getdvar("color") == "")
        setdvar("color", "0.505 0.478 0.721");
    if(getdvar("sph") == "")
        setdvar("sph", 50 );
    if(getdvar("timer") == "")
        setdvar("timer", 1 );
    if(getdvar("roundtimer") == "")
        setdvar("roundtimer", 1 );
    if(getdvar("splits") != "")
        setdvar("splits", 0 );
	if( getdvar("nightmode") == "")
		setdvar("nightmode", 0 );
	if(GetDvar("firstbox") == "")
		setdvar("firstbox", 0);
    
    if(isvictismap())
    {
        if(GetDvar("pers_perk") == "")
            setdvar("pers_perk", 1);
        if(GetDvar("full_bank") == "")
            setdvar("full_bank", 1);
        if(GetDvar("buildables") == "")
            setdvar("buildables", 1);
        if(getdvar("fridge") == "")
            setdvar("fridge", "m16");
    }
    if(ismob())
    {
        if(getDvarInt("tracker") == "")
            setDvar("tracker", 1);
        if(getdvar("traptimer") == "")
            setdvar("traptimer", 0 );
    }
    if(isorigins())
    {
        if(GetDvar("templars") == "")
            setdvar("templars", 0);
        if(getDvarInt("tracker") == "")
            setDvar("tracker", 1);
        if(GetDvar("perkRNG") == "")
            setdvar("perkRNG", 1);
    }
    if(isburied())
    {
        if(GetDvar("perkRNG") == "")
            setdvar("perkRNG", 1);
    }
    if(isdierise())
    {
        if(getDvarInt("tracker") == "")
            setDvar("tracker", 1);
    }
    if(isnuketown())
    {
        if(getDvar("perkRNG") == "")
            setDvar("perkRNG", 1);
    }
}

fix_highround()
{
	if(level.script == "zm_tomb")
		return;
	while(level.round_number > 155)
	{
		zombies = getaiarray("axis");
		i = 0;
		while(i < zombies.size)
		{
			if(zombies[i].targetname != "zombie")
			{
				continue;
			}
			if(zombies[i].targetname == "zombie")
			{
				if(!isdefined(zombies[i].health_override))
				{
					zombies[i].health_override = 1;
					zombies[i].health = 1044606723;
				}
			}
			i++;
		}
		wait(0.1);
	}
}

detect_cheats()
{
    level thread cheatsActivated();
    level thread firstboxActivated();
    level thread perkrng();
    level thread tempalars();
}

cheatsActivated()
{
	level.cheats.hidewheninmenu = 1;
    level.cheats = createserverfontstring( "objective", 1.3 );
    level.cheats.y = 20;
    level.cheats.x = 0;
    level.cheats.fontscale = 3;
    level.cheats.alignx = "center";
    level.cheats.horzalign = "user_center";
    level.cheats.vertalign = "user_top";
    level.cheats.aligny = "top";
    level.cheats.alpha = 0;

    while(1)
    {
        if(getDvarInt("sv_cheats"))
            level.cheats.alpha = 1;
        if(!getDvarInt("sv_cheats"))
            level.cheats.alpha = 0;
        wait 0.1;
    }
}

firstboxActivated()
{
	level.firstbox_active.hidewheninmenu = 1;
    level.firstbox_active = createserverfontstring( "objective", 1.3 );
    level.firstbox_active.y = -20;
    level.firstbox_active.x = 0;
    level.firstbox_active.fontscale = 1;
    level.firstbox_active.alignx = "center";
    level.firstbox_active.horzalign = "user_center";
    level.firstbox_active.vertalign = "user_bottom";
    level.firstbox_active.aligny = "bottom";
    level.firstbox_active.label = &"^2^FFirstbox active";
    level.firstbox_active.alpha = 0;
    if(getDvarInt("firstbox"))
    while(level.round_number < 2)
    {
            level.firstbox_active.alpha = 1;
            wait 0.1;
    }
    level.firstbox_active destroy();
}

perkrng()
{
	level.perkrng_desabled.hidewheninmenu = 1;
    level.perkrng_desabled = createserverfontstring( "objective", 1.3 );
    level.perkrng_desabled.y = -30;
    level.perkrng_desabled.x = 0;
    level.perkrng_desabled.fontscale = 1;
    level.perkrng_desabled.alignx = "center";
    level.perkrng_desabled.horzalign = "user_center";
    level.perkrng_desabled.vertalign = "user_bottom";
    level.perkrng_desabled.aligny = "bottom";
    level.perkrng_desabled.label = &"^4^FPerk RNG manipulated";
    if(isburied() || isorigins() || isnuketown())
    {
        if(!getDvarInt("perkRNG"))
        while(level.round_number < 2)
        {
            level.perkrng_desabled.alpha = 1;
            wait 0.1;
        }
    }
    level.perkrng_desabled destroy();
}

tempalars()
{
	level.templar_modiffied.hidewheninmenu = 1;
    level.templar_modiffied = createserverfontstring( "objective", 1.3 );
    level.templar_modiffied.y = -40;
    level.templar_modiffied.x = 0;
    level.templar_modiffied.fontscale = 1;
    level.templar_modiffied.alignx = "center";
    level.templar_modiffied.horzalign = "user_center";
    level.templar_modiffied.vertalign = "user_bottom";
    level.templar_modiffied.aligny = "bottom";
    level.templar_modiffied.label = &"^6^FTemplars manipulated";
    if(isburied() || isorigins() || isnuketown())
    {
        if(getDvarInt("templars"))
        while(level.round_number < 2)
        {
            level.templar_modiffied.alpha = 1;
            wait 0.1;
        }
    }
    level.templar_modiffied destroy();;
}

/* Box stuff */

boxhits()
{
	level.boxhits.hidewheninmenu = 1;
    level.boxhits = createserverfontstring( "objective", 1.3 );
    level.boxhits.y = 0;
    if(isdierise())
        level.boxhits.y = 10;
    level.boxhits.x = 0;
    level.boxhits.fontscale = 1.4;
    level.boxhits.alignx = "center";
    level.boxhits.horzalign = "user_center";
    level.boxhits.vertalign = "user_top";
    level.boxhits.aligny = "top";
    level.boxhits.alpha = 0;
	level.boxhits.label = &"^3Box hits: ^4";
    level.boxhits setvalue(0);
    if(issurvivalmap())
    {
        level.boxhits.alignx = "left";
        level.boxhits.horzalign = "user_left";
        level.boxhits.x = 2;
        level.boxhits.alpha = 1;
    }
    while(!isDefined(level.total_chest_accessed))
        wait 0.1;
    lol = 0;
    while(1)
    {
        while(!isdefined(level.chest_accessed))
            wait 0.1;
        if(lol != level.chest_accessed)
        {
            level.total_chest_accessed++;
            lol = level.chest_accessed;
            level.boxhits setvalue(level.total_chest_accessed);
            i = 1;
            if(!issurvivalmap())
            {
                while(true)
                {
                    i -= 0.02;
                    level.boxhits.alpha = i;
                    wait 0.1;
                    if(i < 0.1)
                    {
                        level.boxhits.alpha = 0;
                        break;
                    }
                }
            }
        }
        wait 0.1;
    }
    wait 1;
}

avg()
{
    level thread label();
    level thread display();
    level thread make_avg();
}

label()
{
    self endon("disconnect");

    if(!isDefined(level.total_mk2))
        level.total_mk2 = 0;
    if(!isDefined(level.total_raygun))
        level.total_raygun = 0;
    if(!isDefined(level.avgraygunmk2))
        level.avgraygunmk2 = 0;
    if(!isDefined(level.avgraygun))
        level.avgraygun = 0;

	level.raygunavg.hidewheninmenu = 1;
    level.raygunavg = createserverfontstring( "objective", 1.3 );
    level.raygunavg.y = 26;
    level.raygunavg.x = 2;
    level.raygunavg.fontscale = 1.3;
    level.raygunavg.alignx = "left";
    level.raygunavg.horzalign = "user_left";
    level.raygunavg.vertalign = "user_top";
    level.raygunavg.aligny = "top";
    level.raygunavg.label = &"^3Raygun AVG: ^4";
    level.raygunavg.alpha = 1;
	level.raygunmk2avg.hidewheninmenu = 1;
    level.raygunmk2avg = createserverfontstring( "objective", 1.3 );
    level.raygunmk2avg.y = 14;
    level.raygunmk2avg.x = 2;
    level.raygunmk2avg.fontscale = 1.3;
    level.raygunmk2avg.alignx = "left";
    level.raygunmk2avg.horzalign = "user_left";
    level.raygunmk2avg.vertalign = "user_top";
    level.raygunmk2avg.aligny = "top";
    level.raygunmk2avg.label = &"^3Raygun MK2 AVG: ^4";
    level.raygunmk2avg.alpha = 1;
    track_rayguns();
}

track_rayguns()
{
	level waittill("connecting", player);
    while(true)
    {
        if(player has_weapon_or_upgrade("ray_gun_zm"))
            level.total_raygun++;
        if(player has_weapon_or_upgrade("raygun_mark2_zm"))
            level.total_mk2++;

        while(player has_weapon_or_upgrade("ray_gun_zm") || player has_weapon_or_upgrade("raygun_mark2_zm")) 
        {
            if(player has_weapon_or_upgrade("ray_gun_zm") || player has_weapon_or_upgrade("raygun_mark2_zm"))
                wait 0.1;
        }
        wait 1;
    }
}

make_avg()
{
    while(1)
    {
        if(level.total_chest_accessed)
        {
            level.avgraygunmk2 = (level.total_chest_accessed / level.total_mk2);
            level.avgraygun = (level.total_chest_accessed / level.total_raygun);
        }
        wait 0.1;
    }
}
display()
{
    self endon("disconnect");
    
	level.displayraygunmk2avg.hidewheninmenu = 1;
    level.displayraygunmk2avg = createserverfontstring( "objective", 1.3 );
    level.displayraygunmk2avg.y = 14;
    if(getDvar("language") == "japanese")
        level.displayraygunavg.x = 143;
    level.displayraygunmk2avg.x = 82;
    level.displayraygunmk2avg.fontscale = 1.3;
    level.displayraygunmk2avg.alignx = "left";
    level.displayraygunmk2avg.horzalign = "user_left";
    level.displayraygunmk2avg.vertalign = "user_top";
    level.displayraygunmk2avg.aligny = "top";
    level.displayraygunmk2avg.label = &"^4";
    level.displayraygunmk2avg.alpha = 1;
    level.displayraygunmk2avg setvalue(0);

	level.displayraygunavg.hidewheninmenu = 1;
    level.displayraygunavg = createserverfontstring( "objective", 1.3 );
    level.displayraygunavg.y = 26;
    level.displayraygunavg.x = 60;
    if(getDvar("language") == "japanese")
        level.displayraygunavg.x = 103;
    level.displayraygunavg.fontscale = 1.3;
    level.displayraygunavg.alignx = "left";
    level.displayraygunavg.horzalign = "user_left";
    level.displayraygunavg.vertalign = "user_top";
    level.displayraygunavg.aligny = "top";
    level.displayraygunavg.label = &"^4";
    level.displayraygunavg.alpha = 1;
    level.displayraygunavg setvalue(0);

    while(1)
    {
        if(isDefined(level.avgraygun))
            level.displayraygunavg setvalue(level.avgraygun);
        if(isDefined(level.avgraygunmk2))
            level.displayraygunmk2avg setvalue(level.avgraygunmk2);
        wait 1;
    }
}

boxlocation()
{
    while(!isdefined(level.chests))
        wait 0.1;
    switch(getDvarInt("box"))
    {
        case 1: 
            if(isorigins())
                level thread startbox("bunker_tank_chest");
            if(isnuketown())
                level thread startbox("start_chest1");
            if(ismob())
                level thread startbox("cafe_chest");
            if(istown())
                level thread startbox("town_chest_2");
            break;
        case 2:
            if(isorigins())
                level thread startbox("bunker_cp_chest");
            if(isnuketown())
                level thread startbox("start_chest2");
            if(ismob())
                level thread startbox("start_chest");
            if(istown())
                level thread startbox("town_chest");
            break;
        default: break;
    }
}

startBox(start_chest)
{
    self endon("disconnect");
    
	for(i = 0; i < level.chests.size; i++)
	{
        if(level.chests[i].script_noteworthy == start_chest)
    		desired_chest_index = i; 
        else if(level.chests[i].hidden == 0)
     		nondesired_chest_index = i;               	
	}

	if( isdefined(nondesired_chest_index) && (nondesired_chest_index < desired_chest_index))
	{
		level.chests[nondesired_chest_index] hide_chest();
		level.chests[nondesired_chest_index].hidden = 1;

		level.chests[desired_chest_index].hidden = 0;
		level.chests[desired_chest_index] show_chest();
		level.chest_index = desired_chest_index;
	}
}

firstbox()
{
	self endon("disconnect");
	flag_wait("initial_blackscreen_passed");

    if(getDvarInt("firstbox"))
    {
        level thread setUpWeapons();

        special_weapon_magicbox_check = level.special_weapon_magicbox_check;
        level.special_weapon_magicbox_check = undefined;

        foreach(weapon in getarraykeys(level.zombie_weapons))   // this is the only difference in the code
            level.zombie_weapons[weapon].is_in_box = 0;
        
        foreach(weapon in level.forced_box_guns)
            level.zombie_weapons[weapon].is_in_box = 1;

        while( (level.total_chest_accessed - level.chest_moves)!= level.forced_box_guns.size && level.round_number < 10)
            wait 1;

        level.special_weapon_magicbox_check = special_weapon_magicbox_check;
        foreach(weapon in getarraykeys(level.zombie_include_weapons))
        {
            if(level.zombie_include_weapons[weapon] == 1)
                level.zombie_weapons[weapon].is_in_box = 1;
        }
    }
}

setUpWeapons()
{
    if(isdefined(level.forced_box_guns))
        return;
    switch(level.script)
    {
        case "zm_transit":
            switch(level.players.size)
            {
                case 1: 
                level.forced_box_guns = array("raygun_mark2_zm", "cymbal_monkey_zm", "emp_grenade_zm");
                break;
                case 2:
                level.forced_box_guns = array("raygun_mark2_zm", "ray_gun_zm", "cymbal_monkey_zm", "emp_grenade_zm");
                break;
                case 3:
                level.forced_box_guns = array("raygun_mark2_zm", "ray_gun_zm", "ray_gun_zm", "cymbal_monkey_zm", "emp_grenade_zm", "cymbal_monkey_zm");
                break;
                case 4:
                level.forced_box_guns = array("raygun_mark2_zm", "ray_gun_zm", "ray_gun_zm", "ray_gun_zm", "cymbal_monkey_zm", "emp_grenade_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                break;
            }
            break;
        
        case "zm_nuked":
            switch(level.players.size)
            {
                case 1: 
                level.forced_box_guns = array("raygun_mark2_zm", "cymbal_monkey_zm");
                break;
                case 2:
                level.forced_box_guns = array("raygun_mark2_zm", "ray_gun_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                break;
                case 3:
                level.forced_box_guns = array("raygun_mark2_zm", "ray_gun_zm", "ray_gun_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                break;
                case 4:
                level.forced_box_guns = array("raygun_mark2_zm", "ray_gun_zm", "ray_gun_zm", "ray_gun_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                break;
            }
            break;

        case "zm_highrise":
            switch(level.players.size)
            {
                case 1: 
                level.forced_box_guns = array("cymbal_monkey_zm");
                break;
                case 2:
                level.forced_box_guns = array("cymbal_monkey_zm", "cymbal_monkey_zm");
                break;
                case 3:
                level.forced_box_guns = array("cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                break;
                case 4:
                level.forced_box_guns = array("cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                break;
            }
            break;

        case "zm_prison":
            switch(level.players.size)
            {
                case 1: 
                level.forced_box_guns = array("raygun_mark2_zm", "blundergat_zm");
                break;
                case 2:
                level.forced_box_guns = array("raygun_mark2_zm", "ray_gun_zm", "blundergat_zm");
                break;
                case 3:
                level.forced_box_guns = array("raygun_mark2_zm", "ray_gun_zm", "ray_gun_zm", "blundergat_zm");
                break;
                case 4:
                level.forced_box_guns = array("raygun_mark2_zm", "ray_gun_zm", "ray_gun_zm", "ray_gun_zm", "blundergat_zm");
                break;
            }
            break;
        case "zm_buried":
            switch(level.players.size)
            {
                case 1: 
                level.forced_box_guns = array("raygun_mark2_zm", "cymbal_monkey_zm", "slowgun_zm");
                break;
                case 2:
                level.forced_box_guns = array("raygun_mark2_zm", "raygun_mark2_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "slowgun_zm");
                break;
                case 3:
                level.forced_box_guns = array("raygun_mark2_zm", "raygun_mark2_zm", "raygun_mark2_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "slowgun_zm");
                break;
                case 4:
                level.forced_box_guns = array("raygun_mark2_zm", "raygun_mark2_zm", "raygun_mark2_zm", "raygun_mark2_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "slowgun_zm");
                break;
            }
            break;
        case "zm_tomb":
            if(getDvar("SR") == 30)
                switch(level.players.size)
                {
                    case 1: 
                    level.forced_box_guns = array("scar_zm", "raygun_mark2_zm", "cymbal_monkey_zm");
                    break;
                    case 2:
                    level.forced_box_guns = array("scar_zm", "scar_zm", "raygun_mark2_zm", "ray_gun_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                    break;
                    case 3:
                    level.forced_box_guns = array("scar_zm", "scar_zm", "scar_zm", "raygun_mark2_zm", "ray_gun_zm", "ray_gun_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                    break;
                    case 4:
                    level.forced_box_guns = array("scar_zm", "scar_zm", "scar_zm", "scar_zm", "raygun_mark2_zm", "ray_gun_zm", "ray_gun_zm", "ray_gun_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                    break;
                }
            else
                switch(level.players.size)
                {
                    case 1: 
                    level.forced_box_guns = array("scar_zm", "raygun_mark2_zm", "m32_zm");
                    break;
                    case 2:
                    level.forced_box_guns = array("scar_zm", "scar_zm", "raygun_mark2_zm", "ray_gun_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                    break;
                    case 3:
                    level.forced_box_guns = array("scar_zm", "scar_zm", "scar_zm", "raygun_mark2_zm", "ray_gun_zm", "ray_gun_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                    break;
                    case 4:
                    level.forced_box_guns = array("scar_zm", "scar_zm", "scar_zm", "scar_zm", "raygun_mark2_zm", "ray_gun_zm", "ray_gun_zm", "ray_gun_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm", "cymbal_monkey_zm");
                    break;
                }
            break;
        default:
            break;
    }
}

/* Victis */


fridge()
{
	if(level.round_number >= 15)
		return;
	
	if(isdierise() || isburied())
	{
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "an94_upgraded_zm+mms");
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 600);
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 50);
	}
	if(istranzit())
	{
		if(getDvar("fridge") == "m16")
		{
			self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "m16_gl_upgraded_zm");
			self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 270);
			self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 30);
			self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "alt_clip", 1);
			self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "alt_stock", 8);
		}
		else
		{
			self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "mp5k_upgraded_zm");
			self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 200);
			self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 40);
		}
	}
}


award_permaperks_safe()
{
	if(level.round_number >= 15)
		return;
	level endon("end_game");
	self endon("disconnect");

	while (!isalive(self))
		wait 0.05;

	wait 0.5;
	{
		perks_to_process = [];
		perks_to_process[perks_to_process.size] = permaperk_array("revive");
		perks_to_process[perks_to_process.size] = permaperk_array("multikill_headshots");
		perks_to_process[perks_to_process.size] = permaperk_array("perk_lose");
		perks_to_process[perks_to_process.size] = permaperk_array("jugg", undefined, undefined, 15);
		perks_to_process[perks_to_process.size] = permaperk_array("flopper", array("zm_buried"));
		perks_to_process[perks_to_process.size] = permaperk_array("box_weapon", array("zm_highrise", "zm_buried"), array("zm_transit"));
		perks_to_process[perks_to_process.size] = permaperk_array("cash_back");
		perks_to_process[perks_to_process.size] = permaperk_array("sniper");
		perks_to_process[perks_to_process.size] = permaperk_array("insta_kill");
		perks_to_process[perks_to_process.size] = permaperk_array("pistol_points");
		perks_to_process[perks_to_process.size] = permaperk_array("double_points");
	}
	foreach (perk in perks_to_process)
	{
		if( !(istranzit() && perk == permaperk_array("box_weapon", array("zm_highrise", "zm_buried"), array("zm_transit"))))
		self resolve_permaperk(perk);
		wait 0.05;
	}
	if(istranzit())
		remove_permaperk("box_weapon");
	wait 0.5;
	self maps\mp\zombies\_zm_stats::uploadstatssoon();
}

permaperk_array(code, maps_award, maps_take, to_round)
{
	/* Damos todas las ventajas en los mapas correspondientes */
	/* Estoy bastante seguro de que no hace falta porque no se cargan en el resto de mapas */
	if (!isDefined(maps_award))
		maps_award = array("zm_transit", "zm_highrise", "zm_buried");
	if (!isDefined(maps_take))
		maps_take = [];
	if (!isDefined(to_round))
		to_round = 255;

	permaperk = [];
	permaperk["code"] = code;
	permaperk["maps_award"] = maps_award;
	permaperk["maps_take"] = maps_take;
	permaperk["to_round"] = to_round;

	return permaperk;
}

resolve_permaperk(perk)
{
	wait 0.05;

	perk_code = perk["code"];

	/* Too high of a round, return out */
	if (is_round(perk["to_round"]))
		return;

	if (isinarray(perk["maps_award"], level.script) && !self.pers_upgrades_awarded[perk_code])
	{
		for (j = 0; j < level.pers_upgrades[perk_code].stat_names.size; j++)
		{
			stat_name = level.pers_upgrades[perk_code].stat_names[j];
			stat_value = level.pers_upgrades[perk_code].stat_desired_values[j];

			self award_permaperk(stat_name, perk_code, stat_value);
		}
	}

	if (isinarray(perk["maps_take"], level.script) && self.pers_upgrades_awarded[perk_code])
		self remove_permaperk(perk_code);
}


award_permaperk(stat_name, perk_code, stat_value)
{
	flag_set("permaperks_were_set");
	self.stats_this_frame[stat_name] = 1;
	self maps\mp\zombies\_zm_stats::set_global_stat(stat_name, stat_value);
	self playsoundtoplayer("evt_player_upgrade", self);
}

remove_permaperk(perk_code)
{
	self.pers_upgrades_awarded[perk_code] = 0;
	self playsoundtoplayer("evt_player_downgrade", self);
}

bank()
{
	level endon("end_game");
	self endon("disconnect");
	flag_wait("initial_blackscreen_passed");

	if(level.round_number != 1)
		return;
	self.account_value = level.bank_account_max;
}

/* Buildables */


watch_stat( stat, map_array )
{
    if ( !isdefined( map_array ) )
        map_array = array( "zm_buried" );

    if ( !isinarray( map_array, level.script ) )
        return;

    level endon( "end_game" );
    self endon( "disconnect" );

    if ( !isdefined( self.initial_stats[stat] ) )
        self.initial_stats[stat] = self getdstat( "buildables", stat, "buildable_pickedup" );

    while ( true )
    {
        stat_number = self getdstat( "buildables", stat, "buildable_pickedup" );
        delta = stat_number - self.initial_stats[stat];

        if ( delta > 0 && stat_number > 0 )
        {
            self.initial_stats[stat] = stat_number;
            level.buildable_stats[stat] = level.buildable_stats[stat] + delta;
            i = 1;
            while(i != 0)
            {
    
                level.turbine_hud.alpha = i;
                level.subwoofer_hud.alpha = i;
                level.springpad_hud.alpha = i;
                i = i -0.02;
                wait 0.1;
            }
            level.turbine_hud.alpha = 0;
            level.subwoofer_hud.alpha = 0;
            level.springpad_hud.alpha = 0;
        }

        wait 0.1;
    }
}

buildable_hud()
{
	level.springpad_hud.hidewheninmenu = 1;
    level.springpad_hud = createserverfontstring( "objective", 1.3 );
    if(level.script == "zm_buried")
        level.springpad_hud.y = 0;
    else
        level.springpad_hud.y = 15;
    level.springpad_hud.x = 2;
    level.springpad_hud.fontscale = 1.1;
    level.springpad_hud.alignx = "left";
    level.springpad_hud.horzalign = "user_left";
    level.springpad_hud.vertalign = "user_top";
    level.springpad_hud.aligny = "top";
    level.springpad_hud setvalue( 0 );
	level.subwoofer_hud.hidewheninmenu = 1;
    level.subwoofer_hud = createserverfontstring( "objective", 1.3 );
    level.subwoofer_hud.y = 10;
    level.subwoofer_hud.x = 2;
    level.subwoofer_hud.fontscale = 1.1;
    level.subwoofer_hud.alignx = "left";
    level.subwoofer_hud.horzalign = "user_left";
    level.subwoofer_hud.vertalign = "user_top";
    level.subwoofer_hud.aligny = "top";
    level.subwoofer_hud setvalue( 0 );
	level.turbine_hud.hidewheninmenu = 1;
    level.turbine_hud = createserverfontstring( "objective", 1.3 );
    level.turbine_hud.y = 20;
    level.turbine_hud.x = 2;
    level.turbine_hud.fontscale = 1.1;
    level.turbine_hud.alignx = "left";
    level.turbine_hud.horzalign = "user_left";
    level.turbine_hud.vertalign = "user_top";
    level.turbine_hud.aligny = "top";
    level.turbine_hud setvalue( 0 );
    level.turbine_hud.alpha = 0;
    level.subwoofer_hud.alpha = 0;
    level.springpad_hud.alpha = 0;
	level.springpad_hud.label = &"^3SPRINGPADS: ^4";
	level.subwoofer_hud.label = &"^3RESONATORS: ^4";
	level.turbine_hud.label = &"^3TURBINES: ^4";

    if ( isdierise() )
    {
        level.subwoofer_hud destroy();
        level.turbine_hud destroy();
    }
}

buildable_controller()
{
    level endon( "end_game" );

    buildable_hud();
    level.buildable_stats = array();
    level.buildable_stats["springpad_zm"] = 0;
    level.buildable_stats["turbine"] = 0;
    level.buildable_stats["subwoofer_zm"] = 0;

	wait 1;
	if(level.buildable_stats["springpad_zm"] > 0)
		level.buildable_stats["springpad_zm"] = 0;
	if(level.buildable_stats["turbine"] > 0)
		level.buildable_stats["turbine"] = 0;
	if(level.buildable_stats["subwoofer_zm"] > 0)
		level.buildable_stats["subwoofer_zm"] = 0;
    while ( true )
    {
        if ( isburied() )
        {
            level.subwoofer_hud setvalue( level.buildable_stats["subwoofer_zm"] );
            level.turbine_hud setvalue( level.buildable_stats["turbine"] );
        }

        level.springpad_hud setvalue( level.buildable_stats["springpad_zm"] );
        wait 0.1;
    }
}

/* Characters */


set_character_option_buried()
{
    switch( getDvarInt("character") )
    {
    case 1:
        self setmodel( "c_zom_player_farmgirl_fb" );
        self setviewmodel( "c_zom_farmgirl_viewhands" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_farmgirl_viewhands" );
        level.vox zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "rottweil72_zm";
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "870mcs_zm";
        self set_player_is_female( 1 );
        self.characterindex = 2;
        break;
    case 2:
        self setmodel( "c_zom_player_oldman_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_oldman_viewhands" );
        level.vox zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "frag_grenade_zm";
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "claymore_zm";
        self set_player_is_female( 0 );
        self.characterindex = 0;
        break;
    case 3:
        self setmodel( "c_zom_player_reporter_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_reporter_viewhands" );
        level.vox zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "beretta93r_zm";
        self.talks_in_danger = 1;
        level.rich_sq_player = self;
        self set_player_is_female( 0 );
        self.characterindex = 1;
        break;
    case 4:
        self setmodel( "c_zom_player_engineer_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_engineer_viewhands" );
        level.vox zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m14_zm";
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m16_zm";
        self set_player_is_female( 0 );
        self.characterindex = 3;
        break;
    }
    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
    self thread set_exert_id();
}

set_character_option_dierise()
{
    switch( getDvarInt("character") )
    {
    case 1:
        self setmodel( "c_zom_player_farmgirl_dlc1_fb" );
        self.whos_who_shader = "c_zom_player_farmgirl_dlc1_fb";
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_farmgirl_viewhands" );
        level.vox zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "rottweil72_zm";
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "870mcs_zm";
        self set_player_is_female( 1 );
        self.characterindex = 2;
        break;
    case 2:
        self setmodel( "c_zom_player_oldman_dlc1_fb" );
        self.whos_who_shader = "c_zom_player_oldman_dlc1_fb";
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_oldman_viewhands" );
        level.vox zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "frag_grenade_zm";
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "claymore_zm";
        self set_player_is_female( 0 );
        self.characterindex = 0;
        break;
    case 3:
        self setmodel( "c_zom_player_reporter_dlc1_fb" );
        self.whos_who_shader = "c_zom_player_reporter_dlc1_fb";
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_reporter_viewhands" );
        level.vox zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "beretta93r_zm";
        self.talks_in_danger = 1;
        level.rich_sq_player = self;
        self set_player_is_female( 0 );
        self.characterindex = 1;
        break;
    case 4:
        self setmodel( "c_zom_player_engineer_dlc1_fb" );
        self.whos_who_shader = "c_zom_player_engineer_dlc1_fb";
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_engineer_viewhands" );
        level.vox zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m14_zm";
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m16_zm";
        self set_player_is_female( 0 );
        self.characterindex = 3;
        break;
    }
    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
    self thread set_exert_id();
}

set_character_option_nuketown()
{
    self detachall();
    switch( getDvarInt("character") )
    {
    case 1:
        self setmodel("c_zom_player_cdc_fb");
        self setviewmodel("c_zom_suit_viewhands");
        self.voice = "american";
        self.skeleton = "base";
        self set_player_is_female( 0 );
        break;
    case 2:
        self setmodel("c_zom_player_cdc_fb");
        self setviewmodel("c_zom_suit_viewhands");
        self.voice = "american";
        self.skeleton = "base";
        self set_player_is_female( 0 );
        break;
    }
    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
    self thread set_exert_id();
}

set_character_option_mob()
{
    switch( getDvarInt("character") )
    {
    case 1:
        self setmodel( "c_zom_player_arlington_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_arlington_coat_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "ray_gun_zm";
        self set_player_is_female( 0 );
        self.character_name = "Arlington";
        break;
    case 2:
        self setmodel( "c_zom_player_oleary_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "judge_zm";
        self set_player_is_female( 0 );
        self.character_name = "Finn";
        break;
    case 3:
        self setmodel( "c_zom_player_deluca_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_deluca_longsleeve_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "thompson_zm";
        self set_player_is_female( 0 );
        self.character_name = "Sal";
        break;
    case 4:
        self setmodel( "c_zom_player_handsome_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_handsome_sleeveless_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "blundergat_zm";
        self set_player_is_female( 0 );
        self.character_name = "Billy";
        break;
    case 5:
        self setmodel( "c_zom_player_handsome_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_ghost_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "blundergat_zm";
        self set_player_is_female( 0 );
        self.character_name = "Billy";
        break;
    }
    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
    self thread set_exert_id();
}

set_character_option_origins()
{
    self detachall();

    if ( !isdefined( self.characterindex ) )
        self.characterindex = assign_lowest_unused_character_index();

    self.favorite_wall_weapons_list = [];
    self.talks_in_danger = 0;

    switch( getDvarInt("character") )
    {
    case 1:
        self setmodel( "c_zom_tomb_richtofen_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_richtofen_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self set_player_is_female( 0 );
        self.character_name = "Richtofen";
        break;
    case 2:
        self setmodel( "c_zom_tomb_dempsey_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_dempsey_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self set_player_is_female( 0 );
        self.character_name = "Dempsey";
        break;
    case 3:
        self setmodel( "c_zom_tomb_nikolai_fb" );
        self.voice = "russian";
        self.skeleton = "base";
        self setviewmodel( "c_zom_nikolai_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self set_player_is_female( 0 );
        self.character_name = "Nikolai";
        break;
    case 4:
        self setmodel( "c_zom_tomb_takeo_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_takeo_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self set_player_is_female( 0 );
        self.character_name = "Takeo";
        break;
    }
    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
    self thread set_exert_id();
}

set_character_option_transit()
{
    
    self.favorite_wall_weapons_list = [];
    self.talks_in_danger = 0;
    switch( getDvarInt("character") )
    {
    case 1:
        self setmodel( "c_zom_player_farmgirl_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_farmgirl_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "rottweil72_zm";
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "870mcs_zm";
        self set_player_is_female( 1 );
        break;
    case 2:
        self setmodel( "c_zom_player_oldman_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_oldman_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "frag_grenade_zm";
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "claymore_zm";
        self set_player_is_female( 0 );
        break;
    case 3:
        self setmodel( "c_zom_player_reporter_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_reporter_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.talks_in_danger = 1;
        level.rich_sq_player = self;
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "beretta93r_zm";
        self set_player_is_female( 0 );
        break;
    case 4:
        self setmodel( "c_zom_player_engineer_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_engineer_viewhands" );
        level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m14_zm";
        self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m16_zm";
        self set_player_is_female( 0 );
        break;
    }
    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
    self thread set_exert_id();
}

set_exert_id()
{
	self endon("disconnect");
	wait_network_frame();
	self maps\mp\zombies\_zm_audio::setexertvoice(self.characterindex);
}

assign_lowest_unused_character_index()
{
    charindexarray = [];
    charindexarray[0] = 0;
    charindexarray[1] = 1;
    charindexarray[2] = 2;
    charindexarray[3] = 3;
    players = get_players();

    if ( players.size == 1 )
    {
        charindexarray = array_randomize( charindexarray );

        if ( charindexarray[0] == 2 )
            level.has_richtofen = 1;

        return charindexarray[0];
    }
    else
    {
        n_characters_defined = 0;

        foreach ( player in players )
        {
            if ( isdefined( player.characterindex ) )
            {
                arrayremovevalue( charindexarray, player.characterindex, 0 );
                n_characters_defined++;
            }
        }

        if ( charindexarray.size > 0 )
        {
            if ( n_characters_defined == players.size - 1 )
            {
                if ( !( isdefined( level.has_richtofen ) && level.has_richtofen ) )
                {
                    level.has_richtofen = 1;
                    return 2;
                }
            }

            charindexarray = array_randomize( charindexarray );

            if ( charindexarray[0] == 2 )
                level.has_richtofen = 1;

            return charindexarray[0];
        }
    }
    return 0;
}

/* Trackers */

leapertracker()
{
	self endon("disconnect");
	if(!isDefined(level.trackingLeapers))
		level.trackingLeapers = true;

	self.lastleaperround = newclienthudelem(self);
	self.lastleaperround.alignx = "left";
	self.lastleaperround.horzalign = "user_left";
	self.lastleaperround.vertalign = "user_top";
	self.lastleaperround.aligny = "top";
	self.lastleaperround.x = 7;
	self.lastleaperround.y = 370;
	self.lastleaperround.fontscale = 1.1;
	self.lastleaperround.sort = 1;
	self.lastleaperround.color = (1, 1 ,1);
	self.lastleaperround.hidewheninmenu = 1;
	self.lastleaperround.alpha = 1;
	self.lastleaperround.label = &"^3Last leaper round: ^4";
	self.lastleaperround setValue(0);
	while(1)
	{
		level waittill("start_of_round");
		if(flag("leaper_round"))
		self.lastleaperround setvalue(level.round_number);
	}
}

PanzerTracker()
{
	self endon("disconnect");
	if(!isDefined(level.trackingPanzers))
		level.trackingPanzers = true;

	self.lastPanzerRound = newclienthudelem(self);
	self.lastPanzerRound.alignx = "left";
	self.lastPanzerRound.horzalign = "user_left";
	self.lastPanzerRound.vertalign = "user_top";
	self.lastPanzerRound.aligny = "top";
	self.lastPanzerRound.x = 7;
	self.lastPanzerRound.y = 310;
	self.lastPanzerRound.fontscale = 1.1;
	self.lastPanzerRound.sort = 1;
	self.lastPanzerRound.color = (1, 1 ,1);
	self.lastPanzerRound.hidewheninmenu = 1;
	self.lastPanzerRound.label = &"^3Last panzer round: ^4";
	self.lastPanzerRound setValue(0);
	while(1)
	{
		level waittill( "spawn_mechz" );
		self.lastPanzerRound setvalue(level.round_number);
	}
}

TemplarTracker()
{
	self endon("disconnect");
	if(!isDefined(level.trackingTemplars))
		level.trackingTemplars = true;

	self.lastTemplarRound = newclienthudelem(self);
	self.lastTemplarRound.alignx = "left";
	self.lastTemplarRound.horzalign = "user_left";
	self.lastTemplarRound.vertalign = "user_top";
	self.lastTemplarRound.aligny = "top";
	self.lastTemplarRound.x = 7;
	self.lastTemplarRound.y = 300;
	self.lastTemplarRound.fontscale = 1.1;
	self.lastTemplarRound.sort = 1;
	self.lastTemplarRound.color = (1, 1 ,1);
	self.lastTemplarRound.hidewheninmenu = 1;
	self.lastTemplarRound.label = &"^3Last templar round: ^4";
	self.lastTemplarRound setValue(0);
	while(1)
	{
		level waittill( "generator_under_attack" );
		self.lastTemplarRound setvalue(level.round_number);
	}
}


BrutusTracker()
{
	self endon("disconnect");
	if(!isDefined(level.trackingBrutus))
		level.trackingBrutus = true;

	self.lastBrutusRound = newclienthudelem(self);
	self.lastBrutusRound.alignx = "left";
	self.lastBrutusRound.horzalign = "user_left";
	self.lastBrutusRound.vertalign = "user_top";
	self.lastBrutusRound.aligny = "top";
	self.lastBrutusRound.x = 7;
	self.lastBrutusRound.y = 365;
	self.lastBrutusRound.fontscale = 1.1;
	self.lastBrutusRound.sort = 1;
	self.lastBrutusRound.color = (1, 1 ,1);
	self.lastBrutusRound.hidewheninmenu = 1;
	self.lastBrutusRound.alpha = 1;
	self.lastBrutusRound.label = &"^3Last brutus round: ^4";
	self.lastBrutusRound setValue(0);
	while(1)
	{
		level waittill( "brutus_spawned");
		self.lastBrutusRound setvalue(level.round_number);
	}
}

tankTracker()
{
	tank_moves = -1;
	while(1)
	{
		if(level.vh_tank.origin[0] < -320 && level.vh_tank.origin[0] > -340)
		{
			if(tank_last_check_church)
			{
				tank_moves += 1;
                self iprintln("The tank has been moved " + tank_moves + " time.");
			}
			tank_last_check_gen2 = 1;
			tank_last_check_church = 0;
		}
		if(level.vh_tank.origin[0] > 430 &&  level.vh_tank.origin[0] < 450)
		{
			if(tank_last_check_gen2)
			{
				tank_moves += 1;
                self iprintln("The tank has been moved " + tank_moves + " time.");
			}
			tank_last_check_church = 1;
			tank_last_check_gen2 = 0;
		}
		wait 1;
	}
}

/* MOB */

setup_master_key_override()
{
	wait 1;
	switch(getDvarInt("box"))
	{
		case 1:
			level.is_master_key_west = 0;
        	setclientfield( "fake_master_key", level.is_master_key_west + 1 );
			exploder( 100 );
			level thread key_pulley( "east" );
			array_delete( getentarray( "wires_pulley_west", "script_noteworthy" ) );
			break;
		case 2:
			level.is_master_key_west = 1;
        	setclientfield( "fake_master_key", level.is_master_key_west + 1 );
			level thread key_pulley( "west" );
			exploder( 101 );
			array_delete( getentarray( "wires_pulley_east", "script_noteworthy" ) );
			break;
		default:
			level.is_master_key_west = 0;
        	setclientfield( "fake_master_key", level.is_master_key_west + 1 );
			exploder( 100 );
			level thread key_pulley( "east" );
			array_delete( getentarray( "wires_pulley_west", "script_noteworthy" ) );
			break;
	}
}

givetomahawk()
{
	while(true)
	{
		if(self.origin[0] < 2260 && self.origin[0] > 2230 	&& self.origin[1] > 1012 && self.origin[1] < 10050 && self.origin[2] > 1740)
		{
			self play_sound_on_ent( "purchase" );
			self notify( "tomahawk_picked_up" );
			level notify( "bouncing_tomahawk_zm_aquired" );
			self notify( "player_obtained_tomahawk" );
			self.tomahawk_upgrade_kills = 99;
			self.killed_with_only_tomahawk = 1;
			self.killed_something_thq = 1;
			self notify( "tomahawk_upgraded_swap" );
			self set_player_tactical_grenade( "upgraded_tomahawk_zm" );
			self.current_tomahawk_weapon = "upgraded_tomahawk_zm";
			gun = self getcurrentweapon();
			self disable_player_move_states( 1 );
			self giveweapon( "zombie_tomahawk_flourish" );
			self switchtoweapon( "zombie_tomahawk_flourish" );
			self waittill_any( "player_downed", "weapon_change_complete" );
			self switchtoweapon( gun );
			self enable_player_move_states();
			self takeweapon( "zombie_tomahawk_flourish" );
			self giveweapon( "upgraded_tomahawk_zm" );
			self givemaxammo( "upgraded_tomahawk_zm" );
			primaryweapons = self getweaponslistprimaries();
			if( primaryweapons.size > 0 && IsDefined( primaryweapons ) )
			{
				self switchtoweapon( primaryweapons[ 0] );
				self waittill( "weapon_change_complete" );
			}
		}
		wait 0.1;
	}
}

key_pulley( str_master_key_location )
{
    if ( level.is_master_key_west )
    {
        t_other_hurt_trigger = getent( "pulley_hurt_trigger_east", "targetname" );
        t_other_panel = getent( "master_key_pulley_east", "targetname" );
    }
    else
    {
        t_other_hurt_trigger = getent( "pulley_hurt_trigger_west", "targetname" );
        t_other_panel = getent( "master_key_pulley_west", "targetname" );
    }

    t_other_hurt_trigger delete();
    t_other_panel setmodel( "p6_zm_al_power_station_panels_03" );
    t_pulley_hurt_trigger = getent( "pulley_hurt_trigger_" + str_master_key_location, "targetname" );
    //t_pulley_hurt_trigger = ::sndhitelectrifiedpulley( str_master_key_location );
    m_master_key_pulley = getent( "master_key_pulley_" + str_master_key_location, "targetname" );
    m_master_key_pulley play_fx( "fx_alcatraz_panel_on_2", m_master_key_pulley.origin, m_master_key_pulley.angles, "power_down", 1, undefined, undefined );
    m_master_key_pulley thread afterlife_interact_object_think();

    level waittill( "master_key_pulley_" + str_master_key_location );

    m_master_key_pulley playsound( "zmb_quest_generator_panel_spark" );
    m_master_key_pulley notify( "power_down" );
    m_master_key_pulley setmodel( "p6_zm_al_power_station_panels_03" );
    playfxontag( level._effect["fx_alcatraz_panel_ol"], m_master_key_pulley, "tag_origin" );
    m_master_key_pulley play_fx( "fx_alcatraz_panel_off_2", m_master_key_pulley.origin, m_master_key_pulley.angles, "power_down", 1, undefined, undefined );

    if ( level.is_master_key_west )
    {
        stop_exploder( 101 );
        array_delete( getentarray( "wires_pulley_west", "script_noteworthy" ) );
    }
    else
    {
        stop_exploder( 100 );
        array_delete( getentarray( "wires_pulley_east", "script_noteworthy" ) );
    }

    t_hurt_trigger = getent( "pulley_hurt_trigger_" + str_master_key_location, "targetname" );
    t_hurt_trigger delete();

    if ( str_master_key_location == "west" )
        level setclientfield( "fxanim_pulley_down_start", 1 );
    else if ( str_master_key_location == "east" )
        level setclientfield( "fxanim_pulley_down_start", 2 );

    wait 3;
    level setclientfield( "master_key_is_lowered", 1 );
    m_master_key = get_craftable_piece_model( "quest_key1", "p6_zm_al_key" );

    if ( isdefined( m_master_key ) )
    {
        e_master_key_target = getstruct( "master_key_" + str_master_key_location + "_origin", "targetname" );
        m_master_key.origin = e_master_key_target.origin;
        m_master_key setvisibletoall();
    }
}

trap_timer_fraga()
{
	self endon( "disconnect" );

	self.trap_timer_fraga = newclienthudelem( self );
	self.trap_timer_fraga.alignx = "right";
	self.trap_timer_fraga.aligny = "top";
	self.trap_timer_fraga.horzalign = "user_right";
	self.trap_timer_fraga.vertalign = "user_top";
	self.trap_timer_fraga.x = -2;
	self.trap_timer_fraga.y = 14;
	self.trap_timer_fraga.fontscale = 1.4;
	self.trap_timer_fraga.hidewheninmenu = 1;
	self.trap_timer_fraga.hidden = 0;
	self.trap_timer_fraga.label = &"";
	self.trap_timer_fragax.alpha = 1;

	while( 1 )
	{
		if(getDvarInt("traptimer"))
		{
			level waittill( "trap_activated" );
			if( level.trap_activated )
			{
				wait 0.1;
				self.trap_timer_fraga.color = ( 0, 1, 0 );
				self.trap_timer_fraga.alpha = 1;
				self.trap_timer_fraga settimer( 25 );
				wait 25;
				self.trap_timer_fraga settimer( 25 );
				self.trap_timer_fraga.color = ( 1, 0, 0 );
				wait 25;
				self.trap_timer_fraga.alpha = 0;
			}
		}
		wait 0.1;	
	}
}

/* Nuketown */

checkpaplocation()
{
	if(getDvarInt("perkrng") == 1)
		return;
	wait 1;
	if(level.players.size > 1)
	wait 4;
	pap = getent( "specialty_weapupgrade", "script_noteworthy" );
	jug = getent( "vending_jugg", "targetname" );
	if(pap.origin[0] > -1700 || jug.origin[0] > -1700)
		level.players[0] notify ("menuresponse", "", "restart_level_zm");
}

sndhitelectrifiedpulley( str_master_key_location )
{
    self endon( "master_key_pulley_" + str_master_key_location );

    while ( true )
    {
        self waittill( "trigger", e_triggerer );

        self playsound( "fly_elec_sparks_key" );
        wait 1;
    }
}


afterlife_interact_object_think()
{
    self endon( "afterlife_interact_complete" );

    if ( isdefined( self.script_int ) && self.script_int > 0 )
        n_total_interact_count = self.script_int;
    else if ( !isdefined( self.script_int ) || isdefined( self.script_int ) && self.script_int <= 0 )
        n_total_interact_count = 0;

    n_count = 0;
    self.health = 5000;
    self setcandamage( 1 );
    self useanimtree( "animtree" );
    self playloopsound( "zmb_afterlife_shockbox_off", 1 );

    if ( !isdefined( level.shockbox_anim ) )
    {
        level.shockbox_anim["on"] = %fxanim_zom_al_shock_box_on_anim;
        level.shockbox_anim["off"] = %fxanim_zom_al_shock_box_off_anim;
    }

    trig_spawn_offset = ( 0, 0, 0 );

    if ( self.model != "p6_anim_zm_al_nixie_tubes" )
    {
        if ( isdefined( self.script_string ) && self.script_string == "intro_powerup_activate" )
            self.t_bump = spawn( "trigger_radius", self.origin + vectorscale( ( 0, 1, 0 ), 28.0 ), 0, 28, 64 );
        else
        {
            if ( issubstr( self.model, "p6_zm_al_shock_box" ) )
            {
                trig_spawn_offset = ( 0, 11, 46 );
                str_hint = &"ZM_PRISON_AFTERLIFE_INTERACT";
            }
            else if ( issubstr( self.model, "p6_zm_al_power_station_panels" ) )
            {
                trig_spawn_offset = ( 32, 35, 58 );
                str_hint = &"ZM_PRISON_AFTERLIFE_OVERLOAD";
            }

            afterlife_interact_hint_trigger_create( self, trig_spawn_offset, str_hint );
        }
    }

    while ( true )
    {
        if ( isdefined( self.unitrigger_stub ) )
            self.unitrigger_stub.is_activated_in_afterlife = 0;
        else if ( isdefined( self.t_bump ) )
        {
            self.t_bump setcursorhint( "HINT_NOICON" );
            self.t_bump sethintstring( &"ZM_PRISON_AFTERLIFE_INTERACT" );
        }

        self waittill( "damage", amount, attacker );

        if ( attacker == level || isplayer( attacker ) && attacker getcurrentweapon() == "lightning_hands_zm" )
        {
            if ( isdefined( self.script_string ) )
            {
                if ( isdefined( level.afterlife_interact_dist ) )
                {
                    if ( attacker == level || distancesquared( attacker.origin, self.origin ) < level.afterlife_interact_dist * level.afterlife_interact_dist )
                    {
                        level notify( self.script_string );

                        if ( isdefined( self.unitrigger_stub ) )
                        {
                            self.unitrigger_stub.is_activated_in_afterlife = 1;
                            self.unitrigger_stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
                        }
                        else if ( isdefined( self.t_bump ) )
                            self.t_bump sethintstring( "" );

                        self playloopsound( "zmb_afterlife_shockbox_on", 1 );

                        if ( self.model == "p6_zm_al_shock_box_off" )
                        {
                            if ( !isdefined( self.playing_fx ) )
                            {
                                playfxontag( level._effect["box_activated"], self, "tag_origin" );
                                self.playing_fx = 1;
                                self thread afterlife_interact_object_fx_cooldown();
                                self playsound( "zmb_powerpanel_activate" );
                            }

                            self setmodel( "p6_zm_al_shock_box_on" );
                            self setanim( level.shockbox_anim["on"] );
                        }

                        n_count++;

                        if ( n_total_interact_count <= 0 || n_count < n_total_interact_count )
                        {
                            self waittill( "afterlife_interact_reset" );

                            self playloopsound( "zmb_afterlife_shockbox_off", 1 );

                            if ( self.model == "p6_zm_al_shock_box_on" )
                            {
                                self setmodel( "p6_zm_al_shock_box_off" );
                                self setanim( level.shockbox_anim["off"] );
                            }

                            if ( isdefined( self.unitrigger_stub ) )
                            {
                                self.unitrigger_stub.is_activated_in_afterlife = 0;
                                self.unitrigger_stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
                            }
                        }
                        else
                        {
                            if ( isdefined( self.t_bump ) )
                                self.t_bump delete();

                            break;
                        }
                    }
                }
            }
        }
    }
}

play_fx( str_fx, v_origin, v_angles, time_to_delete_or_notify, b_link_to_self, str_tag, b_no_cull )
{
    if ( ( !isdefined( time_to_delete_or_notify ) || !isstring( time_to_delete_or_notify ) && time_to_delete_or_notify == -1 ) && ( isdefined( b_link_to_self ) && b_link_to_self ) && isdefined( str_tag ) )
    {
        playfxontag( getfx( str_fx ), self, str_tag );
        return self;
    }
    else
    {
        m_fx = spawn_model( "tag_origin", v_origin, v_angles );

        if ( isdefined( b_link_to_self ) && b_link_to_self )
        {
            if ( isdefined( str_tag ) )
                m_fx linkto( self, str_tag, ( 0, 0, 0 ), ( 0, 0, 0 ) );
            else
                m_fx linkto( self );
        }

        if ( isdefined( b_no_cull ) && b_no_cull )
            m_fx setforcenocull();

        playfxontag( getfx( str_fx ), m_fx, "tag_origin" );
        m_fx thread _play_fx_delete( self, time_to_delete_or_notify );
        return m_fx;
    }
}


afterlife_interact_hint_trigger_create( m_interact, v_trig_offset, str_hint )
{
    m_interact.unitrigger_stub = spawnstruct();
    m_interact.unitrigger_stub.origin = m_interact.origin + anglestoforward( m_interact.angles ) * v_trig_offset[0] + anglestoright( m_interact.angles ) * v_trig_offset[1] + anglestoup( m_interact.angles ) * v_trig_offset[2];
    m_interact.unitrigger_stub.radius = 40;
    m_interact.unitrigger_stub.height = 64;
    m_interact.unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
    m_interact.unitrigger_stub.hint_string = str_hint;
    m_interact.unitrigger_stub.cursor_hint = "HINT_NOICON";
    m_interact.unitrigger_stub.require_look_at = 1;
    m_interact.unitrigger_stub.ignore_player_valid = 1;
    m_interact.unitrigger_stub.prompt_and_visibility_func = ::afterlife_trigger_visible_in_afterlife;
    maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( m_interact.unitrigger_stub, ::afterlife_interact_hint_trigger_think );
}
afterlife_interact_hint_trigger_think()
{
    self endon( "kill_trigger" );

    while ( true )
    {
        self waittill( "trigger" );

        wait 1000;
    }
}
afterlife_trigger_visible_in_afterlife( player )
{
    b_is_invis = isdefined( self.stub.is_activated_in_afterlife ) && self.stub.is_activated_in_afterlife;
    self setinvisibletoplayer( player, b_is_invis );
    self sethintstring( self.stub.hint_string );

    if ( !b_is_invis )
    {
        if ( player is_player_looking_at( self.origin, 0.25 ) )
        {
            if ( cointoss() )
                player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "need_electricity" );
            else
                player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "electric_zap" );
        }
    }

    return !b_is_invis;
}


get_craftable_piece_model( str_craftable, str_piece )
{
    foreach ( uts_craftable in level.a_uts_craftables )
    {
        if ( uts_craftable.craftablestub.name == str_craftable )
        {
            foreach ( piecespawn in uts_craftable.craftablespawn.a_piecespawns )
            {
                if ( piecespawn.piecename == str_piece && isdefined( piecespawn.model ) )
                    return piecespawn.model;
            }

            break;
        }
    }

    return undefined;
}

afterlife_interact_object_fx_cooldown()
{
    wait 2;
    self.playing_fx = undefined;
}

_play_fx_delete( ent, time_to_delete_or_notify = -1 )
{
    if ( isstring( time_to_delete_or_notify ) )
        ent waittill_either( "death", time_to_delete_or_notify );
    else if ( time_to_delete_or_notify > 0 )
        ent waittill_notify_or_timeout( "death", time_to_delete_or_notify );
    else
        ent waittill( "death" );

    if ( isdefined( self ) )
        self delete();
}


spawn_model( model_name, origin = ( 0, 0, 0 ), angles, n_spawnflags = 0 )
{
    model = spawn( "script_model", origin, n_spawnflags );
    model setmodel( model_name );

    if ( isdefined( angles ) )
        model.angles = angles;

    return model;
}


frkills()
{
    while(level.round_number != 5)
        level waittill("end_of_round");
    while(!level.exited_spawn_room)
    {
        level waittill("end_of_round");
        switch(level.players.size)
        {
            case 1: level thread displaykills1(); break;
            case 2: level thread displaykills1(); level thread displaykills2(); break;
            case 3: level thread displaykills1(); level thread displaykills2(); level thread displaykills3(); break;
            case 4: level thread displaykills1(); level thread displaykills2(); level thread displaykills3(); level thread displaykills4(); break;
        }
        level thread printplayerkills();
    }
}

displaykills1()
{
	level.playerkills1.hidewheninmenu = 1;
    level.playerkills1 = createserverfontstring( "objective", 1.3 );
    level.playerkills1.y = 0;
    level.playerkills1.x = 0;
    level.playerkills1.fontscale = 1.4;
    level.playerkills1.alignx = "center";
    level.playerkills1.horzalign = "user_center";
    level.playerkills1.vertalign = "user_top";
    level.playerkills1.aligny = "top";
    level.playerkills1.alpha = 1;
    level.playerkills1 setvalue(level.players[0].kills);
    wait 11;
    level.playerkills1 destroy();
}

displaykills2()
{
	level.playerkills2.hidewheninmenu = 1;
    level.playerkills2 = createserverfontstring( "objective", 1.3 );
    level.playerkills2.y = 12;
    level.playerkills2.x = 0;
    level.playerkills2.fontscale = 1.4;
    level.playerkills2.alignx = "center";
    level.playerkills2.horzalign = "user_center";
    level.playerkills2.vertalign = "user_top";
    level.playerkills2.aligny = "top";
    level.playerkills2.alpha = 1;
    level.playerkills2 setvalue(level.players[1].kills);
    wait 11;
    level.playerkills2 destroy();
}

displaykills3()
{
	level.playerkills3.hidewheninmenu = 1;
    level.playerkills3 = createserverfontstring( "objective", 1.3 );
    level.playerkills3.y = 24;
    level.playerkills3.x = 0;
    level.playerkills3.fontscale = 1.4;
    level.playerkills3.alignx = "center";
    level.playerkills3.horzalign = "user_center";
    level.playerkills3.vertalign = "user_top";
    level.playerkills3.aligny = "top";
    level.playerkills3.alpha = 1;
    level.playerkills3 setvalue(level.players[2].kills);
    wait 11;
    level.playerkills3 destroy();
}

displaykills4()
{
	level.playerkills4.hidewheninmenu = 1;
    level.playerkills4 = createserverfontstring( "objective", 1.3 );
    level.playerkills4.y = 36;
    level.playerkills4.x = 0;
    level.playerkills4.fontscale = 1.4;
    level.playerkills4.alignx = "center";
    level.playerkills4.horzalign = "user_center";
    level.playerkills4.vertalign = "user_top";
    level.playerkills4.aligny = "top";
    level.playerkills4.alpha = 1;
    level.playerkills4 setvalue(level.players[3].kills);
    wait 11;
    level.playerkills4 destroy();
}

velocity_meter()
{
    self endon("disconnect");

	self.velocity = newclienthudelem(self);
	self.velocity.alignx = "center";
	self.velocity.fontscale = 1.1;
	self.velocity.horzalign = "user_center";
	self.velocity.vertalign = "user_bottom";
	self.velocity.aligny = "user_bottom";
	self.velocity.y = -100;
	self.velocity.alpha = 1;
	self.velocity.hidewheninmenu = 1;
    self.velocity setValue(0);
	level.exited_spawn_room = false;

    while (true)
    {
		if(level.exited_spawn_room == false)
        	self thread velocity_visible();

		velocity = int(length(self getvelocity() * (1, 1, 1)));
		if (!self isOnGround())
			velocity = int(length(self getvelocity() * (1, 1, 0)));

		self thread velocity_meter_scale(velocity);
        self.velocity setValue(velocity);

        wait 0.05;
    }
}
velocity_visible()
{
    self.velocity.alpha = 0;
    while(level.round_number != 5)
        level waittill("end_of_round");
    while(!level.exited_spawn_room)
    {
        zone = self get_current_zone();
        if(istranzit() && zone != "zone_pri")
	        level.exited_spawn_room = true;
        if(isnuketown() && playerexitnuketownfr(zone))
	        level.exited_spawn_room = true;
        if(isdierise() && zone != "zone_green_start")
	        level.exited_spawn_room = true;
        if(ismob() && playerexitedmobfr())
	        level.exited_spawn_room = true;
        if(isburied() && playerexitburiedfr())
	        level.exited_spawn_room = true;
        if(isorigins() && zone != "zone_start" && zone != "zone_start_a" && zone != "zone_start_b")
	        level.exited_spawn_room = true;
        if(isfarm() && zone == "zone_farm_house")
	        level.exited_spawn_room = true;
        if(istown() && (zone == "zone_bar" || zone == "zone_town_barber" || zone == "zone_ban"))
	        level.exited_spawn_room = true;
        self.velocity.alpha = 1;
        wait 1;
    }
    self.velocity destroy();
}

velocity_meter_scale(vel)
{
	self.velocity.color = (0.6, 0, 0);
	self.velocity.glowcolor = (0.3, 0, 0);

	if (vel < 330)
	{
		self.velocity.color = (0.6, 1, 0.6);
		self.velocity.glowcolor = (0.4, 0.7, 0.4);
	}

	else if (vel <= 340)
	{
		self.velocity.color = (0.8, 1, 0.6);
		self.velocity.glowcolor = (0.6, 0.7, 0.4);
	}

	else if (vel <= 350)
	{
		self.velocity.color = (1, 1, 0.6);
		self.velocity.glowcolor = (0.7, 0.7, 0.4);
	}

	else if (vel <= 360)
	{
		self.velocity.color = (1, 0.8, 0.4);
		self.velocity.glowcolor = (0.7, 0.6, 0.2);
	}

	else if (vel <= 370)
	{
		self.velocity.color = (1, 0.6, 0.2);
		self.velocity.glowcolor = (0.7, 0.4, 0.1);
	}

	else if (vel <= 380)
	{
		self.velocity.color = (1, 0.2, 0);
		self.velocity.glowcolor = (0.7, 0.1, 0);
	}
}

playerexitedmobfr()
{
	if(self.origin[1] < 10700 && self.origin[1] > 10300 && self.origin[0] > 300 && self.origin[0] < 2130)
		return true;
	return false;
}

playerexitburiedfr()
{
	if(self.origin [0] < -2200 && self.origin[0] > -3200 && self.origin[1] > -850 && self.origin[1] < 150)
		return false;
	return true;
}

playerexitnuketownfr(zone)
{
	if(zone == "openhouse1_backyard_zone" || zone == "openhouse2_backyard_zone" || zone == "openhouse2_f2_zone" || zone == "openhouse1_f2_zone")
		return true;
	return false;
}


setFragaLanguage()
{
    switch(getDvar("language"))
    {
        case "spanish":
            if(!level.debug)
            self thread spanishWellcome();
            level.boxhits.label = &"^3Tiradas de caja: ^4";
            level.cheats.label = &"^1^FCheats activados";
            level.firstbox_active.label = &"^2^FFirstbox activado";
            if(isorigins() || isburied() || isnuketown() && !level.debug)
                level.perkrng_desabled.label = &"^4^FPerk RNG manipulada";
            if(isorigins() && !level.debug)
                level.templar_modiffied.label = &"^6^FTemplarios manipulados";
            if(isdefined(self.lastBrutusRound))
		        self.lastBrutusRound.label = &"^3Última ronda de brutus: ^4";
            if(isdefined(self.lastTemplarRound))
		        self.lastTemplarRound.label = &"^3Última ronda de templarios: ^4";
            if(isdefined(self.lastPanzerRound))
		        self.lastPanzerRound.label = &"^3Última ronda de panzer: ^4";
            if(isdefined(self.lastleaperround))
                self.lastleaperround.label = &"^3Última ronda de novas: ^4";
            flag_wait("initial_blackscreen_passed");
            if(isdefined(level.springpad_hud))
                level.springpad_hud.label = &"^3TRAMPOLINES: ^4";
            if(isdefined(level.subwoofer_hud))
            {
                level.springpad_hud.label = &"^3TRAMPOLINES: ^4";
                level.subwoofer_hud.label = &"^3RESONADORES: ^4";
                level.turbine_hud.label = &"^3TURBINAS: ^4";
            }
            break;
        case "french":
            if(!level.debug)
            self thread frenchWellcome();
            level.boxhits.label = &"^3Box hits: ^4";
            level.cheats.label = &"^1^FCheats actif";
            level.firstbox_active.label = &"^2^FFirstbox actif";
            if(isorigins() || isburied() || isnuketown())
                level.perkrng_desabled.label = &"^4^FLa RNG des atouts est manipulé";
            if(isorigins())
                level.templar_modiffied.label = &"^6^FTemplier est manipulé";
            if(isdefined(self.lastBrutusRound))
		        self.lastBrutusRound.label = &"^3Dernière manche de brutus: ^4";
            if(isdefined(self.lastTemplarRound))
		        self.lastTemplarRound.label = &"^3Dernière manche des templiers: ^4";
            if(isdefined(self.lastPanzerRound))
		        self.lastPanzerRound.label = &"^3Dernière manche de panzer: ^4";
            if(isdefined(self.lastleaperround))
                self.lastleaperround.label = &"^3Dernière manche de leapers: ^4";
            flag_wait("initial_blackscreen_passed");
            if(isdefined(level.springpad_hud))
                level.springpad_hud.label = &"^3PROPULSEURS: ^4";
            if(isdefined(level.subwoofer_hud))
            {
                level.springpad_hud.label = &"^3PROPULSEURS: ^4";
                level.subwoofer_hud.label = &"^3RÉSONATEUR: ^4";
                level.turbine_hud.label = &"^3TURBINES: ^4";
            }
            break;
        case "japanese":
            self thread japaneseWellcome();
            level.boxhits.label = &"^3Box hits: ^4";
            level.cheats.label = &"^1^FCheats アクティブ";
            level.firstbox_active.label = &"^2^FFirstbox アクティブ";
            if(isorigins() || isburied() || isnuketown() && !level.debug)
                level.perkrng_desabled.label = &"^4^F特典 RNG 操作された";
            if(isorigins() && !level.debug)
                level.templar_modiffied.label = &"^6^Fテンプラー 操作された";
            if(isdefined(self.lastBrutusRound))
		        self.lastBrutusRound.label = &"^3ブルータス最後のラウンド: ^4";
            if(isdefined(self.lastTemplarRound))
		        self.lastTemplarRound.label = &"^3テンプル騎士団の最後のラウンド: ^4";
            if(isdefined(self.lastPanzerRound))
		        self.lastPanzerRound.label = &"^3最後の装甲ラウンド: ^4";
            if(isdefined(self.lastleaperround))
                self.lastleaperround.label = &"^3最後のリーパーラウンド: ^4";
            flag_wait("initial_blackscreen_passed");
            if(isdefined(level.springpad_hud))
                level.springpad_hud.label = &"^3スプリングパッド: ^4";
            if(isdefined(level.subwoofer_hud))
            {
                level.springpad_hud.label = &"^3スプリングパッド: ^4";
                level.subwoofer_hud.label = &"^3レゾネーター: ^4";
                level.turbine_hud.label = &"^3タービン: ^4";
            }
            break;
        default:
            if(!level.debug)
            self thread englishWellcome();
            level.boxhits.label = &"^3Box hits: ^4";
            level.cheats.label = &"^1^FCheats active";
            level.firstbox_active.label = &"^2^FFirstbox active";
            if(isorigins() || isburied() || isnuketown() && !level.debug)
                level.perkrng_desabled.label = &"^4^FPerk RNG manipulated";
            if(isorigins() && !level.debug)
                level.templar_modiffied.label = &"^6^FTemplars manipulated";
            if(isdefined(self.lastBrutusRound))
		        self.lastBrutusRound.label = &"^3Last brutus round: ^4";
            if(isdefined(self.lastTemplarRound))
		        self.lastTemplarRound.label = &"^3Last templar round: ^4";
            if(isdefined(self.lastPanzerRound))
		        self.lastPanzerRound.label = &"^3Last panzer round: ^4";
            if(isdefined(self.lastleaperround))
                self.lastleaperround.label = &"^3Last leaper round: ^4";
            flag_wait("initial_blackscreen_passed");
            if(isdefined(level.springpad_hud))
                level.springpad_hud.label = &"^3SPRINGPADS: ^4";
            if(isdefined(level.subwoofer_hud))
            {
                level.springpad_hud.label = &"^3SPRINGPADS: ^4";
                level.subwoofer_hud.label = &"^3RESONATORS: ^4";
                level.turbine_hud.label = &"^3TURBINES: ^4";
            }
            break;
    }
    if(level.debug)
    {
        level.cheats.label = &"";
        level.firstbox_active.label = &"";
        level.perkrng_desabled.label = &"";
        level.templar_modiffied.label = &"";
    }
}

spanishWellcome()
{
    
    flag_wait("initial_blackscreen_passed");
                                                                            self iprintln("^6Fraga^5V13  ^3Activado ^4[Ancient]");
    if( isburied() || isdierise() || istranzit() ) {            wait 3;     self iprintln("Todas las perma perks otorgadas");}
    if( isburied() || isdierise() || istranzit() ) {            wait 0.5;   self iprintln("Banco lleno");}
    if(getDvar("scr_kill_infinite_loops") != "")
    {
                                                                wait 3;     self iprintln("Usa el comando ^6/sr^7 si vas a hacer un speedrun y pon la ronda correspondiente");
                                                                wait 1;     self iprintln("Acepta 5, 30, 50, 70, 100, 150 y 200");
    }
                                                                wait 5;     self iprintln("Usa ^6/firstbox 1^7 para quitar el RNG de la caja");
    if( ismob() || istown() || isnuketown() || isorigins() ) {  wait 5;     self iprintln("Usa ^6/box [1, 2]^7 para seleccionar el spawn de la caja");}
    if( ismob() ) {                                             wait 5;     self iprintln("Usa ^6/traptimer 1^7 para activar el timer de la trampa");}
    if( isburied()) {                                           wait 5;     self iprintln("Usa ^6/perkRNG 0^7 si quieres que la ultima ventaja otorgada por las brujas sea vulture");}
    if( isorigins()) {                                          wait 5;     self iprintln("Usa ^6/perkRNG 0^7 si quieres quitar el rng del wunderfizz");}
    if( isnuketown()) {                                         wait 5;     self iprintln("Usa ^6/perkRNG 0^7 para reiniciar automáticamente hasta que el pap y titán estén en la casa azul");}
    if( isorigins()) {                                          wait 1;     self iprintln("Usa ^6/templars 0^7 para que los templarios ataquen siempre al generador 4");}

    wait 5;                                                                 self iprintln("Usa ^6/nightmode 1^7 para cambiar al modo noche");
    wait 5;                                                                 self iprintln("Usa ^6/timer [0, 4]^7 para cambiar la posición del timer");
    wait 5;                                                                 self iprintln("^3¡Buena suerte!");
}


japaneseWellcome()
{
    
    flag_wait("initial_blackscreen_passed");
                                                                            self iprintln("^6Fraga^5V13  ^3の上 ^4[Ancient]");
    if( isburied() || isdierise() || istranzit() ) {            wait 3;     self iprintln("すべての永続的特典が付与される");}
    if( isburied() || isdierise() || istranzit() ) {            wait 0.5;   self iprintln("銀行が満杯");}
    if(getDvar("scr_kill_infinite_loops") != "")
    {
                                                                wait 3;     self iprintln("コマンドを使用する ^6/sr^7 ラウンドスピードランを行ってラウンドを追加する場合");
                                                                wait 1;     self iprintln("受け入れる 5, 30, 50, 70, 100, 150 y 200");
    }
                                                                wait 5;     self iprintln("使用 ^6/firstbox 1^7 箱から運を取り除く");
    if( ismob() || istown() || isnuketown() || isorigins() ) {  wait 5;     self iprintln("使用 ^6/box [1, 2]^7 ボックスのスポーンを選択するには");}
    if( ismob() ) {                                             wait 5;     self iprintln("使用 ^6/traptimer 1^7 トラップタイマーを作動させるには");}
    if( isburied()) {                                           wait 5;     self iprintln("使用 ^6/perkRNG 0^7 魔女に与えられる最後の利点をハゲワシにしたいなら");}
    if( isorigins()) {                                          wait 5;     self iprintln("使用 ^6/perkRNG 0^7 wunderfizz から RNG を削除したい場合");}
    if( isnuketown()) {                                         wait 5;     self iprintln("使用 ^6/perkRNG 0^7 PAPとジャグが温室に入るまで自動的に再起動します。");}
    if( isorigins()) {                                          wait 1;     self iprintln("使用 ^6/templars 0^7 テンプル騎士団が常にジェネレーター 4 を攻撃するようにする");}

    wait 5;                                                                 self iprintln("使用 ^6/nightmode 1^7 ナイトモードに切り替えるには");
    wait 5;                                                                 self iprintln("使用 ^6/timer [0, 4]^7 タイマーの位置を変更するには");
    wait 5;                                                                 self iprintln("^3幸運を!");
}

englishWellcome()
{
    
    flag_wait("initial_blackscreen_passed");
                                                                            self iprintln("^6Fraga^5V13 ^3Active ^4[Ancient]");
    if( isburied() || isdierise() || istranzit() ) {            wait 3;     self iprintln("All perma perks awarded");}
    if( isburied() || isdierise() || istranzit() ) {            wait 0.5;   self iprintln("Bank filled");}
    if(getDvar("scr_kill_infinite_loops") != "")
    {
                                                                wait 3;     self iprintln("Use ^6/sr^7 if you're going do a round sr and add the round");
                                                                wait 1;     self iprintln("Accepts 5, 30, 50, 70, 100, 150 and 200");
    }
                                                                wait 5;     self iprintln("Use ^6/firstbox 1^7 to remove RNG from the box");
    if( ismob() || istown() || isnuketown() || isorigins() ) {  wait 5;     self iprintln("Use ^6/box [1, 2]^7 to select box's spawn");}
    if( ismob() ) {                                             wait 5;     self iprintln("Use ^6/traptimer 1^7 to activate traptimer");}
    if( isburied()) {                                           wait 5;     self iprintln("Use ^6/perkRNG 0^7 if you want vulture to be the last perk awarded by witches");}
    if( isorigins()) {                                          wait 5;     self iprintln("Use ^6/perkRNG 0^7 if you want to remove RNG from wunderfizz");}
    if( isnuketown()) {                                         wait 5;     self iprintln("Use ^6/perkRNG 0^7 to auto restart untill pap and jug are on green house");}
    if( isorigins()) {                                          wait 1;     self iprintln("Use ^6/templars 0^7 to make templars go gen4 always");}

    wait 5;                                                                 self iprintln("Use ^6/nightmode 1^7 in order to enter nightmode");
    wait 5;                                                                 self iprintln("Use ^6/timer [0, 4]^7 to change timer's position");
    wait 5;                                                                 self iprintln("^3Good luck!");
}
frenchWellcome()
{
    // Credit to QeZiaa & Astrox
    flag_wait("initial_blackscreen_passed");
                                                                            self iprintln("^6Fraga^5V13  ^3Actif ^4[Ancient]");
    if( isburied() || isdierise() || istranzit() ) {            wait 3;     self iprintln("Tous les atouts permanents sont attribués");}
    if( isburied() || isdierise() || istranzit() ) {            wait 0.5;   self iprintln("La banque est remplie");}
    if(getDvar("scr_kill_infinite_loops") != "")
    {
                                                                wait 3;     self iprintln("Marque ^6/sr^7 si tu vas faire une manche sr et ajoute la manche");
                                                                wait 1;     self iprintln("Acceptes 5, 30, 50, 70, 100, 150 et 200");
    }
                                                                wait 5;     self iprintln("Utilise ^6/firstbox 1^7 pour supprimer la RNG de la boite");
    if( ismob() || istown() || isnuketown() || isorigins() ) {  wait 5;     self iprintln("Utilise ^6/box [1, 2]^7 pour séléctionner l'emplacement de la boite magique");}
    if( ismob() ) {                                             wait 5;     self iprintln("Utilise ^6/traptimer 1^7 pour activer le traptimer");}
    if( isburied()) {                                           wait 5;     self iprintln("Utilise ^6/perkRNG 0^7 Si tu veux que le dernier atout de la sorcière soit vulture");}
    if( isorigins()) {                                          wait 5;     self iprintln("Utilise ^6/perkRNG 0^7 si tu veux supprimer la RNG de la wunderfizz");}
    if( isnuketown()) {                                         wait 5;     self iprintln("Utilise ^6/perkRNG 0^7 pour restart automatiquement jusqu'à ce que le pack à punch et Jug soient dans la maison verte");}
    if( isorigins()) {                                          wait 1;     self iprintln("Utilise ^6/templars 0^7 pour que les templiers aillent toujours au générateur 4");}

    wait 5;                                                                 self iprintln("Utilise ^6/nightmode 1^7 dans le but d'entrer dans le mode nuit");
    wait 5;                                                                 self iprintln("Utilise ^6/timer [0, 4]^7 pour changer la position du timer");
    wait 5;                                                                 self iprintln("^3Bonne chance!");
}

printTankLine(tank_moves)
{
    if(tank_moves == 1)
        switch(getDvar("language"))
        {
            case "spanish":
                self iprintln("El tanque se ha movido " + tank_moves + " vez.");
                break;
            case "french":
                self iprintln("Le tank a été deplacé " + tank_moves + " fois.");
                break;
            default:
                self iprintln("The tank has been moved " + tank_moves + " time.");
                break;
        }
    else
        switch(getDvar("language"))
        {
            case "spanish":
                self iprintln("El tanque se ha movido " + tank_moves + " veces.");
                break;
            case "french":
                self iprintln("Le tank a été deplacé" + tank_moves + " fois.");
                break;
            default:
                self iprintln("The tank has been moved " + tank_moves + " times.");
                break;
        }
}

printRoundTime()
{
    switch(getDvar("language"))
    {
        case "spanish":
	        self.roundtimer_fraga.label = &"Tiempo de la ronda: ";
            break;
        case "french":
	        self.roundtimer_fraga.label = &"Round time: ";
            break;
        default:
	        self.roundtimer_fraga.label = &"Round time: ";
            break;
    }
}

printplayerkills()
{
    
    switch(getDvar("language"))
    {
        case "spanish":
            if(isdefined(level.playerkills1))
            level.playerkills1.label = &"^3Bajas jugador 1: ^4";
            if(isdefined(level.playerkills2))
            level.playerkills1.label = &"^3Bajas jugador 2: ^4";
            if(isdefined(level.playerkills3))
            level.playerkills1.label = &"^3Bajas jugador 3: ^4";
            if(isdefined(level.playerkills4))
            level.playerkills1.label = &"^3Bajas jugador 4: ^4";
            break;
        case "french":
            if(isdefined(level.playerkills1))
            level.playerkills1.label = &"^3Tuer le joueur 1: ^4";
            if(isdefined(level.playerkills2))
            level.playerkills1.label = &"^3Tuer le joueur 2: ^4";
            if(isdefined(level.playerkills3))
            level.playerkills1.label = &"^3Tuer le joueur 3: ^4";
            if(isdefined(level.playerkills4))
            level.playerkills1.label = &"^3Tuer le joueur 4: ^4";
            break;
        default:
            if(isdefined(level.playerkills1))
            level.playerkills1.label = &"^3Kills player 1: ^4";
            if(isdefined(level.playerkills2))
            level.playerkills1.label = &"^3Kills player 2: ^4";
            if(isdefined(level.playerkills3))
            level.playerkills1.label = &"^3Kills player 3: ^4";
            if(isdefined(level.playerkills4))
            level.playerkills1.label = &"^3Kills player 4: ^4";
            break;
    }
}

printbuslocation()
{
    
    switch(getDvar("language"))
    {
        case "spanish":
			if(level.the_bus.origin[0] > -6530 && level.the_bus.origin[0] < -6520 && level.the_bus.origin[1] < 4800 && level.the_bus.origin[1] > 4600)	// Depot
				self.buslocation.label = &"^3Bus: ^4Estación";
			if(level.the_bus.origin[0] > -5560 && level.the_bus.origin[0] < -5550  && level.the_bus.origin[1] > -6870 && level.the_bus.origin[1] < -6800)	// Dinner
				self.buslocation.label = &"^3Bus: ^4Restaurante";
			if(level.the_bus.origin[0] > 6400 && level.the_bus.origin[1] < 6440 && level.the_bus.origin[1] > -5850 && level.the_bus.origin[1] < -5820)	// Farm
				self.buslocation.label = &"^3Bus: ^4Granja";
			if(level.the_bus.origin[0] > 10280 && level.the_bus.origin[0] < 10320 && level.the_bus.origin[1] < 7500 && level.the_bus.origin[1] > 7400)	// Power
				self.buslocation.label = &"^3Bus: ^4Electicidad";
			if(level.the_bus.origin[0] > 1460 && level.the_bus.origin[0] < 1490 && level.the_bus.origin[1] < 900 && level.the_bus.origin[1] > 800) 	// Town
				self.buslocation.label = &"^3Bus: ^4Ciudad";
            break;
        case "french":
			if(level.the_bus.origin[0] > -6530 && level.the_bus.origin[0] < -6520 && level.the_bus.origin[1] < 4800 && level.the_bus.origin[1] > 4600)	// Depot
				self.buslocation.label = &"^3Bus: ^4Depot";
			if(level.the_bus.origin[0] > -5560 && level.the_bus.origin[0] < -5550  && level.the_bus.origin[1] > -6870 && level.the_bus.origin[1] < -6800)	// Dinner
				self.buslocation.label = &"^3Bus: ^4Dinner";
			if(level.the_bus.origin[0] > 6400 && level.the_bus.origin[1] < 6440 && level.the_bus.origin[1] > -5850 && level.the_bus.origin[1] < -5820)	// Farm
				self.buslocation.label = &"^3Bus: ^4Farm";
			if(level.the_bus.origin[0] > 10280 && level.the_bus.origin[0] < 10320 && level.the_bus.origin[1] < 7500 && level.the_bus.origin[1] > 7400)	// Power
				self.buslocation.label = &"^3Bus: ^4Power";
			if(level.the_bus.origin[0] > 1460 && level.the_bus.origin[0] < 1490 && level.the_bus.origin[1] < 900 && level.the_bus.origin[1] > 800) 	// Town
				self.buslocation.label = &"^3Bus: ^4Town";
            break;
        default:
			if(level.the_bus.origin[0] > -6530 && level.the_bus.origin[0] < -6520 && level.the_bus.origin[1] < 4800 && level.the_bus.origin[1] > 4600)	// Depot
				self.buslocation.label = &"^3Bus: ^4Depot";
			if(level.the_bus.origin[0] > -5560 && level.the_bus.origin[0] < -5550  && level.the_bus.origin[1] > -6870 && level.the_bus.origin[1] < -6800)	// Dinner
				self.buslocation.label = &"^3Bus: ^4Dinner";
			if(level.the_bus.origin[0] > 6400 && level.the_bus.origin[1] < 6440 && level.the_bus.origin[1] > -5850 && level.the_bus.origin[1] < -5820)	// Farm
				self.buslocation.label = &"^3Bus: ^4Farm";
			if(level.the_bus.origin[0] > 10280 && level.the_bus.origin[0] < 10320 && level.the_bus.origin[1] < 7500 && level.the_bus.origin[1] > 7400)	// Power
				self.buslocation.label = &"^3Bus: ^4Power";
			if(level.the_bus.origin[0] > 1460 && level.the_bus.origin[0] < 1490 && level.the_bus.origin[1] < 900 && level.the_bus.origin[1] > 800) 	// Town
				self.buslocation.label = &"^3Bus: ^4Town";
            break;
    }
}

printbusstatus(buslastpos)
{
    switch(getDvar("language"))
    {
        case "spanish":
            if(buslastpos != level.the_bus.origin)
                self.busmoving.label = &"^3Bus en movimiento";
            else
                self.busmoving.label = &"^1Bus parado";
            buslastpos = level.the_bus.origin;
            break;
        case "french":
            if(buslastpos != level.the_bus.origin)
                self.busmoving.label = &"^3Bus est en mouvement";
            else
                self.busmoving.label = &"^1Bus est à l'arrêt ";
            buslastpos = level.the_bus.origin;
            break;
        default:
            if(buslastpos != level.the_bus.origin)
                self.busmoving.label = &"^3Bus mooving";
            else
                self.busmoving.label = &"^1Bus stopped";
            buslastpos = level.the_bus.origin;
            break;
    }
}