# AnimTreeIssues

Repo of project that can showcase 3 animation tree issues

1. transition not firing when there's an on end transition waiting to fire: select animation tree of player character and go to state machine gui. Delete the advance expression of run_turn -> run transtition and suddenly run_turn doesn't move to idle if animation hasn't finished. Delete the advance expressions of the "at end" transitions inside the state machine of the run state machine node and the turning animations can't transition to each other anymore. It's not that straightforward though, because

2. on end transition lag: change anim_tree_advance_steps from 5 to 1 which makes the advance method of animation tree get called only once, like the default settings. Then the final frame of the direction change transition lasts for 8 ticks instead of the normal 6.

3. Seemingly minor: Every time you switch state_machine_type and sometimes when the project opens you get several errors on the output: `This function in this node (/root/@EditorNode@17147/@Panel@13/@VBoxContainer@14/@HSplitContainer@17/@HSplitContainer@25/@HSplitContainer@33/@VBoxContainer@34/@VSplitContainer@36/@PanelContainer@6819/@VBoxContainer@6820/@AnimationTreeEditor@12462) can only be accessed from either the main thread or a thread group. Use call_deferred() instead.`