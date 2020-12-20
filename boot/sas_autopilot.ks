
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// KSP kOS SAS AutoPilot v0.1.1
// Copyright (C) 2016 Xyphos Aerospace
// Distributed under the MIT Licence
//
// Description: Causes your vessel to hold your current heading and pitch while in atmospheric flight
//				when the stock SAS system is inactive. When your vessel leaves the atmosphere,
//				or when stock SAS is enabled, the autopilot automatically deactivates.
//
// Instructions: 
//		1) Copy this script to your [KSP\Ships\Script] Folder
//
//		2) Build a ship with a kOS processor on-board. At lease one processor is required,
//		   multiple if needing additional systems.
//
//		3) Right-Click the processor and select this script as the boot file
//			NOTE: If you do not see a boot selector, you'll have to restart KSP
//				  after completing step 1, kOS does not do real-time file tracking.
//
//		4) Fly your vessel and point it in the direction you want to go then disable stock SAS.
//		   the autopilot should activate. To deactivate, simply re-enable the stock SAS system.
//
// Version History:
// 		v0.1.1 - BugFix: Heading bug fixed using northPole method instead of vector angle;
//						  previous vector angle method also calculated pitch into the heading.
//
//				 BugFix: Pitch bug fixed. Wrong method used to determine pitch.
//
//				 Feature Added: SAS Action Group is now toggled upon leaving the atmosphere.
//
//		v0.0.1 - Inital Release and Beta Testing
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@LazyGlobal Off.

Global duriation Is 10.
Global location Is 2. 		// Top Center
Global fontSize Is 42.
Global active Is False.

On SAS {
	If SAS = True {
		If active = True {
			Unlock Steering.
			Set active To False.
			HudText("kOS SAS AutoPilot Deactivated.", duriation, location, fontSize, RED, true).
		}
	} Else {
		If active = False AND Ship:Body:Atm:Exists AND Ship:Altitude < Ship:Body:Atm:Height {
			Local northPole Is LatLng(90, 0).
			Local myHeading Is Round(Mod(360 - northPole:Bearing, 360)). 
			Local myPitch Is Round(Mod(90 - VectorAngle(Up:ForeVector, Ship:Facing:ForeVector), 360)).
			Lock Steering To Heading(myHeading, myPitch).
			Set active To True.
		
			When Ship:Altitude > Ship:Body:Atm:Height Then {
				SAS On.
				Toggle SAS.
			}
			
			HudText("kOS SAS AutoPilot Engaged.", duriation, location, fontSize, GREEN, true).
			HudText("Holding " + myPitch + " degrees, Heading " + myHeading, duriation, location, fontSize, GREEN, true).			
		}
	}

	Preserve.
}

Wait Until False.
