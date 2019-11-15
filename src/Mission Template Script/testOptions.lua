GROUPS_BLUE = {{1, 1}, {2, 2}, {3, 4}}
BLUE_OPERATIONS = {} -- ---------- LEAVE EMPTY ---------- 
GROUPS_RED = {{1, 1}, {2, 2}, {3, 4}}
RED_OPERATIONS = {} -- ---------- LEAVE EMPTY ---------- 
randomGroups = false

msgTimer = 60          -- We specify the time that the target's asignment message will remain visible. The current target's message can be always recall via the F10 menu by selecting Target Report option. 
blueWinMsg = 'BLUE WON'        -- Here we can Specify the Blue and Red Win messages.
redWinMsg = 'RED WON'

-- ------------------POINT COSTS FOR OBJECTS------------------
aircraftCost = 1
heliCost = 0.5
shipCost = 5
unitCost = 0.3
printScoreEvery = 300 -- How much time between its cycle to show message (in seconds)
printScoreFor = 30 -- How much time will the message show up (in seconds)
  
BLUE_OPERATIONS[1] = {
  Name = {'BT_1'},
  isMapObj = {false},
  showMark = {false},
  Briefing = "BLUE TARGET 1",
  Extras = {},
  Points = 2
}
BLUE_OPERATIONS[2] = {
  Name = {'BT_2A', 'BT_2B'},
  isMapObj = {true, false},
  showMark = {false},
  Briefing = "BLUE TARGET 2",
  Extras = {'BT_2_AD', 'BT_2_DEC'},
  Points = 2
}
BLUE_OPERATIONS[3] = {
  Name = {'BT_3'},
  isMapObj = {false},
  showMark = {true},
  Briefing = "BLUE TARGET 3",
  Extras = {},
  Points = 2
}
BLUE_OPERATIONS[4] = {
  Name = {'BT_4'},
  isMapObj = {false},
  showMark = {false},
  Briefing = "BLUE TARGET 4",
  Extras = {},
  Points = 2
}
  
  -- ************************** RED TARGET LIST **************************
  
RED_OPERATIONS[1] = {
  Name = {'RT_1A', 'RT_1B'},
  isMapObj = {false, "polygon"},
  showMark = {false, true},
  Briefing = "RED TARGET 1",
  Extras = {},
  Points = 2
}
RED_OPERATIONS[2] = {
  Name = {'RT_2'},
  isMapObj = {false},
  showMark = {true},
  Briefing = "RED TARGET 2",
  Extras = {},
  Points = 2
}
RED_OPERATIONS[3] = {
  Name = {'RT_3'},
  isMapObj = {false},
  showMark = {false},
  Briefing = "RED TARGET 3",
  Extras = {},
  Points = 2
}
RED_OPERATIONS[4] = {
  Name = {'RT_4'},
  isMapObj = {false},
  showMark = {false},
  Briefing = "RED TARGET 4",
  Extras = {},
  Points = 2
}