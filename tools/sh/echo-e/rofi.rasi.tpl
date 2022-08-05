/**
 * Nordic rofi theme
 * Adapted by undiabler <undiabler@gmail.com>
 *
 * Nord Color palette imported from https://www.nordtheme.com/
 *
 */

* {

	bg: #582000; /* Input bar background (dark) */
	fg: $color__LightGoldenrod2; /* Foreground (medium) */
	input: $color__Grey89; /* Input (light) */
	selectionFg: black; /* Message and selected text (dark text for light bg) */
	selectionBg: $color__DarkOrange; /* Selection background (light) */
	selectionBorder: none;
	border: $color__Orange3; /* Borders (medium, colorful) */
	border: $color__DarkOrange3a; /* Borders (medium, colorful) */

	foreground: @fg;
	/* backlight: #ccffeedd; */
	background-color: transparent;
	
	highlight: underline bold $color__Gold1;

	transparent: rgba(46,52,64,0);
}

window {
	location: center;
	anchor:   center;
	transparency: \"screenshot\";
	padding: 10px;
	border:  0px;
	border-radius: 12px;

	background-color: @transparent;
	spacing: 0;
	children: [mainbox];
	orientation: horizontal;
}

mainbox {
	spacing: 0;
	children: [ inputbar, message, listview ];
}

message {
	color: @selectionFg;
	padding: 5;
	border-color: @foreground;
	border: 0px 2px 2px 2px;
	background-color: @selectionBg;
}

inputbar {
	color: @input;
	padding: 11px;
	background-color: @bg;

	border: 4px 0px 0px;
	border-radius: 12px 12px 0px 0px;
	border-color: @border;
}

entry, prompt, case-indicator {
	text-font: inherit;
	text-color:inherit;
}

prompt {
	margin: 0px 1em 0em 0em ;
}

listview {
	padding: 8px;
	border-radius: 0px 0px 9px 9px;
	border-color: @border;
	border: 0px 0px 4px 0px;
	background-color: rgba(46,52,64,0.9);
	dynamic: false;
}

element {
	padding: 3px;
	vertical-align: 0.5;
	border-radius: 4px;
	background-color: transparent;
	color: @foreground;
	text-color: rgb(216, 222, 233);
}

element selected.normal {
	background-color: @selectionBg;
	text-color: @selectionFg;
	border: @selectionBorder;
}

element-text, element-icon {
	background-color: inherit;
	text-color:	inherit;
}

button {
	padding: 6px;
	color: @foreground;
	horizontal-align: 0.5;

	border: 2px 0px 2px 2px;
	border-radius: 4px 0px 0px 4px;
	border-color: @foreground;
}

button selected normal {
	border: 2px 0px 2px 2px;
	border-color: @foreground;
}

/* ex:set ft=css: */
/* sh:tpl:1:1: */
