#include <amxmodx> 
#include <engine> 

new val 

// Addon to make some windows unbreakable in IburgCity_b1.sma and add banker models 
public plugin_init() 
{ 
    register_plugin( "IburgCity_b2", "0.2l", "Harbu" ); 

} 
public plugin_precache() 
{ 
    precache_model( "models/mecklenburg/banker.mdl" ) 
    precache_model( "models/mecklenburg/chef.mdl" ) 
    precache_model( "models/simivalley/itemslady.mdl" ) 
    precache_model( "models/mecklenburg/armory.mdl" )
    precache_model( "models/player/sv_doctor/sv_doctor.mdl" )
} 

stock create_npc( model[], Float:origin[3], Float:angle = 0.0 ) 
{ 
    new ent = create_entity("info_target")  

    entity_set_origin(ent,origin) 

    entity_set_string(ent,EV_SZ_classname,"ts_model");  
    entity_set_model(ent,model);  
    entity_set_int(ent,EV_INT_solid, 2)  

    entity_set_byte(ent,EV_BYTE_controller1,125);  
    entity_set_byte(ent,EV_BYTE_controller2,125);  
    entity_set_byte(ent,EV_BYTE_controller3,125);  
    entity_set_byte(ent,EV_BYTE_controller4,125);  


    new Float:maxs[3] = {16.0,16.0,30.0}  
    new Float:mins[3] = {-16.0,-16.0,-30.0}  
    new Float:angles[3] = { 0.0, 0.0, 0.0 } 
    angles[1] = angle 
    entity_set_size(ent,mins,maxs) 
    entity_set_vector( ent, EV_VEC_angles, angles ) 

    entity_set_float(ent,EV_FL_animtime,2.0)  
    entity_set_float(ent,EV_FL_framerate,1.0)  
    entity_set_int(ent,EV_INT_sequence,1);  

    return PLUGIN_HANDLED 
} 

public client_putinserver( id ) 
{ 
    if( val ) return PLUGIN_HANDLED 

    val = 1 

    new calc = get_maxplayers() 




    // Model NPC 
    new Float:seveneleven_origin[3] = { -1396.0, 2186.0, 44.0 }    // 7/11 Store
    new Float:office_origin[3] = { -1944.0, 650.0, 44.0 }    // Office Complex
    new Float:diner_origin[3] = { 765.0, -655.0, 60.0 }    // Diner
    new Float:medical_origin[3] = { -16.0, -1691.0, 44.0 }    // Medical Office
    new Float:xevi_origin[3] = { 2196.0, -1549.0, 44.0 }    // Club
    new Float:hotel_origin[3] = { 507.0, 496.0, 44.0 }    // Hotel
    new Float:carshop_origin[3] = { 660.0, 2840.0, 60.0 }    // Carshop
    new Float:gunshop_origin[3] = { 397.0, 1367.0, 44.0 }    // Gunshop
    new Float:bank_origin[3] = { -1492.0, -689.0, 44.0 }    // Bank 1
    new Float:bank2_origin[3] = { -1494.0, -586.0, 44.0 }    // Bank 2
    new Float:dealer_origin[3] = { -509.0, 2303.0, 44.0 }    // dealer

    // 
    create_npc( "models/mecklenburg/chef.mdl", diner_origin, -90.0 ) 
    create_npc( "models/mecklenburg/banker.mdl", bank_origin, 0.0 ) 
    create_npc( "models/simivalley/itemslady.mdl", seveneleven_origin, 0.0 )
    create_npc( "models/mecklenburg/banker.mdl", bank2_origin, 0.0 ) 
    create_npc( "models/simivalley/itemslady.mdl", xevi_origin, 180.0 ) 
    create_npc( "models/mecklenburg/banker.mdl", hotel_origin, -90.0 ) 
    create_npc( "models/mecklenburg/banker.mdl", carshop_origin, -90.0 ) 
    create_npc( "models/mecklenburg/banker.mdl", gunshop_origin, 90.0 )
    create_npc( "models/player/sv_doctor/sv_doctor.mdl", medical_origin, 270.0 ) 
    create_npc( "models/mecklenburg/banker.mdl", office_origin, 0.0 ) 
    create_npc( "models/mecklenburg/banker.mdl", dealer_origin, -90.0 )

    return PLUGIN_HANDLED 
} 

public set_entity_health(door,Float:hp) 
{ 
    if(hp == -1.0) { 
        entity_set_float(door,EV_FL_max_health,2000.0) 
        entity_set_float(door,EV_FL_health,2000.0) 
        entity_set_float(door,EV_FL_dmg,0.0) 
        entity_set_float(door,EV_FL_takedamage,0.0) 
        return 1 
    } 
    entity_set_float(door,EV_FL_max_health,hp) 
    entity_set_float(door,EV_FL_health,hp) 
    return 1  
} 