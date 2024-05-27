
stock explode( output[][], input[], delimiter) 
{ 
	new nIdx = 0
	new iStringSize
	while ( input[iStringSize] ) 
		iStringSize++ 
	new nLen = (1 + copyc( output[nIdx], iStringSize-1, input, delimiter ))

	while( nLen < strlen(input) )
		nLen += (1 + copyc( output[++nIdx], iStringSize-1, input[nLen], delimiter ))
	return nIdx + 1
}

stock cvar_to_array(SzCvar[],length,origin[],dimension = 3)
{
	new output[6][32]
	get_cvar_string(SzCvar,SzCvar,length)
	explode(output,SzCvar,' ')
	for(new i=0;i < dimension;i++) {
	origin[i] = str_to_num(output[i])
	}
	return PLUGIN_HANDLED
}

stock get_user_job(id)
{

	callfunc_begin("get_user_job","HarbuRPAlpha.amxx");
	callfunc_push_int(id);
	return callfunc_end();
		
}

stock get_item_amount(id,itemid,table[],customid[])
{
	
	callfunc_begin("harbu_get_item_amount","HarbuRPAlpha.amxx");
	callfunc_push_int(id);
	callfunc_push_int(itemid);
	callfunc_push_str(table);
	callfunc_push_str(customid);
	return callfunc_end();
	
}

stock get_active_jobs(jobrange[2])
{

	new player[32], playerCount;
	get_players(player,playerCount,"c");
	
	new jobCount = 0;
	
	for( new i = 0; i < playerCount; i++ )
	{
		
		new job = get_user_job(player[i]);
		
		if( job >= jobrange[0] && job <= jobrange[1] )
		{
		
			jobCount += 1;
				
		}
		
	}
	
	return jobCount;
		
}

stock get_user_mask(id,dest[],len)
{

	callfunc_begin("get_user_mask","mask.amxx");
	callfunc_push_int(id);
	new mask = callfunc_end();

	new name[32];
	get_user_name(id,name,31);

	format(dest,len,"%s",name);

}