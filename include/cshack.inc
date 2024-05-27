/* CS "Hack" functions
*
* by Damaged Soul
*
* This file is provided as is (no warranties).
*/

#if defined _cshack_included
  #endinput
#endif
#define _cshack_included

#include <cshack_const>

/************** Natives **************/
/* Returns cost of item. */
native cs_get_item_cost(CsItems:item);

/* Sets cost of item. */
native cs_set_item_cost(CsItems:item, cost);

/* Returns the score of the specified team. 
   Note: Terrorists or CTs only. */
native cs_get_team_score(team);

/* Sets the score of the specified team.
   Note: Terrorists or CTs only. */
native cs_set_team_score(team, score);

/* Returns the number of players on the specified team.
   Note: Terrorists or CTs only. */
native cs_get_team_playercount(team);


/************** Cvar Natives **************/
/* Returns minimum amount of minutes that mp_roundtime can be. */
native Float:cs_get_roundtime_min();

/* Returns maximum amount of minutes that mp_roundtime can be. */
native Float:cs_get_roundtime_max();

/* Sets minimum amount of minutes that mp_roundtime can be.
   Min value: 0
   Max value: 2.116667 (127 seconds) */
native cs_set_roundtime_min(Float:minutes);

/* Sets maximum amount of minutes that mp_roundtime can be.
   Min value: 0
   Max value: 546.116667 (32767 seconds) */
native cs_set_roundtime_max(Float:minutes);

/* Returns maximum amount of seconds that mp_freezetime can be. */
native cs_get_freezetime_max();

/* Sets maximum amount of seconds that mp_freezetime can be.
   Min value: 0
   Max value: 127 */
native cs_set_freezetime_max(seconds);

/* Returns minimum amount of seconds that mp_c4timer can be. */
native cs_get_c4timer_min();

/* Returns maximum amount of seconds that mp_c4timer can be. */
native cs_get_c4timer_max();

/* Sets minimum amount of seconds that mp_c4timer can be.
   Min value: 0
   Max value: 127 */
native cs_set_c4timer_min(seconds);

/* Sets maximum amount of seconds that mp_c4timer can be.
   Min value: 0
   Max value: 127 */
native cs_set_c4timer_max(seconds);

/* Returns minimum amount of money that mp_startmoney can be. */
native cs_get_startmoney_min();

/* Returns maximum amount of money that mp_startmoney can be. */
native cs_get_startmoney_max();

/* Sets minimum amount of money that mp_startmoney can be.
   Min value: 0
   Max value: 2147483583 */
native cs_set_startmoney_min(money);

/* Sets maximum amount of money that mp_startmoney can be.
   Min value: 0
   Max value: 2147483583 */
native cs_set_startmoney_max(money);

/* Returns maximum amount of seconds that sv_restartround can be. */
native cs_get_restartround_max();

/* Sets maximum amount of seconds that sv_restartround can be.
   Min value: 0
   Max value: 255 */
native cs_set_restartround_max(seconds);