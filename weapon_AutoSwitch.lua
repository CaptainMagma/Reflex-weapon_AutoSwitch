require "base/internal/ui/reflexcore"

weapon_AutoSwitch = {canPosition = false; canHide = false;}

registerWidget("weapon_AutoSwitch");

local WEAPON_AXE = 1
local WEAPON_BURST = 2
local WEAPON_SHOTGUN = 3
local WEAPON_GRENADE = 4
local WEAPON_PLASMA = 5
local WEAPON_ROCKET = 6
local WEAPON_LG = 7
local WEAPON_RAIL = 8

local ownedWeapons = {}

local weaponPriority = {}
weaponPriority[1] = WEAPON_ROCKET
weaponPriority[2] = WEAPON_LG
weaponPriority[3] = WEAPON_SHOTGUN
weaponPriority[4] = WEAPON_PLASMA
weaponPriority[5] = WEAPON_RAIL
weaponPriority[6] = WEAPON_GRENADE
weaponPriority[7] = WEAPON_BURST
weaponPriority[8] = WEAPON_AXE
local bestWeapon

local function getBestWeaponIndex(priority, weapons)
	local best
	for i=1,#priority do
		if weapons[priority[i]] then
			best = i
			break;
		end 
	end
	return best
end

function weapon_AutoSwitch:initialize()
	self.userData = loadUserData()
	CheckSetDefaultValue(self,"userData","table",{})
	CheckSetDefaultValue(self.userData,"pickupSwitch","boolean",true)
	CheckSetDefaultValue(self.userData,"emptySwitch","boolean",true)
end

function weapon_AutoSwitch:draw()
	local pickupSwitch = self.userData.pickupSwitch
	local emptySwitch = self.userData.emptySwitch

	local player = getPlayer()
	local active = (playerIndexCameraAttachedTo == playerIndexLocalPlayer)
	if isRaceMode() or not shouldShowHUD() or not player or player.state ~= PLAYER_STATE_INGAME then return end;

	---------------------------
	--Switch on Pickup---------
	---------------------------

	if active and pickupSwitch then
		if next(ownedWeapons) == nil then
			for i=1,#weaponPriority do
				if weaponPriority[i] == WEAPON_BURST then bestWeapon = i; break; end
			end
		end
		for i=1,#weaponPriority do
			if not ownedWeapons[weaponPriority[i]] and player.weapons[weaponPriority[i]].pickedup and i < bestWeapon then
				consolePerformCommand("weapon "..weaponPriority[i])
			end
		end
	end

	ownedWeapons = {}
	for w, weapon in pairs(player.weapons) do
		if w == WEAPON_AXE or (weapon.ammo > 0 and weapon.pickedup) then
			ownedWeapons[w] = weapon
		end
	end

	bestWeapon = getBestWeaponIndex(weaponPriority, ownedWeapons)

	--------------------------
	--Switch on Empty---------
	--------------------------

	if active and emptySwitch then
		if player.weaponIndexSelected > WEAPON_AXE and player.weapons[player.weaponIndexSelected].ammo == 0 then
			local switch = nil
			for i=1,#weaponPriority do
				local w = weaponPriority[i]
				if w == WEAPON_AXE or (player.weapons[w].pickedup and player.weapons[w].ammo > 0) then
					switch = w
					break;
				end
			end
			if switch then consolePerformCommand("weapon "..switch) end;
		end
	end
end

function weapon_AutoSwitch:drawOptions(x, y, intensity)
	local optargs = {}
	optargs.intensity = intensity
	local user = self.userData
	user.pickupSwitch = ui2RowCheckbox(x,y,WIDGET_PROPERTIES_COL_INDENT,"Switch on Pickup",user.pickupSwitch,optargs);
	y = y + 60
	user.emptySwitch = ui2RowCheckbox(x,y,WIDGET_PROPERTIES_COL_INDENT,"Switch on Empty",user.emptySwitch,optargs);
	saveUserData(user)
end