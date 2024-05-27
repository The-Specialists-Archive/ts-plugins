/* Plugin generated by AMXX-Studio */

//NOTE TO SELF: REMOVE ALL COLOR INDICATORS LIKE \r and \d and \y AND SUCH

#include <amxmodx>
#include <amxmisc>
#include <tsfun>

#define PLUGIN "Gun Menu"
#define VERSION "1.0"
#define AUTHOR "fluffy"

#define KeysMainGuns (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9) // Keys: 123450
#define KeysHandGuns (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9) // Keys: 1234567890
#define KeysSMGs (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<9) // Keys: 1234560
#define KeysRifles (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9) // Keys: 123450
#define KeysShotguns (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9) // Keys: 123450
#define KeysSpecialPurpose (1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9) // Keys: 23450
#define KeysAttachments (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9) // Keys: 123450

new g_user_weapon[33][2]
new g_user_menu[33][1]

new Silencer[33][1]   //1
new LaserSight[33][1] //2
new FlashLight[33][1] //4
new Scope[33][1]       //8
new attachnum[33][1]

new weapon_names[38][] = {
	"Null", //To occupy space #0
	"Glock-18",
	"TSW_UNK1",
	"Mini-Uzi",
	"Benelli M3",
	"M4A1",
	"MP5SD",
	"MP5K",
	"Akimbo Berettas",
	"SOCOM-MK23",
	"Akimbo MK23",
	"USAS-12",
	"Desert Eagle",
	"AK47",
	"Five-seveN",
	"STEYR-AUG",
	"Akimbo Uzi",
	"STEYR-TMP",
	"Barrett M82A1",
	"MP7-PDW",
	"SPAS-12",
	"Golden Colts",
	"Glock-20C",
	"UMP",
	"M61 Grenade",
	"Combat Knife",
	"Mossberg 500",
	"M16A4",
	"Ruger-MK1",
	"C4",
	"Akimbo 57",
	"Raging Bull",
	"M60E3",
	"Sawed-off",
	"Katana",
	"Seal Knife",
	"Kung Fu",
	"Seal Knife"
}
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_menucmd(register_menuid("Attachments"), KeysAttachments, "PressedAttachments")
	register_menucmd(register_menuid("SpecialPurpose"), KeysSpecialPurpose, "PressedSpecialPurpose")
	register_menucmd(register_menuid("Shotguns"), KeysShotguns, "PressedShotguns")
	register_menucmd(register_menuid("Rifles"), KeysRifles, "PressedRifles")
	register_menucmd(register_menuid("SMGs"), KeysSMGs, "PressedSMGs")
	register_menucmd(register_menuid("HandGuns"), KeysHandGuns, "PressedHandGuns")
	register_menucmd(register_menuid("MainGuns"), KeysMainGuns, "PressedMainGuns")
	
	register_concmd("say /guns", "ShowMainGuns")
	register_concmd("guns", "ShowMainGuns")
}

public ShowMainGuns(id) {
	show_menu(id, KeysMainGuns, "Weapon Menu by fluffy^n^n1. Handguns^n2. SMGs^n3. Rifles^n4. Shotguns^n5. Special Purpose^n^n0. Exit Menu^n", -1, "MainGuns") // Display menu
	return PLUGIN_HANDLED
}

public PressedMainGuns(id, key) {
	/* Menu:
	* Weapon Menu by fluffy
	* 1. Handguns
	* 2. SMGs
	* 3. Rifles
	* 4. Shotguns
	* 5. Special Purpose
	* 
	* 0. Exit Menu
	*/
	
	switch (key) {
		case 0: { // 1
			ShowHandGuns(id)
		}
		case 1: { // 2
			ShowSMGs(id)
		}
		case 2: { // 3
			ShowRifles(id)
		}
		case 3: { // 4
			ShowShotguns(id)
		}
		case 4: { // 5
			ShowSpecialPurpose(id)
		}
		case 9: { // 0
			return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_HANDLED
}


public ShowHandGuns(id) {
	show_menu(id, KeysHandGuns, "Weapon Menu by fluffy^n^n    Handguns^n^n1. Glock-18^n2. SOCOM-MK23^n3. Desert Eagle^n4. Five-seveN^n5. Akimbo Berettas^n6. Golden Colts^n7. Glock-20C^n8. Ruger-MK1^n9. Raging Bull^n^n0. Go Back^n", -1, "HandGuns") // Display menu
}

public PressedHandGuns(id, key) {
	/* Menu:
	* Weapon Menu by fluffy
	*     Handguns
	* 1. Glock-18
	* 2. SOCOM-MK23
	* 3. Desert Eagle
	* 4. Five-seveN
	* 5. Akimbo Berettas
	* 6. Golden Colts
	* 7. Glock-20C
	* 8. Ruger-MK1
	* 9. Raging Bull
	* 
	* 0. Go Back
	*/
	
	g_user_menu[id][0] = 1

	switch (key) {
		case 0: { // 1
			g_user_weapon[id][0] = 1
			ShowAttachments(id)
		}
		case 1: { // 2
			g_user_weapon[id][0] = 9
			ShowAttachments(id)
		}
		case 2: { // 3
			g_user_weapon[id][0] = 12
			ShowAttachments(id)
		}
		case 3: { // 4
			g_user_weapon[id][0] = 14
			ShowAttachments(id)
		}
		case 4: { // 5
			g_user_weapon[id][0] = 8
			ShowAttachments(id)
		}
		case 5: { // 6
			g_user_weapon[id][0] = 21
			ShowAttachments(id)
		}
		case 6: { // 7
			g_user_weapon[id][0] = 22
			ShowAttachments(id)
		}
		case 7: { // 8
			g_user_weapon[id][0] = 28
			ShowAttachments(id)
		}
		case 8: { // 9
			g_user_weapon[id][0] = 31
			ShowAttachments(id)
		}
		case 9: { // 0
			ShowMainGuns(id)
		}
	}
}


public ShowSMGs(id) {
	show_menu(id, KeysSMGs, "Weapon Menu by fluffy^n^n    SMGs^n^n1. Mini-Uzi^n2. MP5SD^n3. MP5K^n4. STEYR-TMP^n5. MP7-PDW^n6. UMP^n^n0. Go Back^n", -1, "SMGs") // Display menu
}

public PressedSMGs(id, key) {
	/* Menu:
	* Weapon Menu by fluffy
	*     SMGs
	* 1. Mini-Uzi
	* 2. MP5SD
	* 3. MP5K
	* 4. STEYR-TMP
	* 5. MP7-PDW
	* 6. UMP
	* 
	* 0. Go Back
	*/
	
	g_user_menu[id][0] = 2

	switch (key) {
		case 0: { // 1
			g_user_weapon[id][0] = 3
			ShowAttachments(id)
		}
		case 1: { // 2
			g_user_weapon[id][0] = 6
			ShowAttachments(id)
		}
		case 2: { // 3
			g_user_weapon[id][0] = 7
			ShowAttachments(id)
		}
		case 3: { // 4
			g_user_weapon[id][0] = 17
			ShowAttachments(id)
		}
		case 4: { // 5
			g_user_weapon[id][0] = 19
			ShowAttachments(id)
		}
		case 5: { // 6
			g_user_weapon[id][0] = 23
			ShowAttachments(id)
		}
		case 9: { // 0
			ShowMainGuns(id)
		}
	}
}


public ShowRifles(id) {
	show_menu(id, KeysRifles, "Weapon Menu by fluffy^n^n    Rifles^n^n1. M4A1^n2. AK47^n3. STEYR-AUG^n4. M16A4^n5. Barrett M82A1^n^n0. Go Back^n", -1, "Rifles") // Display menu
}

public PressedRifles(id, key) {
	/* Menu:
	* Weapon Menu by fluffy
	*     Rifles
	* 1. M4A1
	* 2. AK47
	* 3. STEYR-AUG
	* 4. M16A4
	* 5. Barrett M82A1
	* 
	* 0. Go Back
	*/
	
	g_user_menu[id][0] = 3

	switch (key) {
		case 0: { // 1
			g_user_weapon[id][0] = 5
			ShowAttachments(id)
		}
		case 1: { // 2
			g_user_weapon[id][0] = 13
			ShowAttachments(id)
		}
		case 2: { // 3
			g_user_weapon[id][0] = 15
			ShowAttachments(id)
		}
		case 3: { // 4
			g_user_weapon[id][0] = 27
			ShowAttachments(id)
		}
		case 4: { // 5
			g_user_weapon[id][0] = 18
			ShowAttachments(id)
		}
		case 9: { // 0
			ShowMainGuns(id)
		}
	}
}



public ShowShotguns(id) {
	show_menu(id, KeysShotguns, "Weapon Menu by fluffy^n^n    Shotguns^n^n1. Benelli M3^n2. USAS-12^n3. SPAS-12^n4. Mossberg 500^n5. Sawed-off^n^n0. Go Back^n", -1, "Shotguns") // Display menu
}

public PressedShotguns(id, key) {
	/* Menu:
	* Weapon Menu by fluffy
	*     Shotguns
	* 1. Benelli M3
	* 2. USAS-12
	* 3. SPAS-12
	* 4. Mossberg 500
	* 5. Sawed-off
	* 
	* 0. Go Back
	*/
	
	g_user_menu[id][0] = 4

	switch (key) {
		case 0: { // 1
			g_user_weapon[id][0] = 4
			ShowAttachments(id)
		}
		case 1: { // 2
			g_user_weapon[id][0] = 11
			ShowAttachments(id)
		}
		case 2: { // 3
			g_user_weapon[id][0] = 20
			ShowAttachments(id)
		}
		case 3: { // 4
			g_user_weapon[id][0] = 26
			ShowAttachments(id)
		}
		case 4: { // 5
			g_user_weapon[id][0] = 33
			ShowAttachments(id)
		}
		case 9: { // 0
			ShowMainGuns(id)
		}
	}
}


public ShowSpecialPurpose(id) {
	show_menu(id, KeysSpecialPurpose, "Weapon Menu by fluffy^n^n    Special Purpose^n^n2. Combat Knife^n3. M60E3^n4. Katana^n5. Seal Knife^n^n0. Go Back^n", -1, "SpecialPurpose") // Display menu
}

public PressedSpecialPurpose(id, key) {
	/* Menu:
	* Weapon Menu by fluffy
	*     Special Purpose
	* 2. Combat Knife
	* 3. M60E3
	* 4. Katana
	* 5. Seal Knife
	* 
	* 0. Go Back
	*/
	
	g_user_menu[id][0] = 5

	switch (key) {
		case 1: { // 2
			g_user_weapon[id][0] = 25
			ts_giveweapon(id, g_user_weapon[id][0], 200, 0)
		}
		case 2: { // 3
			g_user_weapon[id][0] = 32
			ts_giveweapon(id, g_user_weapon[id][0], 200, 0)
		}
		case 3: { // 4
			g_user_weapon[id][0] = 34
			ts_giveweapon(id, g_user_weapon[id][0], 200, 0)
		}
		case 4: { // 5
			g_user_weapon[id][0] = 35
			ts_giveweapon(id, g_user_weapon[id][0], 200, 0)
		}
		case 9: { // 0
			ShowMainGuns(id)
		}
	}
}


public ShowAttachments(id) {
	new AttachString[128], Silcheck[2], Lascheck[2], Flacheck[2], Scocheck[2]
	if(Silencer[id][0]){
		format(Silcheck, 1, "+")
	}
	if(LaserSight[id][0]){
		format(Lascheck, 1, "+")
	}
	if(FlashLight[id][0]){
		format(Flacheck, 1, "+")
	}
	if(Scope[id][0]){
		format(Scocheck, 1, "+")
	}
	format(AttachString, 127, "Weapon Menu by fluffy^n^n    %s^n^n1. Buy^n%s2. Silencer^n%s3. Lasersight^n%s4. Flashlight^n%s5. Scope^n^n0. Go Back^n", weapon_names[g_user_weapon[id][0]], Silcheck, Lascheck, Flacheck, Scocheck)
	show_menu(id, KeysAttachments, AttachString, -1, "Attachments") // Display menu
	format(Silcheck, 0, "")
	format(Lascheck, 0, "")
	format(Flacheck, 0, "")
	format(Scocheck, 0, "")
}

public PressedAttachments(id, key) {
	/* Menu:
	* Weapon Menu by fluffy
	*     Attachments
	* 1. Buy
	* 2. Silencer
	* 3. Lasersight
	* 4. Flashlight
	* 5. Scope
	* 
	* 0. Go Back
	*/
	
	switch (key) {
		case 0: { // 1
			if(Silencer[id][0]){
				attachnum[id][0] += 1
			}
			if(LaserSight[id][0]){
				attachnum[id][0] += 2
			}
			if(FlashLight[id][0]){
				attachnum[id][0] += 4
			}
			if(Scope[id][0]){
				attachnum[id][0] += 8
			}
			
			ts_giveweapon(id, g_user_weapon[id][0], 200, attachnum[id][0])
			
			attachnum[id][0] = 0
			Silencer[id][0] = 0
			LaserSight[id][0] = 0
			FlashLight[id][0] = 0
			Scope[id][0] = 0
		}
		case 1: { // 2
			if(Silencer[id][0]){
				Silencer[id][0] = 0
			} else {
				Silencer[id][0] = 1
			}
			ShowAttachments(id)
		}
		case 2: { // 3
			if(LaserSight[id][0]){
				LaserSight[id][0] = 0
			} else {
				LaserSight[id][0] = 1
			}
			ShowAttachments(id)
		}
		case 3: { // 4
			if(FlashLight[id][0]){
				FlashLight[id][0] = 0
			} else {
				FlashLight[id][0] = 1
			}
			ShowAttachments(id)
		}
		case 4: { // 5
			if(Scope[id][0]){
				Scope[id][0] = 0
			} else {
				Scope[id][0] = 1
			}
			ShowAttachments(id)
		}
		case 9: { // 0
			switch (g_user_menu[id][0]) {
				case 1: {
					ShowHandGuns(id)
				}
				case 2: {
					ShowSMGs(id)
				}
				case 3: {
					ShowRifles(id)
				}
				case 4: {
					ShowShotguns(id)
				}
				case 5: {
					ShowSpecialPurpose(id)
				}
			}
			
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
