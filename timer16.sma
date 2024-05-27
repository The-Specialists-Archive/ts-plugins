// Only requires engine for one function.
#include <amxmodx> 
#include <amxmisc>
#include <engine>

// CONSTANTS
// Used for holding the various unalterable data peices

// Month Names
new const monthname[12][10] = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};

// Season Names
new const seasonname[4][10] = {"Spring", "Summer", "Autumn", "Winter"};

// AM/PM
new const amname[2][3] = {"AM", "PM"};

// Days in each month
new const monthdays[12] = {31,28,31,30,31,30,31,31,30,31,30,31};

// Sequence for Day/Night portion.
new const sequence[25][2] = {"c","c","d","e","f","g","h","i","j","l","o","p",
"r","u","t","r","o","n","l","i","j","h","e","c","c"};

// Weather Strings
new const weathertypes[4][10] = {"Clear","Cloudy","Rain","Snow"};

// Temp Constants
new const base_lowtemp[4] = {45,55,45,30}
new const base_hightemp[4] = {70,80,65,60}


// VARIABLES
// These hold the various information peices for the time display. "Mili_hours" is military time holder.
new minutes;
new mili_hours;
new hours;
new days;
new months;
new season;
new years;
new bool:AM;

// Temperature variables
new temperature;
new lowtemp;
new hightemp;
new bool:tempslope

// Weather holder
new weather = 0;

// Sprite index storage
new light, snow, rain;

// Vault file for storing time data.
new time_file[64];

new hud_green = 0;
new hud_red = 200;
new hud_blue = 0;
new Float:hud_x = 0.3
new Float:hud_y = 0.0
new hud_effects = 0
new Float:fx_time = 0.0
new Float:holdtime = 999.0
new Float:Fadein = 0.0
new Float:Fadeout = 0.0
new hud_channel = 4;

// FUNCTIONS
// These are the basic running functions

// This function does all of the work in this plugin, essentially.
// A big counter, it counts up the display bar.

public dotime(){

	// First off, add one to minutes, since this is usually called every second.
	minutes++;

	// If minutes is bigger then an hour, add to the hour keepers, make minutes 0, and keep going.
	if(minutes >= (get_cvar_num("sv_hourlength")) ){

		// If hours is 12 or over, it needs to be turned back to 1. If it is somehow 0, make it 1.
		if(hours >= 12) hours = 1;
		else if(hours == 0) hours = 1;
		else hours++;

		// If the military time is 24 or over, the day has ended, and we need to add a day and switch to AM.
		// More then that, we need to check the months to see if we need to mess with them too.
		if(mili_hours >= 23){
			AM = false;
			days++;
			mili_hours = 0;
			dailytemp();
			tempslope = false;

			// If there are too many days, roll over the months
			if(days >= monthdays[months]){
				months++;
				days = 1;
	
				// If there are too many months, roll over the years.
				if(months >= 11){
					years++;
					months = 0;
				}
	
			}
		}
		// If its 11 or over, switch up the stats
		else if(mili_hours >= 11){
			mili_hours++;
			AM = true; // Otherwise, if it is over 11, it is time to switch to PM.
			tempslope = true;

		// Otherwise, just add to the hour, and switch up tempslope
		}else{
			tempslope = false;
			mili_hours++;
		}

		// Update the temp, and delete the minutes
		minutes = 0;
		updatetemp();
	}

	// Make sure we are still in the right season.
	switch(months){
		case 1: season = 3;
		case 2: season = 3;
		case 3: season = 0;
		case 4: season = 0;
		case 5: season = 0;
		case 6: season = 1;
		case 7: season = 1;
		case 8: season = 1;
		case 9: season = 2;
		case 10: season = 2;
		case 11: season = 2;
		case 12: season = 3;
	}

	// Check the flags to make sure the owner wants the clock to be displayed.

	new flags[10]
	get_cvar_string("sv_timer_flags",flags,9)
	new type = read_flags(flags)
	if(!(type & (1<<0) ) ) return PLUGIN_HANDLED;

	// If they do, set the hud bar
	set_hudmessage(hud_red,hud_green,hud_blue,hud_x,hud_y,hud_effects,fx_time,holdtime,Fadein,Fadeout,hud_channel);

	// Make a few variables, and see if they want it standard or military
	new hud[512], military = get_cvar_num("sv_military_time");

	// Format the minutes so it looks right
	new minuteformat[64], hourformat[64];
	if(minutes < 10) format(minuteformat,64,"0%d",minutes);
	else format(minuteformat,64,"%d",minutes);

	// If its military, format the hours too
	if(military){
		if(mili_hours < 10) format(hourformat,64,"0%d",mili_hours);
		else format(hourformat,64,"%d",mili_hours);
	}else format(hourformat,64,"%d",hours);

	new hudflags[10]
	get_cvar_string("sv_timer_bar",hudflags,9)
	new hudtype = read_flags(hudflags)

	new temp[128]

	if(hudtype & (1<<6)){
		format(temp,127,"|%s| - ",weathertypes[weather])
		add(hud,511,temp)
	}

	if(hudtype & (1<<7)){
		format(temp,127,"( %s) - ",seasonname[season])
		add(hud,511,temp)
	}

	if(hudtype & (1<<3)){
		format(temp,127,"%s ",monthname[months])
		add(hud,511,temp)
	}

	if(hudtype & (1<<2)){
		format(temp,127,"%d, ",days)
		add(hud,511,temp)
	}

	if(hudtype & (1<<4)){
		format(temp,127,"%d ",years)
		add(hud,511,temp)
	}

	if(hudtype & (1<<1)){
		format(temp,127,"at %s",hourformat)
		add(hud,511,temp)
	}

	if(hudtype & (1<<0)){
		format(temp,127,":%s ",minuteformat)
		add(hud,511,temp)
	}

	if(!military){
		format(temp,127,"%s ",amname[AM])
		add(hud,511,temp)
	}

	if(hudtype & (1<<5)){
		format(temp,127,"(%i.%i degrees F)",temperature, (minutes/6) )
		add(hud,511,temp)
	}

	// Show everyone our timer bar
	show_hudmessage(0,hud)

	// Update the lights, just in case.
	updatelights();

	return PLUGIN_HANDLED;
}

public startweather(){
	weather = 0;
	new flags[10]
	get_cvar_string("sv_timer_flags",flags,9)
	new type = read_flags(flags)
	if(!(type & (1<<2) ) ) return PLUGIN_HANDLED;

	new temp = random_num(0,100)
	if(temp < 20) start_snow(24.0 * get_cvar_float("sv_hourlength"),0.1)
	else if(temp > 80){
		start_rain(24.0 * get_cvar_float("sv_hourlength"),0.1)
		if(temp > 90) start_thunderstorm(24.0 * get_cvar_float("sv_hourlength"),random_float(1.0,2.5) )
	}else if(temp > 70) start_thunderstorm(24.0 * get_cvar_float("sv_hourlength"),random_float(1.0,2.5) )
	else weather = 0;

	return 1;
}

// Get the daily temperatures from the base
public dailytemp(){

	// Get a high and a low temp, then get the current temp from that.
	// make sure the current temp is a little lower then normal.
	hightemp = random_num((base_hightemp[season])-10,(base_hightemp[season])+5)
	lowtemp = random_num(base_lowtemp[season]-10,base_lowtemp[season]+5)

	// Because we're going to update it soon, and it should slope up.
	temperature = random_num(lowtemp-5,hightemp-5)
	updatetemp();
}

// Updates the temperature (based on chaotic theory)
public updatetemp(){

	// In order to simulate a sloping upwards/downwards, we do something a little strange.
	// We give it a slightly higher chance of going up if we want it to go up.
	// And vise versa for going down.
	new newtemp;
	if(tempslope) newtemp = random_num(temperature-2,temperature+1)
	else newtemp = random_num(temperature-1,temperature+2)

	// But we always make sure it is contained within the brackets.
	if(newtemp > hightemp) newtemp = hightemp;
	if(newtemp < lowtemp) newtemp = lowtemp;

	// When we are done, update the temperature variable.
	temperature = newtemp;
}

// Update the lights according to what time it is.
public updatelights() { 

	// Check to make sure they want us to update it
	new flags[10]
	get_cvar_string("sv_timer_flags",flags,9)
	new type = read_flags(flags)

	// If they dont, turn it off.
 	if ( !(type & (1<<1) ) ){
		set_lights("#OFF") 
		return PLUGIN_CONTINUE 
	}

	// If they do, then set the lights accordingly.
	// Check to see HOW we should set them.
	if(!get_cvar_num("sv_real_lights")) set_lights(sequence[mili_hours]);
	else{
		new temp[200]
		get_time ( "%H",temp, 199)
		new hold = str_to_num(temp)
		set_lights(sequence[hold]);
	}


	return PLUGIN_CONTINUE;
}

// Sets the lights to a specific level.
public set_light ( level ){

	// Get the bit of the level, then make it to a string.
	new szlights[2];
	new clevel = (1<<level)
	get_flags ( clevel, szlights, 1 )

	// Set the string
	set_lights(szlights)

	return PLUGIN_HANDLED;
}

// WEATHER
// Weather gets its own section, because it is very strange.
// Making good weather takes a lot of effort and CPU, but it is well worth it.

// Start up the thunder storm
public start_thunderstorm(Float:time,Float:frequency){
	if(!task_exists(511)){
		set_task(time,"stop_thunderstorm")
		set_task(frequency,"continue_thunderstorm",511,"",0,"b")
		if(!weather) weather = 1;
	}
}

// Remove the thunder storm tasks
public stop_thunderstorm(){
	remove_task(511);
	weather = 0;
}

// Make more lightening and sounds.
public continue_thunderstorm(id){
	new xy[2]
	xy[0] = random_num(-2000,2000)
	xy[1] = random_num(-2000,2000)
	lightning(xy)
	if(random_num(0,10) > 6) client_cmd(0, "spk ambience/thunder_clap.wav")
}

public start_rain(Float:time,Float:frequency){
	if(!task_exists(911)){
		set_task(frequency,"rain_handle",991,"",0,"b")
		set_task(time,"stop_rain")
		weather = 2;
	}
	return 1;
}

public stop_rain(id){
	remove_task(991);
	weather = 0;
}

public rain_handle(id){
	if(random_num(0,100) > 10) client_cmd(0,"spk ambience/sandfall1");
	for(new i=0;i < get_cvar_num("sv_rain_multiplier");i++) 
		for(new a; a < get_maxplayers(); a++) if(is_user_alive(a) && is_user_outside(a) ) rain_effect(a);
}

public rain_effect(id){ 

	new vec[3] 
	new aimvec[3] 
	new raineffvec[3]
	new length
	new speed = random_num(50,300)

	// Get their origin.
	get_user_origin(id,vec) 

	// Get the origin in front of them (I think)
	get_user_origin(id,aimvec,get_cvar_num("sv_weather_aim") ) 

	raineffvec[0]=aimvec[0]-vec[0] + random_num(-500,500)
	raineffvec[1]=aimvec[1]-vec[1] + random_num(-500,500)
	raineffvec[2]=aimvec[2]-vec[2] + random_num(-100,100)

	length=sqrt(raineffvec[0]*raineffvec[0]+raineffvec[1]*raineffvec[1]+raineffvec[2]*raineffvec[2]) 

	raineffvec[0]=raineffvec[0]*speed/length 
	raineffvec[1]=raineffvec[1]*speed/length 
	raineffvec[2]=raineffvec[2]*speed/length 

	message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id) 
	write_byte( 17 ) // additive sprite, plays 1 cycle
	write_coord(raineffvec[0]+vec[0]) 
	write_coord(raineffvec[1]+vec[1]) 
	write_coord(raineffvec[2]+vec[2])
	write_short( rain ) 
	write_byte( 14 ) // byte (scale in 0.1's)  
	write_byte( 255 ) //  byte (brightness) 
	message_end()

	return PLUGIN_HANDLED
}

public start_snow(Float:time,Float:frequency){
	if(!task_exists(117)){
		set_task(frequency,"snow_handle",117,"",0,"b")
		set_task(time,"stop_snow")
		weather = 3;
	}
	return 1;
}

public stop_snow(id){
	remove_task(117);
	weather = 0;
}

public snow_handle(id){
	for(new i=0;i < get_cvar_num("sv_snow_multiplier");i++) 
		for(new a; a < get_maxplayers(); a++) 
			if(is_user_alive(a) && is_user_outside(a) ) snow_effect(a);
}

public snow_effect(id){ 
	new vec[3] 
	new aimvec[3] 
	new snoweffvec[3]
	new length
	new speed = random_num(50,300)

	// Get their origin.
	get_user_origin(id,vec) 

	// Get the origin in front of them (I think)
	get_user_origin(id,aimvec,get_cvar_num("sv_weather_aim")) 

	snoweffvec[0]=aimvec[0]-vec[0] + random_num(-500,500)
	snoweffvec[1]=aimvec[1]-vec[1] + random_num(-500,500)
	snoweffvec[2]=aimvec[2]-vec[2] + random_num(-100,100)

	length=sqrt(snoweffvec[0]*snoweffvec[0]+snoweffvec[1]*snoweffvec[1]+snoweffvec[2]*snoweffvec[2]) 

	snoweffvec[0]=snoweffvec[0]*speed/length 
	snoweffvec[1]=snoweffvec[1]*speed/length 
	snoweffvec[2]=snoweffvec[2]*speed/length 

	message_begin( MSG_ONE,SVC_TEMPENTITY,{0,0,0},id) 
	write_byte( 17 ) // additive sprite, plays 1 cycle
	write_coord(snoweffvec[0]+vec[0]) 
	write_coord(snoweffvec[1]+vec[1]) 
	write_coord(snoweffvec[2]+vec[2])
	write_short( snow ) 
	write_byte( 14 ) // byte (scale in 0.1's)  
	write_byte( 255 ) //  byte (brightness) 
	message_end()

	return PLUGIN_HANDLED
}

// Makes a lightening effect, using a temp ent specifically made for this.
public lightning(xy[]){

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte( 0 ) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(4000) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(-2000) 
	write_short( light ) 
	write_byte( 1 ) // framestart 
	write_byte( 5 ) // framerate 
	write_byte( 2 ) // life 
	write_byte( 150 ) // width 
	write_byte( 20 ) // noise 
	write_byte( 200 ) // r, g, b 
	write_byte( 200 ) // r, g, b 
	write_byte( 255 ) // r, g, b 
	write_byte( 200 ) // brightness 
	write_byte( 200 ) //  
	message_end() 
	
	return PLUGIN_CONTINUE
}

// Creates a flash grenade type effect
public flash(id) { 
	message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id) 
	write_short( 1<<15 ) 
	write_short( 1<<10 ) 
	write_short( 1<<12 ) 
	write_byte( 255 ) 	
	write_byte( 255 ) 
	write_byte( 255 ) 
	write_byte( 255 ) 
	message_end();
} 

// FORWARDS
// This section deals with the AMXX forwards

// Make absolutely sure that the sounds are all stopped.
public client_putinserver(id) client_cmd(id, "stopsound");
public client_disconnect(id) client_cmd(id, "stopsound");

// Precache, the most vital of all forwards!
public plugin_precache(){
	snow = precache_model("sprites/snow.spr")
	light = precache_model("sprites/lgtning.spr") 
	rain = precache_model("sprites/rain.spr")
}

// On server shut down, write the time
public plugin_end() write_time();

// On pause, write the time just in case.
public plugin_pause() write_time();

// Read it back when we unpause
public plugin_unpause() read_time();

// Set the dotime task on cfg load, just to make sure the cvar is set.
public plugin_cfg() set_task(get_cvar_float("sv_update_time"),"dotime",0,"",0,"b",99999);

//Plugin Initilize
public plugin_init(){ 
	// Get the time vault file
	new base_dir[30]
	get_configsdir ( base_dir, 29 )
	format(time_file,63,"%s\time.ini",base_dir)

	// Register MY plugin with the traditional 1.17 version decal.
	register_plugin("Timer 16 (light)","1.17","Mel") 

	// Figure out what time it is
	get_plugin_time();

	// |Register the cvars|

	// Military time?
	register_cvar("sv_military_time", "0")

	// How long is an hour?
 	register_cvar("sv_hourlength", "60") 

	// What peices of the plugin do we want to use?
	register_cvar("sv_timer_flags", "abc") 

	// What peices of the hud bar do you want displayed?
	register_cvar("sv_timer_bar", "abcdefgh") 

	// Will day/night be based on reality?
	register_cvar("sv_real_lights", "0") 

	// Whats the update rate on the hud message and dotime
	register_cvar("sv_update_time", "1.0") 

	// Snow multiplier (lower number = lower quality + less CPU usage)
	register_cvar("sv_snow_multiplier","2")

	// Rain multiplier (lower number = lower quality + less CPU usage)
	register_cvar("sv_rain_multiplier","25")

	// How does the weather aim?
	register_cvar("sv_weather_aim", "1") 

	// Make sure people are outside?
	register_cvar("sv_check_outside", "1") 

	// |Register the commands|

	// Change the time to a specific interval
  	register_concmd("change_time","change_time",ADMIN_LEVEL_E,"<minutes> <hours> <AM/PM> <days> <months> <years>");

	// Reset to current date
  	register_concmd("default_time","default_time",ADMIN_LEVEL_E," Set to current time");

	// Set the lights manually.
	register_concmd("amx_setlight","change_lights",ADMIN_LEVEL_E," 1 ( Dark ) to 26 ( Extralight )") 

	// Weather commands.
	register_concmd("amx_rain","t_rain",ADMIN_LEVEL_E,"<Total Time> <Frequency of Strikes>") 
	register_concmd("amx_snow","t_snow",ADMIN_LEVEL_E,"<Total Time> <Frequency of Strikes>") 
	register_concmd("amx_thunderstorm","t_storm",ADMIN_LEVEL_E,"<Total Time> <Frequency of Strikes>")
	register_concmd("amx_timer_hudmessage","set_hud",ADMIN_LEVEL_E,"r,g,b,x,y, effects, fxtime, holdtime, fadeintime, fadeouttime, channel")
} 


// Admin can set the default hud with this
public set_hud(id,level,cid){
	//Must have access!
	if (!cmd_access(id,level,cid,1)) return PLUGIN_CONTINUE

	new arg[32]
	read_argv(1,arg,31)
	new r = str_to_num(arg)

	if(r != -1) hud_red = r;

	read_argv(2,arg,31)
	new g = str_to_num(arg)

	if(g != -1) hud_green = g;

	read_argv(3,arg,31)
	new b = str_to_num(arg)

	if(b != -1) hud_blue = b;

	read_argv(4,arg,31)
	hud_x = floatstr(arg)

	read_argv(5,arg,31)
	hud_y = floatstr(arg)

	read_argv(6,arg,31)
	hud_effects = str_to_num(arg)

	read_argv(7,arg,31)
	fx_time = floatstr(arg)

	read_argv(8,arg,31)
	holdtime = floatstr(arg)

	read_argv(9,arg,31)
	Fadein = floatstr(arg)

	read_argv(10,arg,31)
	Fadeout = floatstr(arg)

	read_argv(11,arg,31)
	new chan = str_to_num(arg)
	if(!chan) hud_channel = 4;

	write_hud();
	return 1;
}


// COMMANDS
// Deals with handling the commands

// Admin can start a thunderstorm using this
public t_storm(id,level,cid){
	//Must have access!
	if (!cmd_access(id,level,cid,3)) return PLUGIN_CONTINUE
	
	// Read our arguement
	new arg[32]
	read_argv(1,arg,31)

	new Float:total_time = floatstr(arg)
	if(!total_time) total_time = 60.0

	read_argv(2,arg,31)

	new Float:frequency = floatstr(arg)
	if(!total_time) frequency = 0.5

	start_thunderstorm(total_time,frequency)

	client_print(0,print_center,"[TSX] Schedualed thunder storm starting..")

	return PLUGIN_HANDLED;
}

// Admin can start a rain storm using this
public t_rain(id,level,cid){
	//Must have access!
	if (!cmd_access(id,level,cid,3)) return PLUGIN_CONTINUE
	
	// Read our arguement
	new arg[32]
	read_argv(1,arg,31)

	new Float:total_time = floatstr(arg)
	if(!total_time) total_time = 60.0

	read_argv(2,arg,31)

	new Float:frequency = floatstr(arg)
	if(!total_time) frequency = 0.5

	start_rain(total_time,frequency)

	client_print(0,print_center,"[TSX] Schedualed Rain starting..")

	return PLUGIN_HANDLED;
}

// Admin can start a snow storm using this
public t_snow(id,level,cid){
	//Must have access!
	if (!cmd_access(id,level,cid,3)) return PLUGIN_CONTINUE
	
	// Read our arguement
	new arg[32]
	read_argv(1,arg,31)

	new Float:total_time = floatstr(arg)
	if(!total_time) total_time = 60.0

	read_argv(2,arg,31)

	new Float:frequency = floatstr(arg)
	if(!total_time) frequency = 0.5

	start_snow(total_time,frequency)

	client_print(0,print_center,"[TSX] Schedualed Snow starting..")

	return PLUGIN_HANDLED;
}

// Changes the lights
public change_lights(id,level,cid) {
	//Must have access!
	if (!cmd_access(id,level,cid,2)) return PLUGIN_CONTINUE
	
	// Read our arguement
	new arg[3]
	read_argv(1,arg,2)

	// Make it into an integer
	new inum = str_to_num(arg)

	// Check to make sure its valid
	if (inum < 0 || inum > 26 ) return PLUGIN_HANDLED;

	// See if they want default
	if(inum == 0) set_lights("#OFF");

	// Pass it on.
	else set_light( inum )

	// Notify the client.
	console_print(id,"[AMXX] Light Change Successful.")

	// Return handled.
	return PLUGIN_HANDLED
}

// Change the time
public change_time(id,level){
	// Must have access!
	if(!access ( id, level )) return PLUGIN_HANDLED;

	//Make some variables
	new arg[200], temp

	// Each one below reads an arg, makes it into a number, then sets it accordingly.
	read_argv(1,arg,199)
	temp = str_to_num(arg)

	if(temp != -1) minutes = temp;

	read_argv(2,arg,199)
	temp = str_to_num(arg)
	if(temp != -1) hours = temp;

	read_argv(3,arg,199)
	temp = str_to_num(arg)
	if(temp != -1){
		if(temp) AM = true
		else AM = false;
	}

	read_argv(4,arg,199)
	temp = str_to_num(arg)
	if(temp != -1) days = temp;

	read_argv(5,arg,199)
	temp = str_to_num(arg)
	if(temp != -1) months = temp;

	read_argv(6,arg,199)
	temp = str_to_num(arg)
	if(temp != -1) years = temp;

	// After all that, just return, a job well done.
	client_print(id,print_chat,"Time Set Completed")
	return PLUGIN_HANDLED;
}	

// Sets to current time
public default_time(id,level){
	// Must have access!
	if(!access ( id, level )) return PLUGIN_HANDLED;

	// Set it to current time, and notify the user.
	current_time()
	client_print(id,print_chat,"Time ReSet Completed")
	return PLUGIN_HANDLED;
}

// Stock-Like Functions
// Contains stock-like functions functions

public sqrt(num) { 
	new div = num 
	new result = 1 
	while (div > result) { // end when div == result, or just below 
		div = (div + result) / 2 // take mean value as new divisor 
		result = num / div 
	} 
	return div 
} 

public is_user_outside(id){
	new Float:origin[3]
	entity_get_vector ( id, EV_VEC_origin, origin )
	return (is_point_outside(origin))
}
	
public is_point_outside(Float:origin[3]){
	if(!get_cvar_num("sv_check_outside") ) return 1;
	while (PointContents(origin) == -1)
	{
		origin[2] += 5.0
	}
	if (PointContents(origin) == -6) return 1;
	return 0;
}


// Stops the sounds we started
public stop_sounds(id) {
	client_cmd(id, "speak NULL")
	client_cmd(id, "stopsound")
	return 1;
}

// Handles getting the tine
public get_plugin_time(){

	// If we've run it before, load it. Otherwise, make a new slate.
	new data[128]
	get_cvaultdata(time_file,"time_exists",data)
	if(equal(data,"")) current_time();
	else read_time();

	dailytemp();
	startweather();
	return 1;
}

// Get the current time, format it, and input it.
public current_time(){
	new temp[200]

	get_time ( "%m",temp, 199)
	months = str_to_num(temp) - 1

	get_time ( "%d",temp, 199)
	days = str_to_num(temp)

	get_time ( "%Y",temp, 199)
	years = str_to_num(temp)

	get_time ( "%H",temp, 199)

	new hold = str_to_num(temp)
	mili_hours = hold;
	if(hold > 12){
		AM = true;
		hours = hold - 12;
	}
	else if(hold == 0) hours = 12;
	else{
		AM = false;
		hours = hold;
	}

	get_time ( "%M",temp, 199)
	minutes = str_to_num(temp)

	// Write the time, just so we know
	write_time()

	//Make the lights reflect the time.
	updatelights()

	return 1;
}

// Reads the time from vault. Quite simple.
public read_time(){
	new data[128]
	get_cvaultdata(time_file,"minutes",data)
	minutes = str_to_num(data)

	get_cvaultdata(time_file,"hours",data)
	hours = str_to_num(data)

	get_cvaultdata(time_file,"days",data)
	days = str_to_num(data)

	get_cvaultdata(time_file,"months",data)
	months = str_to_num(data)

	get_cvaultdata(time_file,"years",data)
	years = str_to_num(data)

	get_cvaultdata(time_file,"AM",data)
	new temp = str_to_num(data)
	if(temp) AM = true;
	else AM = false;

	if(AM) mili_hours = hours + 12;
	else mili_hours = hours;

	read_hud()
	return 1;
}

// Write the time to the vault. Also simple.
public write_time(){
	new data[128]

	format(data,127,"%i",minutes)
	set_cvaultdata(time_file,"minutes",data)

	format(data,127,"%i",hours)
	set_cvaultdata(time_file,"hours",data)

	format(data,127,"%i",days)
	set_cvaultdata(time_file,"days",data)

	format(data,127,"%i",months)
	set_cvaultdata(time_file,"months",data)

	format(data,127,"%i",years)
	set_cvaultdata(time_file,"years",data)

	if(AM) set_cvaultdata(time_file,"AM","1")
	else set_cvaultdata(time_file,"AM","0")

	set_cvaultdata(time_file,"time_exists","1")

	write_hud()
	return 1;
}

public write_hud(){
	new data[128]

	format(data,127,"%i",hud_red)
	set_cvaultdata(time_file,"red",data)

	format(data,127,"%i",hud_blue)
	set_cvaultdata(time_file,"blue",data)

	format(data,127,"%i",hud_green)
	set_cvaultdata(time_file,"green",data)

	format(data,127,"%f",hud_x)
	set_cvaultdata(time_file,"x",data)

	format(data,127,"%f",hud_y)
	set_cvaultdata(time_file,"y",data)

	format(data,127,"%i",hud_effects)
	set_cvaultdata(time_file,"effects",data)

	format(data,127,"%f",fx_time)
	set_cvaultdata(time_file,"fx",data)

	format(data,127,"%f",holdtime)
	set_cvaultdata(time_file,"holdtime",data)

	format(data,127,"%f",Fadein)
	set_cvaultdata(time_file,"fadein",data)

	format(data,127,"%f",Fadeout)
	set_cvaultdata(time_file,"fadeout",data)

	format(data,127,"%i",hud_channel)
	set_cvaultdata(time_file,"channel",data)

	set_cvaultdata(time_file,"hud_set","1")

	return 1;
}

// Reads the time from vault. Quite simple.
public read_hud(){
	new data[128]
	get_cvaultdata(time_file,"hud_set",data)
	if(equal(data,"")){
		write_hud();
		return 1;
	}

	get_cvaultdata(time_file,"red",data)
	hud_red = str_to_num(data)

	get_cvaultdata(time_file,"blue",data)
	hud_blue= str_to_num(data)

	get_cvaultdata(time_file,"green",data)
	hud_green = str_to_num(data)

	get_cvaultdata(time_file,"effects",data)
	hud_effects = str_to_num(data)

	get_cvaultdata(time_file,"channel",data)
	hud_channel = str_to_num(data)

	get_cvaultdata(time_file,"x",data)
	hud_x = floatstr(data)

	get_cvaultdata(time_file,"y",data)
	hud_y = floatstr(data)

	get_cvaultdata(time_file,"fx",data)
	fx_time = floatstr(data)

	get_cvaultdata(time_file,"holdtime",data)
	holdtime = floatstr(data)

	get_cvaultdata(time_file,"fadein",data)
	Fadein = floatstr(data)

	get_cvaultdata(time_file,"fadeout",data)
	Fadeout = floatstr(data)

	return 1;
}

// CVAULT
// Superior storing mechanism
// Allows for a vault-like system with more options, ease of use, and speed.
// All the real work is done through cvault_exists

// Sets a particular key/value pair into the vault file (file[])
public set_cvaultdata(file[],key[],data[]){

	// use exists to get the line
	new currline[192], blank[128]
	new line = cvaultdata_exists(file,key,blank)

	// Format the key/value pair
	format(currline,191,"%s	%s",key,data)

	// Write them
	write_file(file,currline,line)

	// return the line for future use
	return line;
}

// Gets a particular key/value pair. Take all of exists credit, is really just a public.
public get_cvaultdata(file[],key[],data[]){

	// Find the value
	new line = cvaultdata_exists(file,key,data)

	// Return where it is.
	return line;
}

// Removes a key/value from the vault.
public remove_cvaultdata(file[],key[]){
	
	// Find the key/value pair
	new data[128]
	new line = cvaultdata_exists(file,key,data)

	// Over write them
	write_file(file,"",line)

	// Return the now free line
	return line;
}

// The meat and gravy of CVAULT. Finds out where the key/value is, what it contains, and any free lines along the way.
public cvaultdata_exists(file[],key[],data[]){
	// Variables for line, key, and value data.
	new currline[192]
	new currvalue[128];
	new currkey[64];

	// What line are we on, how many letters are on it, and whats the last free line
	new line = 0;
	new txt;
	new free_line = -1;

	// File has to exist
	if( file_exists(file) ) {
		// Run through the entire file
		while( ( line = read_file(file,line,currline,192,txt ) ) ){

			// If its not commented out, continue
			if( !equal( currline,"//", strlen("//") ) && !equal( currline,";",strlen(";") ) ) {

				// Break it into a key and a value
				strtok(currline, currkey, sizeof(currkey), currvalue, sizeof(currvalue),'	',1);
				
				// If its the key we are looking for, copy the data and return where itis
				if(equal(currkey,key)){
					copy(data,128,currvalue);
					return line-1;
				}

				// If its a free line, store that too
				else if( equal(currkey,"") ) free_line = line-1;
			}
		}
	}
	
	// If there isnt a file, there are no values either. So make the file.
	else write_file(file, "// **** Cvault V1.117 Storage Method ****", 0);

	// And return the last free line, just in case.
	return free_line;
}