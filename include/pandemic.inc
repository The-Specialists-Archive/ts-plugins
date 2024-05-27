#define	DISEASE_NONE		0
#define DISEASE_INFLUENZA	1
#define DISEASE_TYPHOID		2
#define DISEASE_SARS		3
#define DISEASE_MALARIA		4
#define DISEASE_ZOMBIE		5

#define DISEASE_MIN			1
#define DISEASE_MAX			5

stock GetPlayerDisease(id)
{
	callfunc_begin("getPlayerDisease","pandemic.amxx");
	callfunc_push_int(id);
	return callfunc_end();
}

stock IsPlayerZombie(id)
{
	callfunc_begin("isPlayerZombie","pandemic.amxx");
	callfunc_push_int(id);
	return callfunc_end();
}

stock SetPlayerDisease(id, disease)
{
	callfunc_begin("setPlayerDisease","pandemic.amxx");
	callfunc_push_int(id);
	callfunc_push_int(disease);
	callfunc_end();
}

stock SetPlayerZombie(id, zombie)
{
	callfunc_begin("setPlayerZombie","pandemic.amxx");
	callfunc_push_int(id);
	callfunc_push_int(zombie);
	callfunc_end();
}