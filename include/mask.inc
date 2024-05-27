stock get_user_mask(id,dest[],len)
{

	callfunc_begin("get_user_mask","mask.amxx");
	callfunc_push_int(id);
	new mask = callfunc_end();

	new name[32];
	get_user_name(id,name,31);

	format(dest,len,"%s",name);

}