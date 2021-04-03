
sv_ts_num_rounds = CreateConVar( "sv_ts_num_rounds", "15",
    { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED },
    "Controls the number of rounds before map change. (def 15)" )

if CLIENT then return end

// GAMEMODE CONFIG VARS
sv_ts_select_mode = CreateConVar( "sv_ts_select_mode", "1", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls how the next stalker is picked. (1 = killer, 2 = most damage dealt, 3 = randomized)" )

sv_ts_spectate_time = CreateConVar( "sv_ts_spectate_time", "60", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the time (in seconds) players must spectate before becoming scanners. (def 60)" )

sv_ts_team_nocollide = CreateConVar( "sv_ts_team_nocollide", "0", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls whether soldiers can walk through eachother. (def 0)" )

sv_ts_ff = CreateConVar( "sv_ts_ff", "1", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls whether soldiers can injure eachother. (def 1)" )

sv_ts_ff_damage_scale = CreateConVar( "sv_ts_ff_damage_scale", "0.01", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls friendly fire damage scaling. (def 0.01)" )

sv_ts_ff_damage_reflect = CreateConVar( "sv_ts_ff_damage_reflect", "1", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls whether friendly fire reflects to the shooter. (def 1)" )

sv_ts_ff_reflect_scale = CreateConVar( "sv_ts_ff_reflect_scale", "2.0", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls how much damage friendly fire will reflect. (def 2.0)" )

sv_ts_prop_dmg_scale = CreateConVar( "sv_ts_prop_dmg_scale", "0.05", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls prop damage scaling. (def 0.05)" )

// STALKER CONFIG VARS
sv_ts_stalker_health = CreateConVar( "sv_ts_stalker_health", "80", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the base amount of health the stalker spawns with. (def 80)" )

sv_ts_stalker_add_health = CreateConVar( "sv_ts_stalker_add_health", "15", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the amount of health the stalker spawns with (per human). (def 15)" )

sv_ts_stalker_gib_health = CreateConVar( "sv_ts_stalker_gib_health", "10", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the amount of health the stalker gets from dismembering corpses. (def 10)" )

sv_ts_stalker_kill_health = CreateConVar( "sv_ts_stalker_kill_health", "15", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the amount of health the stalker gets from killing a human. (def 15)" )

sv_ts_stalker_blood_thirst = CreateConVar( "sv_ts_stalker_blood_thirst", "45", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the amount of health the stalker gets from blood thirst melee attacks. (def 45)" )

sv_ts_stalker_blood_thirst = CreateConVar( "sv_ts_stalker_blood_thirst_gib", "25", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the amount of health the stalker gets from blood thirst dismembering. (def 25)" )

sv_ts_stalker_drain_time = CreateConVar( "sv_ts_stalker_drain_time", "1.0", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the time (in seconds) it takes to drain the stalker's health. (def 1.0)" )

sv_ts_stalker_drain_scale = CreateConVar( "sv_ts_stalker_drain_scale", "0.0", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the percentage of health that is drained from the stalker. (def 1.0)" )

sv_ts_stalker_drain_delay = CreateConVar( "sv_ts_stalker_drain_delay", "45", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the delay (in seconds) before the stalker's health begins to drain. (def 45)" )

// NEW STALKER CONFIG VARS
sv_ts_stalker_blood_thirst_mod_damage = CreateConVar( "sv_ts_stalker_blood_thirst_mod_damage", "10", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the damage modifier for blood thirst melee attacks. (def 10)" )

sv_ts_stalker_scream_drain = CreateConVar( "sv_ts_stalker_scream_drain", "25", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the amount of mana used by the stalker scream ability. (def 25)" )

sv_ts_stalker_flay_drain = CreateConVar( "sv_ts_stalker_flay_drain", "50", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the amount of mana used by the stalker flay ability. (def 50)" )

sv_ts_stalker_psycho_drain = CreateConVar( "sv_ts_stalker_psycho_drain", "75", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the amount of mana used by the stalker telekenesis ability. (def 75)" )

sv_ts_stalker_heal_drain = CreateConVar( "sv_ts_stalker_heal_drain", "100", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the amount of mana used by the stalker heal ability. (def 100)" )

sv_ts_stalker_basedamage = CreateConVar( "sv_ts_stalker_basedamage", "50", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the base damage for stalker melee attacks. (def 50)" )

sv_ts_stalker_jump_drain = CreateConVar( "sv_ts_stalker_jump_drain", "10", 
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the mana used by the stalker's super jump ability. (def 10)" )

// PLAYER CONFIG VARS
sv_ts_unit8_flashlight_base_drain = CreateConVar( "sv_ts_unit8_flashlight_base_drain", "0",
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the drain amount of the flashlight. (def 0)" )

sv_ts_unit8_flashlight_drain_time = CreateConVar( "sv_ts_unit8_flashlight_drain_time", "0.2",
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls time per flashlight drain tick in seconds. (def 0.2)" )

sv_ts_unit8_flashlight_drain_mod = CreateConVar( "sv_ts_unit8_flashlight_drain_mod", "1",
{ FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE }, 
"Controls the drain amount of the special flashlight item. (def 1)" )