#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_weapons;

buried_pap_camo(weapon)
{
	if(getDvarInt("papcamo") == 0)
	{
		if ( !isdefined( self.pack_a_punch_weapon_options ) )
			self.pack_a_punch_weapon_options = [];

		if ( !is_weapon_upgraded( weapon ) )
			return self calcweaponoptions( 0, 0, 0, 0, 0 );

		if ( isdefined( self.pack_a_punch_weapon_options[weapon] ) )
			return self.pack_a_punch_weapon_options[weapon];

		smiley_face_reticle_index = 1;
		base = get_base_name( weapon );
		camo_index = 39;

		if ( "zm_prison" == level.script )
			camo_index = 40;
		else if ( "zm_tomb" == level.script )
			camo_index = 45;

		lens_index = randomintrange( 0, 6 );
		reticle_index = randomintrange( 0, 16 );
		reticle_color_index = randomintrange( 0, 6 );
		plain_reticle_index = 16;
		r = randomint( 10 );
		use_plain = r < 3;

		if ( "saritch_upgraded_zm" == base )
			reticle_index = smiley_face_reticle_index;
		else if ( use_plain )
			reticle_index = plain_reticle_index;
		scary_eyes_reticle_index = 8;
		purple_reticle_color_index = 3;

		if ( reticle_index == scary_eyes_reticle_index )
			reticle_color_index = purple_reticle_color_index;

		letter_a_reticle_index = 2;
		pink_reticle_color_index = 6;

		if ( reticle_index == letter_a_reticle_index )
			reticle_color_index = pink_reticle_color_index;

		letter_e_reticle_index = 7;
		green_reticle_color_index = 1;

		if ( reticle_index == letter_e_reticle_index )
			reticle_color_index = green_reticle_color_index;

		self.pack_a_punch_weapon_options[weapon] = self calcweaponoptions( camo_index, lens_index, reticle_index, reticle_color_index );
		return self.pack_a_punch_weapon_options[weapon];
	}
	else
	{
		if(!isdefined(self.pack_a_punch_weapon_options))
			self.pack_a_punch_weapon_options = [];

		if(!is_weapon_upgraded(weapon))
			return self calcweaponoptions(0, 0, 0, 0, 0);

		if(isdefined(self.pack_a_punch_weapon_options[weapon]))
			return self.pack_a_punch_weapon_options[weapon];

		smiley_face_reticle_index = 1;
		base = get_base_name(weapon);
		camo_index = 39;

		if(base == "rnma_upgraded_zm" || base == "rnma_zm") camo_index = 39;
		else if(getDvar("papcamo") != "") camo_index = getDvarInt("papcamo");
		else camo_index = 40;

		lens_index = randomintrange(0, 6);
		reticle_index = randomintrange(0, 16);
		reticle_color_index = randomintrange(0, 6);
		plain_reticle_index = 16;
		r = randomint(10);
		use_plain = r < 3;

		if(base == "saritch_upgraded_zm")
			reticle_index = smiley_face_reticle_index;

		else if(use_plain)
			reticle_index = plain_reticle_index;

		scary_eyes_reticle_index = 8;
		purple_reticle_color_index = 3;
		if(reticle_index == scary_eyes_reticle_index)
			reticle_color_index = purple_reticle_color_index;

		letter_a_reticle_index = 2;
		pink_reticle_color_index = 6;
		if(reticle_index == letter_a_reticle_index)
			reticle_color_index = pink_reticle_color_index;

		letter_e_reticle_index = 7;
		green_reticle_color_index = 1;

		if(reticle_index == letter_e_reticle_index)
			reticle_color_index = green_reticle_color_index;

		self.pack_a_punch_weapon_options[weapon] = self calcweaponoptions(camo_index, lens_index, reticle_index, reticle_color_index);
		return self.pack_a_punch_weapon_options[weapon];
	}
}


origins_pap_camo(weapon)
{
	if(getDvarInt("papcamo") == 0)
	{
		if ( !isdefined( self.pack_a_punch_weapon_options ) )
			self.pack_a_punch_weapon_options = [];

		if ( !is_weapon_upgraded( weapon ) )
			return self calcweaponoptions( 0, 0, 0, 0, 0 );

		if ( isdefined( self.pack_a_punch_weapon_options[weapon] ) )
			return self.pack_a_punch_weapon_options[weapon];

		smiley_face_reticle_index = 1;
		base = get_base_name( weapon );
		camo_index = 39;

		if ( "zm_prison" == level.script )
			camo_index = 40;
		else if ( "zm_tomb" == level.script )
			camo_index = 45;

		lens_index = randomintrange( 0, 6 );
		reticle_index = randomintrange( 0, 16 );
		reticle_color_index = randomintrange( 0, 6 );
		plain_reticle_index = 16;
		r = randomint( 10 );
		use_plain = r < 3;

		if ( "saritch_upgraded_zm" == base )
			reticle_index = smiley_face_reticle_index;
		else if ( use_plain )
			reticle_index = plain_reticle_index;
		scary_eyes_reticle_index = 8;
		purple_reticle_color_index = 3;

		if ( reticle_index == scary_eyes_reticle_index )
			reticle_color_index = purple_reticle_color_index;

		letter_a_reticle_index = 2;
		pink_reticle_color_index = 6;

		if ( reticle_index == letter_a_reticle_index )
			reticle_color_index = pink_reticle_color_index;

		letter_e_reticle_index = 7;
		green_reticle_color_index = 1;

		if ( reticle_index == letter_e_reticle_index )
			reticle_color_index = green_reticle_color_index;

		self.pack_a_punch_weapon_options[weapon] = self calcweaponoptions( camo_index, lens_index, reticle_index, reticle_color_index );
		return self.pack_a_punch_weapon_options[weapon];
	}
	else
	{
		if(!isdefined(self.pack_a_punch_weapon_options))
			self.pack_a_punch_weapon_options = [];

		if(!is_weapon_upgraded(weapon))
			return self calcweaponoptions(0, 0, 0, 0, 0);

		if(isdefined(self.pack_a_punch_weapon_options[weapon]))
			return self.pack_a_punch_weapon_options[weapon];

		smiley_face_reticle_index = 1;
		base = get_base_name(weapon);
		camo_index = 39;

		if(base == "mg08_upgraded_zm" || base == "mg08_zm" || base == "c96_upgraded_zm" || base == "c96_zm") camo_index = 40;
		else if(getDvar("papcamo") != "") camo_index = getDvarInt("papcamo");
		else camo_index = 40;

		lens_index = randomintrange(0, 6);
		reticle_index = randomintrange(0, 16);
		reticle_color_index = randomintrange(0, 6);
		plain_reticle_index = 16;
		r = randomint(10);
		use_plain = r < 3;

		if(base == "saritch_upgraded_zm")
			reticle_index = smiley_face_reticle_index;

		else if(use_plain)
			reticle_index = plain_reticle_index;

		scary_eyes_reticle_index = 8;
		purple_reticle_color_index = 3;
		if(reticle_index == scary_eyes_reticle_index)
			reticle_color_index = purple_reticle_color_index;

		letter_a_reticle_index = 2;
		pink_reticle_color_index = 6;
		
		if(reticle_index == letter_a_reticle_index)
			reticle_color_index = pink_reticle_color_index;

		letter_e_reticle_index = 7;
		green_reticle_color_index = 1;
		if(reticle_index == letter_e_reticle_index)
			reticle_color_index = green_reticle_color_index;

		self.pack_a_punch_weapon_options[weapon] = self calcweaponoptions(camo_index, lens_index, reticle_index, reticle_color_index);
		return self.pack_a_punch_weapon_options[weapon];
	}
}
