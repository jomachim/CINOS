/**	This abstract enum is used by the Controller class to bind general game actions to actual keyboard keys or gamepad buttons. **/
enum abstract GameAction(Int) to Int {
	var MoveLeft;
	var MoveRight;
	var MoveUp;
	var MoveDown;

	var Jump;
	var Dash;
	var Fire;
	var Lazer;
	var Lock;
	var Action;
	var InventoryScreen;
	var OptionScreen;
	var Extra;
	var Restart;

	var MenuUp;
	var MenuDown;
	var MenuOk;
	var MenuCancel;
	var Pause;

	var ToggleDebugDrone;
	var DebugDroneZoomIn;
	var DebugDroneZoomOut;
	var DebugTurbo;
	var DebugSlowMo;
	var ScreenshotMode;
}

/** Entity state machine. Each entity can only have 1 active State at a time. **/
enum abstract State(Int) {
	var Normal;
	var Dead;
	var Cinema;
}


/** Entity Affects have a limited duration in time and you can stack different affects. **/
enum abstract Affect(Int) {
	var Stun;
	var Poison;
	var Speed;
}

enum LevelBreaks{
	Visited;
	Breaks;
	Breaking;
	Broken;
	Die;
	Door;
	None;
}

enum abstract LevelMark(Int) to Int {
	var M_Coll_Wall; // 0
	var M_Coll_Slope_LU;
	var M_Coll_Slope_RU;
	var M_Coll_Slope_LD;
	var M_Coll_Slope_RD;
	var M_Coll_Slope_LU2;
	var M_Coll_Slope_RU2;
	var M_Coll_Slope_LD2;
	var M_Coll_Slope_RD2;
	var M_Coll_Slope_LU3;
	var M_Coll_Slope_RU3;
	var M_Coll_Ladder;
	var M_Coll_Ledge;
	var M_CHKPT;
	var M_JUMPER;
	var M_ICE;
	var M_SWIRL;
	var M_SPIKES;

}
enum LevelWaterMark {
	WaterLevel;
}
enum abstract LevelSubMark(Int) to Int {
	var SM_None; // 0
}

enum abstract SlowMoId(Int) to Int {
	var S_Default; // 0
	var S_Death;
}

enum abstract ChargedAction(Int) to Int {
	var Lazer;
}