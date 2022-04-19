/*
Flower Power (Prilblume)

by IOIO72 aka Tamio Patrick Honma (https://honma.de)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

The "Pril-Blume" is a geometric representation of a flower and an iconic part of a campaign in the 1970s for Henkel's dishwashing liquid Pril. These flowers were stickers that accompanied the labels of the bottles. The stickers were very popular and still known as a retro piece of pop art.
*/


/* [Flower] */

// Set number of petal layers in addtion to stigma and stamen. Set at least 1.
layer_count = 2;

// Set the original diameter of one petal of the first layer, which is the calculation basis for the other layers.
petal_diameter = 7;

// Set height of each layer
layer_height = 0.5;

// Set rotation twist for each layer
layer_twist = 22.5;

// Decide to fill the layers' center. Disable to save some filament.
layer_fill = true;

// Define the color change factor
color_change = 72; // [1:99]


/* [Label text] */

// Enter your desired text. Leave empty, if you don't want to use a label.
label = "";

// Enter the name of a font, which is installed on your computer. You might also add a font style. Example: "Arial" or "Arial:style=Italic". Use the font list function in the help menu, copy your desired font from there and paste it here without quotation marks.
font = "Brush Script MT";

// Set a font size. Try not to exceed the bottom petal layer as the text should be part of the model.
size = 14;

// Set the height of the label text on top of the stigma layer.
text_tip_height = 0.75;


/* [Select part to export] */

// Select a layer for separated print export. Set to 0 to display all layers. Note: This value should not exceed the number of layers you've set in "layer_count" (see above) if you use a label text.
select_layer = 0;

// Select text label only. This only makes sense, if you've set a label text (see above). Note: The selected layer from above will be ignored, if you select the label text.
select_label = false;


/* [Advanced] */

// Set offset for text cut outs for better part attachment. This affects only separated part exports by using the "Select part to export" feature.
label_cutout_offset = 0.1;

// Set number of fragments to render
$fn = 70; // [1:100]


/*
BlocksCAD functions
*/
function doHsvMatrix(h,s,v,p,q,t,a=1)=[h<1?v:h<2?q:h<3?p:h<4?p:h<5?t:v,h<1?t:h<2?v:h<3?v:h<4?q:h<5?p:p,h<1?p:h<2?p:h<3?t:h<4?v:h<5?v:q,a];
function hsv(h, s=1, v=1,a=1)=doHsvMatrix((h%1)*6,s<0?0:s>1?1:s,v<0?0:v>1?1:v,v*(1-s),v*(1-s*((h%1)*6-floor((h%1)*6))),v*(1-s*(1-((h%1)*6-floor((h%1)*6)))),a);


/*
Modules
*/

module fill(_layer, _diameter, _height) {
  linear_extrude(_height, center = true) {
    circle(d = (_diameter * _layer / 1.5));
  };
};

module stigma(_diameter, _height) {
  linear_extrude(_height, center = true) {
    circle(d = _diameter);
  };
};

module stamen(_diameter, _height) {
  linear_extrude(_height, center = true) {
    for (i = [1:4]) {
      rotate([0, 0, i * 360 / 4]) {
        translate([_diameter / 2, 0, 0]) {
          circle(d = _diameter);
        };
      };
    };
  };
};

module petal(_layer, _diameter, _height) {
  linear_extrude(_height, center = true) {
    for (i = [1:8]) {
      rotate([0, 0, i * 360 / 8]) {
        translate([_diameter * _layer / 2, 0, 0]) {
          circle(d = _diameter * _layer / 2);
        };
      };
    };
  };
};

module petal_layer(_layer, _count, _twist, _change, _diameter, _height, _fill = false) {
  translate([0, 0, (_count + 1 - _layer) * _height]) {
    rotate([0, 0, _layer * _twist]) {
      color(hsv(.01 * ((_layer + 2) * _change))) {
        petal(_layer + 1, _diameter, _height);
        if (_fill) {
          fill(_layer + 1, _diameter, _height);
        };
      };
    };
  };
};

module label_layer(_text, _font, _size, _tip_height, _layer_height, _layer_count, _offset = 0) {
  translate([0, 0, _layer_height - _layer_height / 2]) {
    linear_extrude((_layer_count + 2) * _layer_height + _tip_height) {
      offset(r = _offset)
      text(_text, _size, _font, halign="center", valign="center");
    };
  };
};


/*
Main
*/

if (label != "" && (select_layer <= 0 || select_label == true)) color(hsv(.01 * -1 * color_change)) label_layer(label, font, size, text_tip_height, layer_height, layer_count);

if (select_label == false && (select_layer <= 0 || select_layer == 1)) {
  difference() {
    translate([0, 0, (layer_count + 2) * layer_height]) {
      color(hsv(.01 * color_change)) {
        stigma(petal_diameter, layer_height);
      };
    };
    if (label != "") label_layer(label, font, size, text_tip_height, layer_height, layer_count, select_layer > 0 ? label_cutout_offset : 0);
  };
};

if (select_label == false && (select_layer <= 0 || select_layer == 2)) {
  difference() {
    translate([0, 0, (layer_count + 1) * layer_height]) {
      color(hsv(.01 * 2 * color_change)) {
        stamen(petal_diameter, layer_height);
      };
    };
    if (label != "") label_layer(label, font, size, text_tip_height, layer_height, layer_count, select_layer > 0 ? label_cutout_offset : 0);
  };
};

if (select_label == false && select_layer <= 0) {
  for (i = [1:layer_count]) {
    difference() {
      petal_layer(i, layer_count, layer_twist, color_change, petal_diameter, layer_height, layer_fill);
      if (label != "") label_layer(label, font, size, text_tip_height, layer_height, layer_count, select_layer > 0 ? label_cutout_offset : 0);
    };
  };
};

if (select_label == false && select_layer > 2) {
  difference() {
    petal_layer(select_layer - 2, layer_count, layer_twist, color_change, petal_diameter, layer_height, layer_fill);
    if (label != "") label_layer(label, font, size, text_tip_height, layer_height, layer_count, select_layer > 0 ? label_cutout_offset : 0);
  };
};
