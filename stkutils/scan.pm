# Module for scanning stalker config files
# Update history: 
#	29/08/2012 - changed priority of clsids.ini querys , implemented two-way config scan
#	26/08/2012 - fix for new fail() syntax, fall back to 'include scanning', added some extra debug check
######################################################
package stkutils::scan;
use strict;
use stkutils::debug qw(fail);
use stkutils::ini_file;
use stkutils::utils qw(get_includes get_path get_all_includes get_filelist);
use IO::File;
use constant section_to_clsid => {

#common
	'm_crow' => 'AI_CROW',
	'flesh_group' => 'AI_FLE_G',
	'graph_point' => 'AI_GRAPH',
	'm_phantom' => 'AI_PHANT',
	'm_rat_e' => 'AI_RAT',
	'rat_group' => 'AI_RAT_G',
	'spawn_group_zone' => 'AI_SPGRP',
	'spawn_group' => 'AI_SPGRP',
	'ammo_11.43x23_hydro' => 'AMMO_S',
	'ammo_9x18_fmj' => 'AMMO_S',
	'ammo_5.56x45_ss190' => 'AMMO_S',
	'ammo_9x19_pbp' => 'AMMO_S',
	'ammo_12x76_zhekan_heli' => 'AMMO_S',
	'ammo_5.56x45_ap' => 'AMMO_S',
	'ammo_12x70_buck' => 'AMMO_S',
	'ammo_9x18_pmm' => 'AMMO_S',
	'ammo_7.62x54_7h1' => 'AMMO_S',
	'ammo_5.45x39_ap' => 'AMMO_S',
	'ammo_5.45x39_fmj' => 'AMMO_S',
	'ammo_gauss' => 'AMMO_S',
	'ammo_9x39_pab9' => 'AMMO_S',
	'ammo_9x19_fmj' => 'AMMO_S',
	'ammo_12x76_zhekan' => 'AMMO_S',
	'ammo_11.43x23_fmj' => 'AMMO_S',
	'ammo_pkm_100' => 'AMMO_S',
	'ammo_9x39_ap' => 'AMMO_S',
	'af_dummy_dummy' => 'ARTEFACT',
	'af_dummy_glassbeads' => 'ARTEFACT',
	'af_dummy_battery' => 'ARTEFACT',
	'af_gold_fish' => 'ARTEFACT',
	'af_night_star' => 'ARTEFACT',	# SCRPTART before 128
	'af_cristall' => 'ARTEFACT',
	'af_medusa' => 'ARTEFACT',
	'af_gravi' => 'ARTEFACT',
	'af_blood' => 'ARTEFACT',
	'af_fireball' => 'ARTEFACT',
	'af_vyvert' => 'ARTEFACT',
	'af_soul' => 'ARTEFACT',
	'af_cristall_flower' => 'ARTEFACT',
	'af_mincer_meat' => 'ARTEFACT',
	'helicopter' => 'C_HLCP_S',
	'detector_advanced' => 'DET_ADVA',
	'detector_elite' => 'DET_ELIT',
	'detector_simple' => 'DET_SIMP',
	'device_flare' => 'D_FLARE',
	'dev_flash_2' => 'D_PDA',
	'dev_flash_1' => 'D_PDA',
	'stalker_outfit' => 'E_STLK',
	'specops_outfit' => 'E_STLK',
	'svoboda_light_outfit' => 'E_STLK',
	'svoboda_heavy_outfit' => 'E_STLK',
	'cs_heavy_outfit' => 'E_STLK',
	'scientific_outfit' => 'E_STLK',
	'exo_outfit' => 'E_STLK',
	'novice_outfit' => 'E_STLK',
	'dolg_heavy_outfit' => 'E_STLK',
	'military_outfit' => 'E_STLK',
	'dolg_outfit' => 'E_STLK',
	'grenade_gd-05' => 'G_F1_S',
	'grenade_f1' => 'G_F1_S',
	'wpn_fake_missile2' => 'G_FAKE',
	'wpn_fake_missile1' => 'G_FAKE',
	'wpn_fake_missile' => 'G_FAKE',
	'grenade_rgd5' => 'G_RGD5_S',
	'wpn_rpg7_missile' => 'G_RPG7',
	'helicopter_missile' => 'G_RPG7',
	'guitar_a' => 'II_ATTCH',
	'attachable_item' => 'II_ATTCH',
	'harmonica_a' => 'II_ATTCH',
	'hand_radio' => 'II_ATTCH',
	'bolt' => 'II_BOLT',
	'new_attachable_item' => 'II_BTTCH',
	'document' => 'II_DOC',
	'level_changer' => 'LVL_CHNG',
	'custom_script_object' => 'NW_ATTCH',
	'breakable_object' => 'O_BRKBL',
	'climable_object' => 'O_CLMBL',
	'lojka' => 'O_DSTR_S',
	'wheel_litter_01_braked' => 'O_DSTR_S',
	'rupor' => 'O_DSTR_S',
	'tarelka1' => 'O_DSTR_S',
	'komp_klava' => 'O_DSTR_S',
	'kolyaska_01_braked' => 'O_DSTR_S',
	'krujka' => 'O_DSTR_S',
	'child_bench' => 'O_DSTR_S',
	'kolyaska_wheel_01_braked' => 'O_DSTR_S',
	'kolyaska_01' => 'O_DSTR_S',
	'med_stolik_01' => 'O_DSTR_S',
	'ognetushitel' => 'O_DSTR_S',
	'tiski' => 'O_DSTR_S',
	'komp_monitor' => 'O_DSTR_S',
	'vedro_01' => 'O_DSTR_S',
	'table_lamp_01' => 'O_DSTR_S',
	'kanistra_02' => 'O_DSTR_S',
	'komp_block' => 'O_DSTR_S',
	'debris_01' => 'O_DSTR_S',
	'teapot_1' => 'O_DSTR_S',
	'tarelka2' => 'O_DSTR_S',
	'wheel_litter_01' => 'O_DSTR_S',
	'shooting_target_1' => 'O_DSTR_S',
	'bottle_3l' => 'O_DSTR_S',
	'priemnik_gorizont' => 'O_DSTR_S',
	'kastrula_up' => 'O_DSTR_S',
	'physic_destroyable_object' => 'O_DSTR_S',
	'notebook' => 'O_DSTR_S',
	'miska' => 'O_DSTR_S',
	'kanistra_01' => 'O_DSTR_S',
	'kastrula' => 'O_DSTR_S',
	'fire_vedro' => 'O_DSTR_S',
	'freezer' => 'O_DSTR_S',
	'transiver' => 'O_DSTR_S',
	'tv_1' => 'O_DSTR_S',
	'physic_object' => 'O_PHYS_S',
	'search_light' => 'O_SEARCH',
	'ph_skeleton_object' => 'P_SKELET',
	'script_zone' => 'SCRIPTZN',
	'sim_faction' => 'SFACTION',
	'af_electra_moonlight' => 'SCRPTART',
	'af_fuzz_kolobok' => 'SCRPTART',		# ARTEFACT before 128
	'af_electra_sparkler' => 'SCRPTART',
	'af_electra_flash' => 'SCRPTART',
	'm_car' => 'SCRPTCAR',
	'script_object' => 'SCRPTOBJ',
	'smart_terrain' => 'SMRTTRRN',
	'smart_cover' => 'SMRT_C_S',
	'bloodsucker_weak' => 'SM_BLOOD',
	'bloodsucker_normal' => 'SM_BLOOD',
	'm_bloodsucker_e' => 'SM_BLOOD',
	'bloodsucker_strong' => 'SM_BLOOD',
	'm_boar_e' => 'SM_BOARW',
	'boar_normal' => 'SM_BOARW',
	'boar_strong' => 'SM_BOARW',
	'm_burer_e' => 'SM_BURER',
	'm_chimera_e' => 'SM_CHIMS',
	'chimera_normal' => 'SM_CHIMS',
	'm_controller_normal' => 'SM_CONTR',
	'm_controller_e' => 'SM_CONTR',
	'controller_tubeman' => 'SM_CONTR',
	'psy_dog_phantom' => 'SM_DOG_F',
	'psy_dog' => 'SM_DOG_P',
	'dog_normal' => 'SM_DOG_S',
	'm_dog_e' => 'SM_DOG_S',
	'dog_strong' => 'SM_DOG_S',
	'dog_weak' => 'SM_DOG_S',
	'flesh_strong' => 'SM_FLESH',
	'flesh_normal' => 'SM_FLESH',
	'm_flesh_e' => 'SM_FLESH',
	'gigant_normal' => 'SM_GIANT',
	'm_gigant_e' => 'SM_GIANT',
	'm_poltergeist_normal_flame' => 'SM_POLTR',
	'm_poltergeist_normal_tele' => 'SM_POLTR',
	'm_poltergeist_e' => 'SM_POLTR',
	'm_pseudodog_e' => 'SM_P_DOG',
	'pseudodog_normal' => 'SM_P_DOG',
	'aes_snork' => 'SM_SNORK', 		# before 128
	'snork_indoor' => 'SM_SNORK',
	'snork_jumper' => 'SM_SNORK',
	'snork_outdoor' => 'SM_SNORK',
	'snork_normal' => 'SM_SNORK',
	'm_snork_e' => 'SM_SNORK',
	'snork_weak' => 'SM_SNORK',
	'snork_strong' => 'SM_SNORK',
	'tushkano_normal' => 'SM_TUSHK',
	'm_tushkano_e' => 'SM_TUSHK',
	'lights_hanging_lamp' => 'SO_HLAMP',
	'lights_signal_light' => 'SO_HLAMP',
	'space_restrictor' => 'SPC_RS_S',
	'spectator' => 'SPECT',
	'actor' => 'S_ACTOR',		# O_ACTOR before 122 (cse_alife_creature_actor)
	'explosive_grenade' => 'S_EXPLO',	#II_EXPLO before 122
	'explosive_dinamit' => 'S_EXPLO',	#II_EXPLO before 122
	'explosive_hide' => 'S_EXPLO',	#II_EXPLO before 122
	'explosive_particle' => 'S_EXPLO',	#II_EXPLO before 122
	'explosive_tank' => 'S_EXPLO',	#II_EXPLO before 122
	'explosive_barrel_low' => 'S_EXPLO',	#II_EXPLO before 122
	'explosive_mobiltank' => 'S_EXPLO',	#II_EXPLO before 122
	'explosive_barrel' => 'S_EXPLO',	#II_EXPLO before 122
	'explosive_fuelcan' => 'S_EXPLO',	#II_EXPLO before 122
	'bandage' => 'S_FOOD',		# II_BANDG  before 128
	'vodka' => 'S_FOOD',			# II_BOTTL  before 128
	'energy_drink' => 'S_FOOD',	# II_BOTTL  before 128
	'medkit_army' => 'S_FOOD',	# II_MEDKI  before 128
	'bread' => 'S_FOOD',			# II_FOOD  before 128
	'medkit' => 'S_FOOD',			# II_MEDKI  before 128
	'kolbasa' => 'S_FOOD',		# II_FOOD  before 128
	'medkit_scientic' => 'S_FOOD',	# II_MEDKI  before 128
	'conserva' => 'S_FOOD',		# II_FOOD  before 128
	'antirad' => 'S_FOOD',		# II_ANTIR  before 128
	'inventory_box' => 'S_INVBOX',
	'ammo_m209' => 'S_M209',		#A_M209 in 124
	'ammo_og-7b' => 'S_OG7B',		#A_OG7B in 124
	'device_pda' => 'S_PDA',
	'ammo_vog-25' => 'S_VOG25',		#A_VOG25 in 124
	'device_torch' => 'TORCH_S',
	'wpn_g36' => 'WP_AK74',
	'wpn_abakan' => 'WP_AK74',
	'wpn_vintorez' => 'WP_AK74', # WP_VINT in soc
	'wpn_ak74' => 'WP_AK74',
	'wpn_pkm' => 'WP_AK74',
	'wpn_sig550' => 'WP_AK74',
	'wpn_ak74u' => 'WP_AK74',
	'wpn_groza' => 'WP_AK74',
	'wpn_l85' => 'WP_AK74',
	'wpn_lr300' => 'WP_AK74',
	'wpn_spas12' => 'WP_ASHTG',
	'wpn_wincheaster1300' => 'WP_ASHTG',
	'wpn_binoc' => 'WP_BINOC',
	'wpn_bm16' => 'WP_BM16',
	'wpn_toz34' => 'WP_BM16',
	'wpn_addon_grenade_launcher' => 'WP_GLAUN',
	'wpn_addon_grenade_launcher_m203' => 'WP_GLAUN',
	'wpn_fn2000' => 'WP_GROZA',
	'wpn_hpsa' => 'WP_HPSA',
	'wpn_knife' => 'WP_KNIFE',
	'wpn_beretta' => 'WP_LR300',	# WP_PM before 128
	'wpn_mp5' => 'WP_LR300',
	'wpn_sig220' => 'WP_LR300',	# WP_PM before 128
	'wpn_usp' => 'WP_LR300',		# WP_USP45 before 128
	'wpn_walther' => 'WP_LR300',	# WP_WALTH - soc', WP_PM - cs
	'wpn_fort' => 'WP_PM',
	'wpn_pm' => 'WP_PM',
	'wpn_pb' => 'WP_PM',
	'wpn_desert_eagle' => 'WP_PM',
	'wpn_colt1911' => 'WP_PM',
	'wpn_rg-6' => 'WP_RG6',
	'wpn_rpg7' => 'WP_RPG7',
	'wpn_addon_scope' => 'WP_SCOPE',
	'wpn_addon_scope_susat' => 'WP_SCOPE',
	'wpn_addon_silencer' => 'WP_SILEN',
	'wpn_gauss' => 'WP_SVD',
	'wpn_svd' => 'WP_SVD',
	'wpn_svu' => 'WP_SVU',
	'wpn_val' => 'WP_VAL',
	'mounted_weapon' => 'W_MOUNTD',
	'stationary_mgun' => 'W_STMGUN',
	'zone_burning_fuzz_average' => 'ZS_BFUZZ',
	'zone_burning_fuzz_strong' => 'ZS_BFUZZ',
	'zone_burning_fuzz' => 'ZS_BFUZZ',
	'zone_burning_fuzz_weak' => 'ZS_BFUZZ',
	'zone_gravi_zone' => 'ZS_GALAN',
	'zone_mine_gravitational_average' => 'ZS_GALAN',
	'zone_mine_acidic' => 'ZS_MBALD',
	'zone_mine_thermal_strong' => 'ZS_MBALD',
	'zone_buzz_strong' => 'ZS_MBALD',
	'zone_zharka_static' => 'ZS_MBALD',
	'zone_buzz_average' => 'ZS_MBALD',
	'zone_witches_galantine_weak' => 'ZS_MBALD',
	'zone_zharka_static_weak' => 'ZS_MBALD',
	'zone_mine_acidic_weak' => 'ZS_MBALD',
	'zone_mine_electric_weak' => 'ZS_MBALD',
	'zone_zharka_static_strong' => 'ZS_MBALD',
	'zone_zharka_static_average' => 'ZS_MBALD',
	'zone_witches_galantine_average' => 'ZS_MBALD',
	'zone_mine_electric_strong' => 'ZS_MBALD',
	'zone_mine_electric' => 'ZS_MBALD',
	'zone_mine_gravitational_weak' => 'ZS_MBALD',
	'zone_mine_thermal_average' => 'ZS_MBALD',
	'zone_mine_thermal' => 'ZS_MBALD',
	'zone_buzz' => 'ZS_MBALD',
	'zone_mine_acidic_average' => 'ZS_MBALD',
	'zone_mine_thermal_weak' => 'ZS_MBALD',
	'zone_witches_galantine' => 'ZS_MBALD',
	'zone_mine_electric_average' => 'ZS_MBALD',
	'zone_buzz_weak' => 'ZS_MBALD',
	'zone_witches_galantine_strong' => 'ZS_MBALD',
	'zone_mine_acidic_strong' => 'ZS_MBALD',
	'zone_mine_gravitational_strong' => 'ZS_MINCE',
	'zone_field_psychic_strong' => 'ZS_RADIO',
	'zone_field_psychic_average' => 'ZS_RADIO',
	'zone_field_radioactive_average' => 'ZS_RADIO',
	'zone_field_thermal_weak' => 'ZS_RADIO',
	'zone_field_radioactive_strong' => 'ZS_RADIO',
	'zone_field_psychic' => 'ZS_RADIO',
	'zone_field_acidic_weak' => 'ZS_RADIO',
	'zone_field_acidic_average' => 'ZS_RADIO',
	'zone_field_radioactive' => 'ZS_RADIO',
	'zone_field_psychic_weak' => 'ZS_RADIO',
	'zone_field_radioactive_weak' => 'ZS_RADIO',
	'zone_field_acidic_strong' => 'ZS_RADIO',
	'zone_field_acidic' => 'ZS_RADIO',
	'zone_field_thermal_strong' => 'ZS_RADIO',
	'zone_field_thermal_average' => 'ZS_RADIO',
	'zone_field_thermal' => 'ZS_RADIO',
	'fireball_zone' => 'ZS_TORRD',		# Z_TORRID before 128
	'campfire' => 'Z_CFIRE',
	'zone_mine_field' => 'Z_MBALD',
	'zone_teleport' => 'Z_MBALD',
	'zone_no_gravity' => 'Z_NOGRAV',
	'zone_radioactive' => 'Z_RADIO',
	'zone_radioactive_average' => 'Z_RADIO',
	'zone_radioactive_strong' => 'Z_RADIO',
	'zone_radioactive_weak' => 'Z_RADIO',
	'zone_team_base' => 'Z_TEAMBS',

	
#118	
	'af_ameba_mica' => 'ARTEFACT',
	'af_ameba_slime' => 'ARTEFACT',
	'af_ameba_slug' => 'ARTEFACT',
	'af_blood_tutorial' => 'ARTEFACT',
	'af_drops' => 'ARTEFACT',
	'af_dummy_pellicle' => 'ARTEFACT',
	'af_dummy_spring' => 'ARTEFACT',
	'af_rusty_kristall' => 'ARTEFACT',
	'af_rusty_sea-urchin' => 'ARTEFACT',
	'af_rusty_thorn' => 'ARTEFACT',
	'agr_bandit_respawn_1' => 'AI_STL_S',
	'agr_bandit_respawn_2' => 'AI_STL_S',
	'agr_soldier_regular' => 'AI_STL_S',
	'agr_soldier_veteran' => 'AI_STL_S',
	'agr_stalker_regular' => 'AI_STL_S',
	'agr_stalker_veteran' => 'AI_STL_S',
	'ammo_5.7x28_ap' => 'AMMO',
	'ammo_5.7x28_fmj' => 'AMMO',
	'bad_psy_helmet' => 'II_ATTCH',
	'bar_arena_respawner' => 'AI_STL_S',
	'bar_dolg_respawn_1' => 'AI_STL_S',
	'bar_dolg_respawn_2' => 'AI_STL_S',
	'bar_dolg_respawn_3' => 'AI_STL_S',
	'bar_ecolog_flash' => 'II_ATTCH',
	'bar_lucky_pda' => 'II_ATTCH',
	'bar_stalker_respawn_1' => 'AI_STL_S',
	'bar_stalker_respawn_2' => 'AI_STL_S',
	'bar_stalker_respawn_3' => 'AI_STL_S',
	'bar_stalker_respawn_4' => 'AI_STL_S',
	'bar_tiran_pda' => 'II_ATTCH',
	'binocular_a' => 'II_ATTCH',
	'bread_a' => 'II_ATTCH',
	'cit_bandit_respawn_1' => 'AI_STL_S',
	'cit_bandit_respawn_2' => 'AI_STL_S',
	'cit_doctors_key' => 'II_ATTCH',
	'cit_killer_respawn_1' => 'AI_STL_S',
	'cit_killer_respawn_2' => 'AI_STL_S',
	'cit_killer_respawn_3' => 'AI_STL_S',
	'crazy_flash' => 'II_ATTCH',
	'custom_script_object' => 'NW_ATTCH',
	'dar_document1' => 'II_ATTCH',
	'dar_document2' => 'II_ATTCH',
	'dar_document3' => 'II_ATTCH',
	'dar_document4' => 'II_ATTCH',
	'dar_document5' => 'II_ATTCH',
	'dar_pass_document' => 'II_ATTCH',
	'dar_pass_flash' => 'II_ATTCH',
	'decoder' => 'II_ATTCH',
	'detector_advances' => 'D_SIMDET',
	'device_atifact_merger' => 'II_ATTCH',
	'dolg_regular' => 'AI_STL_S',
	'dolg_scientific_outfit' => 'E_STLK',
	'ds_bandit_respawn_1' => 'AI_STL_S',
	'ds_bandit_respawn_2' => 'AI_STL_S',
	'ds_bandit_respawn_3' => 'AI_STL_S',
	'ds_stalker_respawn_1' => 'AI_STL_S',
	'ds_stalker_respawn_2' => 'AI_STL_S',
	'dynamite' => 'II_ATTCH',
	'ecolog_outfit' => 'E_STLK',
	'esc_bandit_respawn_1' => 'AI_STL_S',
	'esc_bandit_respawn_2' => 'AI_STL_S',
	'esc_soldier_respawn_1' => 'AI_STL_S',
	'esc_soldier_respawn_specnaz' => 'AI_STL_S',
	'esc_stalker_respawn_1' => 'AI_STL_S',
	'esc_stalker_respawn_2' => 'AI_STL_S',
	'esc_wounded_flash' => 'II_ATTCH',
	'flesh_weak' => 'SM_FLESH',
	'gar_bandit_respawn_1' => 'AI_STL_S',
	'gar_bandit_respawn_2' => 'AI_STL_S',
	'gar_dolg_respawn_1' => 'AI_STL_S',
	'gar_dolg_respawn_2' => 'AI_STL_S',
	'gar_stalker_respawn_1' => 'AI_STL_S',
	'gar_stalker_respawn_2' => 'AI_STL_S',
	'good_psy_helmet' => 'II_ATTCH',
	'gunslinger_flash' => 'II_ATTCH',
	'hunters_toz' => 'WP_BM16',
	'killer' => 'AI_STL_S',
	'killer_outfit' => 'E_STLK',
	'kolbasa_a' => 'II_ATTCH',
	'kruglov_flash' => 'D_SIMDET',
	'lab_x16_documents' => 'II_ATTCH',
	'm_army_commander' => 'AI_STL',
	'm_army_sniper' => 'AI_STL',
	'm_army_soldier' => 'AI_STL',
	'm_army_specnaz' => 'AI_STL',
	'm_bandit_bandit' => 'AI_STL',
	'm_bandit_commander' => 'AI_STL',
	'm_fraction_commander' => 'AI_STL',
	'm_fraction_sniper' => 'AI_STL',
	'm_fraction_soldier' => 'AI_STL',
	'm_fraction_specnaz' => 'AI_STL',
	'm_poltergeist_normal' => 'SM_POLTR',
	'm_poltergeist_tele_outdoor' => 'SM_POLTR',
	'mil_freedom_barier_respawn_1' => 'AI_STL_S',
	'mil_freedom_respawn_1' => 'AI_STL_S',
	'mil_freedom_respawn_2' => 'AI_STL_S',
	'mil_freedom_respawn_3' => 'AI_STL_S',
	'mil_freedom_respawn_sniper' => 'AI_STL_S',
	'mil_killer_respawn_1' => 'AI_STL_S',
	'mil_killer_respawn_2' => 'AI_STL_S',
	'mil_killer_respawn_3' => 'AI_STL_S',
	'mil_killer_respawn_4' => 'AI_STL_S',
	'mil_monolit_rush_respawn_1' => 'AI_STL_S',
	'mil_neutral_barier_respawn_1' => 'AI_STL_S',
	'mil_stalker_respawn_1' => 'AI_STL_S',
	'mil_stalker_respawn_2' => 'AI_STL_S',
	'mil_stalker_respawn_3' => 'AI_STL_S',
	'mil_svoboda_leader_pda' => 'II_ATTCH',
	'military' => 'AI_STL_S',
	'military_commander_outfit' => 'EQU_MLTR',
	'military_stalker_outfit' => 'EQU_MLTR',
	'monolit_outfit' => 'E_STLK',
	'outfit_killer_m1' => 'E_STLK',
	'pri_decoder_documents' => 'II_ATTCH',
	'pri_monolith_respawn_1' => 'AI_STL_S',
	'pri_monolith_respawn_2' => 'AI_STL_S',
	'pri_monolith_respawn_3' => 'AI_STL_S',
	'pri_respawn_dolg' => 'AI_STL_S',
	'pri_respawn_freedom' => 'AI_STL_S',
	'pri_respawn_military' => 'AI_STL_S',
	'pri_respawn_neutral' => 'AI_STL_S',
	'protection_outfit' => 'E_STLK',
	'quest_case_01' => 'II_ATTCH',
	'quest_case_02' => 'II_ATTCH',
	'rad_freedom_respawn_1' => 'AI_STL_S',
	'rad_freedom_respawn_2' => 'AI_STL_S',
	'rad_freedom_respawn_3' => 'AI_STL_S',
	'rad_monolith_respawn_1' => 'AI_STL_S',
	'rad_monolith_respawn_2' => 'AI_STL_S',
	'rad_monolith_respawn_3' => 'AI_STL_S',
	'rad_soldier_master' => 'AI_STL_S',
	'rad_specnaz_respawn_specnaz' => 'AI_STL_S',
	'rad_zombied_respawn_1' => 'AI_STL_S',
	'rad_zombied_respawn_2' => 'AI_STL_S',
	'rad_zombied_respawn_3' => 'AI_STL_S',
	'ros_bandit_respawn_3' => 'AI_STL_S',
	'ros_bandit_respawn_4' => 'AI_STL_S',
	'ros_killer_respawn_1' => 'AI_STL_S',
	'ros_killer_respawn_2' => 'AI_STL_S',
	'ros_killer_respawn_3' => 'AI_STL_S',
	'ros_killer_respawn_4' => 'AI_STL_S',
	'sar_monolith_respawn' => 'AI_STL_S',
	'sim_freedom_master_quest' => 'AI_STL_S',
	'soldier_outfit' => 'E_STLK',
	'trigger' => 'O_SWITCH',
	'val_bandit_respawn_1' => 'AI_STL_S',
	'val_bandit_respawn_2' => 'AI_STL_S',
	'val_bandit_respawn_3' => 'AI_STL_S',
	'val_bandit_respawn_4' => 'AI_STL_S',
	'val_key_to_underground' => 'II_ATTCH',
	'val_soldier_respawn_1' => 'AI_STL_S',
	'vodka_a' => 'II_ATTCH',
	'wpn_abakan_m1' => 'WP_AK74',
	'wpn_abakan_m2' => 'WP_AK74',
	'wpn_ak74_m1' => 'WP_AK74',
	'wpn_colt_m1' => 'WP_PM',
	'wpn_eagle_m1' => 'WP_PM',
	'wpn_fort_m1' => 'WP_PM',
	'wpn_groza_m1' => 'WP_GROZA',
	'wpn_l85_m1' => 'WP_AK74',
	'wpn_l85_m2' => 'WP_AK74',
	'wpn_lr300_m1' => 'WP_AK74',
	'wpn_mac10' => 'W_AK74',
	'wpn_mp5_m1' => 'WP_LR300',
	'wpn_mp5_m2' => 'WP_LR300',
	'wpn_rg6_m1' => 'WP_RG6',
	'wpn_sig_m1' => 'WP_AK74',
	'wpn_sig_m2' => 'WP_AK74',
	'wpn_spas12_m1' => 'WP_SHOTG',
	'wpn_svd_m1' => 'WP_SVD',
	'wpn_val_m1' => 'WP_VAL',
	'wpn_walther_m1' => 'WP_WALTH',
	'wpn_winchester_m1' => 'WP_SHOTG',
	'yan_ecolog_respawn_1' => 'AI_STL_S',
	'yan_zombied_respawn_1' => 'AI_STL_S',
	'yan_zombied_respawn_2' => 'AI_STL_S',
	'yan_zombied_respawn_3' => 'AI_STL_S',

#118-124	
	'bandit' => 'AI_STL_S',			# before 128
	'bandit_outfit' => 'E_STLK',		# before 128
	'bloodsucker_arena' => 'SM_BLOOD',# before 128
	'bloodsucker_mil' => 'SM_BLOOD',  # before 128
	'boar_weak' => 'SM_BOARW',  		# before 128
	'burer_arena' => 'SM_BURER',		# before 128
	'burer_indoor' => 'SM_BURER',		# before 128
	'burer_outdoor' => 'SM_BURER',	# before 128
	'dolg' => 'AI_STL_S',				# before 128
	'ecolog' => 'AI_STL_S',			# before 128
	'freedom' => 'AI_STL_S',			# before 128
	'm_barman' => 'AI_STL_S',			# before 128
	'm_burer_normal' => 'SM_BURER',	# before 128
	'm_burer_normal_black' => 'SM_BURER',	# before 128
	'm_cat_e' => 'SM_CAT_S',	# before 128
	'm_controller_normal_fat' => 'SM_CONTR',	# before 128
	'm_controller_old' => 'SM_CONTR',	# before 128
	'm_controller_old_fat' => 'SM_CONTR',	# before 128
	'm_fracture_e' => 'SM_IZLOM',	# before 128
	'm_gigant_normal' => 'SM_GIANT',	# before 128
	'm_izgoy' => 'AI_STL',	# before 128
	'm_osoznanie' => 'AI_STL_S',	# before 128
	'm_poltergeist_strong_flame' => 'SM_POLTR',	# before 128
	'm_trader' => 'AI_TRD_S',	# before 128
	'm_tushkano_normal' => 'SM_TUSHK',	# before 128
	'm_zombie_e' => 'SM_ZOMBI',	# before 128
	'monolith' => 'AI_STL_S',	# before 128
	'outfit_bandit_m1' => 'E_STLK',	# before 128
	'outfit_dolg_m1' => 'E_STLK',	# before 128
	'outfit_exo_m1' => 'E_STLK',	# before 128
	'outfit_novice_m1' => 'E_STLK',	# before 128
	'outfit_specnaz_m1' => 'E_STLK',	# before 128
	'outfit_stalker_m1' => 'E_STLK',	# before 128
	'outfit_stalker_m2' => 'E_STLK',	# before 128
	'outfit_svoboda_m1' => 'E_STLK',	# before 128
	'pseudodog_arena' => 'SM_P_DOG',	# before 128
	'pseudodog_strong' => 'SM_P_DOG',	# before 128
	'pseudodog_weak' => 'SM_P_DOG',	# before 128
	'psy_dog_radar' => 'SM_DOG_P',	# before 128
	'respawn' => 'RE_SPAWN',		# before 128
	'snork_arena' => 'SM_SNORK',		# before 128
	'stalker' => 'AI_STL_S',		# before 128
	'stalker_fresh_zombied' => 'AI_STL_S',		# before 128
	'stalker_monolith' => 'AI_STL_S',		# before 128
	'stalker_sakharov' => 'AI_STL_S',		# before 128
	'stalker_trader' => 'AI_STL_S',		# before 128
	'stalker_zombied' => 'AI_STL_S',		# before 128
	'torrid_zone' => 'Z_TORRID',			# before 128
	'wpn_ak74_arena' => 'WP_AK74',		# before 128
	'wpn_ak74u_arena' => 'WP_AK74',		# before 128', in soc - WP_LR300
	'wpn_ak74u_m1' => 'WP_AK74',		# before 128', in soc - WP_LR300
	'wpn_bm16_arena' => 'WP_BM16',	# before 128
	'wpn_fn2000_arena' => 'WP_GROZA',	# before 128
	'wpn_g36_arena' => 'WP_AK74',		# before 128
	'wpn_groza_arena' => 'WP_GROZA',	# before 128
	'wpn_mp5_arena' => 'WP_LR300',	# before 128
	'wpn_pm_arena' => 'WP_PM',		# before 128
	'wpn_spas12_arena' => 'WP_SHOTG',	# before 128
	'wpn_toz34_arena' => 'WP_BM16',	# before 128
	'wpn_val_arena' => 'WP_VAL',		# before 128
	'zombie_immortal' => 'SM_ZOMBI',		# before 128
	'zombie_normal' => 'SM_ZOMBI',		# before 128
	'zombie_strong' => 'SM_ZOMBI',		# before 128
	'zombie_weak' => 'SM_ZOMBI',		# before 128
	'zombied' => 'AI_STL_S',		# before 128
	'zone_ameba' => 'Z_AMEBA',		# before 128
	'zone_ameba1' => 'Z_AMEBA',		# before 128
	'zone_burning_fuzz_bottom_average' => 'ZS_BFUZZ',		# before 128
	'zone_burning_fuzz_bottom_strong' => 'ZS_BFUZZ',		# before 128
	'zone_burning_fuzz_bottom_weak' => 'ZS_BFUZZ',		# before 128
	'zone_burning_fuzz1' => 'ZS_BFUZZ',		# before 128
	'zone_campfire_grill' => 'Z_MBALD',		# before 128
	'zone_campfire_mp_nolight' => 'Z_MBALD',		# before 128
	'zone_death' => 'Z_MBALD',		# before 128
	'zone_emi' => 'Z_MBALD',		# before 128
	'zone_flame' => 'Z_MBALD',		# before 128
	'zone_flame_small' => 'Z_MBALD',		# before 128
	'zone_gravi_zone_average' => 'ZS_GALAN',		# before 128
	'zone_gravi_zone_killing' => 'ZS_GALAN',		# before 128
	'zone_gravi_zone_strong' => 'ZS_GALAN',		# before 128
	'zone_gravi_zone_weak' => 'ZS_GALAN',		# before 128
	'zone_gravi_zone_weak_noart' => 'ZS_GALAN',		# before 128
	'zone_mincer' => 'ZS_MINCE',		# before 128
	'zone_mincer_average' => 'ZS_MINCE',		# before 128
	'zone_mincer_strong' => 'ZS_MINCE',		# before 128
	'zone_mincer_weak' => 'ZS_MINCE',		# before 128
	'zone_mincer_weak_noart' => 'ZS_MINCE',		# before 128
	'zone_mine_acidic_weak_noshadow' => 'ZS_MBALD',		# before 128
	'zone_monolith' => 'Z_RADIO',		# before 128
	'zone_mosquito_bald' => 'ZS_MBALD',		# before 128
	'zone_mosquito_bald_average' => 'ZS_MBALD',		# before 128
	'zone_mosquito_bald_strong' => 'ZS_MBALD',		# before 128
	'zone_mosquito_bald_strong_noart' => 'ZS_MBALD',		# before 128
	'zone_mosquito_bald_weak' => 'ZS_MBALD',		# before 128
	'zone_mosquito_bald_weak_noart' => 'ZS_MBALD',		# before 128
	'zone_radioactive_killing' => 'Z_RADIO',		# before 128
	'zone_rusty_hair' => 'Z_RUSTYH',		# before 128
	'zone_sarcofag' => 'Z_MBALD',		# before 128
	'zone_teleport_monolith' => 'Z_ZONE',		# before 128
	'zone_teleport_out' => 'Z_MBALD',		# before 128
	'zone_zhar' => 'Z_MBALD',			# before 128
	
#124
	'mar_quest_af_cristall_flower_1' => 'ARTEFACT',
	'mil_quest_af_fuzz_kolobok' => 'ARTEFACT',
	'agr_bar_stalker_1' => 'AI_STL_S',
	'agr_bar_stalker_2' => 'AI_STL_S',
	'agr_bar_stalker_3' => 'AI_STL_S',
	'agr_bar_stalker_4' => 'AI_STL_S',
	'agr_bar_stalker_5' => 'AI_STL_S',
	'agr_barman' => 'AI_STL_S',
	'agr_bloodsucker_home' => 'SM_BLOOD',
	'agr_dog_01' => 'SM_DOG_S',
	'agr_dog_02' => 'SM_DOG_S',
	'agr_dog_03' => 'SM_DOG_S',
	'agr_dog_04' => 'SM_DOG_S',
	'agr_dog_05' => 'SM_DOG_S',
	'agr_dog_06' => 'SM_DOG_S',
	'agr_dog_07' => 'SM_DOG_S',
	'agr_dog_08' => 'SM_DOG_S',
	'agr_dog_09' => 'SM_DOG_S',
	'agr_dog_10' => 'SM_DOG_S',
	'agr_dolg_blockpost_commander' => 'AI_STL_S',
	'agr_duty_base_trader' => 'AI_STL_S',
	'agr_holeman' => 'AI_STL_S',
	'agr_map_animals' => 'D_PDA',
	'agr_mechanic_pda' => 'D_PDA',
	'agr_pda_for_secret_trader' => 'D_PDA',
	'agr_quest_duty_abakan' => 'WP_AK74',
	'agr_quest_duty_case' => 'D_PDA',
	'agr_quest_duty_secret_pda' => 'D_PDA',
	'agr_quest_wpn_spas12' => 'WP_SHOTG',
	'agr_scientists_bloodsucker' => 'SM_BLOOD',
	'agr_secret_trader' => 'AI_STL_S',
	'agr_snork_hole_1' => 'SM_SNORK',
	'agr_snork_hole_2' => 'SM_SNORK',
	'agr_snork_hole_3' => 'SM_SNORK',
	'agr_snork_hole_4' => 'SM_SNORK',
	'agr_snork_hole_5' => 'SM_SNORK',
	'agr_snork_hole_6' => 'SM_SNORK',
	'agr_snork_hole_7' => 'SM_SNORK',
	'agr_snork_hole_8' => 'SM_SNORK',
	'agr_snork_hole_9' => 'SM_SNORK',
	'agr_snork_jumper_1' => 'SM_SNORK',
	'agr_snork_jumper_2' => 'SM_SNORK',
	'agr_snork_jumper_3' => 'SM_SNORK',
	'agr_stalker_base_leader' => 'AI_STL_S',
	'agr_stalker_base_mechanic' => 'AI_STL_S',
	'agr_stalker_base_trader' => 'AI_STL_S',
	'agr_stalker_commander_1' => 'AI_STL_S',
	'agr_stalker_commander_2' => 'AI_STL_S',
	'agr_stalker_zombied_1_default' => 'AI_STL_S',
	'agr_weaponmaster' => 'AI_STL_S',
	'agru_bloodsucker' => 'SM_BLOOD',
	'agru_controller_1' => 'SM_CONTR',
	'agru_door' => 'O_PHYS_S',
	'agru_end_poltergeist_1' => 'SM_POLTR',
	'agru_end_poltergeist_2' => 'SM_POLTR',
	'agru_end_poltergeist_3' => 'SM_POLTR',
	'agru_end_poltergeist_4' => 'SM_POLTR',
	'agru_poltergeist_1' => 'SM_POLTR',
	'agru_poltergeist_2' => 'SM_POLTR',
	'agru_poltergeist_3' => 'SM_POLTR',
	'agru_poltergeist_4' => 'SM_POLTR',
	'agru_snork_1' => 'SM_SNORK',
	'agru_snork_10' => 'SM_SNORK',
	'agru_snork_11' => 'SM_SNORK',
	'agru_snork_12' => 'SM_SNORK',
	'agru_snork_13' => 'SM_SNORK',
	'agru_snork_14' => 'SM_SNORK',
	'agru_snork_15' => 'SM_SNORK',
	'agru_snork_16' => 'SM_SNORK',
	'agru_snork_17' => 'SM_SNORK',
	'agru_snork_2' => 'SM_SNORK',
	'agru_snork_3' => 'SM_SNORK',
	'agru_snork_4' => 'SM_SNORK',
	'agru_snork_5' => 'SM_SNORK',
	'agru_snork_6' => 'SM_SNORK',
	'agru_snork_7' => 'SM_SNORK',
	'agru_snork_8' => 'SM_SNORK',
	'agru_snork_9' => 'SM_SNORK',
	'agru_tushkanchik_1' => 'SM_TUSHK',
	'agru_tushkanchik_2' => 'SM_TUSHK',
	'agru_tushkanchik_3' => 'SM_TUSHK',
	'ammo_12x76_dart' => 'AMMO',
	'ammo_223_fmj' => 'AMMO',
	'ammo_7.62x54_7h14' => 'AMMO',
	'ammo_7.62x54_ap' => 'AMMO',
	'ammo_9x18_pbp' => 'AMMO',
	'ammo_9x39_sp5' => 'AMMO',
	'ammo_minigame' => 'AMMO',
	'ammo_vog-25p' => 'A_VOG25',
	'arena_enemy' => 'AI_STL_S',
	'arena_first_battle_ally_stalker_1' => 'AI_STL_S',
	'arena_first_battle_stalker_1' => 'AI_STL_S',
	'arena_fourth_battle_stalker_1' => 'AI_STL_S',
	'arena_fourth_battle_stalker_2' => 'AI_STL_S',
	'arena_fourth_battle_stalker_3' => 'AI_STL_S',
	'arena_fourth_battle_stalker_4' => 'AI_STL_S',
	'arena_fourth_battle_stalker_5' => 'AI_STL_S',
	'arena_second_battle_stalker_1' => 'AI_STL_S',
	'arena_second_battle_stalker_1_boss' => 'AI_STL_S',
	'arena_survival_spawn' => 'AI_STL_S',
	'arena_survival_spawn1' => 'AI_STL_S',
	'arena_survival_spawn2' => 'AI_STL_S',
	'arena_third_battle_stalker_1' => 'AI_STL_S',
	'arena_third_battle_stalker_1_boss' => 'AI_STL_S',
	'army' => 'AI_STL_S',
	'bes_selo_anomaly_1_npc' => 'AI_STL_S',
	'bes_selo_anomaly_2_npc' => 'AI_STL_S',
	'bloodsucker_fast' => 'SM_BLOOD',
	'bloodsucker_jumper' => 'SM_BLOOD',
	'bloodsucker_jumper_deadly' => 'SM_BLOOD',
	'bloodsucker_marsh' => 'SM_BLOOD',
	'bloodsucker_night_king' => 'SM_BLOOD',
	'bloodsucker_nv_1' => 'AI_STL_S',
	'bloodsucker_redforest' => 'SM_BLOOD',
	'bloodsucker_redhunter' => 'SM_BLOOD',
	'boar_fake' => 'SM_BOARW',
	'boar_zoo' => 'SM_BOARW',
	'campfire_gas' => 'Z_CFIRE',
	'campfire_gas_fire' => 'Z_CFIRE',
	'campfire_stove' => 'Z_CFIRE',
	'cs_light_outfit' => 'E_STLK',
	'csky' => 'AI_STL_S',
	'csky_nv_1' => 'AI_STL_S',
	'csky_nv_2' => 'AI_STL_S',
	'csky_nv_3' => 'AI_STL_S',
	'csky_nv_4' => 'AI_STL_S',
	'csky_nv_5' => 'AI_STL_S',
	'csky_nv_6' => 'AI_STL_S',
	'default_bandit' => 'AI_STL_S',
	'default_duty' => 'AI_STL_S',
	'default_freedom' => 'AI_STL_S',
	'default_stalker' => 'AI_STL_S',
	'device_pda_bloodsucker' => 'D_PDA',
	'device_pda_comendant' => 'D_PDA',
	'device_pda_digger' => 'D_PDA',
	'device_pda_fang' => 'D_PDA',
	'device_pda_freedom' => 'D_PDA',
	'device_pda_garbage_traitor' => 'D_PDA',
	'device_pda_military' => 'D_PDA',
	'device_pda_old' => 'D_PDA',
	'esc_device_pda_driver' => 'D_PDA',
	'esc_driver' => 'AI_STL_S',
	'esc_leader_stalkerbase' => 'AI_STL_S',
	'esc_mechanic_flash_card_1' => 'D_PDA',
	'esc_mechanic_flash_card_2' => 'D_PDA',
	'esc_mechanic_flash_card_3' => 'D_PDA',
	'esc_mechanic_flash_card_4' => 'D_PDA',
	'esc_military_general' => 'AI_STL_S',
	'esc_military_secret_trader' => 'AI_STL_S',
	'esc_quest_akm47' => 'WP_AK74',
	'esc_quest_luky_detector' => 'D_SIMDET',
	'esc_quest_magic_vodka' => 'D_PDA',
	'esc_quest_spec_medkit' => 'D_PDA',
	'esc_stalker_guard_east_bridge' => 'AI_STL_S',
	'esc_stalker_guard_west_bridge' => 'AI_STL_S',
	'esc_story_military' => 'AI_STL_S',
	'esc_tech_stalkerbase' => 'AI_STL_S',
	'esc_trader_habar' => 'D_PDA',
	'esc_trader_stalkerbase' => 'AI_STL_S',
	'esc_wolf' => 'AI_STL_S',
	'esc_wolf_brother' => 'AI_STL_S',
	'esc_zak_stalkerbase' => 'AI_STL_S',
	'esc_zak_stalkerbase_2' => 'AI_STL_S',
	'flesh_up_a_novice_outfit' => 'D_PDA',
	'flesh_up_ab_pkm' => 'D_PDA',
	'flesh_up_ab_svu' => 'D_PDA',
	'flesh_up_abcd_pkm' => 'D_PDA',
	'flesh_up_abcd_svu' => 'D_PDA',
	'flesh_up_ac_ak74u' => 'D_PDA',
	'flesh_up_ac_desert_eagle' => 'D_PDA',
	'flesh_up_ac_mp5' => 'D_PDA',
	'flesh_up_ac_spas12' => 'D_PDA',
	'flesh_up_ac_wincheaster1300' => 'D_PDA',
	'flesh_up_aceg_scientific_outfit' => 'D_PDA',
	'flesh_up_bd_desert_eagle' => 'D_PDA',
	'flesh_up_bd_mp5' => 'D_PDA',
	'flesh_up_bd_wincheaster1300' => 'D_PDA',
	'flesh_up_bdfh_scientific_outfit' => 'D_PDA',
	'flesh_up_cd_pkm' => 'D_PDA',
	'flesh_up_cd_svu' => 'D_PDA',
	'flesh_up_fh_scientific_outfit' => 'D_PDA',
	'flesh_weak' => 'SM_FLESH',
	'flesh_zoo' => 'SM_FLESH',
	'gar_bandit_ambush_1' => 'AI_STL_S',
	'gar_bandit_ambush_2' => 'AI_STL_S',
	'gar_bandit_barman' => 'AI_STL_S',
	'gar_bandit_digger_traitor' => 'AI_STL_S',
	'gar_bandit_fixer' => 'AI_STL_S',
	'gar_bandit_leader' => 'AI_STL_S',
	'gar_bandit_minigame' => 'AI_STL_S',
	'gar_bandit_robber_1' => 'AI_STL_S',
	'gar_bandit_robber_2' => 'AI_STL_S',
	'gar_bandit_senya' => 'AI_STL_S',
	'gar_bandit_trader' => 'AI_STL_S',
	'gar_dead_camp_snork' => 'SM_SNORK',
	'gar_digger_conc_camp_prisoner_1' => 'AI_STL_S',
	'gar_digger_conc_camp_prisoner_2' => 'AI_STL_S',
	'gar_digger_conc_camp_searcher_1' => 'AI_STL_S',
	'gar_digger_conc_camp_searcher_2' => 'AI_STL_S',
	'gar_digger_conc_camp_searcher_3' => 'AI_STL_S',
	'gar_digger_fighter_1' => 'AI_STL_S',
	'gar_digger_fighter_2' => 'AI_STL_S',
	'gar_digger_fighter_3' => 'AI_STL_S',
	'gar_digger_fighter_4' => 'AI_STL_S',
	'gar_digger_fighter_5' => 'AI_STL_S',
	'gar_digger_fixer' => 'AI_STL_S',
	'gar_digger_messenger_man' => 'AI_STL_S',
	'gar_digger_quester' => 'AI_STL_S',
	'gar_digger_smuggler' => 'AI_STL_S',
	'gar_digger_traitor' => 'AI_STL_S',
	'gar_quest_novice_outfit' => 'E_STLK',
	'gar_quest_vodka_2' => 'D_PDA',
	'gar_quest_wpn_desert_eagle' => 'WP_PM',
	'gar_quest_wpn_pm' => 'WP_PM',
	'gar_quest_wpn_wincheaster1300' => 'WP_SHOTG',
	'gen_ally_camper_1' => 'AI_STL_S',
	'gen_ally_camper_2' => 'AI_STL_S',
	'gen_ally_camper_3' => 'AI_STL_S',
	'gen_ally_camper_4' => 'AI_STL_S',
	'gen_ally_camper_5' => 'AI_STL_S',
	'gen_dummy_actor_1' => 'AI_STL_S',
	'gen_dummy_actor_2' => 'AI_STL_S',
	'gen_snork_anim_left_0' => 'SM_SNORK',
	'gen_snork_anim_left_1' => 'SM_SNORK',
	'gen_snork_anim_left_2' => 'SM_SNORK',
	'gen_snork_anim_left_3' => 'SM_SNORK',
	'gen_snork_anim_right_0' => 'SM_SNORK',
	'gen_snork_anim_right_1' => 'SM_SNORK',
	'gen_snork_anim_right_2' => 'SM_SNORK',
	'gen_snork_anim_right_3' => 'SM_SNORK',
	'gen_snork_anim_right_4' => 'SM_SNORK',
	'gen_uno_scientist_1_1' => 'AI_STL_S',
	'gen_uno_scientist_1_2' => 'AI_STL_S',
	'gen_uno_scientist_1_3' => 'AI_STL_S',
	'gen_uno_scientist_1_4_leader' => 'AI_STL_S',
	'gen_uno_scientist_1_5' => 'AI_STL_S',
	'gen_uno_scientist_2_1' => 'AI_STL_S',
	'gen_uno_scientist_2_2' => 'AI_STL_S',
	'gen_uno_scientist_2_3' => 'AI_STL_S',
	'gen_uno_scientist_2_4_leader' => 'AI_STL_S',
	'gen_uno_scientist_2_5' => 'AI_STL_S',
	'gen_zombie_back' => 'AI_STL_S',
	'gen_zombie_front' => 'AI_STL_S',
	'generator_dust' => 'Z_TORRID',
	'generator_dust_static' => 'ZS_MBALD',
	'generator_electra' => 'ZS_MBALD',
	'generator_torrid' => 'Z_TORRID',
	'gigant_strong' => 'SM_GIANT',
	'kat_hosp_z1_enemy_floor2l_1' => 'AI_STL_S',
	'kat_hosp_z1_enemy_floor2l_2' => 'AI_STL_S',
	'kat_hosp_z1_enemy_floor2r_1' => 'AI_STL_S',
	'kat_hosp_z1_enemy_floor2r_2' => 'AI_STL_S',
	'kat_hosp_z1_enemy_floor2r_3' => 'AI_STL_S',
	'kat_hosp_z2_enemy_1' => 'AI_STL_S',
	'kat_hosp_z2_enemy_2' => 'AI_STL_S',
	'kat_hosp_z2_enemy_3' => 'AI_STL_S',
	'kat_hosp_z2_enemy_4' => 'AI_STL_S',
	'kat_hosp_z2_enemy_5' => 'AI_STL_S',
	'kat_hosp_z2_enemy_6' => 'AI_STL_S',
	'kat_hosp_z2_enemy_rpg' => 'AI_STL_S',
	'kat_hosp_z3_cs_commander' => 'AI_STL_S',
	'kat_hosp_z3_cs_grenadier' => 'AI_STL_S',
	'kat_hosp_z3_cs_soldier1' => 'AI_STL_S',
	'kat_hosp_z3_cs_soldier2' => 'AI_STL_S',
	'kat_hosp_z3_cs_soldier3' => 'AI_STL_S',
	'kat_hosp_z3_cs_soldier4' => 'AI_STL_S',
	'kat_hosp_z3_floor2_enemy_1' => 'AI_STL_S',
	'kat_hosp_z3_floor2_enemy_10' => 'AI_STL_S',
	'kat_hosp_z3_floor2_enemy_2' => 'AI_STL_S',
	'kat_hosp_z3_floor2_enemy_3' => 'AI_STL_S',
	'kat_hosp_z3_floor2_enemy_4' => 'AI_STL_S',
	'kat_hosp_z3_floor2_enemy_5' => 'AI_STL_S',
	'kat_hosp_z3_floor2_enemy_6' => 'AI_STL_S',
	'kat_hosp_z3_floor2_enemy_7' => 'AI_STL_S',
	'kat_hosp_z3_floor2_enemy_8' => 'AI_STL_S',
	'kat_hosp_z3_floor2_enemy_9' => 'AI_STL_S',
	'lim_ambush_2_enemy_1_stalker' => 'AI_STL_S',
	'lim_ambush_2_enemy_2_stalker' => 'AI_STL_S',
	'lim_ambush_2_enemy_3_stalker' => 'AI_STL_S',
	'lim_ambush_2_enemy_4_stalker' => 'AI_STL_S',
	'lim_ambush_2_enemy_5_stalker' => 'AI_STL_S',
	'lim_barricade_enemy_1' => 'AI_STL_S',
	'lim_barricade_enemy_2' => 'AI_STL_S',
	'lim_barricade_enemy_3' => 'AI_STL_S',
	'lim_barricade_enemy_4' => 'AI_STL_S',
	'lim_barricade_enemy_5' => 'AI_STL_S',
	'lim_construction_enemy_1' => 'AI_STL_S',
	'lim_construction_enemy_2' => 'AI_STL_S',
	'lim_construction_enemy_3' => 'AI_STL_S',
	'lim_construction_enemy_4' => 'AI_STL_S',
	'lim_construction_enemy_5' => 'AI_STL_S',
	'lim_construction_enemy_6' => 'AI_STL_S',
	'lim_csky_commander' => 'AI_STL_S',
	'lim_csky_commander_2' => 'AI_STL_S',
	'lim_csky_soldier' => 'AI_STL_S',
	'lim_csky_tech' => 'AI_STL_S',
	'lim_enemy_bandit_3' => 'AI_STL_S',
	'lim_enemy_sniper_stalker_1' => 'AI_STL_S',
	'lim_enemy_sniper_stalker_2' => 'AI_STL_S',
	'lim_enemy_sniper_stalker_3' => 'AI_STL_S',
	'lim_enemy_sniper_stalker_4' => 'AI_STL_S',
	'lim_enemy_sniper_stalker_5' => 'AI_STL_S',
	'lim_enemy_sniper_stalker_6' => 'AI_STL_S',
	'lim_enemy_stalker_2' => 'AI_STL_S',
	'lim_enemy_stalker_window' => 'AI_STL_S',
	'lim_square_enemy_assaulter' => 'AI_STL_S',
	'lim_stalker_enemy' => 'AI_STL_S',
	'lim_test_stalker_1' => 'AI_STL_S',
	'lim_test_stalker_2' => 'AI_STL_S',
	'lim_test_stalker_3' => 'AI_STL_S',
	'lim_test_stalker_4' => 'AI_STL_S',
	'lim_test_stalker_5' => 'AI_STL_S',
	'm_lesnik' => 'AI_TRD_S',
	'mar_csky_barman' => 'AI_STL_S',
	'mar_csky_commander' => 'AI_STL_S',
	'mar_csky_scientist' => 'AI_STL_S',
	'mar_csky_tactic' => 'AI_STL_S',
	'mar_csky_tech' => 'AI_STL_S',
	'mar_csky_trader' => 'AI_STL_S',
	'mar_csky_tutorial_man' => 'AI_STL_S',
	'mar_intro_actor' => 'AI_STL_S',
	'mar_intro_kalancha' => 'AI_STL_S',
	'mar_intro_lebedev_1' => 'AI_STL_S',
	'mar_intro_lebedev_2' => 'AI_STL_S',
	'mar_quest_af_cristall_flower_1' => 'ARTEFACT',
	'mar_quest_novice_outfit_1' => 'E_STLK',
	'mar_quest_scout_pda' => 'D_PDA',
	'mar_quest_wpn_ak74u_1' => 'WP_AK74',
	'mar_quest_wpn_pm_1' => 'WP_PM',
	'mar_tutorial_boar' => 'SM_BOARW',
	'mil_bloodsucker' => 'SM_BLOOD',
	'mil_bloodsucker_house_01' => 'SM_BLOOD',
	'mil_bloodsucker_house_02' => 'SM_BLOOD',
	'mil_bloodsucker_house_03' => 'SM_BLOOD',
	'mil_bloodsucker_house_04' => 'SM_BLOOD',
	'mil_controller_normal_1' => 'SM_CONTR',
	'mil_controller_normal_2' => 'SM_CONTR',
	'mil_controller_normal_3' => 'SM_CONTR',
	'mil_device_pda_lost_squard' => 'D_PDA',
	'mil_dog_01' => 'SM_DOG_S',
	'mil_dog_02' => 'SM_DOG_S',
	'mil_dog_03' => 'SM_DOG_S',
	'mil_dog_04' => 'SM_P_DOG',
	'mil_dog_05' => 'SM_P_DOG',
	'mil_freedom_attack_base' => 'AI_STL_S',
	'mil_freedom_attacker' => 'AI_STL_S',
	'mil_freedom_quest_1' => 'AI_STL_S',
	'mil_freedom_speaker' => 'AI_STL_S',
	'mil_hog' => 'AI_STL_S',
	'mil_kostiuk' => 'AI_STL_S',
	'mil_night_king_bloodsucker' => 'SM_BLOOD',
	'mil_quest_af_fuzz_kolobok' => 'ARTEFACT',
	'mil_questman' => 'AI_STL_S',
	'mil_soldier_with_zombier' => 'AI_STL_S',
	'mil_zombied' => 'AI_STL_S',
	'mutant_boar_leg' => 'II_ATTCH',
	'mutant_burer_hand' => 'II_ATTCH',
	'mutant_dog_tail' => 'II_ATTCH',
	'mutant_flesh_eye' => 'II_ATTCH',
	'mutant_krovosos_jaw' => 'II_ATTCH',
	'mutant_psevdodog_tail' => 'II_ATTCH',
	'mutant_snork_leg' => 'II_ATTCH',
	'mutant_zombie_hand' => 'II_ATTCH',
	'pl_test_sect' => 'AI_STL_S',
	'pl_test_sect1' => 'AI_STL_S',
	'red_bloodsucker_hunter' => 'SM_BLOOD',
	'red_bloodsucker_runner' => 'SM_BLOOD',
	'red_bloodsucker_runner10' => 'SM_BLOOD',
	'red_bloodsucker_runner11' => 'SM_BLOOD',
	'red_bloodsucker_runner2' => 'SM_BLOOD',
	'red_bloodsucker_runner3' => 'SM_BLOOD',
	'red_bloodsucker_runner4' => 'SM_BLOOD',
	'red_bloodsucker_runner5' => 'SM_BLOOD',
	'red_bloodsucker_runner6' => 'SM_BLOOD',
	'red_bloodsucker_runner7' => 'SM_BLOOD',
	'red_bloodsucker_runner8' => 'SM_BLOOD',
	'red_bloodsucker_runner9' => 'SM_BLOOD',
	'red_bounty_hunter_1' => 'AI_STL_S',
	'red_bounty_hunter_2' => 'AI_STL_S',
	'red_bounty_hunter_3' => 'AI_STL_S',
	'red_bounty_hunter_4' => 'AI_STL_S',
	'red_bounty_hunter_5' => 'AI_STL_S',
	'red_bounty_hunter_6' => 'AI_STL_S',
	'red_bridge_ally_stalker_1' => 'AI_STL_S',
	'red_bridge_ally_stalker_2' => 'AI_STL_S',
	'red_bridge_ally_stalker_3' => 'AI_STL_S',
	'red_bridge_ally_stalker_4' => 'AI_STL_S',
	'red_bridge_bandit_guard_1' => 'AI_STL_S',
	'red_bridge_bandit_guard_2' => 'AI_STL_S',
	'red_bridge_bandit_sniper' => 'AI_STL_S',
	'red_bridge_bandit_sniper2' => 'AI_STL_S',
	'red_bridge_csky_commander' => 'AI_STL_S',
	'red_bridge_csky_soldier' => 'AI_STL_S',
	'red_bridge_csky_soldier_1' => 'AI_STL_S',
	'red_bridge_csky_soldier_2' => 'AI_STL_S',
	'red_bridge_csky_soldier_3' => 'AI_STL_S',
	'red_bridge_csky_soldier_4' => 'AI_STL_S',
	'red_bridge_csky_soldier_5' => 'AI_STL_S',
	'red_bridge_csky_soldier_6' => 'AI_STL_S',
	'red_bridge_csky_soldier_7' => 'AI_STL_S',
	'red_bridge_renegade' => 'AI_STL_S',
	'red_bridge_stalker_leshiy' => 'AI_STL_S',
	'red_forest_bridge' => 'O_PHYS_S',
	'red_forest_pda_map' => 'D_PDA',
	'red_forest_pda_map_2' => 'D_PDA',
	'red_pursuit_bounty_hunter' => 'AI_STL_S',
	'red_pursuit_strelok' => 'AI_STL_S',
	'red_quest_prototipe_device' => 'D_PDA',
	'red_quest_tank_minigun' => 'WP_AK74',
	'red_stalker_artefact_hunter' => 'AI_STL_S',
	'red_stalker_gate_1' => 'AI_STL_S',
	'red_stalker_gate_2' => 'AI_STL_S',
	'red_stalker_gate_3' => 'AI_STL_S',
	'red_stalker_gate_4' => 'AI_STL_S',
	'red_stalker_gate_5' => 'AI_STL_S',
	'red_stalker_gate_6' => 'AI_STL_S',
	'red_strong_merc' => 'AI_STL_S',
	'red_undeground_polter_1' => 'SM_POLTR',
	'red_undeground_tushkan_1' => 'SM_TUSHK',
	'renegade' => 'AI_STL_S',
	'sim_default_bandit_0' => 'AI_STL_S',
	'sim_default_bandit_1' => 'AI_STL_S',
	'sim_default_bandit_2' => 'AI_STL_S',
	'sim_default_bandit_3' => 'AI_STL_S',
	'sim_default_bandit_4' => 'AI_STL_S',
	'sim_default_csky_0' => 'AI_STL_S',
	'sim_default_csky_1' => 'AI_STL_S',
	'sim_default_csky_2' => 'AI_STL_S',
	'sim_default_csky_3' => 'AI_STL_S',
	'sim_default_csky_4' => 'AI_STL_S',
	'sim_default_digger_0' => 'AI_STL_S',
	'sim_default_digger_1' => 'AI_STL_S',
	'sim_default_digger_2' => 'AI_STL_S',
	'sim_default_digger_3' => 'AI_STL_S',
	'sim_default_digger_4' => 'AI_STL_S',
	'sim_default_duty_0' => 'AI_STL_S',
	'sim_default_duty_1' => 'AI_STL_S',
	'sim_default_duty_2' => 'AI_STL_S',
	'sim_default_duty_3' => 'AI_STL_S',
	'sim_default_duty_4' => 'AI_STL_S',
	'sim_default_freedom_0' => 'AI_STL_S',
	'sim_default_freedom_1' => 'AI_STL_S',
	'sim_default_freedom_2' => 'AI_STL_S',
	'sim_default_freedom_3' => 'AI_STL_S',
	'sim_default_freedom_4' => 'AI_STL_S',
	'sim_default_freedom_sniper' => 'AI_STL_S',
	'sim_default_killer_0' => 'AI_STL_S',
	'sim_default_killer_1' => 'AI_STL_S',
	'sim_default_killer_2' => 'AI_STL_S',
	'sim_default_killer_3' => 'AI_STL_S',
	'sim_default_killer_4' => 'AI_STL_S',
	'sim_default_military_0' => 'AI_STL_S',
	'sim_default_military_1' => 'AI_STL_S',
	'sim_default_military_2' => 'AI_STL_S',
	'sim_default_military_3' => 'AI_STL_S',
	'sim_default_military_3_sniper' => 'AI_STL_S',
	'sim_default_military_4' => 'AI_STL_S',
	'sim_default_monolith_0' => 'AI_STL_S',
	'sim_default_monolith_1' => 'AI_STL_S',
	'sim_default_monolith_2' => 'AI_STL_S',
	'sim_default_monolith_3' => 'AI_STL_S',
	'sim_default_monolith_4' => 'AI_STL_S',
	'sim_default_renegade_0' => 'AI_STL_S',
	'sim_default_renegade_1' => 'AI_STL_S',
	'sim_default_renegade_2' => 'AI_STL_S',
	'sim_default_stalker_0' => 'AI_STL_S',
	'sim_default_stalker_1' => 'AI_STL_S',
	'sim_default_stalker_2' => 'AI_STL_S',
	'sim_default_stalker_3' => 'AI_STL_S',
	'sim_default_stalker_4' => 'AI_STL_S',
	'stalker_die_hard' => 'AI_STL_S',
	'stalker_outfit_up_stalk' => 'E_STLK',
	'stalker_ragdoll' => 'AI_STL_S',
	'stalker_regular' => 'AI_STL_S',
	'stalker_strelok' => 'AI_STL_S',
	'stc_csky_stalker' => 'AI_STL_S',
	'stc_csky_stalker_2' => 'AI_STL_S',
	'stc_monolith_sniper_1' => 'AI_STL_S',
	'stc_monolith_sniper_2' => 'AI_STL_S',
	'stc_monolith_sniper_3' => 'AI_STL_S',
	'stc_monolith_stalker' => 'AI_STL_S',
	'stc_monolith_stalker_2' => 'AI_STL_S',
	'stc_monolith_stalker_strelok_way_enemy_1' => 'AI_STL_S',
	'stc_monolith_stalker_strelok_way_enemy_2' => 'AI_STL_S',
	'stc_monolith_stalker_strelok_way_enemy_3' => 'AI_STL_S',
	'stc_monolith_stalker_strelok_way_enemy_4' => 'AI_STL_S',
	'stc_monolith_stalker_strelok_way_enemy_5' => 'AI_STL_S',
	'stc_monolith_stalker_strelok_way_enemy_6' => 'AI_STL_S',
	'stc_monolith_stalker_strelok_way_enemy_7' => 'AI_STL_S',
	'stc_monolith_stalker_teleport_1' => 'AI_STL_S',
	'stc_monolith_stalker_teleport_2' => 'AI_STL_S',
	'stc_monolith_stalker_teleport_3' => 'AI_STL_S',
	'stc_monolith_stalker_teleport_4' => 'AI_STL_S',
	'svoboda_exo_outfit' => 'E_STLK',
	'test_stalker' => 'AI_STL_S',
	'test_stalker_dual_weapon' => 'AI_STL_S',
	'trader' => 'AI_STL_S',
	'val_bandit_spy_1' => 'AI_STL_S',
	'val_bandit_spy_2' => 'AI_STL_S',
	'val_bandit_spy_3' => 'AI_STL_S',
	'val_bandit_spy_4' => 'AI_STL_S',
	'val_freedom_attack_1' => 'AI_STL_S',
	'val_freedom_attack_10' => 'AI_STL_S',
	'val_freedom_attack_2' => 'AI_STL_S',
	'val_freedom_attack_3' => 'AI_STL_S',
	'val_freedom_attack_4' => 'AI_STL_S',
	'val_freedom_attack_6' => 'AI_STL_S',
	'val_freedom_attack_7' => 'AI_STL_S',
	'val_freedom_attack_8' => 'AI_STL_S',
	'val_freedom_attack_9' => 'AI_STL_S',
	'val_freedom_attack_commander' => 'AI_STL_S',
	'val_freedom_barmen' => 'AI_STL_S',
	'val_freedom_blockpost_guard_leader_north' => 'AI_STL_S',
	'val_freedom_blockpost_guard_leader_south' => 'AI_STL_S',
	'val_freedom_blockpost_guard_north_1' => 'AI_STL_S',
	'val_freedom_blockpost_guard_north_2' => 'AI_STL_S',
	'val_freedom_blockpost_guard_south_1' => 'AI_STL_S',
	'val_freedom_blockpost_guard_south_2' => 'AI_STL_S',
	'val_freedom_deadblockpost_guard_1' => 'AI_STL_S',
	'val_freedom_deadblockpost_guard_2' => 'AI_STL_S',
	'val_freedom_deadblockpost_guard_3' => 'AI_STL_S',
	'val_freedom_deadblockpost_guard_4' => 'AI_STL_S',
	'val_freedom_deadblockpost_guard_5' => 'AI_STL_S',
	'val_freedom_trader' => 'AI_STL_S',
	'val_killer_1' => 'AI_STL_S',
	'val_killer_10' => 'AI_STL_S',
	'val_killer_2' => 'AI_STL_S',
	'val_killer_3' => 'AI_STL_S',
	'val_killer_4' => 'AI_STL_S',
	'val_killer_5' => 'AI_STL_S',
	'val_killer_6' => 'AI_STL_S',
	'val_killer_7' => 'AI_STL_S',
	'val_killer_8' => 'AI_STL_S',
	'val_killer_9' => 'AI_STL_S',
	'val_killer_sniper_1' => 'AI_STL_S',
	'val_killer_sniper_10' => 'AI_STL_S',
	'val_killer_sniper_2' => 'AI_STL_S',
	'val_killer_sniper_3' => 'AI_STL_S',
	'val_killer_sniper_4' => 'AI_STL_S',
	'val_killer_sniper_5' => 'AI_STL_S',
	'val_killer_sniper_6' => 'AI_STL_S',
	'val_killer_sniper_7' => 'AI_STL_S',
	'val_killer_sniper_8' => 'AI_STL_S',
	'val_killer_sniper_9' => 'AI_STL_S',
	'val_quest_flash_movies' => 'D_PDA',
	'val_quest_guitar_serg' => 'II_ATTCH',
	'val_quest_scope_x8' => 'WP_SCOPE',
	'wpn_223_pistol' => 'WP_USP45',
	'wpn_abakan_up2' => 'WP_AK74',
	'wpn_addon_scope_4x' => 'WP_SCOPE',
	'wpn_addon_silencer_rifle' => 'W_SILENC',
	'wpn_ak74_minigame' => 'WP_AK74',
	'wpn_ak74_up' => 'WP_AK74',
	'wpn_ak74_up2' => 'WP_AK74',
	'wpn_ak74u_minigame' => 'WP_AK74',
	'wpn_beretta_minigame' => 'WP_PM',
	'wpn_bozar' => 'WP_AK74',
	'wpn_colt1911_up2' => 'WP_PM',
	'wpn_desert_eagle_up' => 'WP_PM',
	'wpn_fort_up' => 'WP_PM',
	'wpn_g36_up2' => 'WP_AK74',
	'wpn_gauss_aes' => 'WP_SVD',
	'wpn_lr300_minigame' => 'WP_AK74',
	'wpn_lr300_up2' => 'WP_AK74',
	'wpn_mp5_minigame' => 'WP_LR300',
	'wpn_pm_9x19' => 'WP_PM',
	'wpn_pm_minigame' => 'WP_PM',
	'wpn_pm_up' => 'WP_PM',
	'wpn_sig_no_draw_sound' => 'WP_AK74',
	'wpn_sig_with_scope' => 'WP_AK74',
	'wpn_sig550_minigame' => 'WP_AK74',
	'wpn_sig550_up2' => 'WP_AK74',
	'wpn_val_minigame' => 'WP_VAL',
	'wpn_vintorez_up' => 'WP_AK74',
	'wpn_walther_up2' => 'WP_PM',
	'yan_default_stalker_1' => 'AI_STL_S',
	'yan_default_stalker_2' => 'AI_STL_S',
	'yan_quest_ammo_sleep' => 'AMMO',
	'yan_quest_granade' => 'D_PDA',
	'yan_quest_scarlet_flower' => 'SCRPTART',
	'yan_stalker_levsha' => 'AI_STL_S',
	'yan_stalker_sci_base' => 'AI_STL_S',
	'yan_stalker_zombied' => 'AI_STL_S',
	'yan_wave_zombie_1' => 'AI_STL_S',
	'yan_wave_zombie_10' => 'AI_STL_S',
	'yan_wave_zombie_11' => 'AI_STL_S',
	'yan_wave_zombie_12' => 'AI_STL_S',
	'yan_wave_zombie_13' => 'AI_STL_S',
	'yan_wave_zombie_2' => 'AI_STL_S',
	'yan_wave_zombie_20' => 'AI_STL_S',
	'yan_wave_zombie_21' => 'AI_STL_S',
	'yan_wave_zombie_3' => 'AI_STL_S',
	'yan_wave_zombie_4' => 'AI_STL_S',
	'yan_wave_zombie_5' => 'AI_STL_S',
	'yan_wave_zombie_6' => 'AI_STL_S',
	'yan_wave_zombie_7' => 'AI_STL_S',
	'yan_wave_zombie_8' => 'AI_STL_S',
	'yan_wave_zombie_9' => 'AI_STL_S',
# dce zone_field � �� Z_RADIO
	'zone_mine_field_no_damage' => 'Z_MBALD',
	'zone_mine_field_strong' => 'Z_MBALD',
	'zone_mine_thermal_firetube' => 'ZS_MBALD',


#122-128
	'af_baloon' => 'ARTEFACT',
	'af_compass' => 'SCRPTART',
	'af_eye' => 'ARTEFACT',
	'af_fire' => 'ARTEFACT',
	'af_glass' => 'ARTEFACT',
	'af_ice' => 'ARTEFACT',
	'anomal_zone' => 'SPC_RS_S',
	'balon_01' => 'O_DSTR_S',
	'balon_02' => 'O_DSTR_S',
	'balon_02a' => 'O_DSTR_S',
	'banka_kraski_1' => 'O_DSTR_S',
	'bidon' => 'O_DSTR_S',	# O_PHYS_S before 128
	'bludo' => 'O_DSTR_S',
	'bochka_close_1' => 'O_DSTR_S',
	'bochka_close_2' => 'O_DSTR_S',
	'bochka_close_3' => 'O_DSTR_S',
	'bochka_close_4' => 'O_DSTR_S',
	'museum_abakan' => 'O_DSTR_S',
	'museum_ak74' => 'O_DSTR_S',
	'museum_ak74u' => 'O_DSTR_S',
	'museum_ammo_12x70_buck' => 'O_DSTR_S',
	'museum_ammo_545x39_fmj' => 'O_DSTR_S',
	'museum_ammo_762x54_7h14' => 'O_DSTR_S',
	'museum_bm16' => 'O_DSTR_S',
	'museum_groza' => 'O_DSTR_S',
	'museum_lr300' => 'O_DSTR_S',
	'museum_toz34' => 'O_DSTR_S',
	'museum_rg6' => 'O_DSTR_S',
	'museum_rpg7' => 'O_DSTR_S',
	'museum_sig550' => 'O_DSTR_S',
	'museum_spas12' => 'O_DSTR_S',
	'museum_svd' => 'O_DSTR_S',
	'museum_val' => 'O_DSTR_S',
	'museum_vintorez' => 'O_DSTR_S',
	'museum_winchester1300' => 'O_DSTR_S',

#128
	'af_quest_b14_twisted' => 'SCRPTART',
	'af_oasis_heart' => 'SCRPTART',
	'ammo_gauss_cardan' => 'AMMO_S',
	'anomaly_scaner' => 'II_ATTCH',
	'axe' => 'O_DSTR_S',
	'balloon_poison_gas' => 'O_DSTR_S',
	'balon_02link' => 'O_DSTR_S',
	'boar_jup_b9' => 'SM_BOARW',
	'booster' => 'S_FOOD',
	'box_1a' => 'O_DSTR_S',
	'box_1b' => 'O_DSTR_S',
	'box_1c' => 'O_DSTR_S',
	'box_bottle_1' => 'O_DSTR_S',
	'box_metall_01' => 'O_DSTR_S',
	'box_paper' => 'O_DSTR_S',
	'box_wood_01' => 'O_DSTR_S',
	'box_wood_02' => 'O_DSTR_S',
	'burer_normal' => 'SM_BURER',
	'camp_zone' => 'SPC_RS_S',
	'child_bench' => 'O_DSTR_S',
	'chimera_normal' => 'SM_CHIMS',
	'debris_01' => 'O_DSTR_S',
	'detector_scientific' => 'DET_SCIE',
	'device_flash_snag' => 'S_PDA',
	'device_pda_port_bandit_leader' => 'S_PDA',
	'device_pda_zat_b5_dealer' => 'S_PDA',
	'disel_generator' => 'O_DSTR_S',
	'dog_cute' => 'SM_DOG_S',
	'door_lab_x8' => 'O_PHYS_S',
	'drug_anabiotic' => 'S_FOOD',
	'drug_antidot' => 'S_FOOD',
	'drug_booster' => 'S_FOOD',
	'drug_coagulant' => 'S_FOOD',
	'drug_psy_blockade' => 'S_FOOD',
	'drug_radioprotector' => 'S_FOOD',
	'explosive_gaz_balon' => 'S_EXPLO',
	'fireball_acidic_zone' => 'ZS_TORRD',
	'fireball_electric_zone' => 'ZS_TORRD',
	'flesh_jup_b9' => 'SM_FLESH',
	'gaz_balon' => 'O_DSTR_S',
	'gaz_plita' => 'O_DSTR_S',
	'gaz_plita_small' => 'O_DSTR_S',
	'hammer' => 'O_DSTR_S',
	'hand_radio_r' => 'II_ATTCH',
	'hatch_01' => 'O_DSTR_S',
	'helm_battle' => 'E_HLMET',
	'helm_hardhat' => 'E_HLMET',
	'helm_hardhat_snag' => 'E_HLMET',
	'helm_protective' => 'E_HLMET',
	'helm_respirator' => 'E_HLMET',
	'helm_respirator_joker' => 'E_HLMET',
	'helm_tactic' => 'E_HLMET',
	'helmet' => 'E_HLMET',
	'jup_a9_conservation_info' => 'S_PDA',
	'jup_a9_delivery_info' => 'S_PDA',
	'jup_a9_evacuation_info' => 'S_PDA',
	'jup_a9_losses_info' => 'S_PDA',
	'jup_a9_meeting_info' => 'S_PDA',
	'jup_a9_power_info' => 'S_PDA',
	'jup_a9_way_info' => 'S_PDA',
	'jup_b1_controller' => 'SM_CONTR',
	'jup_b1_half_artifact' => 'SCRPTART',
	'jup_b1_tushkano_target' => 'SM_TUSHK',
	'jup_b10_notes_01' => 'S_PDA',
	'jup_b10_notes_02' => 'S_PDA',
	'jup_b10_notes_03' => 'S_PDA',
	'jup_b10_ufo_memory' => 'S_PDA',
	'jup_b10_ufo_memory_2' => 'S_PDA',
	'jup_b16_pseudodog_strong' => 'SM_DOG_P',
	'jup_b200_tech_materials_acetone' => 'S_PDA',
	'jup_b200_tech_materials_capacitor' => 'S_PDA',
	'jup_b200_tech_materials_textolite' => 'S_PDA',
	'jup_b200_tech_materials_transistor' => 'S_PDA',
	'jup_b200_tech_materials_wire' => 'S_PDA',
	'jup_b202_bandit_pda' => 'S_PDA',
	'jup_b205_sokolov_note' => 'S_PDA',
	'jup_b206_plant' => 'S_PDA',
	'jup_b206_plant_ph' => 'O_DSTR_S',
	'jup_b207_depot_cover' => 'O_PHYS_S',
	'jup_b207_merc_pda_with_contract' => 'S_PDA',
	'jup_b209_monster_scanner' => 'S_PDA',
	'jup_b209_ph_scanner' => 'O_PHYS_S',
	'jup_b212_chimera_killer' => 'SM_CHIMS',
	'jup_b219_gate' => 'O_PHYS_S',
	'jup_b32_ph_scanner' => 'O_PHYS_S',
	'jup_b32_scanner_device' => 'S_PDA',
	'jup_b41_af_half_artifact' => 'O_PHYS_S',
	'jup_b41_af_oasis_heart' => 'O_PHYS_S',
	'jup_b43_af_fuzz_kolobok' => 'O_PHYS_S',
	'jup_b43_af_mincer_meat' => 'O_PHYS_S',
	'jup_b46_duty_founder_pda' => 'S_PDA',
	'jup_b47_jupiter_products_info' => 'S_PDA',
	'jup_b47_merc_pda' => 'S_PDA',
	'jup_b6_bloodsucker_1' => 'SM_BLOOD',
	'jup_b6_bloodsucker_2' => 'SM_BLOOD',
	'jup_b6_bloodsucker_3' => 'SM_BLOOD',
	'jup_b9_blackbox' => 'S_PDA',
	'keyga' => 'O_DSTR_S',
	'krisagenerator' => 'O_DSTR_S',
	'labx8_poltergeist' => 'SM_POLTR',
	'lopata' => 'O_DSTR_S',
	'lx8_1_tushkano_1' => 'SM_TUSHK',
	'lx8_1_tushkano_2' => 'SM_TUSHK',
	'lx8_1_tushkano_3' => 'SM_TUSHK',
	'lx8_1_tushkano_4' => 'SM_TUSHK',
	'lx8_2_tushkano_1' => 'SM_TUSHK',
	'lx8_2_tushkano_2' => 'SM_TUSHK',
	'lx8_2_tushkano_3' => 'SM_TUSHK',
	'lx8_2_tushkano_4' => 'SM_TUSHK',
	'lx8_burer' => 'SM_BURER',
	'lx8_burer_2' => 'SM_BURER',
	'lx8_burer_3' => 'SM_BURER',
	'lx8_controller' => 'SM_CONTR',
	'lx8_lab_tushkano_1' => 'SM_TUSHK',
	'lx8_lab_tushkano_2' => 'SM_TUSHK',
	'lx8_lab_tushkano_3' => 'SM_TUSHK',
	'lx8_lab_tushkano_4' => 'SM_TUSHK',
	'lx8_lab_tushkano_5' => 'SM_TUSHK',
	'lx8_lab_tushkano_6' => 'SM_TUSHK',
	'lx8_lab_tushkano_7' => 'SM_TUSHK',
	'lx8_lab_tushkano_8' => 'SM_TUSHK',
	'lx8_litf_tushkano_1' => 'SM_TUSHK',
	'lx8_litf_tushkano_2' => 'SM_TUSHK',
	'lx8_litf_tushkano_3' => 'SM_TUSHK',
	'lx8_litf_tushkano_4' => 'SM_TUSHK',
	'lx8_litf_tushkano_5' => 'SM_TUSHK',
	'lx8_poltergeist' => 'SM_POLTR',
	'lx8_service_instruction' => 'S_PDA',
	'lx8_snork' => 'SM_SNORK',
	'lx8_snork_1_jump' => 'SM_SNORK',
	'lx8_snork_2_jump' => 'SM_SNORK',
	'lx8_toilet_burer' => 'SM_BURER',
	'lx8_upper_tushkano_1' => 'SM_TUSHK',
	'lx8_upper_tushkano_2' => 'SM_TUSHK',
	'lx8_upper_tushkano_3' => 'SM_TUSHK',
	'lx8_upper_tushkano_4' => 'SM_TUSHK',
	'lx8_upper_tushkano_5' => 'SM_TUSHK',
	'lx8_upper_tushkano_6' => 'SM_TUSHK',
	'lx8_upper_tushkano_7' => 'SM_TUSHK',
	'medkit_script' => 'S_FOOD',
	'molot' => 'O_DSTR_S',
	'pas_b400_tushkano_smart' => 'SM_TUSHK',
	'physic_door' => 'O_DSTR_S',
	'pick' => 'O_DSTR_S',
	'pri_a15_documents' => 'II_ATTCH',
	'pri_a15_wpn_ak74' => 'II_ATTCH',
	'pri_a15_wpn_ak74u' => 'II_ATTCH',
	'pri_a15_wpn_svu' => 'II_ATTCH',
	'pri_a15_wpn_wincheaster1300' => 'II_ATTCH',
	'pri_a17_gauss_rifle' => 'WP_SVD',
	'pri_a19_american_experiment_info' => 'S_PDA',
	'pri_a19_lab_x10_info' => 'S_PDA',
	'pri_a19_lab_x16_info' => 'S_PDA',
	'pri_a19_lab_x18_info' => 'S_PDA',
	'pri_a19_lab_x7_info' => 'S_PDA',
	'pri_a25_antenna_grenade' => 'S_EXPLO',
	'pri_a25_enter_door_explosive_grenade' => 'S_EXPLO',
	'pri_a25_explosive_charge' => 'O_PHYS_S',
	'pri_a25_explosive_charge_item' => 'D_PDA',
	'pri_a25_poltergeist' => 'SM_POLTR',
	'pri_a28_actor_hideout' => 'O_PHYS_S',
	'pri_a28_earth_helli_1' => 'O_PHYS_S',
	'pri_a28_earth_helli_2' => 'O_PHYS_S',
	'pri_b301_snork_1' => 'SM_SNORK',
	'pri_b301_snork_2' => 'SM_SNORK',
	'pri_b301_snork_3' => 'SM_SNORK',
	'pri_b301_snork_4' => 'SM_SNORK',
	'pri_b301_snork_5' => 'SM_SNORK',
	'pri_b306_envoy_pda' => 'S_PDA',
	'pri_b35_lab_x8_key' => 'D_PDA',
	'pri_b36_monolith_hiding_place_pda' => 'S_PDA',
	'psy_dog_normal' => 'SM_DOG_P',
	'riffler' => 'O_DSTR_S',
	'saw' => 'O_DSTR_S',
	'snork_indoor_normal' => 'SM_SNORK',
	'snork_indoor_strong' => 'SM_SNORK',
	'snork_indoor_weak' => 'SM_SNORK',
	'snork_weak_special' => 'SM_SNORK',
	'speakerphone' => 'O_DSTR_S',
	'stalker_outfit_barge' => 'E_STLK',
	'stul_child_01' => 'O_DSTR_S',
	'stul_school_01' => 'O_DSTR_S',
	'stul_school_01_br' => 'O_DSTR_S',
	'stul_wood_01' => 'O_DSTR_S',
	'taburet_village' => 'O_DSTR_S',
	'taburet_wood_01' => 'O_DSTR_S',
	'toolkit_1' => 'S_PDA',
	'toolkit_2' => 'S_PDA',
	'toolkit_3' => 'S_PDA',
	'ventilator_01' => 'O_DSTR_S',
	'ventilator_02' => 'O_DSTR_S',
	'ventilator_03' => 'O_DSTR_S',
	'ventilator_04' => 'O_DSTR_S',
	'ventilator_05' => 'O_DSTR_S',
	'vodka_script' => 'S_FOOD',
	'wood_fence_1' => 'O_DSTR_S',
	'wood_fence_2' => 'O_DSTR_S',
	'wood_fence_3' => 'O_DSTR_S',
	'wood_fence_4' => 'O_DSTR_S',
	'wpn_addon_scope_detector' => 'WP_SCOPE',
	'wpn_addon_scope_night' => 'WP_SCOPE',
	'wpn_addon_scope_susat_custom' => 'WP_SCOPE',
	'wpn_addon_scope_susat_dusk' => 'WP_SCOPE',
	'wpn_addon_scope_susat_night' => 'WP_SCOPE',
	'wpn_addon_scope_susat_x1.6' => 'WP_SCOPE',
	'wpn_addon_scope_x2.7' => 'WP_SCOPE',
	'wpn_ak74u_snag' => 'WP_AK74',
	'wpn_desert_eagle_nimble' => 'WP_PM',
	'wpn_fn2000_nimble' => 'WP_GROZA',
	'wpn_fort_snag' => 'WP_PM',
	'wpn_g36_nimble' => 'WP_AK74',
	'wpn_groza_nimble' => 'WP_AK74',
	'wpn_groza_specops' => 'WP_AK74',
	'wpn_mp5_nimble' => 'WP_LR300',
	'wpn_pkm_zulus' => 'WP_AK74',
	'wpn_pm_actor' => 'WP_PM',
	'wpn_protecta' => 'WP_ASHTG',
	'wpn_protecta_nimble' => 'WP_ASHTG',
	'wpn_sig220_nimble' => 'WP_LR300',
	'wpn_sig550_luckygun' => 'WP_AK74',
	'wpn_spas12_nimble' => 'WP_ASHTG',
	'wpn_svd_nimble' => 'WP_SVD',
	'wpn_svu_nimble' => 'WP_SVU',
	'wpn_usp_nimble' => 'WP_LR300',
	'wpn_vintorez_nimble' => 'WP_AK74',
	'wpn_wincheaster1300_trapper' => 'WP_ASHTG',
	'zat_a23_access_card' => 'D_PDA',
	'zat_a23_gauss_rifle_docs' => 'S_PDA',
	'zat_a23_labx8_key' => 'D_PDA',
	'zat_b106_chimera' => 'SM_CHIMS',
	'zat_b12_documents_1' => 'S_PDA',
	'zat_b12_documents_2' => 'S_PDA',
	'zat_b12_key_1' => 'D_PDA',
	'zat_b12_key_2' => 'D_PDA',
	'zat_b18_dog' => 'SM_P_DOG',
	'zat_b18_dog_noah' => 'SM_P_DOG',
	'zat_b20_noah_pda' => 'S_PDA',
	'zat_b22_medic_pda' => 'S_PDA',
	'zat_b33_safe_container' => 'S_PDA',
	'zat_b38_bloodsucker_1' => 'SM_BLOOD',
	'zat_b38_bloodsucker_2' => 'SM_BLOOD',
	'zat_b38_bloodsucker_corpse' => 'SM_BLOOD',
	'zat_b39_joker_pda' => 'S_PDA',
	'zat_b40_notebook' => 'S_PDA',
	'zat_b40_pda_1' => 'S_PDA',
	'zat_b40_pda_2' => 'S_PDA',
	'zat_b44_barge_pda' => 'S_PDA',
	'zat_b57_gas' => 'S_PDA',
	'zat_b57_ph_gas' => 'O_PHYS_S',
	'zone_mine_acidic_big' => 'ZS_MBALD',
	'zone_mine_chemical_average' => 'ZS_MBALD',
	'zone_mine_chemical_strong' => 'ZS_MBALD',
	'zone_mine_chemical_weak' => 'ZS_MBALD',
	'zone_mine_gravitational_big' => 'ZS_MINCE',
	'zone_mine_static_average' => 'ZS_MBALD',
	'zone_mine_static_strong' => 'ZS_MBALD',
	'zone_mine_static_weak' => 'ZS_MBALD',
	'zone_mine_steam_average' => 'ZS_MBALD',
	'zone_mine_steam_strong' => 'ZS_MBALD',
	'zone_mine_steam_weak' => 'ZS_MBALD',

# LA DC
	'peanut_conserva'   => 'II_FOOD',
	'korn_conserva'     => 'II_FOOD',
	'yantar_food'       => 'II_FOOD',
	'sardinia_conserva' => 'II_FOOD',
	'tushenka_conserva' => 'II_FOOD',
	'tushenka_conserva' => 'II_FOOD',
	'olives_conserva'   => 'II_FOOD',
};
use constant clsid_to_class => {
	# build 749
	O_ACTOR		=> 'cse_alife_creature_actor',				# deprecated from clear sky	
	R_ACTOR		=> 'cse_alife_object_idol',					# deprecated from build 1098
	W_MGUN 		=> 'cse_alife_item_weapon_magazined',		# deprecated from build 1098
	W_RAIL		=> 'cse_alife_item_weapon_magazined',		# deprecated from build 1098
	W_ROCKET	=> 'cse_alife_item_weapon_magazined',		# deprecated from build 1098
	
	# build 788
	W_M134		=> 'cse_alife_item_weapon',					# deprecated from build 1834 [2004-04-09]

	# build 1098
	AI_HUMAN	=> 'se_stalker',							# deprecated from build 1114
	W_GROZA		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]
	W_M134en	=> 'cse_alife_item_weapon',					# deprecated from build 1229

	# build 1114-1096
	AI_CROW 	=> 'cse_alife_creature_crow',
	AI_HEN		=> 'unknown',								# deprecated from build 1229
	AI_RAT		=> 'se_monster',							# deprecated from call of pripyat
	AI_SOLD		=> 'se_stalker',							# deprecated from build 1475
	AI_ZOMBY	=> 'cse_alife_monster_zombie',				# deprecated from build 1254
	EVENT		=> 'not_used',								# not used
	W_AK74		=> 'cse_alife_item_weapon',					# deprecated from clear sky
	W_FN2000	=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]	
	W_HPSA		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]	
	W_LR300		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]		
	
	#build 1154
	C_NIVA		=> 'cse_alife_car',							# deprecated from build 2205 [2005-04-15]
	O_DUMMY		=> 'cse_alife_object_dummy',				# deprecated from build 1510
	W_BINOC		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]	
	W_FORT		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]	
	W_PM		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]	
	
	# build 1230
	O_HEALTH	=> 'unknown',								# deprecated from build 1893 [2004-09-06]

	# build 1254
	AF_MBALL	=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AI_ZOM		=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	T_ASS		=> 'not_used',
	T_CS		=> 'not_used',
	T_CSBASE	=> 'cse_target_cs_base',
	T_CSCASK	=> 'cse_target_cs_cask',
	W_SHOTGN	=> 'cse_alife_item_weapon',					# deprecated from clear sky
	
	# build 1265
	SPECT		=> 'cse_spectator',
	
	# build 1465
	AI_RAT_G	=> 'cse_alife_rat_group',					# deprecated from call of pripyat
	AI_STL		=> 'cse_alife_human_stalker',				# deprecated from call of pripyat
	A_PM		=> 'cse_alife_item_ammo',					# deprecated from build 1472
	AI_CONTR	=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	AI_DOG	 	=> 'cse_alife_monster_base',				# deprecated from build 1510
	AI_GRAPH 	=> 'cse_alife_graph_point',
	AI_SOLDR	=> 'se_stalker',							# deprecated from build 1475
	AI_TRADE	=> 'cse_alife_trader',						# deprecated from build 2939
	AR_BDROP => 'cse_alife_item_artefact',					# deprecated from build 1610
	AR_GRAVI => 'cse_alife_item_artefact',					# deprecated from build 1610
	AR_MAGNT => 'cse_alife_item_artefact',					# deprecated from build 1610
	AR_MBALL => 'cse_alife_item_artefact',					# deprecated from build 1610
	AR_RADIO => 'cse_alife_item_artefact',					# deprecated from build 1610
	D_SIMDET => 'cse_alife_item_detector',
EQ_ASUIT => 'unknown',								# deprecated from build 1472
EQ_CNT => 'unknown',								# deprecated from build 1472
EQ_CNT_A => 'unknown',								# deprecated from build 1472
EQ_CNT_B => 'unknown',								# deprecated from build 1472
EQ_CPS => 'unknown',								# deprecated from build 1472
EQ_CPS_G => 'unknown',								# deprecated from build 1472
EQ_CSUIT => 'unknown',								# deprecated from build 1472
EQ_DTC => 'unknown',								# deprecated from build 1472
EQ_DTC_L => 'unknown',								# deprecated from build 1472
EQ_DTC_S => 'unknown', 								# deprecated from build 1472
EQ_DTC_U => 'unknown',								# deprecated from build 1472
EQ_LIFES => 'unknown',								# deprecated from build 1472
EQ_MKT => 'unknown',								# deprecated from build 1472
EQ_MKT_U => 'unknown',								# deprecated from build 1472
EQ_PSI_P => 'unknown',								# deprecated from build 1472
EQ_PSUIT => 'unknown',								# deprecated from build 1472
EQ_RADIO => 'unknown',								# deprecated from build 1472
EQ_TSUIT => 'unknown',								# deprecated from build 1472
	II_BOLT => 'cse_alife_item_bolt',
W_AK_CHR => 'unknown',								# deprecated from build 1472
W_FN_CHR => 'unknown',								# deprecated from build 1472
W_FR_CHR => 'unknown',								# deprecated from build 1472
W_HP_CHR => 'unknown',								# deprecated from build 1472
W_LR_CHR => 'unknown',								# deprecated from build 1472
W_PM_CHR => 'unknown',								# deprecated from build 1472
W_TZ_CHR => 'unknown',								# deprecated from build 1472
	W_SVD		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]	
	W_SVU		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]
	Z_MBALD		=> 'cse_alife_anomalous_zone',
	Z_MINCER	=> 'cse_alife_anomalous_zone',				# not used from build 2571 [2006-03-16]
	
	# build 1469
	AI_IDOL		=> 'cse_alife_object_idol',					# deprecated from build 2945
	AMMO		=> 'cse_alife_item_ammo',					# deprecated from call of pripyat
	G_F1		=> 'cse_alife_item_grenade',				# deprecated from call of pripyat
	G_RGD5		=> 'cse_alife_item_grenade',				# deprecated from call of pripyat
	G_RPG7		=> 'cse_alife_item_ammo',
	O_HLAMP		=> 'cse_alife_object_hanging_lamp',			# deprecated from call of pripyat
	W_RPG7		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]
	
	# build 1472
	D_TORCH		=> 'cse_alife_item_torch',					# deprecated from build 2559 [2005-05-04]
	O_PHYSIC	=> 'cse_alife_object_physic',				# deprecated from build 2939
	W_USP45		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]
	W_VAL		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]
	W_VINT		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]
	W_WALTHR	=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]
	
	# build 1475
	LVLPOINT 	=> 'cse_alife_graph_point',					# deprecated from build 1510
	LVL_CHNG	=> 'se_level_changer',
	W_KNIFE		=> 'cse_alife_item_weapon',
	
	# build 1510
	AI_BLOOD	=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	AI_DOG_R 	=> 'se_monster',							# deprecated from clear sky
	AI_FLESH	=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	AI_FLE_G 	=> 'cse_alife_flesh_group',
	AI_HIMER	=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	AI_SPGRP	=> 'cse_alife_spawn_group',
	ARTEFACT	=> 'cse_alife_item_artefact',
	D_PDA		=> 'cse_alife_item_pda',
	G_FAKE		=> 'cse_alife_item_grenade',	
	Z_ACIDF		=> 'cse_alife_anomalous_zone',				# deprecated from build 2218 [2005-01-28]
	Z_BFUZZ		=> 'cse_alife_zone_visual',					# deprecated from build 2559 [2005-05-04]
	Z_DEAD		=> 'cse_alife_anomalous_zone',				# deprecated from build 2218 [2005-01-28]
	Z_GALANT	=> 'cse_alife_anomalous_zone',				# deprecated from build 2559 [2005-05-04]
	Z_RADIO		=> 'cse_alife_anomalous_zone',					
	Z_RUSTYH	=> 'cse_alife_anomalous_zone',				# deprecated from call of pripyat
	
	# build 1558
	AI_BOAR		=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	EQU_EXO		=> 'cse_alife_item_custom_outfit',			# deprecated from build 2571 [2006-03-16]
	EQU_MLTR	=> 'cse_alife_item_custom_outfit',			# deprecated from clear sky
	EQU_SCIE	=> 'cse_alife_item_custom_outfit',			# deprecated from build 2571 [2006-03-16]
	EQU_STLK	=> 'cse_alife_item_custom_outfit',			# deprecated from build 2559 [2005-05-04]
	II_ANTIR	=> 'cse_alife_eatable_item',				# deprecated from call of pripyat, changed class in LA DC
	II_BREAD	=> 'cse_alife_item',						# deprecated from build 1828 [2004-02-03]
	II_DOC		=> 'cse_alife_item_document',
	II_MEDKI	=> 'cse_alife_eatable_item',				# deprecated from call of pripyat, changed class in LA DC

	# build 1567
	AF_BDROP	=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AF_NEEDL	=> 'cse_alife_item_artefact',				# deprecated from build 1902
	D_AFMERG	=> 'cse_alife_item',						# deprecated from build 2945
	SCRIPTZN	=> 'cse_alife_space_restrictor',	
	
	# build 1610
	AF_BAST		=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AF_BGRAV	=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AF_DUMMY	=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AF_EBALL 	=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AF_FBALL	=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AF_GALAN	=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AF_RHAIR	=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AF_THORN	=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AF_ZUDA		=> 'cse_alife_item_artefact',				# deprecated from build 1902
	AI_DOG_B	=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	W_SCOPE		=> 'cse_alife_item',						# deprecated from build 2559 [2005-05-04]	
	W_SILENC	=> 'cse_alife_item',						# deprecated from call of pripyat
	W_GLAUNC	=> 'cse_alife_item',						# deprecated from call of pripyat

	# build 1623
	SCRPTOBJ	=> 'cse_alife_dynamic_object_visual',	
	
	# build 1851 [2004-01-26]
	O_SEARCH	=> 'cse_alife_object_projector',
	
	# build 1828 [2004-02-03]
	II_BOTTL	=> 'cse_alife_eatable_item',				# deprecated from call of pripyat, changed class in LA DC
	II_FOOD		=> 'cse_alife_eatable_item',				# deprecated from call of pripyat, changed class in LA DC
	
	# build 1844 [2004-02-19]
	C_HLCPTR	=> 'cse_alife_helicopter',					# deprecated from build 2939
	II_ATTCH	=> 'cse_alife_item',
	W_MOUNTD	=> 'cse_alife_mounted_weapon',
	
	# build 1834 [2004-04-09]
	II_EXPLO	=> 'cse_alife_item_explosive',				# deprecated from call of pripyat
	O_BRKBL		=> 'cse_alife_object_breakable',
	
	# build 1834 [2004-05-09]
	AI_BURER	=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	AI_GIANT	=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	Z_TEAMBS	=> 'cse_alife_team_base_zone',
	
	# build 1842 [2004-06-17]
	A_M209		=> 'cse_alife_item_ammo',					# deprecated from call of pripyat
	A_OG7B		=> 'cse_alife_item_ammo',					# deprecated from call of pripyat
	A_VOG25		=> 'cse_alife_item_ammo',					# deprecated from call of pripyat
	W_BM16		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]	

	# build 1865 [2004-08-09]
	AI_PHANT	=> 'cse_alife_monster_base',
	NW_ATTCH	=> 'cse_alife_item',	
	P_SKELET	=> 'cse_alife_ph_skeleton_object',
	Z_TORRID	=> 'cse_alife_torrid_zone',					# deprecated from call of pripyat

	# build 1893 [2004-09-06]
	AI_FRACT	=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	SPACE_RS	=> 'cse_alife_space_restrictor',			# deprecated from build 2939
	
	# build 1925
	AI_SNORK	=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	O_CLMBL		=> 'cse_alife_object_climable',	
	
	# build 1935
	SMRTTRRN	=> 'se_smart_terrain',

	# build 1964
	AI_CAT		=> 'cse_alife_monster_base',				# deprecated from build 2205 [2005-04-15]
	II_BTTCH	=> 'cse_alife_item',
	
	# build 1971
	CLSID_Z_BFUZZ	=> 'cse_alife_anomalous_zone',			# deprecated from build 1994
	Z_AMEBA		=> 'cse_alife_zone_visual',					# deprecated from call of pripyat

	# build 2212 [2005-01-22]
	AI_STL_S	=> 'se_stalker',
	P_DSTRBL	=> 'cse_alife_object_physic',				# deprecated in call of pripyat
	O_SWITCH	=> 'unknown',								# deprecated from clear sky
	W_RG6		=> 'cse_alife_item_weapon',					# deprecated from build 2559 [2005-05-04]	
	
	# build 2205 [2005-04-15]
	SM_BLOOD	=> 'se_monster',
	SM_BOARW	=> 'se_monster',
	SM_BURER	=> 'se_monster',
	SM_CAT_S	=> 'se_monster',
	SM_CHIMS	=> 'se_monster',
	SM_CONTR	=> 'se_monster',
	SM_FLESH	=> 'se_monster',
	SM_GIANT	=> 'se_monster',
	SM_IZLOM	=> 'se_monster',
	SM_POLTR	=> 'se_monster',
	SM_P_DOG	=> 'se_monster',
	SM_SNORK	=> 'se_monster',
	SM_TUSHK	=> 'se_monster',
	SM_ZOMBI	=> 'se_monster',
	SCRPTART	=> 'cse_alife_item_artefact',
	SCRPTCAR	=> 'cse_alife_car',

	# build 2217 [2005-07-27]
	W_STMGUN	=> 'cse_alife_stationary_mgun',	
	
	# build 2571 [2006-03-16]
	II_BANDG	=> 'cse_alife_eatable_item',					# deprecated in call of pripyat, changed class in LA DC
	ON_OFF_G	=> 'cse_alife_online_offline_group',			# deprecated from call of pripyat
	RE_SPAWN	=> 'se_respawn',								# deprecated in call of pripyat
	SM_DOG_F	=> 'se_monster',
	SM_DOG_P	=> 'se_monster',	
	Z_NOGRAV	=> 'cse_alife_anomalous_zone',	
	
	# build 2559 [2006-05-04]
	TORCH_S		=> 'cse_alife_item_torch',
	E_STLK		=> 'cse_alife_item_custom_outfit',
	WP_AK74		=> 'cse_alife_item_weapon_magazined_w_gl',
	WP_BINOC	=> 'cse_alife_item_weapon_magazined',
	WP_BM16		=> 'cse_alife_item_weapon_shotgun',
	WP_GROZA	=> 'cse_alife_item_weapon_magazined_w_gl',
	WP_HPSA		=> 'cse_alife_item_weapon_magazined',
	WP_KNIFE	=> 'cse_alife_item_weapon',
	WP_LR300	=> 'cse_alife_item_weapon_magazined',
	WP_PM		=> 'cse_alife_item_weapon_magazined',
	WP_RG6		=> 'cse_alife_item_weapon_shotgun',
	WP_RPG7		=> 'cse_alife_item_weapon_magazined',
	WP_SCOPE	=> 'cse_alife_item',
	WP_SHOTG	=> 'cse_alife_item_weapon_shotgun',				# deprecated in call of pripyat
	WP_SVD		=> 'cse_alife_item_weapon_magazined',
	WP_SVU		=> 'cse_alife_item_weapon_magazined',
	WP_USP45	=> 'cse_alife_item_weapon_magazined',			# deprecated in call of pripyat
	WP_VAL		=> 'cse_alife_item_weapon_magazined',
	WP_VINT		=> 'cse_alife_item_weapon_magazined',			# deprecated in clear sky
	WP_WALTH	=> 'cse_alife_item_weapon_magazined',			# deprecated in clear sky
	ZS_BFUZZ	=> 'se_zone_visual',
	ZS_GALAN	=> 'se_zone_anom',
	ZS_MBALD	=> 'se_zone_anom',
	ZS_MINCE	=> 'se_zone_anom',
	Z_ZONE		=> 'cse_alife_anomalous_zone',					# deprecated in call of pripyat

	# build 2588
	O_INVBOX	=> 'cse_alife_inventory_box',					# deprecated in call of pripyat
	
	# build 2939
	C_HLCP_S	=> 'cse_alife_helicopter',
	O_PHYS_S	=> 'cse_alife_object_physic',
	SPC_RS_S	=> 'cse_alife_space_restrictor',
	AI_TRD_S	=> 'cse_alife_trader',	
	AI_TRADE_S	=> 'cse_alife_trader',	

	# build 3120
	SFACTION	=> 'se_sim_faction',							# deprecated in call of pripyat
	Z_CFIRE		=> 'cse_alife_anomalous_zone',	
	
	# clear sky
	D_ADVANC	=> 'cse_alife_item_detector',					# deprecated in call of pripyat
	D_ELITE		=> 'cse_alife_item_detector',					# deprecated in call of pripyat
	D_FLARE		=> 'unknown',
	SMRT_C_S	=> 'se_smart_cover',
	SM_DOG_S	=> 'se_monster',
	S_ACTOR		=> 'se_actor',	
	
	# call of pripyat
	AMMO_S		=> 'cse_alife_item_ammo',
	DET_ADVA	=> 'cse_alife_item_detector',
	DET_ELIT	=> 'cse_alife_item_detector',
	DET_SCIE	=> 'cse_alife_item_detector',
	DET_SIMP	=> 'cse_alife_item_detector',
	E_HLMET		=> 'cse_alife_item_helmet',
	G_F1_S		=> 'cse_alife_item_grenade',
	G_RGD5_S	=> 'cse_alife_item_grenade',
	O_DSTR_S	=> 'cse_alife_object_physic',
	ON_OFF_S	=> 'sim_squad_scripted',
	SO_HLAMP	=> 'cse_alife_object_hanging_lamp',
	S_ANTIR		=> 'cse_alife_item',
	S_BANDG		=> 'cse_alife_item',
	S_BOTTL		=> 'cse_alife_item',
	S_EXPLO		=> 'cse_alife_item_explosive',
	S_FOOD		=> 'cse_alife_eatable_item',					# hack fo LA DC
	S_INVBOX	=> 'cse_alife_inventory_box',
	S_MEDKI		=> 'cse_alife_item',
	S_M209		=> 'cse_alife_item_ammo',
	S_OG7B		=> 'cse_alife_item_ammo',	
	S_PDA		=> 'cse_alife_item_pda',
	S_VOG25		=> 'cse_alife_item_ammo',
	WP_ASHTG	=> 'cse_alife_item_weapon_shotgun',
	WP_GLAUN	=> 'cse_alife_item',
	WP_SILEN	=> 'cse_alife_item',
	ZS_RADIO	=> 'se_zone_anom',
	ZS_TORRD	=> 'se_zone_torrid',

};
sub launch {
	print "scanning configs...";
	my $stalker_path = $_[1];
	my $s_to_cl = IO::File->new('sections.ini', 'w') or fail("$!: sections.ini\n");
	print $s_to_cl "[sections]\n";
	my $clsids_ini = stkutils::ini_file->new('clsids.ini', 'r');
	my %engine_hash = ();
	my $obj = {};
	$obj->{sections_hash} = ();
	$obj->{sections_list} = [];
	my %table_hash = ();
	if (defined $stalker_path) {
		# scanning configs
		scan_system($stalker_path, $obj, $_[2]);
		foreach my $section (@{$obj->{sections_list}}) {
			delete ($obj->{sections_hash}{$section}) and next if $section =~ /^mp_/;
#			print "$section\n";
			my $sect = $section;
			my $parent_id = 0;
			while (1) {
				if (defined $obj->{sections_hash}{$section}{class}) {
					# if exists class or we alredy get some parent class
					$obj->{sections_hash}{$sect}{class} = $obj->{sections_hash}{$section}{class} if !exists($obj->{sections_hash}{$sect}{class});
#					print "	$obj->{sections_hash}{$sect}{class}\n";
					last;
				} elsif ($#{$obj->{sections_hash}{$section}{parent}} != -1)  {
#					print "	$obj->{sections_hash}{$section}{parent}[$parent_id]\n";
					# if no class, but parent exists, get class from parent
					if (defined $obj->{sections_hash}{$obj->{sections_hash}{$section}{parent}[$parent_id]}) {
						$section = $obj->{sections_hash}{$section}{parent}[$parent_id];
						next;
					} else {delete($obj->{sections_hash}{$sect}) and last;}
					# if no class, but parent exists in section_to_clsid hash, get class from parent through hash
					my @clsids = get_clsid($obj->{sections_hash}{$section}{parent});
					if ($#clsids != -1) {
						fail ("section $section has two or more parent sections with defined class\n") if $#clsids != 0;
						$obj->{sections_hash}{$sect}{class} = $clsids[0];
						last;
					}
				} else {
					# delete section if no class and no parent
					delete($obj->{sections_hash}{$sect}) and last;
				}
			}		
		}
		# output
		my %result;
#			my %r1;
#			my $fhd = IO::File->new('debug.ini', 'w');
#			foreach my $section (%{$obj->{sections_hash}}) {
#				next if !defined $obj->{sections_hash}{$section}{class};
#				$r1{$obj->{sections_hash}{$section}{class}} = $section;
#			}
#			foreach my $class (sort {$a cmp $b} keys %r1) {
#				print $fhd "$class = $r1{$class}\n";
#			}
#			$fhd->close();
		foreach my $section (%{$obj->{sections_hash}}) {
			next if !defined $obj->{sections_hash}{$section}{class};
			my $cse_class;
			$cse_class = $clsids_ini->value('clsids', $obj->{sections_hash}{$section}{class}) if defined $clsids_ini;
			$cse_class = clsid_to_class->{$obj->{sections_hash}{$section}{class}} if !defined $cse_class;
			$result{$section} = $cse_class;
			$result{$section} = $obj->{sections_hash}{$section}{class} unless defined $cse_class;
		}
		foreach my $section (sort {$result{$a} cmp $result{$b}} keys %result) {
			my $lcSection = lc($section);
			print $s_to_cl "'$lcSection' = $result{$section}\n";
		}
	} else {
		die usage();
	}
	$s_to_cl->close();
	$clsids_ini->close() if defined $clsids_ini;
	print "done!\n";
}
sub get_clsid {
	my @temp;
	foreach (@{$_[0]}) {
		my $clsid = section_to_clsid->{$_};
		if ($clsid) {push @temp, $clsid}
	}
	return @temp;
}
sub get_class {
	my $clsid = section_to_clsid->{$_[1]};
	fail('cannot find clsid for class '.$_[1]) unless defined $clsid;
	my $class = clsid_to_class->{$clsid};
	fail('cannot find class for clsid '.$clsid) unless defined $class;
	return $class;
}
sub scan_system {
	my ($stalker_path, $obj, $idx) = @_;
	my $files = get_all_includes($stalker_path, 'system.ltx');
	my $flag;
	foreach my $l (@$files) {
		$l = $stalker_path.'\\'.$l;
	}
	push @$files, $stalker_path.'\\'.'system.ltx';
TRY:
	$flag = 0;
	foreach my $file (@$files) {
		$file =~ s/\/\//\// if defined $idx;
		next if defined $idx && ($idx =~ /$file/);
		next if $file =~ /environment_1/;
		my $system = read_ini($file);
		if (!defined $system) {
			$flag++;
			last;
		}
		push @{$obj->{sections_list}}, @{$system->{sections_list}};
		foreach my $section (keys %{$system->{sections_hash}}) {
			$obj->{sections_hash}{$section}{class} = $system->{sections_hash}{$section}{class} if defined $system->{sections_hash}{$section}{class};
			push @{$obj->{sections_hash}{$section}{parent}}, @{$system->{sections_hash}{$section}{parent}} if defined $system->{sections_hash}{$section}{parent};
		}
	}
	return if $flag == 0;
	print "\nproblems occured while scanning configs. Try again...\n";
	$files = get_filelist($stalker_path, 'ltx');
	goto TRY;
}
sub read_ini {
	my $fh = IO::File->new($_[0], 'r') or return undef;
	my $self = {};
	$self->{fh} = $fh;
	$self->{sections_list} = [];
	$self->{sections_hash} = ();

	my $section;
	while (<$fh>) {
		$_ =~ qr/^\s*;/ and next;
		if (/^\s*\[(.*)\]\s*:\s*(\w.*)?/) {
			$section = $1;
			fail('duplicate section found while reading '.$_[0]) if defined $self->{sections_hash}->{$section};
			push @{$self->{sections_list}}, $section;
			my %tmp = ();
			$self->{sections_hash}{$section} = \%tmp;
			@{$self->{sections_hash}{$section}{parent}}= ();
			my $parent = $2;
			if ((defined $parent) && ($parent =~ /^([A-Za-z_0-9\.\-@]+)/)) {
				push @{$self->{sections_hash}{$section}{parent}}, $1;
			}
			next;
		} elsif (/^\[(.*)\]\s*:*\s*(\w.*)?/) {
			$section = $1;
			fail('duplicate section '.$section.' found while reading '.$_[0]) if (defined $self->{sections_hash}->{$section} && ($section ne 'postprocess_base'));
			push @{$self->{sections_list}}, $section;
			my %tmp = ();
			$self->{sections_hash}{$section} = \%tmp;
			next;			
		}
		if (/^\s*(class)\s*=\s*(\w+)\s*;*/) {
			my ($name, $value) = ($1, $2);
			next unless defined $section;
			if ($value =~ /^\W+(\w+)\W+/) {
				$value = $1;
			}
			if ($name =~ /^\W+(\w+)\W+/) {
				$self->{sections_hash}{$section}{$1} = $value;
			} else {
				$self->{sections_hash}{$section}{$name} = $value;
			}
		}
	}
	$fh->close();
	return $self;
}
1;
#######################################################################